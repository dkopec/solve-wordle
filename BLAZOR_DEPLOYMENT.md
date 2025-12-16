# Blazor WebAssembly Deployment Guide

## Deploying to GitHub Pages

This Blazor WebAssembly application is configured for automatic deployment to GitHub Pages.

### Setup Instructions

1. **Enable GitHub Pages**:
   - Go to your repository Settings > Pages
   - Under "Source", select "GitHub Actions"

2. **Push to main branch**:
   ```bash
   git add .
   git commit -m "Convert to Blazor WebAssembly"
   git push origin main
   ```

3. **Monitor deployment**:
   - Go to the "Actions" tab in your repository
   - Watch the "Deploy Blazor WASM to GitHub Pages" workflow
   - Once complete, your site will be live at: `https://dkopec.github.io/solve-wordle/`

### Local Development

Run the application locally:

```bash
dotnet run
```

Or with hot reload:

```bash
dotnet watch
```

### Build for Production

```bash
dotnet publish -c Release
```

The output will be in `bin/Release/net9.0/publish/wwwroot/`

### Project Structure

- **Blazor WebAssembly**: Runs entirely in the browser using WebAssembly
- **No server required**: All logic runs client-side
- **Static hosting**: Can be hosted on any static file server (GitHub Pages, Netlify, Azure Static Web Apps, etc.)

### What Changed from Razor Pages

- ✅ **Kept all C# code**: `WordleSolver.cs` works unchanged
- ✅ **Client-side only**: No server-side dependencies
- ✅ **Blazor components**: Converted `.cshtml` to `.razor` with interactive UI
- ✅ **HTTP-based data loading**: Word lists loaded via HttpClient
- ✅ **GitHub Pages ready**: Automatic deployment pipeline configured

### Technologies Used

- .NET 9.0
- Blazor WebAssembly
- Bootstrap 5.3.3
- Bootstrap Icons 1.11.3
