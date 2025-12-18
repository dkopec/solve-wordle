# Saved AI Prompts

This directory contains useful prompts and workflows for AI-assisted development.

## Common Development Tasks

### Add New Feature
```
I need to add [feature description]. 

Context:
- Files involved: [list files]
- Dependencies: [list dependencies]
- User story: As a [user type], I want to [action] so that [benefit]

Please:
1. Review the current implementation in [relevant files]
2. Suggest the best approach following our conventions (see CONVENTIONS.md)
3. Implement the changes with appropriate error handling
4. Update any related documentation
```

### Debug an Issue
```
I'm experiencing [problem description].

Symptoms:
- [What's happening]
- [Error messages if any]
- [When it occurs]

Expected behavior:
- [What should happen]

Relevant code:
- [File and line numbers]

Please check TROUBLESHOOTING.md first, then help me debug this issue.
```

### Refactor Code
```
I want to refactor [component/service/method] to improve [performance/maintainability/readability].

Current implementation: [file path]
Concerns:
- [List issues]

Please:
1. Review the current implementation
2. Suggest refactoring approach following SOLID principles
3. Implement changes while maintaining backward compatibility
4. Add appropriate tests if needed
```

### Add Documentation
```
Please document [feature/component/algorithm].

Include:
- Purpose and use cases
- API/interface documentation
- Examples
- Edge cases and limitations

Follow the style in existing docs (see CONVENTIONS.md).
```

## Project-Specific Prompts

### Understanding the Codebase
```
I need to understand how [specific feature] works.

Please:
1. Explain the data flow from [starting point] to [end point]
2. Show me the relevant code sections
3. Explain any complex algorithms or patterns used
4. Point out any gotchas or edge cases I should know about

Reference ARCHITECTURE.md for system context.
```

### Implement New Scoring Strategy
```
I want to add a new word scoring strategy that [description of strategy].

Current scoring strategies are documented in SCORING_STRATEGIES.md.

Please:
1. Review existing scoring implementations in WordleSolver.cs
2. Design the new algorithm
3. Implement it following the same pattern as existing strategies
4. Add it to the scoring strategy dropdown
5. Document it in SCORING_STRATEGIES.md
```

### Optimize Performance
```
The [operation] is slow when [conditions].

Current performance: [timing/measurements]
Expected performance: [target]

Files involved: [list]

Please:
1. Profile the current implementation
2. Identify bottlenecks
3. Suggest optimizations following our performance guidelines (see ARCHITECTURE.md)
4. Implement changes
5. Verify performance improvement
```

### Add UI Component
```
I need a new UI component for [purpose].

Requirements:
- Should fit with existing design (Bootstrap 5.3+)
- Must support dark mode
- Should be responsive (mobile-friendly)
- Needs to follow our component conventions (see CONVENTIONS.md)

Please:
1. Design the component structure
2. Implement the Razor markup
3. Add appropriate styling in site.css if needed
4. Ensure accessibility (ARIA labels, keyboard navigation)
```

### Update Dependencies
```
I need to update [dependency] from version [old] to [new].

Please:
1. Check DECISIONS.md for why we're using this dependency
2. Review the changelog for breaking changes
3. Update the package reference
4. Update any affected code
5. Test that everything still works
6. Update documentation if the API changed
```

## Workflow Prompts

### Starting a New Feature
```
Before I start implementing [feature], help me plan it:

1. Check if there are related ADRs in DECISIONS.md
2. Review existing similar features for patterns to follow
3. Create a task breakdown
4. Identify which files need to be created or modified
5. Suggest tests that should be written
6. Highlight any potential issues or conflicts

Follow the conventions in CONVENTIONS.md.
```

### Code Review
```
Please review [file or PR] for:

1. Adherence to conventions (CONVENTIONS.md)
2. Consistency with architecture (ARCHITECTURE.md)
3. Code quality and maintainability
4. Performance considerations
5. Missing error handling
6. Documentation needs
7. Test coverage gaps

Be specific about issues and suggest improvements.
```

### Deployment Preparation
```
I'm preparing to deploy version [x.y.z]. Help me:

1. Review changes since last release
2. Update CHANGELOG.md
3. Verify all documentation is current
4. Check for breaking changes
5. Update version numbers
6. Prepare release notes
7. Verify GitHub Actions workflow will succeed
```

## Learning Prompts

### Explain a Concept
```
Explain [concept/pattern/algorithm] used in [file].

Include:
- Why we chose this approach (check DECISIONS.md)
- How it works
- Trade-offs vs alternatives
- Where else it's used in the codebase
- Common pitfalls to avoid
```

### Best Practices
```
What are the best practices for [task/pattern] in Blazor WebAssembly?

Consider:
- Our current architecture (see ARCHITECTURE.md)
- .NET 9.0 and Blazor capabilities
- Performance implications
- Maintainability
- How it fits with our conventions (CONVENTIONS.md)
```

## Prompt Templates

### Issue Investigation Template
```
**Issue**: [Brief description]

**Reproduction Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected**: [What should happen]
**Actual**: [What actually happens]

**Environment**:
- Browser: [name and version]
- .NET SDK: [version]
- OS: [operating system]

**Relevant Files**: [list files]

**Checked**:
- [ ] Reviewed TROUBLESHOOTING.md
- [ ] Checked browser console for errors
- [ ] Verified latest version deployed
- [ ] Attempted basic fixes

Please help diagnose and fix this issue.
```

### Enhancement Request Template
```
**Feature**: [Feature name]

**Problem**: [What problem does this solve?]

**Proposed Solution**: [Your idea]

**Alternatives Considered**: [Other approaches]

**Impact**:
- Files affected: [list]
- Breaking changes: [yes/no]
- Documentation needed: [list]

**Acceptance Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

Please review DECISIONS.md for related architectural decisions, then help implement this.
```

## Tips for Effective AI Prompts

### Be Specific
- ❌ "Fix the bug"
- ✅ "The auto-focus in Index.razor line 150 doesn't advance to the next input when typing in the yellow letter grid"

### Provide Context
- Reference relevant documentation files
- Mention related code sections
- Explain what you've already tried

### Set Clear Expectations
- Specify what you want: explanation, implementation, review, etc.
- Define success criteria
- Mention any constraints

### Use Incremental Prompts
- Start with understanding
- Then plan
- Then implement
- Then test

### Reference Documentation
- Point to ARCHITECTURE.md for system context
- Cite CONVENTIONS.md for style guidelines
- Check DECISIONS.md for architectural rationale
- Reference TROUBLESHOOTING.md for known issues
