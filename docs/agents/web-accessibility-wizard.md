# accessibility-wizard — Guided Accessibility Audit

> Runs a full, interactive accessibility audit of your project by coordinating all specialist agents in sequence. Instead of dumping a wall of issues at you, it walks you through eleven phases, one accessibility domain at a time, and asks you questions at each step to focus the review on what matters for your specific project.

## When to Use It

- You want a comprehensive audit but do not know where to start
- You are new to accessibility and want guided, educational reviews
- You need to prepare for a third-party accessibility assessment
- You want a structured VPAT or conformance report
- You are onboarding a team and want to show them the full scope of accessibility
- A feature is shipping and you want a final pre-launch review

## The Eleven Phases

| Phase | Domain | Specialist Used |
|-------|--------|----------------|
| 1 | Project discovery and scope | — |
| 2 | Document structure and semantics | alt-text-headings |
| 3 | Keyboard navigation and focus | keyboard-navigator |
| 4 | Forms and input accessibility | forms-specialist |
| 5 | Color and visual accessibility | contrast-master |
| 6 | Dynamic content and live regions | live-region-controller |
| 7 | ARIA usage review | aria-specialist |
| 8 | Data tables and grids | tables-data-specialist |
| 9 | Link text and navigation | link-checker |
| 10 | Document accessibility (optional) | word/excel/powerpoint/pdf-accessibility |
| 11 | Testing strategy and tools | testing-coach |

At the end, it generates a prioritized report with issues grouped by severity (Critical > Serious > Moderate > Minor), WCAG criterion references, and a suggested fix order.

## Example Prompts

### Claude Code

```
/accessibility-wizard run a full audit on this project
/accessibility-wizard audit the checkout flow
/accessibility-wizard I need to prepare for a VPAT assessment
/accessibility-wizard walk me through accessibility for the dashboard
```

### GitHub Copilot

```
@accessibility-wizard audit this project for accessibility
@accessibility-wizard guide me through a review of the signup flow
@accessibility-wizard run a full accessibility audit
@accessibility-wizard I am new to accessibility, walk me through everything
```

## Behavioral Constraints

- Always asks the user before moving to the next phase — never skips ahead silently
- Presents findings from each phase before proceeding, so the user can fix issues iteratively
- Generates a final report only after all phases complete (or the user chooses to stop early)
- Does not write code itself — delegates to the appropriate specialist agent and reports what it found
- Groups issues by WCAG conformance level and severity, not by file or line number
