# Architecture Overview

## System Design

This is a **client-side only** Blazor WebAssembly application that runs entirely in the browser. No server-side processing occurs after initial load.

```
┌─────────────────────────────────────────────────────────────┐
│                        Browser                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Blazor WebAssembly App                   │  │
│  │                                                       │  │
│  │  ┌─────────────┐    ┌──────────────┐    ┌─────────┐ │  │
│  │  │   Index     │───▶│ WordListSvc  │───▶│  HTTP   │ │  │
│  │  │   .razor    │    │              │    │ Client  │ │  │
│  │  └─────────────┘    └──────────────┘    └────┬────┘ │  │
│  │         │                   │                  │      │  │
│  │         ▼                   ▼                  ▼      │  │
│  │  ┌─────────────┐    ┌──────────────┐    ┌─────────┐ │  │
│  │  │     JS      │    │   Wordle     │    │  wwwroot│ │  │
│  │  │   Interop   │    │   Solver     │    │  /data/ │ │  │
│  │  │  (Focus)    │    │   (Model)    │    │ *.txt   │ │  │
│  │  └─────────────┘    └──────────────┘    └─────────┘ │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Application Initialization
```
User loads page
    ↓
Index.razor OnInitializedAsync()
    ↓
WordListService.InitializeAsync()
    ↓
HttpClient fetches 3 text files from wwwroot/data/
    ├─ words.txt (complete word list ~13,000 words)
    ├─ common-words.txt (~3,000 common words)
    └─ past-answers.txt (~2,800 actual Wordle answers)
    ↓
Parse into List<string> and HashSet<string>
    ↓
Create WordleSolver instance with data
    ↓
Initialize frequency analysis (O(n) one-time cost)
```

### 2. User Input Processing
```
User types in input field
    ↓
@oninput event in Index.razor
    ↓
Update local state (correctLetters[], wrongPositionRows[][], etc.)
    ↓
JS Interop: Auto-advance focus to next input
    ↓
Trigger FilterWords() method
    ↓
WordleSolver.FilterWords() algorithm runs
    ↓
Update UI with results (matching words, suggestions)
```

### 3. Word Filtering Algorithm
```
Input: User constraints (green, yellow, gray letters)
    ↓
Step 1: Filter by correct positions (green letters)
    ↓
Step 2: Filter by required letters (yellow letters exist)
    ↓
Step 3: Exclude wrong positions (yellow letters not in those spots)
    ↓
Step 4: Exclude gray letters (not in word at all)
    ↓
Step 5: Apply duplicate letter logic
    ↓
Output: Filtered word list
    ↓
Calculate suggestions with scoring algorithm
```

## Key Components

### Frontend Layer (Blazor Components)

#### Index.razor
- **Purpose**: Main UI component, handles all user interaction
- **Responsibilities**:
  - Input field management (5 correct + dynamic yellow/gray rows)
  - Dark mode toggle with localStorage persistence
  - Word filtering orchestration
  - Result display (matching words, suggestions, statistics)
- **State Management**: Component-level state (no state management library needed)
- **Performance**: Minimal re-renders via `@key` directives and manual StateHasChanged()

#### MainLayout.razor
- **Purpose**: App shell and global layout
- **Responsibilities**: Dark mode theme application, Bootstrap container

### Service Layer

#### WordListService
- **Purpose**: Data loading and caching
- **Why HttpClient?**: Blazor WASM runs in browser sandbox - cannot access file system
- **Singleton Lifetime**: Registered as singleton in Program.cs to cache data
- **Initialization**: Lazy - only loads on first access
- **Error Handling**: Falls back to empty lists if files fail to load

### Domain Logic Layer

#### WordleSolver
- **Purpose**: Core filtering and scoring algorithms
- **Algorithm Complexity**:
  - Filtering: O(n) where n = number of words (~13,000)
  - Scoring: O(n) for each scoring method
  - One-time initialization: O(n) for frequency analysis
- **Design Pattern**: Strategy pattern for multiple scoring methods

**Scoring Strategies** (see [SCORING_STRATEGIES.md](SCORING_STRATEGIES.md)):
1. Letter frequency analysis
2. Position-specific frequency
3. Vowel distribution scoring
4. Common word prioritization
5. Past answer weighting

### JavaScript Interop

#### site.js
- **Purpose**: Auto-advance focus between inputs
- **Why JS?**: DOM focus manipulation is more reliable with native JS
- **Functions**:
  - `focusNextInput(currentId)`: Advances to next input in sequence
  - `focusPreviousInput(currentId)`: Backspace navigation
- **Error Handling**: Silent fallback if elements not found

## Data Storage

### Static Text Files (wwwroot/data/)
- **Format**: Plain text, one word per line
- **Encoding**: UTF-8
- **Size**: ~500 KB total (minimal load time)
- **Update Strategy**: Manual updates via data file replacement

### Browser Storage
- **localStorage**: Dark mode preference only
- **Key**: `darkMode` (boolean as string)
- **No sensitive data**: All processing is client-side

## Deployment Architecture

### GitHub Pages (Static Hosting)
```
GitHub Repository
    ↓
GitHub Actions Workflow (.github/workflows/deploy.yml)
    ↓
dotnet publish -c Release
    ↓
Blazor WebAssembly build artifacts
    ↓
GitHub Pages serves static files
    ↓
User browser downloads and runs WASM
```

### Build Output
- **index.html**: Entry point
- **dotnet.wasm**: .NET runtime compiled to WebAssembly
- **_framework/**: Compiled C# assemblies (DLLs as .dll.gz)
- **wwwroot/**: Static assets (CSS, JS, data files)

## Performance Considerations

### Optimization Strategies
1. **Frequency Data Caching**: Calculate once on initialization, reuse for all queries
2. **HashSet Lookups**: O(1) lookups for common words and past answers
3. **Early Exit Filtering**: Short-circuit on impossible conditions
4. **Minimal Re-renders**: Blazor component state carefully managed
5. **Asset Compression**: Gzip/Brotli compression via Blazor build

### Performance Characteristics
- **Initial Load**: ~2-3 seconds (WASM download + data files)
- **Filter Operation**: <10ms for typical query
- **Memory Usage**: ~50MB (WASM runtime + data)
- **Target**: Runs on any modern browser (2018+)

## Security

### Attack Surface
- **Minimal**: No server, no authentication, no user data storage
- **XSS**: Blazor handles escaping automatically
- **CORS**: Not applicable (same-origin static files)

### Privacy
- **No tracking**: No analytics, no cookies (except dark mode in localStorage)
- **No backend**: No server logs, no user data collection

## Technology Decisions

### Why Blazor WebAssembly?
- ✅ Full C# on client (leverage existing .NET skills)
- ✅ Rich component model with Razor syntax
- ✅ No backend needed (perfect for GitHub Pages)
- ✅ Strong typing throughout stack
- ❌ Larger initial download than plain JS (~2MB WASM runtime)

### Why Not...?
- **React/Vue**: Team prefers C# over JavaScript
- **Server-side Blazor**: Wanted zero hosting costs
- **Console app**: Needed user-friendly web interface

### Why Bootstrap?
- Built-in dark mode support (Bootstrap 5.3+)
- Battle-tested responsive grid system
- Reduces custom CSS requirements
- Larger than Tailwind but faster to implement

## Future Scalability

### Potential Enhancements
1. **IndexedDB**: Store word lists locally (faster subsequent loads)
2. **Web Workers**: Offload filtering to background thread
3. **Progressive Web App**: Add manifest for installability
4. **Dictionary API**: Show word definitions
5. **Analytics**: Optional telemetry with user consent

### Known Limitations
- Cannot add custom words without rebuilding (design choice)
- English only (could support other languages via additional data files)
- No account system (intentionally stateless)
