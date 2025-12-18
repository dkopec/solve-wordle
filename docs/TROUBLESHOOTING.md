# Troubleshooting Guide

This document covers common issues, their causes, and solutions for the Wordle Solver application.

## Table of Contents
- [Build and Deployment Issues](#build-and-deployment-issues)
- [Runtime Errors](#runtime-errors)
- [UI Issues](#ui-issues)
- [Performance Problems](#performance-problems)
- [Development Environment](#development-environment)

---

## Build and Deployment Issues

### Build Fails with "Framework not found"

**Symptoms:**
```
It was not possible to find any compatible framework version
The framework 'Microsoft.NETCore.App', version '9.0.0' was not found.
```

**Cause:** .NET 9.0 SDK not installed

**Solution:**
1. Install [.NET 9.0 SDK](https://dotnet.microsoft.com/download)
2. Verify installation: `dotnet --version`
3. Rebuild: `dotnet build`

---

### GitHub Pages Shows 404 Error

**Symptoms:**
- Deployment succeeds but site shows 404
- URL: `https://<username>.github.io/<repo>/` returns "Page not found"

**Cause:** GitHub Pages not enabled or incorrect base path

**Solution:**
1. Check GitHub Pages is enabled:
   - Go to repository Settings → Pages
   - Source should be "GitHub Actions"
2. Verify base path in [index.html](wwwroot/index.html):
   ```html
   <base href="/solve-wordle/" />
   ```
   Must match repository name exactly

---

### Blazor App Loads but Shows Blank Page

**Symptoms:**
- Page loads but displays nothing
- Console shows 404 errors for `_framework/*` files

**Cause:** Incorrect base path or missing files

**Solution:**
1. Check browser console (F12) for specific errors
2. Verify base href in [index.html](wwwroot/index.html) matches deployment path
3. Ensure GitHub Actions workflow published all files:
   ```yaml
   - name: Publish
     run: dotnet publish -c Release -o release
   ```

---

### "Failed to fetch" Errors for Word Lists

**Symptoms:**
```
Failed to load data: System.Net.Http.HttpRequestException
```

**Cause:** Word list files missing or incorrect path

**Solution:**
1. Verify files exist in [wwwroot/data/](wwwroot/data/):
   - `words.txt`
   - `common-words.txt`
   - `past-answers.txt`
2. Check file paths in [WordListService.cs](Services/WordListService.cs):
   ```csharp
   await _httpClient.GetStringAsync("data/words.txt");
   ```
3. Ensure files are included in publish:
   ```xml
   <ItemGroup>
     <Content Include="wwwroot\data\*.txt" />
   </ItemGroup>
   ```

---

## Runtime Errors

### Dark Mode Doesn't Persist

**Symptoms:**
- Dark mode toggle works but resets on page refresh
- Console shows localStorage errors

**Cause:** localStorage blocked or JavaScript errors

**Solution:**
1. Check if browser allows localStorage (private browsing may block)
2. Verify [site.js](wwwroot/js/site.js) is loaded:
   ```html
   <script src="js/site.js"></script>
   ```
3. Check console for JavaScript errors
4. Test manually in console:
   ```javascript
   localStorage.setItem('darkMode', 'true');
   localStorage.getItem('darkMode');
   ```

---

### Auto-Focus Not Working

**Symptoms:**
- Typing in letter boxes doesn't advance focus
- Must manually tab to next input

**Cause:** JavaScript not loaded or element IDs don't match

**Solution:**
1. Verify [site.js](wwwroot/js/site.js) is loaded (check Network tab)
2. Check element IDs match pattern:
   - Correct letters: `correct-0`, `correct-1`, etc.
   - Wrong position: `wrong-0-0`, `wrong-0-1`, etc.
3. Check for JavaScript errors in console
4. Verify JS interop call in [Index.razor](Pages/Index.razor):
   ```csharp
   await JS.InvokeVoidAsync("focusNextInput", currentId);
   ```

---

### No Words Found Despite Valid Input

**Symptoms:**
- Valid Wordle clues entered but "No matching words" shown
- Should find words but list is empty

**Cause:** Logic error in filtering or conflicting constraints

**Solution:**
1. Check for conflicting rules:
   - Letter marked as both correct (green) AND excluded (gray)
   - Letter in wrong position also marked as correct
2. Verify letter casing - all processing is lowercase
3. Debug WordleSolver.FilterWords():
   ```csharp
   // Add logging
   Console.WriteLine($"Input: {string.Join(",", correctLetters)}");
   Console.WriteLine($"Found: {filteredWords.Count} words");
   ```
4. Test with simple case:
   - Correct: `_ _ _ _ _` (all blank)
   - Should return full word list

---

### Suggestions Show Inappropriate Words

**Symptoms:**
- Suggested words seem wrong or offensive
- Past answers include unexpected words

**Cause:** Word list contains questionable entries

**Solution:**
1. Review [wwwroot/data/words.txt](wwwroot/data/words.txt)
2. Remove unwanted words from source files
3. Rebuild and redeploy
4. Consider curating `common-words.txt` for better suggestions

---

## UI Issues

### Layout Broken on Mobile

**Symptoms:**
- Inputs overflow screen
- Buttons not clickable
- Text too small

**Cause:** Bootstrap responsive classes not applied correctly

**Solution:**
1. Verify Bootstrap CSS is loaded:
   ```html
   <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
   ```
2. Test responsive classes:
   - Use `col-lg-5` for input column
   - Use `col-lg-7` for results
3. Check viewport meta tag in [index.html](wwwroot/index.html):
   ```html
   <meta name="viewport" content="width=device-width, initial-scale=1.0" />
   ```

---

### Dark Mode Colors Look Wrong

**Symptoms:**
- Some elements don't change color in dark mode
- Text hard to read
- Inconsistent styling

**Cause:** CSS not using Bootstrap dark mode variables

**Solution:**
1. Verify `data-bs-theme` attribute set on `<html>`:
   ```javascript
   document.documentElement.setAttribute('data-bs-theme', 'dark');
   ```
2. Use Bootstrap color classes instead of custom colors:
   - `bg-body` instead of `background-color: white`
   - `text-body` instead of `color: black`
3. Check [site.css](wwwroot/css/site.css) for hardcoded colors

---

### Letter Boxes Don't Align

**Symptoms:**
- Green/yellow/gray input boxes different sizes
- Grid looks misaligned

**Cause:** Inconsistent sizing in inline styles

**Solution:**
1. Standardize dimensions in [Index.razor](Pages/Index.razor):
   ```csharp
   // Correct letters (green)
   style="width: 60px; height: 60px;"
   
   // Wrong position (yellow)
   style="width: 50px; height: 50px;"
   ```
2. Consider moving to CSS classes for consistency:
   ```css
   .letter-box { width: 60px; height: 60px; }
   .wrong-pos-box { width: 50px; height: 50px; }
   ```

---

## Performance Problems

### App Loads Slowly

**Symptoms:**
- Initial load takes >5 seconds
- "Loading word lists..." shows for long time

**Cause:** Large WASM runtime or network issues

**Expected Behavior:**
- First load: ~2-3 seconds (download WASM runtime)
- Subsequent loads: <1 second (cached)

**Solutions:**
1. Check browser caching headers in deployed site
2. Use browser DevTools Network tab to identify slow resources
3. Consider enabling Brotli compression in GitHub Pages
4. Optimize word list sizes if >1MB total

---

### Filtering Feels Slow

**Symptoms:**
- Delay when typing in inputs
- UI freezes briefly when filtering

**Cause:** Too many words or inefficient filtering

**Solution:**
1. Check word list size:
   ```csharp
   Console.WriteLine($"Total words: {_wordList.Count}");
   ```
   Should be ~13,000
2. Profile filtering performance:
   ```csharp
   var sw = Stopwatch.StartNew();
   var results = FilterWords(...);
   Console.WriteLine($"Filtered in {sw.ElapsedMilliseconds}ms");
   ```
   Should be <50ms
3. Verify frequency data initialized once:
   ```csharp
   if (_letterFrequency == null)
       InitializeFrequencyData();
   ```

---

### Memory Usage High

**Symptoms:**
- Browser tab uses >200MB RAM
- Browser slows down or crashes

**Cause:** WASM runtime + data structures

**Expected Behavior:**
- Typical usage: 50-100MB
- With large word lists: up to 150MB

**Solutions:**
1. Check for memory leaks in browser DevTools
2. Reduce word list sizes
3. Consider lazy loading word lists only when needed
4. Clear cached data periodically:
   ```csharp
   _cachedBestStartingWords = null;
   ```

---

## Development Environment

### VS Code Doesn't Show Razor IntelliSense

**Symptoms:**
- No autocomplete in `.razor` files
- Syntax highlighting broken

**Cause:** C# Dev Kit extension not installed or not working

**Solution:**
1. Install "C# Dev Kit" extension from marketplace
2. Restart VS Code
3. Check `.vscode/settings.json` if needed:
   ```json
   {
     "razor.languageServer.forceRuntimeCodeGeneration": true
   }
   ```

---

### Breakpoints Not Hit in Blazor Code

**Symptoms:**
- Debugger doesn't stop at breakpoints
- F5 debugging not working

**Cause:** Debugging not configured for Blazor WebAssembly

**Solution:**
1. Use browser DevTools instead of VS Code for client-side debugging
2. Add debugging properties to [launchSettings.json](Properties/launchSettings.json):
   ```json
   {
     "inspectUri": "{wsProtocol}://{url.hostname}:{url.port}/_framework/debug/ws-proxy?browser={browserInspectUri}"
   }
   ```
3. Launch with `dotnet run` and open browser DevTools (F12)
4. Source maps should allow debugging C# in browser

---

### "dotnet watch" Not Hot Reloading

**Symptoms:**
- Changes to `.razor` files don't update without full rebuild
- Must stop and restart `dotnet run`

**Cause:** Hot reload not enabled or not supported for change type

**Solution:**
1. Use `dotnet watch` instead of `dotnet run`:
   ```bash
   dotnet watch run
   ```
2. Some changes require full rebuild:
   - Adding new dependencies
   - Changing Program.cs
   - Modifying .csproj file
3. Check .NET SDK version supports hot reload (requires .NET 6+)

---

### Port Already in Use

**Symptoms:**
```
Failed to bind to address https://localhost:5027
```

**Cause:** Another process using port 5027

**Solution:**
1. Find process using port:
   ```powershell
   # Windows
   netstat -ano | findstr :5027
   taskkill /PID <PID> /F
   ```
   ```bash
   # Linux/Mac
   lsof -i :5027
   kill -9 <PID>
   ```
2. Or change port in [launchSettings.json](Properties/launchSettings.json):
   ```json
   "applicationUrl": "https://localhost:5028;http://localhost:5029"
   ```

---

## Getting More Help

### Enable Detailed Logging

Add to [Program.cs](Program.cs):
```csharp
builder.Logging.SetMinimumLevel(LogLevel.Debug);
```

### Browser Developer Tools

1. Open DevTools: F12
2. Check Console tab for JavaScript errors
3. Check Network tab for failed requests
4. Check Application tab for localStorage

### Diagnostic Checklist

Before reporting issues:
- [ ] .NET version: `dotnet --version`
- [ ] Browser version and type
- [ ] Error messages from console
- [ ] Network requests failing (F12 → Network)
- [ ] Reproduction steps
- [ ] Expected vs actual behavior

### Reporting Issues

Include in bug reports:
1. Detailed description of the problem
2. Steps to reproduce
3. Environment details (OS, browser, .NET version)
4. Screenshots or console logs
5. What you've already tried

### Resources

- [Blazor Documentation](https://learn.microsoft.com/en-us/aspnet/core/blazor/)
- [Bootstrap Documentation](https://getbootstrap.com/docs/5.3/)
- [GitHub Issues](https://github.com/dkopec/solve-wordle/issues)
- Project documentation:
  - [../README.md](../README.md) - Getting started
  - [ARCHITECTURE.md](ARCHITECTURE.md) - System design
  - [CONVENTIONS.md](CONVENTIONS.md) - Code standards
  - [DECISIONS.md](DECISIONS.md) - Technical decisions
