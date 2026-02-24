---
description: Compare a current markdown accessibility audit against a previous one to track remediation progress. Shows fixed, new, persistent, and regressed issues with score changes.
mode: agent
agent: markdown-a11y-assistant
---

# Compare Markdown Accessibility Audits

Compare two markdown accessibility audit reports to track remediation progress over time. Shows which issues were fixed, which are new, which persist, and which regressed.

## Instructions

Use the `markdown-a11y-assistant` agent's remediation tracking capabilities:

1. Use `askQuestions` to ask:
   - "What is the path to the **previous** audit report?" (default: `MARKDOWN-ACCESSIBILITY-AUDIT.md`)
   - "What is the path to the **current** audit report, or should I run a new scan?"
     - Options: "Use an existing report (I'll provide the path)" | "Run a new full scan now"

2. If running a new scan, invoke `markdown-scanner` on the same file set and generate a fresh report.

3. Parse both reports and classify every finding:
   - **Fixed** - in previous report but not in current
   - **New** - in current report but not in previous
   - **Persistent** - in both reports (not yet addressed)
   - **Regressed** - was absent from the previous report but has returned

4. Generate the comparison report in this format:

```markdown
# Markdown Accessibility Remediation Progress

## Summary

| Metric | Previous | Current | Change |
|--------|----------|---------|--------|
| Total Issues | [n] | [n] | [+/-n] |
| Critical | [n] | [n] | [+/-n] |
| Serious | [n] | [n] | [+/-n] |
| Moderate | [n] | [n] | [+/-n] |
| Minor | [n] | [n] | [+/-n] |
| Files Scanned | [n] | [n] | [+/-n] |
| Overall Score (avg) | [n]/100 | [n]/100 | [+/-n] |

## Progress: [X]% of previous issues resolved

### Fixed Issues ([count])
[List with file:line and what was fixed - these are wins]

### New Issues ([count])
[List with file:line - these need attention]

### Persistent Issues ([count])
[List with file:line - prioritize these for next sprint]

### Regressed Issues ([count])
[List with file:line - investigate why these returned]

## Per-File Score Changes

| File | Previous Score | Current Score | Change | Grade |
|------|---------------|---------------|--------|-------|
| [file] | [n] | [n] | [+/-n] | [A-F] |

## Trend
[Improving / Stable / Declining] - [one-sentence assessment]
```

5. Offer to run `fix-markdown-issues` on the persistent and new issues.

## Handoff Transparency

Announce comparison progress:
- **Start:** "Comparing markdown audit reports - analyzing [N] findings..."
- **Completion:** "Comparison complete: [N] fixed, [N] new, [N] persistent, [N] regressed"
- **On failure:** "Could not parse [report]: [reason]. Comparison aborted."
