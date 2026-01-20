# Testing Wordle Solver with Docker

This guide shows you how to run and test the Wordle Solver Blazor WebAssembly application using Docker.

## Quick Start

### Production Mode (Recommended for Testing)
Run the app with nginx (production-like environment):

```bash
docker-compose up wordle-solver-prod
```

Then open **http://localhost:8080** in your browser.

### Development Mode (For Active Development)
Run with hot reload for development:

```bash
docker-compose up wordle-solver-dev
```

Then open **http://localhost:5000** in your browser.

## Available Services

| Service | Port | Purpose | Server |
|---------|------|---------|--------|
| `wordle-solver-prod` | 8080 | Production testing | nginx |
| `wordle-solver-dev` | 5000 | Development with hot reload | .NET Kestrel |

## Common Commands

### Start Services
```bash
# Start production service
docker-compose up wordle-solver-prod

# Start in background
docker-compose up -d wordle-solver-prod

# Start with rebuild
docker-compose up --build wordle-solver-prod

# Start both services
docker-compose up
```

### Stop Services
```bash
# Stop all
docker-compose down

# Stop specific service
docker-compose stop wordle-solver-prod
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f wordle-solver-prod
```

### Rebuild
```bash
# Rebuild from scratch
docker-compose build --no-cache wordle-solver-prod

# Rebuild and restart
docker-compose up --build --force-recreate wordle-solver-prod
```

## Features by Environment

### Production Container (wordle-solver-prod)
- ✅ Multi-stage build (smaller image ~150MB)
- ✅ nginx with gzip compression
- ✅ Proper cache headers
- ✅ Health checks
- ✅ SPA routing configured
- ✅ Security headers
- ⚡ Fast, optimized for testing production builds

### Development Container (wordle-solver-dev)
- ✅ Hot reload on file changes
- ✅ Source code mounted as volumes
- ✅ Full .NET debugging
- ✅ Development environment
- 🔄 Auto-rebuild on save
- 📦 Larger image (~2-3GB) with full SDK

## Testing Workflow

### 1. Test Production Build
```bash
# Build and run production version
docker-compose up --build wordle-solver-prod

# Open http://localhost:8080
# Test the app functionality
# Check browser console for errors
# Test dark mode toggle
# Verify word filtering works
```

### 2. Test with Development Hot Reload
```bash
# Start development service
docker-compose up wordle-solver-dev

# Make changes to Pages/Index.razor or other files
# App auto-reloads in browser
# Test changes immediately
```

### 3. Clean Test (Fresh Build)
```bash
# Stop all containers
docker-compose down

# Remove all containers and volumes
docker-compose down -v

# Rebuild from scratch
docker-compose build --no-cache

# Start fresh
docker-compose up
```

## Port Configuration

If ports 8080 or 5000 are already in use, edit [docker-compose.yml](docker-compose.yml):

```yaml
services:
  wordle-solver-prod:
    ports:
      - "8081:80"  # Change 8080 to any available port
```

## Troubleshooting

### Port Already in Use
```powershell
# Check what's using the port (Windows)
netstat -ano | findstr :8080

# Change port in docker-compose.yml if needed
```

### Hot Reload Not Working
```bash
# Restart development container
docker-compose restart wordle-solver-dev

# Check file watcher is enabled
docker-compose exec wordle-solver-dev env | grep DOTNET_USE_POLLING
```

### Build Fails
```bash
# Clean local build artifacts
dotnet clean
Remove-Item -Recurse -Force bin, obj

# Rebuild without cache
docker-compose build --no-cache
```

### Container Won't Start
```bash
# Check logs
docker-compose logs wordle-solver-prod

# Check container status
docker-compose ps

# Inspect container
docker inspect wordle-solver-prod
```

## Manual Docker Commands

If you prefer Docker CLI over docker-compose:

### Production
```bash
# Build
docker build -t wordle-solver:latest -f Dockerfile .

# Run
docker run -d -p 8080:80 --name wordle-solver wordle-solver:latest

# View logs
docker logs -f wordle-solver

# Stop
docker stop wordle-solver
docker rm wordle-solver
```

### Development
```bash
# Build
docker build -t wordle-solver:dev -f Dockerfile.dev .

# Run with volumes (Windows PowerShell)
docker run -d -p 5000:5000 `
  -v ${PWD}/Pages:/app/Pages `
  -v ${PWD}/Shared:/app/Shared `
  -v ${PWD}/Models:/app/Models `
  -v ${PWD}/Services:/app/Services `
  -v ${PWD}/wwwroot:/app/wwwroot `
  --name wordle-solver-dev wordle-solver:dev
```

## Performance

- **Production image**: ~150-200 MB
- **Development image**: ~2-3 GB
- **Initial build**: 2-3 minutes
- **Cached builds**: <30 seconds

## Configuration Files

- **[Dockerfile](Dockerfile)** - Production multi-stage build
- **[Dockerfile.dev](Dockerfile.dev)** - Development with hot reload
- **[docker-compose.yml](docker-compose.yml)** - Service orchestration
- **[nginx.conf](nginx.conf)** - nginx configuration for SPA
- **[.dockerignore](.dockerignore)** - Excluded files from build

## Health Checks

Production container includes health checks:

```bash
# Check status
docker inspect wordle-solver-prod --format='{{.State.Health.Status}}'
```

## Why Use Docker for Testing?

1. **Consistent Environment**: Same as production
2. **No Local Dependencies**: Don't need .NET SDK installed
3. **Easy Cleanup**: `docker-compose down` removes everything
4. **Multiple Versions**: Test different builds side-by-side
5. **CI/CD Ready**: Same containers in pipelines

## Integration Tests

Use these containers in automated tests:

```bash
# Start container in background
docker-compose up -d wordle-solver-prod

# Wait for health check
sleep 5

# Run tests against http://localhost:8080
# (Use your preferred testing tool)

# Cleanup
docker-compose down
```

## Additional Resources

- [Main README](README.md) - Project overview
- [Docker Documentation](https://docs.docker.com/)
- [Blazor Deployment Docs](docs/BLAZOR_DEPLOYMENT.md)
- [Word List Updater Docker](README.docker.md) - Separate Docker setup for word list updates

## Notes

- Production container serves static files only (Blazor runs in browser)
- No backend needed - all computation is client-side
- nginx handles SPA routing for Blazor routes
- Development mode runs full .NET SDK with Kestrel server
