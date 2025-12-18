# Documentation Index

This folder contains detailed technical documentation for the Wordle Solver project.

## Documentation Structure

### Root-Level Documentation (Quick Access)
These essential files remain in the project root for maximum visibility:

- **[../README.md](../README.md)** - Project overview, features, and getting started guide
- **[../CHANGELOG.md](../CHANGELOG.md)** - Version history and release notes
- **[../.github/copilot-instructions.md](../.github/copilot-instructions.md)** - AI assistant context and guidelines
- **[../.ai/prompts.md](../.ai/prompts.md)** - Saved prompts and workflows for AI-assisted development

### Technical Documentation (docs/)
Detailed technical documentation organized in this folder:

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design, data flow, and technical architecture
- **[CONVENTIONS.md](CONVENTIONS.md)** - Coding standards, naming conventions, and style guide
- **[DECISIONS.md](DECISIONS.md)** - Architectural Decision Records (ADR log)
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[SCORING_STRATEGIES.md](SCORING_STRATEGIES.md)** - Word scoring algorithms explained
- **[BLAZOR_DEPLOYMENT.md](BLAZOR_DEPLOYMENT.md)** - Deployment options and configurations
- **[QUICKSTART.md](QUICKSTART.md)** - Rapid deployment guide for Azure
- **[CONVERSION_SUMMARY.md](CONVERSION_SUMMARY.md)** - Project migration history

## Documentation Purpose

### For New Developers
Start with these in order:
1. [../README.md](../README.md) - Understand what the project does
2. [QUICKSTART.md](QUICKSTART.md) - Get it running locally (or deploy to Azure)
3. [ARCHITECTURE.md](ARCHITECTURE.md) - Learn how it's built
4. [CONVENTIONS.md](CONVENTIONS.md) - Learn coding standards

### For AI Assistants
The AI should prioritize:
1. [../.github/copilot-instructions.md](../.github/copilot-instructions.md) - Project context
2. [ARCHITECTURE.md](ARCHITECTURE.md) - System design
3. [CONVENTIONS.md](CONVENTIONS.md) - Code standards
4. [DECISIONS.md](DECISIONS.md) - Why things are built this way

### For Contributors
Check these before making changes:
1. [CONVENTIONS.md](CONVENTIONS.md) - Follow coding standards
2. [DECISIONS.md](DECISIONS.md) - Understand past decisions
3. [../CHANGELOG.md](../CHANGELOG.md) - See recent changes
4. [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common pitfalls

### For Users
User-facing documentation:
1. [../README.md](../README.md) - How to use the application
2. [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Fix common problems

## Documentation Guidelines

### When to Add New Documentation

Create a new document when:
- Starting a new major feature area
- Documenting complex algorithms (like SCORING_STRATEGIES.md)
- Explaining deployment options (like BLAZOR_DEPLOYMENT.md)
- Recording migration or conversion processes

### Where to Put Documentation

**Root directory** for:
- High-visibility, frequently accessed docs (README.md)
- Version tracking (CHANGELOG.md)
- AI assistant context (.github/copilot-instructions.md)
- IDE configuration (.editorconfig)

**docs/ folder** for:
- Technical deep-dives (ARCHITECTURE.md, CONVENTIONS.md)
- Architectural decision records (DECISIONS.md)
- Troubleshooting guides (TROUBLESHOOTING.md)
- Deployment guides (BLAZOR_DEPLOYMENT.md, QUICKSTART.md)
- Algorithm documentation (SCORING_STRATEGIES.md)
- Historical documentation (CONVERSION_SUMMARY.md)

**Inline code comments** for:
- Complex algorithm explanations
- Non-obvious design decisions
- Performance-critical sections
- AI context markers (AGENT_CONTEXT, TODO(agent))

### Documentation Maintenance

Keep documentation current:
- Update ../CHANGELOG.md with every release
- Update ARCHITECTURE.md when making structural changes
- Add to DECISIONS.md when making significant technical choices
- Update TROUBLESHOOTING.md when solving new issues
- Keep ../README.md in sync with actual features

### Documentation Style

Follow these principles:
- **Clear and concise** - Get to the point quickly
- **Well-organized** - Use headings, lists, and tables
- **Code examples** - Show, don't just tell
- **Cross-references** - Link to related documentation
- **Keep it current** - Outdated docs are worse than no docs

## Future Documentation

Planned additions:
- [ ] API reference (if public API develops)
- [ ] Performance benchmarking results
- [ ] User guide with screenshots
- [ ] Video tutorials
- [ ] Contributing guidelines (CONTRIBUTING.md)
- [ ] Security policy (SECURITY.md)

## Documentation Tools

Current tooling:
- **Markdown** - All documentation is in Markdown format
- **GitHub** - Uses GitHub's Markdown rendering
- **No build step** - Documentation is readable as-is

Potential additions:
- Documentation site generator (MkDocs, Docusaurus)
- API documentation generator (DocFX for C#)
- Diagram tools (Mermaid, PlantUML)
- Screenshot management

## Need Help?

If you can't find what you're looking for:
1. Check the [README](../README.md) for overview
2. Search in [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
3. Review [ARCHITECTURE.md](../ARCHITECTURE.md) for design details
4. Check [DECISIONS.md](../DECISIONS.md) for rationale
5. Use GitHub's search to find specific code or docs
6. Open an issue if documentation is missing or unclear
