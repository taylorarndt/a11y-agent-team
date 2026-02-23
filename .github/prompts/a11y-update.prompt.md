---
name: a11y-update
description: "Get the latest accessibility improvements across all tracked repos -- with WCAG cross-references and ARIA pattern mapping"
agent: insiders-a11y-tracker
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Show me the latest accessibility improvements across tracked repositories.

${input:scope:Optional: 'insiders', 'stable', 'both', a specific month, 'screen reader', search keywords, 'track owner/repo', or a specific repo name}

## Behavior

Load accessibility tracking configuration from `.github/agents/preferences.md` (repos, labels, channels). If no preferences exist, use defaults (microsoft/vscode with accessibility labels).

Interpret the scope:

- **No input / "both"** --> show recent a11y changes across ALL tracked repos (from preferences or defaults), both Insiders and Stable channels where applicable
- **"insiders"** --> only Insiders-released changes (VS Code-specific channel)
- **"stable"** --> only Stable-released changes (VS Code-specific channel)
- **Repo name** (e.g., "owner/my-app") --> scope to that specific repo's accessibility issues
- **Month name** (e.g., "February", "last month") --> search that month's milestone
- **Category** (e.g., "screen reader", "keyboard", "contrast") --> filter results by that category
- **Keywords** (e.g., "minimap", "terminal", "editor") --> search with those terms + accessibility label
- **"track owner/repo"** --> add a new repository to the tracking list for this session
- **"WCAG"** or **"criteria"** --> emphasize WCAG cross-references in the output
- **"ARIA"** or **"patterns"** --> emphasize ARIA design pattern mapping

Present results as a categorized list grouped by: Screen Reader, Keyboard Navigation, Visual/Contrast, Audio/Motion, Cognitive, Other.

For each issue, include:
- WCAG success criteria reference (e.g., "WCAG 2.4.3 Focus Order (Level A)")
- ARIA design pattern if applicable (e.g., "Dialog pattern")
- Impact level: Critical / Major / Minor
- Assistive technologies affected

After showing results, offer: _"Want me to generate a full monthly accessibility report with WCAG coverage analysis, dive into a specific change, or add another repo to tracking?"_
