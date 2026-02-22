---
description: Quick accessibility triage of a web page. Runtime axe-core scan only — no code review. Fast pass/fail verdict with score.
mode: agent
tools:
  - askQuestions
  - runInTerminal
  - getTerminalOutput
---

# Quick Web Accessibility Check

Fast triage — run axe-core against a live URL and get a pass/fail verdict. No code review, no screenshots. Fastest way to check a page.

## Page to check

**URL:** `${input:pageUrl}`

## Settings

- **Audit method:** Runtime scan only (axe-core)
- **Thoroughness:** Quick scan
- **Target standard:** WCAG 2.2 AA
- **Report:** Inline (no separate file)

## Instructions

Use the **web-accessibility-wizard** agent workflow in quick mode:

1. Skip Phase 0 discovery — settings are pre-configured above
2. Run axe-core against the URL:
   ```bash
   npx @axe-core/cli ${input:pageUrl} --tags wcag2a,wcag2aa,wcag21a,wcag21aa
   ```
3. Parse the results and report inline in this format:

```
Quick Check: ${input:pageUrl}
Score: [0-100] ([A-F])

Violations: [count]
  Critical: [count]
  Serious: [count]
  Moderate: [count]
  Minor: [count]

Top Issues:
  1. [rule-id] — [description] — [impact]
  2. ...
  3. ...

Rules Passed: [count]

Verdict: [PASS if 0 critical/serious | NEEDS WORK if 1-3 serious | FAIL if 4+ serious or any critical]
```

4. If issues are found, ask: "Want to run a full audit with code review and remediation steps?"
