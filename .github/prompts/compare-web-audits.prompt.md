---
description: Compare a current web accessibility audit against a previous one to track remediation progress. Shows fixed, new, persistent, and regressed issues.
mode: agent
tools:
  - askQuestions
---

# Compare Web Accessibility Audits

Compare two web accessibility audit reports to track remediation progress over time. Shows which issues were fixed, which are new, which persist, and which regressed.

## Instructions

Use the **web-accessibility-wizard** agent's remediation tracking capabilities:

1. Use askQuestions to ask:
   - "What is the path to the **previous** audit report?" — default: `ACCESSIBILITY-AUDIT.md`
   - "What is the path to the **current** audit report (or should I run a new audit)?"
     - Options: "Use an existing report" (let me provide the path) | "Run a new audit now"

2. If running a new audit, ask for the URL and run a standard audit first.

3. Parse both reports and classify every finding:
   - **Fixed** — in previous report but not in current
   - **New** — in current report but not in previous
   - **Persistent** — in both reports
   - **Regressed** — was fixed (not in a mid-point report) but has returned

4. Generate the comparison report:

```markdown
# Accessibility Remediation Progress

## Summary

| Metric | Previous | Current | Change |
|--------|----------|---------|--------|
| Total Issues | [n] | [n] | [+/-n] |
| Critical | [n] | [n] | [+/-n] |
| Serious | [n] | [n] | [+/-n] |
| Overall Score | [n]/100 | [n]/100 | [+/-n] |

## Progress: [X]% of previous issues resolved

### Fixed Issues ([count])
[List with celebration — these are wins]

### New Issues ([count])
[List — these need attention]

### Persistent Issues ([count])
[List — prioritize these for next sprint]

### Regressed Issues ([count])
[List — investigate why these returned]

## Trend
[Improving / Stable / Declining] — [one sentence assessment]
```

5. Ask: "Want to focus on fixing the persistent issues now?"
