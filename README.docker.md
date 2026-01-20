# Running Word List Updater with Docker

This document explains how to run the word list update script using Docker, without needing to install Python or dependencies locally.

## Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose (included with Docker Desktop)

## Quick Start

### Run Update (Production Mode)
```bash
# Build and run the updater
docker-compose -f docker-compose.update-words.yml up --build

# Or run without rebuilding if no changes to dependencies
docker-compose -f docker-compose.update-words.yml up
```

### Dry Run (Test Mode)
To see what would change without actually modifying files:

```bash
docker-compose -f docker-compose.update-words.yml run --rm update-word-lists --dry-run --verbose
```

### Run with Custom Options
```bash
# Dry run with verbose output
docker-compose -f docker-compose.update-words.yml run --rm update-word-lists --dry-run --verbose

# Normal run with verbose output
docker-compose -f docker-compose.update-words.yml run --rm update-word-lists --verbose

# Normal run (minimal output)
docker-compose -f docker-compose.update-words.yml run --rm update-word-lists
```

## How It Works

1. **Dockerfile.update-words** - Defines the Python 3.11 container with required packages:
   - `requests` - HTTP library for fetching data
   - `beautifulsoup4` - HTML parsing
   - `lxml` - XML/HTML parser

2. **docker-compose.update-words.yml** - Orchestrates the container:
   - Mounts `wwwroot/data/` so updates persist on your local machine
   - Mounts the script as read-only so you can edit it without rebuilding
   - Sets environment variables for proper output

3. **Script Execution**:
   - Fetches latest Wordle answers from NYTimes
   - Updates word lists in `wwwroot/data/`
   - Creates backups in `wwwroot/data/backups/`
   - All changes persist on your local filesystem

## Volume Mounts

The Docker container mounts two volumes:

```yaml
volumes:
  - ./wwwroot/data:/app/wwwroot/data           # Read/write - data files
  - ./Scripts/update-word-lists.py:/app/...   # Read-only - script
```

This means:
- ✅ Updated word lists are saved to your local `wwwroot/data/` folder
- ✅ You can edit the Python script and run again without rebuilding
- ✅ Backups are created in your local `wwwroot/data/backups/` folder

## Cleanup

Remove the container and image:
```bash
# Stop and remove container
docker-compose -f docker-compose.update-words.yml down

# Remove built image
docker rmi wordle-word-updater
```

## Troubleshooting

### Container Fails to Build
- Check Docker is running: `docker ps`
- Check internet connection (needs to download Python base image)
- Try rebuilding: `docker-compose -f docker-compose.update-words.yml build --no-cache`

### Permission Errors
On Linux/Mac, you may need to adjust file permissions:
```bash
chmod -R 755 wwwroot/data/
```

### Changes Not Persisting
Verify volume mount is correct:
```bash
docker-compose -f docker-compose.update-words.yml config
```

Should show `./wwwroot/data:/app/wwwroot/data` under volumes.

## Updating the Script

After editing `Scripts/update-word-lists.py`:
```bash
# No rebuild needed - script is mounted as volume
docker-compose -f docker-compose.update-words.yml run --rm update-word-lists --verbose
```

## Updating Dependencies

If you modify the Python dependencies, rebuild the image:
```bash
docker-compose -f docker-compose.update-words.yml build --no-cache
```

## Windows-Specific Notes

### Path Separators
Docker on Windows automatically converts paths. Use forward slashes in docker-compose.yml:
```yaml
volumes:
  - ./wwwroot/data:/app/wwwroot/data  # ✅ Works on Windows
```

### Line Endings
Ensure Python script uses LF (Unix) line endings, not CRLF:
```bash
# In Git Bash
dos2unix Scripts/update-word-lists.py

# Or configure Git
git config core.autocrlf false
```

### PowerShell
You can run docker-compose from PowerShell:
```powershell
docker-compose -f docker-compose.update-words.yml up --build
```

## Comparison: Docker vs Local Python

| Aspect | Docker | Local Python |
|--------|--------|--------------|
| Setup Time | 2-3 min (one-time) | 5-10 min (install Python + deps) |
| Dependencies | Isolated in container | Installed globally or in venv |
| Portability | Works anywhere with Docker | Requires Python 3.11+ |
| Disk Space | ~200 MB (base image) | ~100 MB (Python + packages) |
| Execution Speed | Slightly slower (container overhead) | Native speed |

**Recommendation**: Use Docker for one-off updates or CI/CD. Use local Python for frequent development.
