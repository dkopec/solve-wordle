# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation for AI-assisted development workflow
  - docs/ARCHITECTURE.md - System design and data flow documentation
  - docs/CONVENTIONS.md - Coding standards and naming conventions
  - docs/DECISIONS.md - Architectural decision records (ADR)
  - docs/TROUBLESHOOTING.md - Common issues and solutions
  - CHANGELOG.md - Version history tracking

## [1.0.0] - 2025-12-18

### Added
- Initial release of Wordle Solver Blazor WebAssembly application
- Dark mode toggle with persistent preference in localStorage
- Side-by-side layout with sticky input column
- Multiple input methods:
  - Visual 5x6 grid for correct position letters (green)
  - Dynamic rows for wrong position letters (yellow)
  - Dynamic rows for excluded letters (gray)
- Auto-focus advancement in letter grids using JavaScript interop
- Smart word suggestions with multiple scoring strategies:
  - Letter frequency analysis
  - Position-specific frequency
  - Vowel distribution scoring
  - Common word prioritization
  - Past Wordle answer weighting
- Three word list datasets:
  - Complete word list (~13,000 words)
  - Common English words (~3,000 words)
  - Historical Wordle answers (~2,800 words)
- GitHub Pages deployment via GitHub Actions
- Responsive UI with Bootstrap 5.3.3
- Bootstrap Icons integration

### Documentation
- README.md with features and usage instructions
- docs/QUICKSTART.md for rapid Azure deployment
- docs/SCORING_STRATEGIES.md detailing suggestion algorithms
- docs/BLAZOR_DEPLOYMENT.md for deployment options
- docs/CONVERSION_SUMMARY.md documenting migration history
- .github/copilot-instructions.md for AI assistant context

### Technical
- Built on .NET 9.0 and Blazor WebAssembly
- Client-side word filtering with efficient algorithms (O(n) complexity)
- HttpClient-based data loading for browser compatibility
- Singleton WordListService for data caching
- Frequency analysis pre-computation for fast suggestions
- Zero backend dependencies - pure static site

---

## Version History

### Versioning Scheme
This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible changes
- **MINOR** version for new features (backwards compatible)
- **PATCH** version for bug fixes

### Unreleased Changes
Changes in `main` branch not yet released will be listed in the `[Unreleased]` section above.

### Release Process
1. Update CHANGELOG.md with new version section
2. Update version in solve-wordle.csproj
3. Commit changes: `git commit -m "chore: release v1.1.0"`
4. Create git tag: `git tag -a v1.1.0 -m "Release v1.1.0"`
5. Push changes: `git push origin main --tags`
6. GitHub Actions will automatically deploy to GitHub Pages

---

## Future Roadmap

### Planned Features
- [ ] IndexedDB caching for faster subsequent loads
- [ ] Progressive Web App (PWA) support for offline use
- [ ] Multiple language support (Spanish, French, etc.)
- [ ] Word definition lookup integration
- [ ] Export/import puzzle state
- [ ] Statistics tracking (games solved, average guesses)
- [ ] Hard mode support (must use revealed clues)
- [ ] Guess simulator to test strategies
- [ ] Mobile app packaging (iOS/Android)

### Under Consideration
- Unit test suite for core algorithms
- Integration tests for data loading
- Automated screenshot testing
- Performance benchmarking
- Accessibility (WCAG 2.1 AA compliance)
- Internationalization (i18n) framework

---

## Maintenance Notes

### Breaking Changes
This section will document breaking changes that require user action:

**None yet** - Version 1.0.0 is the initial release

### Deprecations
Features or APIs that will be removed in future versions:

**None yet**

### Security Updates
Security-related fixes will be called out specifically:

**None yet** - No known vulnerabilities

---

## Contributing

If you'd like to contribute to this project:
1. Check the [Unreleased] section for in-progress work
2. Review CONVENTIONS.md for coding standards
3. Review DECISIONS.md for architectural context
4. Submit PRs against the `main` branch
5. Update this CHANGELOG.md in your PR

---

## Links
- [GitHub Repository](https://github.com/dkopec/solve-wordle)
- [Live Demo](https://dkopec.github.io/solve-wordle/)
- [Report Issues](https://github.com/dkopec/solve-wordle/issues)
