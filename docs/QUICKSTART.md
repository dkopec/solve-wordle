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

## How to Use the Solver

1. **Choose a starting word** - The app suggests optimal starting words
   - Use arrow keys (←/→) or click arrows to cycle suggestions
   - Press shuffle button for a random word
   - Click edit button to type your own word

2. **Enter it in Wordle** - Use the suggested word in your actual Wordle game

3. **Mark the results**:
   - Gray tiles: Letter not in word
   - Yellow tiles: Letter in word, wrong position  
   - Green tiles: Letter in correct position
   - Use Tab to navigate tiles, Space/Click to change colors

4. **Lock your guess** - Press Enter or click the checkmark ✓

5. **Get next suggestion** - Based on your feedback, get the next best word

6. **Repeat until solved!**
   - When only one word remains, it auto-completes!

### Keyboard Shortcuts

- **Tab** - Navigate through letter tiles
- **←/→** - Cycle word suggestions
- **Enter** - Lock current guess
- **Space/Click** - Change tile color (Gray → Yellow → Green)

### Features

- 🎯 **Smart suggestions** based on letter frequency and position analysis
- ⌨️ **Full keyboard navigation** for hands-free solving
- 🔄 **Real-time filtering** as you mark tiles
- 🤖 **Auto-complete** when only one word remains
- 📊 **Confidence scores** for each suggestion
- ✏️ **Manual word entry** for custom guesses
- 🎲 **Random suggestions** to try different approaches
- 🌙 **Dark mode** support
- 📱 **Mobile-friendly** responsive design

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
