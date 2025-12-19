# Wordle Solver

A Blazor WebAssembly application that helps you solve Wordle puzzles by filtering possible words based on your clues. Runs entirely in the browser with no server required.

🌐 **[Live Demo on GitHub Pages](https://dkopec.github.io/solve-wordle/)**

## Features

- **🌓 Dark Mode**: Toggle between light and dark themes with persistent preference
- **📱 Responsive Layout**: Side-by-side columns for inputs and results
- **⌨️ Smart Input**: Auto-advance focus as you type in letter grids
- **🎯 Multiple Input Methods**:
  - **Grid Input**: Visual 5x6 grid for green (correct position) and yellow (wrong position) letters
  - **Quick Text Input**: Fast text entry for correct positions (e.g., `_a_e_`)
  - **Gray Letters**: Enter excluded letters in bulk
- **📊 Smart Suggestions**: 
  - Best starting words ranked by letter frequency
  - Guess-in-one possibilities
  - Filtered word list based on your clues

## Getting Started

### Prerequisites

- [.NET 9.0 SDK](https://dotnet.microsoft.com/download) or later

### Running Locally

1. Clone this repository:
   ```bash
   git clone https://github.com/dkopec/solve-wordle.git
   cd solve-wordle
   ```

2. Run the application:
   ```bash
   dotnet run
   ```

3. Open your browser to `http://localhost:5027`

### Using VS Code Tasks

If you're using Visual Studio Code:
- Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on Mac) and select the **run** task
- The application will start automatically

## How to Use

### Grid Input Method

1. **Green Letters (Correct Position)**: Click on cells in the grid and type letters that are in the correct position
2. **Yellow Letters (Wrong Position)**: Type letters in yellow rows where they appear in the word but in wrong positions
3. **Gray Letters**: Enter all letters that are NOT in the word
4. Results update automatically as you type

### Text Input Method

1. **Correct Letters**: Enter pattern with underscores for unknowns
   - Example: `_a_e_` means 'a' is the 2nd letter, 'e' is the 4th letter

2. **Wrong Position Letters**: Enter letter:position pairs
   - Example: `r:1, t:3` means 'r' exists but not at position 1, 't' exists but not at position 3

3. **Excluded Letters**: Enter letters to exclude
   - Example: `xyz` means x, y, and z are not in the solution

## Technologies

- **Framework**: .NET 9.0 with Blazor WebAssembly
- **UI**: Bootstrap 5.3.3 with Dark Mode
- **Deployment**: GitHub Pages via GitHub Actions

For detailed project structure and conventions, see [docs/CONVENTIONS.md](docs/CONVENTIONS.md).

## How It Works

The application runs entirely in your browser using Blazor WebAssembly. It filters a dictionary of 5-letter words based on three types of Wordle clues:

1. **Correct positions (Green)** - Filters words that have specific letters in specific positions
2. **Wrong positions (Yellow)** - Filters words that contain certain letters but not in specific positions
3. **Excluded letters (Gray)** - Removes words containing specific letters

The filtering algorithm efficiently narrows down possibilities to help you solve the puzzle faster.

## Deployment

This application is automatically deployed to GitHub Pages using GitHub Actions. Every push to the `main` branch triggers a build and deployment.

See [docs/BLAZOR_DEPLOYMENT.md](docs/BLAZOR_DEPLOYMENT.md) for deployment details and [docs/QUICKSTART.md](docs/QUICKSTART.md) for quick setup instructions.

## Word List Updates

The application includes an **automated word list update system** that:
- 🔄 Runs weekly via GitHub Actions
- 📥 Fetches latest Wordle answers from NYTimes
- ✅ Updates past-answers.txt with new daily puzzles
- 🚀 Automatically deploys changes to GitHub Pages

You can also trigger updates manually or run locally. See [docs/AUTO_UPDATE.md](docs/AUTO_UPDATE.md) for details.

## Documentation

For detailed technical documentation, see the [docs/](docs/) folder:

- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design and data flow
- **[docs/CONVENTIONS.md](docs/CONVENTIONS.md)** - Coding standards and style guide
- **[docs/DECISIONS.md](docs/DECISIONS.md)** - Architectural decision records
- **[docs/AUTO_UPDATE.md](docs/AUTO_UPDATE.md)** - Automated word list updates
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[docs/SCORING_STRATEGIES.md](docs/SCORING_STRATEGIES.md)** - Word scoring algorithms
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

## License

This project is open source and available for educational purposes.
