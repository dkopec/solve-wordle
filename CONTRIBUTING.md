# Contributing to Wordle Solver

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Table of Contents
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Commit Message Convention](#commit-message-convention)
- [Branching Strategy](#branching-strategy)
- [Pull Request Process](#pull-request-process)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Release Process](#release-process)

---

## Getting Started

### Prerequisites
- [.NET 9.0 SDK](https://dotnet.microsoft.com/download)
- [Git](https://git-scm.com/)
- Code editor (VS Code recommended with C# Dev Kit extension)
- Modern web browser for testing

### Fork and Clone
```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/solve-wordle.git
cd solve-wordle

# Add upstream remote
git remote add upstream https://github.com/dkop/solve-wordle.git
```

---

## Development Setup

### Build and Run Locally
```bash
# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Run the application
dotnet run

# Or use VS Code task: Press F5 or run "run" task
```

The application will be available at `https://localhost:5027` (or the port shown in terminal).

### Project Structure
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture information.

```
solve-wordle/
├── Pages/           # Blazor pages (.razor files)
├── Models/          # Business logic (WordleSolver.cs)
├── Services/        # Data services (WordListService.cs)
├── wwwroot/         # Static assets (CSS, JS, data files)
├── docs/            # Documentation
└── .github/         # GitHub Actions workflows
```

---

## Commit Message Convention

**This project uses [Conventional Commits](https://www.conventionalcommits.org/)** to automate versioning and changelog generation.

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types and Version Bumps

#### PATCH Bump (1.0.0 → 1.0.1)
Bug fixes and minor improvements:
```bash
git commit -m "fix: correct dark mode toggle persistence"
git commit -m "fix(ui): align letter input boxes properly"
git commit -m "perf: optimize word filtering algorithm"
git commit -m "docs: update installation instructions"
git commit -m "style: format code according to conventions"
```

#### MINOR Bump (1.0.0 → 1.1.0)
New features (backwards-compatible):
```bash
git commit -m "feat: add new scoring strategy for vowel distribution"
git commit -m "feat(ui): add export results to CSV"
git commit -m "feat(solver): implement trigram pattern matching"
```

#### MAJOR Bump (1.0.0 → 2.0.0)
Breaking changes:
```bash
# Method 1: Add ! after type
git commit -m "feat!: redesign API with new interface"

# Method 2: Add BREAKING CHANGE in footer
git commit -m "feat: rewrite solver algorithm

BREAKING CHANGE: WordleSolver.FilterWords() signature has changed"
```

### Common Types
- **`feat:`** - New feature
- **`fix:`** - Bug fix
- **`perf:`** - Performance improvement
- **`docs:`** - Documentation changes
- **`style:`** - Code formatting (no logic change)
- **`refactor:`** - Code restructuring (no behavior change)
- **`test:`** - Adding/updating tests
- **`chore:`** - Build process, dependencies, tooling
- **`ci:`** - CI/CD configuration changes

### Scopes (Optional)
Use scopes to specify what area is affected:
- **`ui`** - User interface changes
- **`solver`** - Word filtering/scoring logic
- **`service`** - Data services
- **`docs`** - Documentation
- **`workflow`** - GitHub Actions

### Examples
```bash
# Good commits
git commit -m "feat(solver): add position-specific frequency scoring"
git commit -m "fix: resolve race condition in word list loading"
git commit -m "docs(contributing): add commit message guidelines"
git commit -m "chore: upgrade Bootstrap to 5.3.3"

# Complete example with body
git commit -m "feat(ui): add dark mode toggle

- Implements localStorage persistence
- Uses Bootstrap 5.3 dark mode
- Adds toggle button in header
- Syncs with system preferences

Closes #42"
```

### What NOT to Do
```bash
# ❌ Avoid vague messages
git commit -m "update stuff"
git commit -m "fixes"
git commit -m "WIP"

# ❌ Avoid non-conventional format
git commit -m "Added new feature"
git commit -m "bug fix for dark mode"
git commit -m "Updated documentation"
```

---

## Branching Strategy

### Branch Naming
```bash
# Feature branches
git checkout -b feat/add-vowel-scoring
git checkout -b feat/ui-export-results

# Bug fix branches
git checkout -b fix/dark-mode-persistence
git checkout -b fix/word-list-loading

# Documentation branches
git checkout -b docs/update-architecture

# Refactoring branches
git checkout -b refactor/extract-scoring-logic
```

### Workflow
1. **Create feature branch** from `main`
2. **Make changes** with conventional commits
3. **Keep branch updated** with `main`:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
4. **Push to your fork**:
   ```bash
   git push origin feat/your-feature
   ```
5. **Open Pull Request** to `main` branch

---

## Pull Request Process

### Before Submitting
- [ ] Code follows [conventions](docs/CONVENTIONS.md)
- [ ] All commits use conventional commit format
- [ ] Code builds without errors: `dotnet build`
- [ ] Application runs correctly: `dotnet run`
- [ ] No console errors in browser DevTools
- [ ] Dark mode works properly
- [ ] Responsive design tested (mobile/desktop)
- [ ] Documentation updated if needed

### PR Title Format
Use conventional commit format for PR titles:
```
feat(solver): add trigram pattern matching
fix: resolve dark mode persistence issue
docs: update contributing guidelines
```

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that causes existing functionality to change)
- [ ] Documentation update

## How Has This Been Tested?
- [ ] Tested locally with `dotnet run`
- [ ] Tested in Chrome/Firefox/Safari
- [ ] Tested dark mode
- [ ] Tested mobile responsive design

## Checklist
- [ ] Follows conventional commit format
- [ ] Code follows project conventions
- [ ] Self-review completed
- [ ] No console errors
- [ ] Documentation updated

## Screenshots (if applicable)
[Add screenshots of UI changes]

## Related Issues
Closes #123
```

### Review Process
1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, PR will be merged to `main`
4. **Automated release workflow** will:
   - Calculate new version from commits
   - Update `CHANGELOG.md`
   - Create git tag
   - Publish GitHub release
   - Deploy to GitHub Pages

---

## Code Standards

### Follow Existing Conventions
Read [docs/CONVENTIONS.md](docs/CONVENTIONS.md) for detailed coding standards.

### Quick Reference

#### C# Naming
```csharp
// Classes: PascalCase
public class WordleSolver { }

// Methods: PascalCase
public void FilterWords() { }

// Private fields: _camelCase
private readonly HttpClient _httpClient;

// Properties: PascalCase
public string Word { get; set; }

// Local variables: camelCase
var filteredWords = new List<string>();
```

#### Razor Components
```csharp
// Parameters: PascalCase
[Parameter] public string Title { get; set; }

// Component fields: camelCase
private bool isDarkMode = false;

// Event handlers: On{Event}{Description}
private void OnDarkModeToggle() { }
```

#### File Naming
- **Razor Components**: PascalCase.razor
- **C# Classes**: PascalCase.cs
- **CSS/JS**: kebab-case
- **Data Files**: kebab-case.txt

### Code Comments
```csharp
// ✅ Good - explains WHY
// HttpClient required because Blazor WASM cannot access file system
private readonly HttpClient _httpClient;

// ✅ Good - documents complex logic
// Using exponential scoring to heavily favor top suggestion
var score = Math.Pow(baseScore, 0.4);

// ❌ Avoid - obvious "what" comments
// Increment counter
count++;
```

---

## Testing

### Manual Testing Checklist
Since this project currently uses manual testing:

#### Core Functionality
- [ ] Enter correct letters (green) - filters correctly
- [ ] Enter wrong position letters (yellow) - filters correctly
- [ ] Enter excluded letters (gray) - filters correctly
- [ ] Combined constraints work together
- [ ] Suggestions appear and are ranked
- [ ] Word count updates correctly

#### UI/UX
- [ ] Auto-focus advances between inputs
- [ ] Dark mode toggle works
- [ ] Dark mode persists on reload
- [ ] Layout responsive on mobile
- [ ] No visual glitches or alignment issues
- [ ] Bootstrap styling consistent

#### Browser Compatibility
Test in at least 2 browsers:
- [ ] Chrome/Edge (Chromium)
- [ ] Firefox
- [ ] Safari (if on Mac)

### Future: Unit Tests
We welcome contributions to add unit testing! See [docs/CONVENTIONS.md#testing-strategy](docs/CONVENTIONS.md#testing-strategy).

---

## Release Process

### Automated Releases
**Releases happen automatically** when changes are merged to `main`:

1. **Developer** creates PR with conventional commits
2. **Maintainer** reviews and merges to `main`
3. **Auto-release workflow** (`.github/workflows/auto-release.yml`):
   - Analyzes commit messages since last release
   - Calculates semantic version (patch/minor/major)
   - Updates `solve-wordle.csproj` version
   - Updates `CHANGELOG.md`
   - Creates git tag (e.g., `v1.2.0`)
   - Publishes GitHub Release
4. **Release workflow** (`.github/workflows/release.yml`):
   - Triggers on new tag
   - Builds and deploys to GitHub Pages
   - Creates release artifacts

### Manual Release (Maintainers Only)
If needed, manually trigger release:
1. Go to GitHub Actions → **Auto Release**
2. Click **Run workflow**
3. Select `main` branch
4. Click **Run workflow**

### Version Strategy
- **PATCH** (1.0.x): Bug fixes, performance tweaks, docs
- **MINOR** (1.x.0): New features, UI improvements
- **MAJOR** (x.0.0): Breaking changes, major redesigns

---

## Documentation Updates

### When to Update Docs
- **New features** → Update [README.md](README.md) and relevant docs
- **Architecture changes** → Update [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Code conventions** → Update [docs/CONVENTIONS.md](docs/CONVENTIONS.md)
- **Technical decisions** → Add to [docs/DECISIONS.md](docs/DECISIONS.md)
- **Troubleshooting** → Add to [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

### Documentation Standards
- Keep docs in sync with code
- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Link between related docs

---

## Getting Help

### Resources
- [README.md](README.md) - Project overview and quick start
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - System design
- [docs/CONVENTIONS.md](docs/CONVENTIONS.md) - Coding standards
- [docs/DECISIONS.md](docs/DECISIONS.md) - Architectural decisions
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues

### Ask Questions
- **GitHub Issues** - For bugs and feature requests
- **GitHub Discussions** - For questions and ideas
- **Pull Requests** - For code reviews and feedback

### Code of Conduct
- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow project conventions
- Credit others' contributions

---

## Example Contribution Workflow

### Complete Example: Adding a New Feature
```bash
# 1. Sync with upstream
git checkout main
git fetch upstream
git rebase upstream/main

# 2. Create feature branch
git checkout -b feat/add-export-button

# 3. Make changes and commit (conventional format)
# ... edit files ...
git add Pages/Index.razor
git commit -m "feat(ui): add export results to CSV button

- Adds export button in results section
- Generates CSV with word list
- Uses JavaScript download trigger
- Styled with Bootstrap button classes"

# 4. Push to your fork
git push origin feat/add-export-button

# 5. Open PR on GitHub
# - Use title: "feat(ui): add export results to CSV button"
# - Fill out PR template
# - Wait for review

# 6. After merge:
# - Auto-release workflow runs
# - Version bumps to 1.1.0 (new feature = minor bump)
# - Tag v1.1.0 created
# - Release published
# - Deployed to GitHub Pages
```

---

## Questions?

If you have questions about contributing, please:
1. Check existing [documentation](docs/)
2. Search [closed issues](https://github.com/dkop/solve-wordle/issues?q=is%3Aissue+is%3Aclosed)
3. Open a [new issue](https://github.com/dkop/solve-wordle/issues/new) or discussion

Thank you for contributing! 🎉
