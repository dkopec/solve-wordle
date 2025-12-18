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
- **Pages/** - Blazor components (Index.razor)
- **Models/** - Domain logic (WordleSolver.cs)
- **Services/** - Data loading (WordListService.cs using HttpClient)
- **wwwroot/data/** - Word lists (words.txt, common-words.txt, past-answers.txt)
- **docs/** - Technical documentation

See [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) for complete architecture details and [../docs/CONVENTIONS.md](../docs/CONVENTIONS.md) for file organization principles.

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

## Additional Documentation
For detailed technical documentation, see the docs/ folder:
- [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) - System design and data flow
- [../docs/CONVENTIONS.md](../docs/CONVENTIONS.md) - Coding standards and style guide
- [../docs/DECISIONS.md](../docs/DECISIONS.md) - Architectural decision records
- [../docs/TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md) - Common issues and solutions
- [../docs/SCORING_STRATEGIES.md](../docs/SCORING_STRATEGIES.md) - Word scoring algorithms