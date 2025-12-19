# Automatic Word List Updates

## Overview

The Wordle Solver includes an automated system to keep word lists up to date. The system runs weekly via GitHub Actions and can be triggered manually at any time.

## How It Works

### Architecture

```
GitHub Actions Workflow (Weekly Schedule)
    ↓
Python Update Script
    ├─ Fetches latest Wordle answers from NYTimes
    ├─ Updates comprehensive word lists
    ├─ Refreshes common word rankings
    └─ Syncs to wwwroot/data/ for deployment
    ↓
Git Commit & Push (if changes detected)
    ↓
Triggers Deployment Workflow
    ↓
Updated site deployed to GitHub Pages
```

### What Gets Updated

1. **past-answers.txt** (~2,800+ words)
   - Historical Wordle answers used by NYTimes
   - Highest priority for suggestions
   - Updated as new daily puzzles are published

2. **common-words.txt** (~3,000+ words)
   - Frequently used English words
   - Includes all past answers plus curated common words
   - Balanced for everyday vocabulary

3. **words.txt** (~13,000+ words)
   - Comprehensive 5-letter English word list
   - Valid Wordle guesses and potential answers
   - Includes less common but valid words

## Schedule

### Automatic Updates
- **Frequency**: Every Monday at 2:00 AM UTC
- **Action**: GitHub Actions workflow runs automatically
- **Duration**: ~30-60 seconds
- **Commits**: Only made if changes are detected

### Manual Trigger
You can trigger an update manually:

1. Go to [Actions tab](../../actions/workflows/update-word-lists.yml)
2. Click "Run workflow"
3. Optionally check "Force update" to commit even without changes
4. Click green "Run workflow" button

## Running Locally

### Python Script (Recommended - Cross-platform)

**Requirements:**
- Python 3.8+
- pip packages: `requests`, `beautifulsoup4`, `lxml`

**Installation:**
```bash
pip install requests beautifulsoup4 lxml
```

**Usage:**
```bash
# Standard run
python Scripts/update-word-lists.py

# Dry run (see what would change)
python Scripts/update-word-lists.py --dry-run

# Verbose output
python Scripts/update-word-lists.py --verbose

# Combine options
python Scripts/update-word-lists.py --dry-run --verbose
```

### PowerShell Script (Windows)

**Requirements:**
- PowerShell 5.1+ or PowerShell Core 7+
- No additional packages needed

**Usage:**
```powershell
# Standard run
.\Scripts\update-word-lists.ps1

# Dry run (see what would change)
.\Scripts\update-word-lists.ps1 -DryRun

# Verbose output
.\Scripts\update-word-lists.ps1 -Verbose

# Combine options
.\Scripts\update-word-lists.ps1 -DryRun -Verbose
```

## Features

### Intelligent Change Detection
- Only commits if word lists actually change
- Compares file contents before writing
- Avoids unnecessary deployments

### Automatic Backups
- Creates timestamped backups in `Data/backups/`
- Format: `words_20250101_143022.txt`
- Preserves old versions for rollback

### Retry Logic
- 3 automatic retries for network requests
- Exponential backoff between attempts
- Graceful fallback to existing data

### Data Sources
1. **NYTimes Wordle JSON** - Official game data
2. **Wordle JavaScript Bundle** - Embedded word lists
3. **Scrabble Dictionary** - Comprehensive word validation
4. **Existing Files** - Fallback when sources unavailable

## Workflow Details

### GitHub Actions Workflow

**File**: [.github/workflows/update-word-lists.yml](../.github/workflows/update-word-lists.yml)

**Permissions:**
- `contents: write` - Commit updated files
- `pull-requests: write` - Future PR-based updates (optional)

**Steps:**
1. Checkout repository
2. Setup Python 3.11
3. Install dependencies (`requests`, `beautifulsoup4`, `lxml`)
4. Run update script
5. Detect changes via `git diff`
6. Display changes in workflow logs
7. Commit and push if changes found
8. Create workflow summary

**Outputs:**
- Change detection status
- File statistics (word counts)
- Modified file list
- Detailed diff output

## Monitoring

### Check Workflow Status

1. Go to [Actions tab](../../actions)
2. Look for "Update Word Lists" workflow
3. Click on latest run to see details
4. Review logs and summary

### Success Indicators
- ✅ Green checkmark on workflow run
- Summary shows file counts
- Commit appears in history (if changes made)

### Troubleshooting

#### Workflow Fails
**Symptoms**: Red X on Actions tab

**Common Causes:**
- Network timeout fetching data
- Invalid JSON response from NYTimes
- Git permission issues

**Solutions:**
1. Check workflow logs for specific error
2. Re-run workflow manually
3. Update script to handle new data format
4. Check GitHub token permissions

#### No Changes Detected (But Expected)
**Symptoms**: Workflow runs but doesn't commit

**Possible Reasons:**
- NYTimes hasn't published new answers yet
- Word lists already up to date
- Script defaulting to existing files

**Solutions:**
1. Verify data source is accessible
2. Check logs for "Using existing file" warnings
3. Run with `force_update: true` to commit anyway

#### Files Not Syncing
**Symptoms**: Data/ updated but wwwroot/data/ unchanged

**Cause:** Sync step failed or skipped

**Solution:**
- Check logs for "Synced to wwwroot/data/" messages
- Manually copy files: `copy Data\*.txt wwwroot\data\`
- Re-run workflow

## Customization

### Change Schedule

Edit [.github/workflows/update-word-lists.yml](../.github/workflows/update-word-lists.yml):

```yaml
on:
  schedule:
    # Change this cron expression
    # Format: minute hour day-of-month month day-of-week
    # Current: Every Monday at 2 AM UTC
    - cron: '0 2 * * 1'
    
    # Examples:
    # Daily at midnight UTC: '0 0 * * *'
    # Every 6 hours: '0 */6 * * *'
    # First of month: '0 0 1 * *'
```

### Add Custom Data Sources

Edit [Scripts/update-word-lists.py](../Scripts/update-word-lists.py):

```python
def fetch_past_wordle_answers(self) -> Set[str]:
    # Add your custom source here
    custom_url = "https://your-data-source.com/words.json"
    response = self.fetch_url(custom_url)
    data = response.json()
    
    # Process and return words
    return set(data['words'])
```

### Modify Word Filtering

Control which words are included/excluded:

```python
def fetch_comprehensive_wordlist(self) -> Set[str]:
    all_words = set()
    
    # Add custom filtering logic
    excluded_words = {'inappropriate', 'word', 'list'}
    
    for word in fetched_words:
        if word not in excluded_words:
            all_words.add(word)
    
    return all_words
```

## Security Considerations

### No Secrets Required
- Uses public data sources only
- GitHub token automatically provided
- No API keys or credentials needed

### Safe to Run
- Read-only access to external sources
- Only modifies project files
- No system-level changes

### Permissions
Workflow has minimal permissions:
- `contents: write` - Only for committing to repo
- No access to: secrets, deployments, packages, etc.

## Performance

### Typical Run Times
- Successful update: 30-45 seconds
- No changes detected: 20-30 seconds
- With network retries: up to 2 minutes

### Data Transfer
- ~500 KB word list downloads
- ~50 KB JSON responses
- Minimal GitHub API usage

### Resource Usage
- GitHub Actions free tier: 2,000 minutes/month
- This workflow: ~4 minutes/month (weekly runs)
- Well within free limits

## Future Enhancements

### Planned Features
- [ ] Email notifications on successful updates
- [ ] Pull Request workflow (review before merge)
- [ ] Differential change summary
- [ ] Word frequency ranking updates
- [ ] Support for multiple languages

### Possible Improvements
- WebSocket connection to NYTimes for real-time updates
- Machine learning-based common word detection
- Community-contributed word list submissions
- Historical trend analysis of word usage

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - System design details
- [CONVENTIONS.md](CONVENTIONS.md) - Coding standards
- [DECISIONS.md](DECISIONS.md) - Technical decisions (see ADR-012)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

## Support

### Questions or Issues?
1. Check [Troubleshooting](#troubleshooting) section above
2. Review workflow logs in Actions tab
3. Open an [issue](../../issues) on GitHub
4. Include workflow run logs and error messages

### Contributing
Want to improve the update system?
1. Fork the repository
2. Modify update scripts
3. Test locally with `--dry-run`
4. Submit a pull request
