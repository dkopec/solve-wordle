# Architectural Decision Records (ADR)

This document tracks significant architectural and technical decisions made during the project's development.

## Format
Each decision follows this structure:
- **Date**: When the decision was made
- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Context**: The situation and problem
- **Decision**: What was decided
- **Consequences**: Positive and negative outcomes

---

## ADR-001: Use Blazor WebAssembly Instead of Server-Side Blazor

**Date**: 2025-11-20 (Initial project setup)  
**Status**: Accepted

### Context
Needed to build a Wordle solver with a web interface. Two main Blazor hosting models available:
1. Blazor Server (requires backend server, SignalR connection)
2. Blazor WebAssembly (runs entirely in browser)

### Decision
Use Blazor WebAssembly.

### Consequences
**Positive:**
- ✅ Zero hosting costs - can use GitHub Pages
- ✅ No server required - pure static files
- ✅ Works offline after initial load
- ✅ All computation client-side (privacy-friendly)
- ✅ Scalable to unlimited users (CDN)

**Negative:**
- ❌ Larger initial download (~2MB WASM runtime)
- ❌ ~2-3 second initial load time
- ❌ Limited to browser capabilities
- ❌ All code visible in browser (not a concern for this project)

---

## ADR-002: Use HttpClient for Data Loading Instead of File System

**Date**: 2025-11-20 (Initial implementation)  
**Status**: Accepted

### Context
Blazor WebAssembly runs in browser sandbox and cannot access local file system. Need to load word lists (words.txt, common-words.txt, past-answers.txt).

### Decision
Load data files via HttpClient from wwwroot/ directory as static assets.

### Consequences
**Positive:**
- ✅ Only option that works in browser
- ✅ Files served with HTTP caching headers
- ✅ Can use CDN for faster delivery
- ✅ Simple implementation

**Negative:**
- ❌ Requires HTTP request (async loading)
- ❌ Cannot dynamically update word lists without rebuild
- ❌ Slightly slower than in-memory initialization

**Alternative Considered:**
- Embed word lists as embedded resources in assembly → Would increase DLL size and prevent easy updates

---

## ADR-003: Use Bootstrap 5.3+ for UI Framework

**Date**: 2025-11-20 (Initial UI implementation)  
**Status**: Accepted

### Context
Needed a CSS framework for responsive layout and dark mode support. Options considered:
1. Bootstrap 5.3+
2. Tailwind CSS
3. Custom CSS only
4. Material Design (MudBlazor)

### Decision
Use Bootstrap 5.3.3 with built-in dark mode support.

### Consequences
**Positive:**
- ✅ Built-in dark mode (`data-bs-theme="dark"`)
- ✅ Battle-tested responsive grid system
- ✅ Familiar to most developers
- ✅ Fast implementation - minimal custom CSS
- ✅ Bootstrap Icons for iconography

**Negative:**
- ❌ Larger bundle size than Tailwind (~200KB CSS)
- ❌ Less customizable than utility-first frameworks
- ❌ "Bootstrap look" is recognizable

**Alternative Considered:**
- Tailwind CSS → Requires more custom work for dark mode
- MudBlazor → Adds extra .NET dependencies and complexity

---

## ADR-004: Store Dark Mode Preference in localStorage

**Date**: 2025-12-16 (Dark mode implementation)  
**Status**: Accepted

### Context
Users want dark mode preference to persist across sessions. Options:
1. localStorage
2. Cookies
3. User account preferences (requires backend)
4. Don't persist (resets on page load)

### Decision
Use browser localStorage with key `darkMode`.

### Consequences
**Positive:**
- ✅ Simple implementation
- ✅ No backend required
- ✅ Persists across sessions
- ✅ No cookies (privacy-friendly)
- ✅ Accessible via JavaScript

**Negative:**
- ❌ Per-browser, not per-user
- ❌ Cleared if user clears browser data
- ❌ Requires JavaScript interop

---

## ADR-005: Use Plain Text Files Instead of JSON for Word Lists

**Date**: 2025-11-20 (Data structure design)  
**Status**: Accepted

### Context
Need to store ~13,000 words. Format options:
1. Plain text (one word per line)
2. JSON array
3. CSV
4. Binary format

### Decision
Use plain text with one word per line.

### Consequences
**Positive:**
- ✅ Simplest format - easy to edit manually
- ✅ Smallest file size (~130KB vs ~180KB for JSON)
- ✅ Easy to parse (`Split('\n')`)
- ✅ Git-friendly (clear diffs)
- ✅ Human-readable

**Negative:**
- ❌ No metadata support (frequency, definitions, etc.)
- ❌ Requires parsing on each load

**Future Enhancement:**
Could switch to JSON if we need to add metadata (word frequency, difficulty ratings, etc.)

---

## ADR-006: Use Component-Level State Instead of State Management Library

**Date**: 2025-11-20 (State management decision)  
**Status**: Accepted

### Context
Application needs to track user input (correct letters, wrong positions, etc.). Options:
1. Component-level state (fields in Index.razor)
2. State management library (Fluxor, Blazor.State)
3. Service-based state
4. Redux-style pattern

### Decision
Use component-level state with simple fields.

### Consequences
**Positive:**
- ✅ Simple - no additional dependencies
- ✅ Easy to understand and maintain
- ✅ Sufficient for single-page app
- ✅ Fast - no overhead

**Negative:**
- ❌ State doesn't persist across page refreshes
- ❌ No time-travel debugging
- ❌ Harder to share state across components (not needed here)

**Rationale:**
This is a single-page app with simple state. Adding a state management library would be over-engineering.

---

## ADR-007: Use JavaScript Interop for Input Auto-Focus

**Date**: N/A (Input UX enhancement - need to verify from git history)  
**Status**: Accepted

### Context
Want to automatically advance focus to next input as user types in letter grids. Options:
1. JavaScript interop with native DOM focus()
2. Blazor @ref and FocusAsync()
3. No auto-focus (manual tab navigation)

### Decision
Use JavaScript interop with custom `focusNextInput()` function.

### Consequences
**Positive:**
- ✅ More reliable cross-browser behavior
- ✅ Immediate focus change (no async delay)
- ✅ Fine control over focus logic
- ✅ Can handle complex navigation (backspace, arrow keys)

**Negative:**
- ❌ Requires JavaScript file (site.js)
- ❌ Less "pure Blazor"
- ❌ Must maintain element ID naming convention

**Alternative Tried:**
- Blazor's ElementReference.FocusAsync() → Had timing issues and felt sluggish

---

## ADR-008: Deploy to GitHub Pages Instead of Azure

**Date**: 2025-12-16 (Deployment strategy)  
**Status**: Accepted

### Context
Need to host the Blazor WASM app. Options:
1. GitHub Pages (free static hosting)
2. Azure Static Web Apps
3. Azure App Service
4. Netlify/Vercel

### Decision
Deploy to GitHub Pages via GitHub Actions.

### Consequences
**Positive:**
- ✅ Completely free
- ✅ Automatic SSL/HTTPS
- ✅ Integrated with GitHub repository
- ✅ Simple CI/CD with GitHub Actions
- ✅ No account/credit card needed

**Negative:**
- ❌ Public repositories only (for free)
- ❌ No custom backend (not needed)
- ❌ Limited to static content

**Note:**
Azure setup scripts (setup-azure.ps1) are preserved for users who want to deploy to Azure instead.

---

## ADR-009: Calculate Frequency Data Once at Initialization

**Date**: 2025-11-20 (Performance optimization)  
**Status**: Accepted

### Context
Word scoring requires letter frequency, position frequency, and pattern analysis. Options:
1. Calculate on every filter operation
2. Calculate once at initialization
3. Pre-compute and embed in data files
4. Lazy calculation on first use

### Decision
Calculate all frequency data once during WordleSolver initialization.

### Consequences
**Positive:**
- ✅ O(n) one-time cost instead of repeated calculation
- ✅ Fast filtering (<10ms per query)
- ✅ Cached data reused for all suggestions
- ✅ No external dependencies

**Negative:**
- ❌ Slight delay on first app load (~100-200ms)
- ❌ Memory overhead (~5-10MB for frequency maps)
- ❌ Must recalculate if word list changes

**Alternative Considered:**
- Pre-compute and save as JSON → Would complicate word list updates and add file size

---

## ADR-010: Prioritize Past Wordle Answers in Scoring

**Date**: 2025-11-20 (Scoring refinement)  
**Status**: Accepted

### Context
Need to rank suggested words by likelihood. Past Wordle answers are proven to be good 5-letter words used by NYT. Options:
1. Treat all words equally
2. Boost past answers slightly
3. Show past answers in separate list
4. Use past answers exclusively

### Decision
Give past answers highest weight (1000.0) in commonality score, well above other words.

### Consequences
**Positive:**
- ✅ Suggests words more likely to be actual answers
- ✅ Faster puzzle solving
- ✅ Learns from NYT's word selection patterns
- ✅ Reduces obscure word suggestions

**Negative:**
- ❌ May miss valid but never-used words
- ❌ Biases toward historical answers
- ❌ Assumes NYT won't repeat words (they won't)

**Rationale:**
Past answers are the gold standard - these are words NYT considers "fair" and common enough for puzzles.

---

## ADR-011: Support Multiple Scoring Strategies

**Date**: N/A (Feature enhancement - need to verify from git history)  
**Status**: Accepted

### Context
Different strategies work better at different stages of the puzzle. Options:
1. Single fixed scoring algorithm
2. Multiple strategies user can choose
3. Automatic strategy selection
4. Hybrid combined score

### Decision
Implement multiple scoring strategies (see SCORING_STRATEGIES.md) with user selection.

### Consequences
**Positive:**
- ✅ Flexibility for different solving styles
- ✅ Better suggestions at different puzzle stages
- ✅ Educational - shows different approaches
- ✅ Can test and compare strategies

**Negative:**
- ❌ More complex codebase
- ❌ Increased maintenance
- ❌ Requires UI for strategy selection
- ❌ May confuse beginners

---

## ADR-012: Automate Word List Updates via GitHub Actions

**Date**: 2025-12-19 (Automated data maintenance)  
**Status**: Accepted

### Context
Word lists need periodic updates as new Wordle answers are published daily. Options:
1. Manual updates (edit files, commit, push)
2. GitHub Actions scheduled workflow
3. Azure Functions with timer trigger
4. External service polling and updating

### Decision
Use GitHub Actions with weekly scheduled workflow to automatically fetch and update word lists.

### Consequences
**Positive:**
- ✅ Zero manual maintenance required
- ✅ Free within GitHub Actions limits
- ✅ Integrated with existing CI/CD pipeline
- ✅ Automatic deployment after updates
- ✅ Version controlled updates with clear history
- ✅ Can be triggered manually on demand
- ✅ Cross-platform (Python) and Windows (PowerShell) scripts

**Negative:**
- ❌ Depends on NYTimes data source availability
- ❌ Weekly schedule may miss immediate updates
- ❌ Requires maintaining scraper/fetcher scripts
- ❌ GitHub Actions usage (minimal - ~4 min/month)

**Implementation:**
- Workflow: `.github/workflows/update-word-lists.yml`
- Python script: `Scripts/update-word-lists.py` (cross-platform)
- PowerShell script: `Scripts/update-word-lists.ps1` (Windows)
- Schedule: Every Monday at 2:00 AM UTC
- Manual trigger: Available via workflow_dispatch

**Data Sources:**
1. NYTimes Wordle JSON endpoint (primary)
2. Wordle JavaScript bundle (fallback)
3. Scrabble dictionary (comprehensive words)
4. Existing files (last resort)

**See Also:**
- [docs/AUTO_UPDATE.md](AUTO_UPDATE.md) - Complete documentation

---

## Deprecated Decisions

### ADR-XXX: [None yet]

When a decision is superseded or deprecated, it will be moved to this section with explanation.

---

## Decision Process

### When to Create an ADR
Create an ADR when making decisions about:
- Architecture patterns
- Technology choices
- External dependencies
- Data structures
- Performance trade-offs
- Security approaches

### When NOT to Create an ADR
Don't create ADRs for:
- Minor bug fixes
- UI styling changes
- Variable naming
- Code formatting

### Review Process
1. Propose decision with "Status: Proposed"
2. Review with team (if applicable) or think through consequences
3. Update to "Status: Accepted" when finalized
4. Mark as "Deprecated" or "Superseded" if later changed
