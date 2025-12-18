# Quick Start Guide

Get the Wordle Solver running in minutes!

## Option 1: Run Locally (Fastest)

### Prerequisites
- [.NET 9.0 SDK](https://dotnet.microsoft.com/download)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/dkopec/solve-wordle.git
   cd solve-wordle
   ```

2. Run the application:
   ```bash
   dotnet run
   ```

3. Open your browser to `http://localhost:5027`

### Using VS Code
- Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on Mac)
- Select the **run** task
- The application will start automatically

---

## Option 2: Deploy to GitHub Pages (Automatic)

The project includes automatic deployment to GitHub Pages via GitHub Actions.

### Steps
1. Fork or clone the repository to your GitHub account

2. Enable GitHub Pages:
   - Go to repository **Settings** → **Pages**
   - Source: **GitHub Actions**

3. Push to `main` branch:
   ```bash
   git push origin main
   ```

4. GitHub Actions will automatically build and deploy

5. Access your app at: `https://<username>.github.io/solve-wordle/`

See [BLAZOR_DEPLOYMENT.md](BLAZOR_DEPLOYMENT.md) for detailed deployment options.

---

## Option 3: Deploy to Azure (Optional)

For Azure deployment, use the provided scripts:

**Windows/Linux/Mac (PowerShell):**
```powershell
./Scripts/setup-azure.ps1
```

**Linux/Mac (Bash):**
```bash
chmod +x Scripts/setup-azure.sh
./Scripts/setup-azure.sh
```

The script will:
- ✓ Auto-detect your GitHub repository
- ✓ Create Azure resources
- ✓ Configure deployment
- ✓ Provide deployment URL

**Note**: Requires Azure CLI and appropriate permissions.

---

## Troubleshooting

### Build Errors
- Ensure .NET 9.0 SDK is installed: `dotnet --version`
- Clean and rebuild: `dotnet clean && dotnet build`

### Port Already in Use
- Change port in `Properties/launchSettings.json`
- Or stop the process using port 5027

### Deployment Issues
- Check GitHub Actions logs in your repository
- Verify `base href` in `wwwroot/index.html` matches your repository name
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions

---

## Next Steps

- Read the [README](../README.md) for features and usage
- Check [ARCHITECTURE.md](ARCHITECTURE.md) to understand the design
- Review [CONVENTIONS.md](CONVENTIONS.md) before contributing
