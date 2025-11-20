# Wordle Solver

A .NET Core web application that helps you solve Wordle puzzles by filtering possible words based on your clues.

## Features

- **Green Letters (Correct Position)**: Enter letters you know are in the correct position using underscores for unknowns (e.g., `_a_e_`)
- **Yellow Letters (Wrong Position)**: Enter letters that exist in the word but not in specific positions (e.g., `r:1, t:3`)
- **Gray Letters (Excluded)**: Enter letters that don't appear in the word at all (e.g., `xyz`)

## Getting Started

### Prerequisites

- [.NET 9.0 SDK](https://dotnet.microsoft.com/download) or later

### Running the Application

1. Clone or download this repository
2. Navigate to the project directory:
   ```bash
   cd solve-wordle
   ```
3. Run the application:
   ```bash
   dotnet run
   ```
4. Open your browser and navigate to the URL shown in the terminal (typically `https://localhost:5001` or `http://localhost:5000`)

### Using VS Code Tasks

If you're using Visual Studio Code:
- Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on Mac) and select the **run** task
- The application will start automatically

## How to Use

1. **Enter Correct Letters**: If you know certain letters are in the correct position, enter them with underscores for unknown positions
   - Example: `_a_e_` means 'a' is the 2nd letter and 'e' is the 4th letter

2. **Enter Wrong Position Letters**: If a letter is in the word but not in a specific position, enter it with the position
   - Example: `r:1, t:3` means 'r' is in the word but not position 1, and 't' is in the word but not position 3

3. **Enter Excluded Letters**: Enter all letters that you know are NOT in the word
   - Example: `xyz` means x, y, and z are not in the solution

4. Click **Find Words** to see all possible matching words

## Project Structure

```
solve-wordle/
├── Data/
│   └── words.txt          # Dictionary of 5-letter words
├── Models/
│   └── WordleSolver.cs    # Word filtering logic
├── Pages/
│   ├── Index.cshtml       # Main UI page
│   └── Index.cshtml.cs    # Page model with logic
├── Services/
│   └── WordListService.cs # Service to load word list
├── Program.cs             # Application entry point
└── README.md              # This file
```

## Technologies Used

- ASP.NET Core 9.0
- Razor Pages
- Bootstrap 5
- C#

## How It Works

The application filters a dictionary of 5-letter words based on three types of Wordle clues:

1. **Correct positions** - filters words that have specific letters in specific positions
2. **Wrong positions** - filters words that contain certain letters but not in specific positions
3. **Excluded letters** - removes words containing specific letters

The filtering algorithm efficiently narrows down possibilities to help you solve the puzzle faster.

## License

This project is open source and available for educational purposes.
