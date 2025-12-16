# Wordle Solver - Blazor WebAssembly Application

## Project Overview
This is a Blazor WebAssembly application that helps users solve Wordle puzzles by filtering possible words based on:
- Correct letters in correct positions (green)
- Correct letters in wrong positions (yellow)
- Excluded letters (gray)

The application runs entirely in the browser and is deployed to GitHub Pages.

## Technology Stack
- .NET 9.0
- Blazor WebAssembly
- C#
- Bootstrap 5.3.3 with built-in dark mode support
- Bootstrap Icons 1.11.3
- JavaScript Interop for DOM manipulation

## Project Structure
- Pages/ - Blazor components (Index.razor)
- Models/ - Data models and word filtering logic (WordleSolver.cs)
- Services/ - Services for data loading (WordListService.cs using HttpClient)
- Shared/ - Shared Blazor components (MainLayout.razor)
- wwwroot/ - Static files (CSS, JS, data files)
  - wwwroot/data/ - Word list dictionaries (words.txt, common-words.txt, past-answers.txt)
  - wwwroot/css/ - Custom styling including dark mode
  - wwwroot/js/ - JavaScript functions for auto-focus functionality
- .github/workflows/ - GitHub Actions for automated deployment

## Key Features
- **Dark Mode Toggle**: Persistent theme selection using localStorage
- **Side-by-Side Layout**: Left column for inputs (sticky), right column for results
- **Auto-Focus Input**: Automatic focus advancement as user types in letter grids
- **Smart Word Filtering**: Efficient algorithms for finding matching words
- **GitHub Pages Deployment**: Automated CI/CD pipeline

## Development Guidelines
- Use clean, maintainable C# code
- Follow Blazor WebAssembly best practices
- Use HttpClient for loading data files (not file system)
- Implement efficient word filtering algorithms
- Ensure responsive UI design with Bootstrap
- Use JavaScript Interop sparingly and only when necessary
- Test auto-focus and DOM manipulation thoroughly
- Maintain dark mode compatibility in all UI elements
