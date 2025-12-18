# Development Conventions

This document establishes coding standards and conventions for the Wordle Solver project to maintain consistency and enable effective AI-assisted development.

## Code Organization

### Project Structure
```
solve-wordle/
├── Pages/           # Blazor pages/components (.razor files)
├── Shared/          # Shared Blazor components (layouts)
├── Models/          # Domain logic and business entities
├── Services/        # Application services (data loading, etc.)
├── wwwroot/         # Static assets (CSS, JS, data files)
│   ├── css/         # Stylesheets
│   ├── js/          # JavaScript for interop
│   └── data/        # Text data files
├── .github/         # GitHub-specific files
│   ├── workflows/   # CI/CD pipelines
│   └── copilot-instructions.md  # AI assistant context
└── docs/            # Additional documentation (optional)
```

### File Organization Principles
- **One major component per file** - Keep files focused and under 1000 lines
- **Related files grouped** - Put related functionality in same folder
- **Clear separation of concerns** - UI, business logic, and services in separate layers

## Naming Conventions

### Files and Directories
- **Razor Components**: PascalCase with `.razor` extension
  - ✅ `Index.razor`, `MainLayout.razor`
  - ❌ `index.razor`, `main-layout.razor`
- **C# Classes**: PascalCase with `.cs` extension
  - ✅ `WordleSolver.cs`, `WordListService.cs`
  - ❌ `wordleSolver.cs`, `WLS.cs` (avoid abbreviations)
- **Data Files**: kebab-case with descriptive names
  - ✅ `common-words.txt`, `past-answers.txt`
  - ❌ `cw.txt`, `data.txt`
- **CSS/JS**: kebab-case
  - ✅ `site.css`, `site.js`
  - ❌ `Site.css`, `siteStyles.css`

### Code Identifiers

#### C# Classes and Methods
```csharp
// Classes: PascalCase (noun or noun phrase)
public class WordleSolver { }
public class WordListService { }

// Methods: PascalCase (verb or verb phrase)
public void FilterWords() { }
public async Task InitializeAsync() { }

// Private fields: _camelCase with underscore prefix
private readonly HttpClient _httpClient;
private List<string>? _cachedWords;

// Properties: PascalCase
public string Word { get; set; }
public int Score { get; set; }

// Local variables: camelCase
var filteredWords = new List<string>();
int matchCount = 0;

// Constants: PascalCase
private const int MaxWordLength = 5;
```

#### Razor Components
```csharp
// Parameters: PascalCase
[Parameter] public string Title { get; set; }

// Component fields: camelCase (no underscore)
private bool isDarkMode = false;
private string[] correctLetters = new string[5];

// Event handlers: On{Event}{Description}
private void OnCorrectLetterInput(int index, ChangeEventArgs e) { }
private void OnDarkModeToggle() { }

// HTML IDs: kebab-case
<input id="correct-letter-0" />
<div id="wordle-form">

// CSS classes: Bootstrap standard (kebab-case)
<div class="btn btn-primary">
<div class="form-control">
```

#### JavaScript
```javascript
// Functions: camelCase
function focusNextInput(currentId) { }
function focusPreviousInput(currentId) { }

// Variables: camelCase
const nextInput = document.getElementById(nextId);
let darkMode = localStorage.getItem('darkMode');
```

## Code Style

### C# Style Guidelines

#### Prefer Clarity Over Brevity
```csharp
// ✅ Clear and explicit
var filteredWords = words.Where(w => w.Length == 5).ToList();

// ❌ Too terse
var w = words.Where(x => x.Length == 5).ToList();
```

#### Use Null-Conditional and Null-Coalescing
```csharp
// ✅ Safe navigation
var count = _cachedWords?.Count ?? 0;

// ✅ Nullable reference types
private List<string>? _words;  // Explicit nullable
private HashSet<string> _commonWords = new();  // Non-nullable with initialization
```

#### Async/Await Patterns
```csharp
// ✅ Async methods end with "Async"
public async Task InitializeAsync()
{
    var data = await _httpClient.GetStringAsync("data/words.txt");
}

// ✅ Avoid async void (except event handlers)
private async Task LoadDataAsync() { }

// ✅ OK for event handlers only
private async void OnButtonClick() { }
```

#### LINQ Preferences
```csharp
// ✅ Use method syntax for simple queries
var fiveLetterWords = words.Where(w => w.Length == 5).ToList();

// ✅ Use query syntax for complex multi-step queries
var result = from word in words
             where word.Length == 5
             let score = CalculateScore(word)
             orderby score descending
             select new { word, score };
```

### Razor Component Style

#### Component Structure
```razor
@* 1. Page directive and injections at top *@
@page "/"
@inject WordListService WordListService
@inject IJSRuntime JS

@* 2. Markup section *@
<div class="container">
    @if (isLoading)
    {
        <p>Loading...</p>
    }
    else
    {
        <div>@content</div>
    }
</div>

@* 3. Code block at bottom *@
@code {
    // Parameters first
    [Parameter] public string Title { get; set; } = "";
    
    // Private fields
    private bool isLoading = true;
    
    // Lifecycle methods
    protected override async Task OnInitializedAsync()
    {
        await LoadData();
    }
    
    // Event handlers
    private void OnButtonClick() { }
    
    // Helper methods
    private string FormatValue(string value) => value.ToUpper();
}
```

#### Event Handler Patterns
```razor
@* ✅ Inline lambda for simple operations *@
<button @onclick="() => count++">Increment</button>

@* ✅ Method reference for complex logic *@
<button @onclick="HandleComplexClick">Process</button>

@* ✅ Parameter passing *@
<button @onclick="@((e) => OnItemClick(item.Id))">Select</button>
```

### JavaScript Style

```javascript
// ✅ Use strict equality
if (value === 'darkMode') { }

// ✅ Use const by default, let when reassignment needed
const nextId = `correct-${index + 1}`;
let retryCount = 0;

// ✅ Guard clauses for early return
function focusNextInput(currentId) {
    if (!currentId) return;
    
    const nextInput = document.getElementById(nextId);
    if (!nextInput) return;
    
    nextInput.focus();
}
```

## Comments and Documentation

### When to Comment

#### DO Comment:
```csharp
// AGENT_CONTEXT: HttpClient is used because Blazor WASM cannot access file system
public class WordListService
{
    private readonly HttpClient _httpClient;
}

// WHY: Past answers get highest priority because they're proven Wordle words
foreach (var word in _pastAnswers)
{
    _wordCommonality[word] = 1000.0;
}

// PERF: Using HashSet for O(1) lookups instead of List
private HashSet<string> _commonWords;
```

#### DON'T Comment:
```csharp
// ❌ Obvious "what" comments
// Increment counter
count++;

// ❌ Redundant comments
// Get words
var words = GetWords();
```

### TODO Markers
```csharp
// TODO(agent): Extract this logic to separate service when adding user preferences
// PERF(agent): Consider caching if word list exceeds 50K words
// SECURITY(agent): Validate input length before processing
// BUG(agent): Fix race condition in concurrent filtering
```

### XML Documentation
```csharp
/// <summary>
/// Filters the word list based on Wordle constraints.
/// </summary>
/// <param name="correctLetters">Letters in correct positions (green). Use empty string for unknown.</param>
/// <param name="wrongPositions">Letters in wrong positions (yellow) with their incorrect positions.</param>
/// <param name="excludedLetters">Letters that don't appear in the word (gray).</param>
/// <returns>List of matching words sorted by likelihood score.</returns>
public List<string> FilterWords(
    string[] correctLetters,
    Dictionary<char, List<int>> wrongPositions,
    HashSet<char> excludedLetters)
{
    // Implementation
}
```

## Error Handling

### Strategy
```csharp
// ✅ Try-catch for external operations (HTTP, file access)
try
{
    var data = await _httpClient.GetStringAsync("data/words.txt");
}
catch (HttpRequestException ex)
{
    Console.WriteLine($"Failed to load data: {ex.Message}");
    // Fallback to defaults
    _words = new List<string>();
}

// ✅ Guard clauses for invalid input
public List<string> FilterWords(string[] correctLetters)
{
    if (correctLetters == null || correctLetters.Length != 5)
    {
        throw new ArgumentException("Must provide exactly 5 letter positions", nameof(correctLetters));
    }
    
    // Continue with valid input
}

// ✅ Silent fallback for UI convenience (not critical errors)
private void OnInputChange(string value)
{
    // Just skip invalid input instead of throwing
    if (string.IsNullOrWhiteSpace(value)) return;
    
    ProcessInput(value);
}
```

## Testing Strategy

### Current State
- **Manual Testing**: Primary method - testing via browser
- **No Unit Tests Yet**: Simple project doesn't require extensive testing

### Future Testing Approach
```
src/
  Models/
    WordleSolver.cs
tests/
  Unit/
    Models/
      WordleSolverTests.cs          # Test filtering logic
  Integration/
    Services/
      WordListServiceTests.cs       # Test data loading
```

### Testing Conventions (When Implemented)
```csharp
// Test class naming: {ClassUnderTest}Tests
public class WordleSolverTests { }

// Test method naming: {Method}_{Scenario}_{ExpectedOutcome}
[Fact]
public void FilterWords_WithCorrectLetters_ReturnsMatchingWords() { }

[Fact]
public void FilterWords_WithEmptyInput_ReturnsAllWords() { }
```

## Git Commit Conventions

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Adding tests
- `chore`: Build process, dependencies, tooling

### Examples
```bash
# ✅ Good commits
feat(solver): add letter frequency scoring algorithm
fix(ui): correct dark mode toggle persistence
docs(architecture): add system design diagrams
refactor(service): extract data loading into separate methods

# ❌ Avoid
update stuff
fixes
WIP
minor changes
```

## Dependencies

### Adding New NuGet Packages
1. Prefer well-maintained, popular packages
2. Check license compatibility (MIT, Apache 2.0 preferred)
3. Evaluate bundle size impact (critical for Blazor WASM)
4. Document reason in DECISIONS.md

### Current Philosophy
- **Minimal dependencies**: Rely on .NET BCL when possible
- **Bootstrap via CDN**: Reduces bundle size
- **No state management library**: Component state is sufficient

## Performance Guidelines

### Blazor-Specific
```csharp
// ✅ Use @key to prevent unnecessary re-renders
@foreach (var word in words)
{
    <div @key="word">@word</div>
}

// ✅ Avoid excessive StateHasChanged() calls
private void OnInputChange(string value)
{
    _value = value;
    // Don't call StateHasChanged() - Blazor handles this
}

// ✅ Lazy initialization for expensive operations
private List<string>? _cachedResults;
public List<string> Results => _cachedResults ??= ComputeExpensiveResults();
```

### Algorithm Complexity
- **Target**: O(n) for filtering operations where n = word count
- **Avoid**: Nested loops over word list (O(n²))
- **Prefer**: HashSet lookups (O(1)) over List.Contains (O(n))

## AI Assistant Integration

### Code Context Markers
```csharp
// AGENT_CONTEXT: This class uses specific scoring algorithms detailed in SCORING_STRATEGIES.md
public class WordleSolver
{
    // AGENT_NOTE: Frequency data is calculated once at initialization for performance
    private void InitializeFrequencyData() { }
}
```

### Documentation References
```csharp
// For details on scoring methodology, see: SCORING_STRATEGIES.md
// For deployment architecture, see: ARCHITECTURE.md
// For troubleshooting common issues, see: TROUBLESHOOTING.md
```

## IDE Configuration

### EditorConfig (.editorconfig)
```ini
[*.cs]
indent_size = 4
indent_style = space
csharp_style_var_for_built_in_types = true
csharp_style_var_when_type_is_apparent = true

[*.razor]
indent_size = 4
indent_style = space

[*.{js,json}]
indent_size = 2
indent_style = space
```

### Recommended VS Code Extensions
- C# Dev Kit
- GitHub Copilot
- Blazor WASM Debugging
- EditorConfig for VS Code
