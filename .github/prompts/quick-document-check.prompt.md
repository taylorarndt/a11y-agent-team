---
description: Quick-check a single document for the most critical accessibility issues. Errors only, no warnings or tips. Fast triage mode.
mode: agent
tools:
  - askQuestions
---

# Quick Document Accessibility Check

Fast triage scan - check a single document for critical accessibility errors only. Skips warnings and tips for speed.

## Document to check

**Path:** `${input:documentPath}`

## Settings

- **Scan profile:** Minimal (errors only)
- **Remediation steps:** Summary only
- **Confidence filter:** High confidence only (skip medium/low to reduce noise)

## Instructions

Use the **document-accessibility-wizard** agent to:

1. Identify the file type from the path
2. Delegate to the appropriate sub-agent with **minimal profile** (errors only)
3. Filter to **high-confidence** findings only
4. Report results inline (no separate report file) in this format:

```text
Quick Check: [filename]
Score: [0-100] ([A-F])

Errors Found: [count]
  1. [Rule ID] - [description] - [location]
  2. ...

Verdict: [PASS if 0 errors | NEEDS WORK if 1-3 errors | FAIL if 4+ errors]
```

5. If errors are found, ask: "Want to run a full audit with detailed remediation steps?"
