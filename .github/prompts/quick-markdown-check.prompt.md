---
description: Quick accessibility triage of markdown files. Errors only - no report file saved. Fast pass/fail verdict with score.
mode: agent
agent: markdown-a11y-assistant
---

# Quick Markdown Accessibility Check

Fast triage - scan one or more markdown files and get a pass/fail verdict with error-only findings. No report file saved. Fastest way to check if your documentation has critical accessibility barriers.

## Files to Check

Tell the agent which files to scan:

- Single file: `check README.md`
- Multiple files: `check CONTRIBUTING.md and CHANGELOG.md`
- All files: `check all markdown in this repo`

## Settings (pre-configured)

- **Scan profile:** Errors only (Critical and Serious severity)
- **Emoji:** Remove-decorative (default)
- **Mermaid:** Flag only - no replacement in quick mode
- **ASCII diagrams:** Flag only - no replacement in quick mode
- **Dashes:** Flag only
- **Anchor validation:** Yes
- **Report:** Inline only (no MARKDOWN-ACCESSIBILITY-AUDIT.md file)

## Instructions for the Agent

Skip Phase 0 discovery questions - settings are pre-configured above.

1. Dispatch `markdown-scanner` for each file (in parallel for multiple files)
2. Filter findings to Critical and Serious severity only
3. Report inline in this format for each file:

```text
Quick Check: <filename>
Score: [0-100] ([A-F])

Errors Only:
  Critical: [count]
    - [line N]: [issue]
  Serious: [count]
    - [line N]: [issue]

Verdict: PASS (no Critical/Serious issues) | FAIL ([N] errors found)
```

4. If no issues found: report "PASS - no Critical or Serious accessibility issues found."
5. Do NOT generate a MARKDOWN-ACCESSIBILITY-AUDIT.md file.
6. Offer to run a full audit if errors are found.
