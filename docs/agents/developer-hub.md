# developer-hub - Developer Tools Command Center

> Your intelligent developer command center -- start here for any Python, wxPython, desktop app, accessibility tool building, desktop accessibility, or general software engineering task. Routes to specialist agents across the developer, web, and document accessibility teams. Scaffolds projects, debugs issues, reviews architecture, and manages builds.

## When to Use It

- Starting any Python or wxPython development task
- Unsure which developer specialist you need
- Building a desktop application with accessibility requirements
- Need to debug, package, test, or optimize Python code
- Building accessibility scanning tools or rule engines
- Need coordination across multiple developer specialists

## What It Does NOT Do

- Does not perform deep specialist work itself -- it routes to the right expert
- Does not handle web accessibility auditing (routes to web-accessibility-wizard)
- Does not handle document accessibility (routes to document-accessibility-wizard)

## Team Members

| Agent | Expertise |
|-------|-----------|
| [python-specialist](python-specialist.md) | Python debugging, packaging, testing, type checking, async, optimization |
| [wxpython-specialist](wxpython-specialist.md) | wxPython GUI: sizers, events, AUI, custom controls, threading |
| [desktop-a11y-specialist](desktop-a11y-specialist.md) | Platform accessibility APIs (UIA, MSAA, ATK, NSAccessibility) |
| [desktop-a11y-testing-coach](desktop-a11y-testing-coach.md) | Screen reader testing, Accessibility Insights, automated UIA tests |
| [a11y-tool-builder](a11y-tool-builder.md) | Rule engines, document parsers, report generators, CLI/GUI scanners |

## Example Prompts

- "Debug this crash in my wxPython app"
- "Help me package my app with PyInstaller"
- "Scaffold a new wxPython project with accessibility"
- "Review my application architecture"
- "Build an accessibility scanner for DOCX files"

## Skills Used

| Skill | Purpose |
|-------|---------|
| [python-development](../skills/python-development.md) | Python version reference, pyproject.toml patterns, PyInstaller modes, wxPython cheat sheets |

## Related Agents

- [web-accessibility-wizard](web-accessibility-wizard.md) -- cross-team handoff for web content auditing
- [document-accessibility-wizard](document-accessibility-wizard.md) -- cross-team handoff for document auditing
