<#
.SYNOPSIS
    Automated Word List Updater for Wordle Solver

.DESCRIPTION
    This script fetches the latest Wordle data and updates word list files.
    It retrieves:
    1. Past Wordle answers from NYTimes Wordle game data
    2. Common English words from frequency lists
    3. Comprehensive 5-letter word lists

.PARAMETER DryRun
    Show what would be done without making changes

.PARAMETER Verbose
    Enable verbose logging

.EXAMPLE
    .\update-word-lists.ps1
    Run update with default settings

.EXAMPLE
    .\update-word-lists.ps1 -DryRun -Verbose
    Test run with detailed logging
#>

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Configuration
$DataDir = Join-Path $PSScriptRoot "..\Data"
$WwwrootDataDir = Join-Path $PSScriptRoot "..\wwwroot\data"
$BackupDir = Join-Path $DataDir "backups"

# Data sources
$WordleAnswersUrl = "https://www.nytimes.com/games-assets/v2/wordle.json"
$ScrabbleWordsUrl = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        "DEBUG" { "Gray" }
        default { "White" }
    }
    
    if ($Level -eq "DEBUG" -and -not $Verbose) {
        return
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Invoke-WebRequestWithRetry {
    param(
        [string]$Uri,
        [int]$MaxRetries = 3,
        [int]$TimeoutSec = 10
    )
    
    $headers = @{
        'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Write-Log "Fetching $Uri (attempt $i)" -Level DEBUG
            $response = Invoke-WebRequest -Uri $Uri -Headers $headers -TimeoutSec $TimeoutSec
            return $response
        }
        catch {
            Write-Log "Attempt $i failed: $_" -Level WARNING
            if ($i -lt $MaxRetries) {
                $waitTime = [math]::Pow(2, $i - 1)
                Start-Sleep -Seconds $waitTime
            }
            else {
                throw
            }
        }
    }
}

function Get-PastWordleAnswers {
    Write-Log "Fetching past Wordle answers from NYTimes..."
    $pastAnswers = @()
    
    try {
        # Try official Wordle JSON endpoint
        $response = Invoke-WebRequestWithRetry -Uri $WordleAnswersUrl
        $data = $response.Content | ConvertFrom-Json
        
        if ($data.solutions) {
            $pastAnswers = $data.solutions | Where-Object { $_.Length -eq 5 } | ForEach-Object { $_.ToLower() }
            Write-Log "Found $($pastAnswers.Count) answers from JSON endpoint"
        }
    }
    catch {
        Write-Log "Could not fetch from JSON endpoint: $_" -Level WARNING
    }
    
    # Fallback: Use existing file
    if ($pastAnswers.Count -eq 0) {
        Write-Log "Using existing past-answers.txt as base" -Level WARNING
        $existingFile = Join-Path $DataDir "past-answers.txt"
        
        if (Test-Path $existingFile) {
            $pastAnswers = Get-Content $existingFile -Encoding UTF8
            Write-Log "Loaded $($pastAnswers.Count) existing answers"
            
            # Add any known recent answers manually
            # (In production, maintain a list of recent answers to add)
            $knownRecent = @(
                # Add new answers here as they appear
            )
            $pastAnswers = @($pastAnswers) + $knownRecent | Select-Object -Unique
        }
    }
    
    return $pastAnswers | Sort-Object
}

function Get-ComprehensiveWordList {
    Write-Log "Fetching comprehensive word list..."
    $allWords = @()
    
    # Use existing file as base
    $existingFile = Join-Path $DataDir "words.txt"
    if (Test-Path $existingFile) {
        $allWords = Get-Content $existingFile -Encoding UTF8
        Write-Log "Loaded $($allWords.Count) existing words"
    }
    
    # Optionally fetch additional words from Scrabble dictionary
    try {
        $response = Invoke-WebRequestWithRetry -Uri $ScrabbleWordsUrl
        $scrabbleWords = $response.Content -split "`n" | 
            Where-Object { $_.Length -eq 5 -and $_ -match '^[a-zA-Z]+$' } |
            ForEach-Object { $_.ToLower().Trim() }
        
        $originalCount = $allWords.Count
        $allWords = @($allWords) + $scrabbleWords | Select-Object -Unique
        $newCount = $allWords.Count
        
        if ($newCount -gt $originalCount) {
            Write-Log "Added $($newCount - $originalCount) new words from Scrabble dictionary"
        }
    }
    catch {
        Write-Log "Could not fetch Scrabble dictionary: $_" -Level WARNING
    }
    
    return $allWords | Sort-Object
}

function Get-CommonWords {
    param(
        [string[]]$AllWords,
        [string[]]$PastAnswers
    )
    
    Write-Log "Determining common words..."
    $common = @()
    
    # Start with past answers (proven Wordle words)
    $common = @($PastAnswers)
    
    # Load existing common words
    $existingFile = Join-Path $DataDir "common-words.txt"
    if (Test-Path $existingFile) {
        $existingCommon = Get-Content $existingFile -Encoding UTF8
        $common = @($common) + $existingCommon | Select-Object -Unique
    }
    
    # Filter to only include words in comprehensive list
    $allWordsSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$AllWords, [StringComparer]::OrdinalIgnoreCase)
    $common = $common | Where-Object { $allWordsSet.Contains($_) }
    
    Write-Log "Determined $($common.Count) common words"
    return $common | Sort-Object
}

function Backup-Files {
    if ($DryRun) {
        Write-Log "DRY RUN: Would create backups"
        return
    }
    
    if (-not (Test-Path $BackupDir)) {
        New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    foreach ($filename in @("words.txt", "common-words.txt", "past-answers.txt")) {
        $source = Join-Path $DataDir $filename
        if (Test-Path $source) {
            $backup = Join-Path $BackupDir "$([System.IO.Path]::GetFileNameWithoutExtension($filename))_$timestamp.txt"
            Copy-Item $source $backup
            Write-Log "Backed up $filename to $backup" -Level DEBUG
        }
    }
}

function Write-WordFile {
    param(
        [string]$FilePath,
        [string[]]$Words,
        [string]$Description
    )
    
    $sortedWords = $Words | Sort-Object
    $content = $sortedWords -join "`n"
    
    # Check if content changed
    $existingContent = ""
    if (Test-Path $FilePath) {
        $existingContent = (Get-Content $FilePath -Raw -Encoding UTF8).Trim()
    }
    
    if ($content -ne $existingContent) {
        $script:ChangesMade = $true
        
        if ($DryRun) {
            Write-Log "DRY RUN: Would update $FilePath ($($sortedWords.Count) words)"
            $existingCount = if ($existingContent) { ($existingContent -split "`n").Count } else { 0 }
            Write-Log "  Current: $existingCount words" -Level DEBUG
            Write-Log "  New: $($sortedWords.Count) words" -Level DEBUG
            return
        }
        
        $content | Out-File -FilePath $FilePath -Encoding UTF8 -NoNewline
        Write-Log "✓ Updated $([System.IO.Path]::GetFileName($FilePath)): $($sortedWords.Count) $Description" -Level SUCCESS
    }
    else {
        Write-Log "✓ No changes for $([System.IO.Path]::GetFileName($FilePath))"
    }
}

function Sync-ToWwwroot {
    if ($DryRun) {
        Write-Log "DRY RUN: Would sync to wwwroot/data/"
        return
    }
    
    if (-not (Test-Path $WwwrootDataDir)) {
        New-Item -Path $WwwrootDataDir -ItemType Directory -Force | Out-Null
    }
    
    foreach ($filename in @("words.txt", "common-words.txt", "past-answers.txt")) {
        $source = Join-Path $DataDir $filename
        $dest = Join-Path $WwwrootDataDir $filename
        
        if (Test-Path $source) {
            Copy-Item $source $dest -Force
            Write-Log "Synced $filename to wwwroot/data/" -Level DEBUG
        }
    }
}

# Main execution
try {
    Write-Log "=== Starting Word List Update ==="
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $script:ChangesMade = $false
    
    # Backup existing files
    Backup-Files
    
    # Fetch data
    $pastAnswers = Get-PastWordleAnswers
    $allWords = Get-ComprehensiveWordList
    $commonWords = Get-CommonWords -AllWords $allWords -PastAnswers $pastAnswers
    
    # Ensure directories exist
    if (-not (Test-Path $DataDir)) {
        New-Item -Path $DataDir -ItemType Directory -Force | Out-Null
    }
    
    # Write updated files
    Write-WordFile `
        -FilePath (Join-Path $DataDir "past-answers.txt") `
        -Words $pastAnswers `
        -Description "past Wordle answers"
    
    Write-WordFile `
        -FilePath (Join-Path $DataDir "common-words.txt") `
        -Words $commonWords `
        -Description "common words"
    
    Write-WordFile `
        -FilePath (Join-Path $DataDir "words.txt") `
        -Words $allWords `
        -Description "total words"
    
    # Sync to wwwroot
    Sync-ToWwwroot
    
    $stopwatch.Stop()
    Write-Log "=== Update Complete ($($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s) ==="
    
    if ($script:ChangesMade) {
        Write-Log "✓ Changes detected and files updated" -Level SUCCESS
        exit 0
    }
    else {
        Write-Log "ℹ No changes needed - files are up to date"
        exit 0
    }
}
catch {
    Write-Log "Error during update: $_" -Level ERROR
    Write-Log $_.ScriptStackTrace -Level ERROR
    exit 1
}
