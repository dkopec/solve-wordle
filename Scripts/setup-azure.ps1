#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup script for Azure deployment with GitHub Actions and Terraform

.DESCRIPTION
    This script automates the setup process for deploying to Azure:
    1. Creates Azure Service Principal for GitHub Actions
    2. Configures GitHub repository secrets
    3. Optionally creates Terraform remote state storage

.PARAMETER GitHubRepo
    GitHub repository in format 'owner/repo' (e.g., 'dkop/solve-wordle')
    If not provided, will attempt to auto-detect from git remote

.PARAMETER GitHubToken
    GitHub Personal Access Token with repo scope
    Required for setting GitHub secrets automatically
    Get one at: https://github.com/settings/tokens

.PARAMETER SkipGitHubSecrets
    Skip setting GitHub secrets (you'll need to set them manually)

.PARAMETER CreateStateStorage
    Create Azure Storage Account for Terraform remote state

.EXAMPLE
    .\setup-azure.ps1 -GitHubRepo "dkop/solve-wordle" -GitHubToken "ghp_xxxxx"

.EXAMPLE
    .\setup-azure.ps1 -SkipGitHubSecrets
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$GitHubRepo,
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipGitHubSecrets,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateStateStorage
)

# Color output helpers
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }

# Check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    $missing = @()
    
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        $missing += "Azure CLI (az)"
    }
    
    if (-not $SkipGitHubSecrets -and -not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Warning "GitHub CLI (gh) not found. Will need to set secrets manually."
        $script:SkipGitHubSecrets = $true
    }
    
    if ($missing.Count -gt 0) {
        Write-Error "Missing required tools: $($missing -join ', ')"
        Write-Info "Install Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli"
        Write-Info "Install GitHub CLI: https://cli.github.com/"
        exit 1
    }
    
    Write-Success "All prerequisites met"
}

# Auto-detect GitHub repository from git remote
function Get-GitHubRepository {
    if ($GitHubRepo) {
        return $GitHubRepo
    }
    
    Write-Info "Auto-detecting GitHub repository..."
    
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        # Parse git@github.com:owner/repo.git or https://github.com/owner/repo.git
        if ($remote -match 'github\.com[:/]([^/]+/[^/\.]+)') {
            $repo = $matches[1]
            Write-Success "Detected repository: $repo"
            return $repo
        }
    }
    
    Write-Error "Could not auto-detect GitHub repository"
    $repo = Read-Host "Enter GitHub repository (owner/repo)"
    return $repo
}

# Login to Azure
function Connect-Azure {
    Write-Info "Checking Azure login status..."
    
    $account = az account show 2>$null | ConvertFrom-Json
    if (-not $account) {
        Write-Info "Not logged in to Azure. Opening browser..."
        az login
        $account = az account show | ConvertFrom-Json
    }
    
    Write-Success "Logged in to Azure as: $($account.user.name)"
    Write-Info "Subscription: $($account.name) ($($account.id))"
    
    $confirm = Read-Host "Use this subscription? (y/n)"
    if ($confirm -ne 'y') {
        Write-Info "Available subscriptions:"
        az account list --output table
        $subId = Read-Host "Enter subscription ID"
        az account set --subscription $subId
        $account = az account show | ConvertFrom-Json
        Write-Success "Switched to: $($account.name)"
    }
    
    return $account
}

# Create Service Principal for GitHub Actions
function New-ServicePrincipal {
    param($SubscriptionId, $RepoName)
    
    $spName = "github-actions-$($RepoName -replace '/', '-')"
    
    Write-Info "Creating service principal: $spName"
    
    # Check if SP already exists
    $existingSp = az ad sp list --display-name $spName 2>$null | ConvertFrom-Json
    if ($existingSp) {
        Write-Warning "Service principal '$spName' already exists"
        $recreate = Read-Host "Recreate it? This will invalidate existing credentials (y/n)"
        if ($recreate -eq 'y') {
            Write-Info "Deleting existing service principal..."
            az ad sp delete --id $existingSp[0].appId
        } else {
            Write-Error "Cannot continue with existing service principal. Please delete it manually or choose a different name."
            exit 1
        }
    }
    
    # Create service principal with contributor role
    Write-Info "Creating new service principal with Contributor role..."
    $sp = az ad sp create-for-rbac `
        --name $spName `
        --role contributor `
        --scopes "/subscriptions/$SubscriptionId" `
        --sdk-auth | ConvertFrom-Json
    
    Write-Success "Service principal created successfully"
    
    return $sp
}

# Create Terraform remote state storage
function New-TerraformStateStorage {
    param($RepoName)
    
    Write-Info "Creating Terraform remote state storage..."
    
    $rgName = "terraform-state-rg"
    $location = "eastus"
    $storageAccountName = "tfstate$($RepoName -replace '[^a-z0-9]', '')" # Must be alphanumeric
    $storageAccountName = $storageAccountName.Substring(0, [Math]::Min(24, $storageAccountName.Length)) # Max 24 chars
    $containerName = "tfstate"
    
    # Create resource group
    Write-Info "Creating resource group: $rgName"
    az group create --name $rgName --location $location --output none
    
    # Create storage account
    Write-Info "Creating storage account: $storageAccountName"
    az storage account create `
        --name $storageAccountName `
        --resource-group $rgName `
        --location $location `
        --sku Standard_LRS `
        --encryption-services blob `
        --output none
    
    # Get storage account key
    $key = az storage account keys list `
        --resource-group $rgName `
        --account-name $storageAccountName `
        --query '[0].value' -o tsv
    
    # Create container
    Write-Info "Creating blob container: $containerName"
    az storage container create `
        --name $containerName `
        --account-name $storageAccountName `
        --account-key $key `
        --output none
    
    Write-Success "Terraform state storage created"
    Write-Info "Storage Account: $storageAccountName"
    Write-Info "Container: $containerName"
    
    # Update terraform backend configuration
    $backendConfig = @"

  backend "azurerm" {
    resource_group_name  = "$rgName"
    storage_account_name = "$storageAccountName"
    container_name       = "$containerName"
    key                  = "terraform.tfstate"
  }
"@
    
    Write-Info ""
    Write-Warning "To enable remote state, uncomment the backend block in terraform/main.tf and add:"
    Write-Host $backendConfig -ForegroundColor Yellow
}

# Set GitHub secrets
function Set-GitHubSecrets {
    param($Repo, $Credentials, $Token)
    
    Write-Info "Setting GitHub secrets..."
    
    if ($Token) {
        # Use gh CLI with token
        $env:GH_TOKEN = $Token
        $credJson = $Credentials | ConvertTo-Json -Compress
        
        Write-Info "Setting AZURE_CREDENTIALS secret..."
        $credJson | gh secret set AZURE_CREDENTIALS --repo $Repo
        
        Write-Success "GitHub secrets configured via API"
    } else {
        # Use gh CLI (requires login)
        Write-Info "Using GitHub CLI (must be logged in)..."
        
        $credJson = $Credentials | ConvertTo-Json -Compress
        $credJson | gh secret set AZURE_CREDENTIALS --repo $Repo
        
        Write-Success "GitHub secrets configured"
    }
}

# Manual instructions for setting secrets
function Show-ManualInstructions {
    param($Credentials)
    
    Write-Info ""
    Write-Info "═══════════════════════════════════════════════════════════"
    Write-Warning "Manual GitHub Secret Setup Required"
    Write-Info "═══════════════════════════════════════════════════════════"
    Write-Info ""
    Write-Info "1. Go to your GitHub repository Settings"
    Write-Info "2. Navigate to: Secrets and variables → Actions"
    Write-Info "3. Click 'New repository secret'"
    Write-Info "4. Add the following secret:"
    Write-Info ""
    Write-Host "   Name: " -NoNewline; Write-Host "AZURE_CREDENTIALS" -ForegroundColor Yellow
    Write-Info "   Value: (copy the JSON below)"
    Write-Info ""
    Write-Host ($Credentials | ConvertTo-Json) -ForegroundColor Cyan
    Write-Info ""
    Write-Info "═══════════════════════════════════════════════════════════"
}

# Main execution
function Main {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   Azure + GitHub Actions + Terraform Setup Script     ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Check prerequisites
    Test-Prerequisites
    
    # Get GitHub repository
    $repo = Get-GitHubRepository
    $repoName = $repo -replace '.*/', ''
    
    # Login to Azure
    $account = Connect-Azure
    
    # Create service principal
    $sp = New-ServicePrincipal -SubscriptionId $account.id -RepoName $repoName
    
    # Create state storage if requested
    if ($CreateStateStorage) {
        New-TerraformStateStorage -RepoName $repoName
    }
    
    # Set GitHub secrets
    if (-not $SkipGitHubSecrets) {
        try {
            Set-GitHubSecrets -Repo $repo -Credentials $sp -Token $GitHubToken
        } catch {
            Write-Warning "Failed to set GitHub secrets automatically: $_"
            Show-ManualInstructions -Credentials $sp
        }
    } else {
        Show-ManualInstructions -Credentials $sp
    }
    
    # Summary
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    Setup Complete!                     ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Success "Azure Service Principal created"
    Write-Success "GitHub repository: $repo"
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "  1. Verify GitHub secret AZURE_CREDENTIALS is set"
    Write-Info "  2. (Optional) Customize terraform/terraform.tfvars"
    Write-Info "  3. Push to main branch or manually trigger workflow"
    Write-Info "  4. Monitor deployment in GitHub Actions tab"
    Write-Host ""
    Write-Info "Your app will be deployed to Azure Container Apps (serverless with .NET 9 support)"
    Write-Info "URL format: https://ca-$repoName.[region].azurecontainerapps.io"
    Write-Host ""
}

# Run main function
Main
