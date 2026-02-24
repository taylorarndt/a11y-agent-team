---
description: Compare two document accessibility audit reports and show what improved, what regressed, and what remains. Tracks remediation progress over time.
mode: agent
tools:
  - askQuestions
---

# Compare Document Accessibility Audits

Compare two audit reports to track remediation progress over time.

## Reports to compare

**Previous (baseline):** `${input:previousReport}`
**Current:** `${input:currentReport}`

## Instructions

Use the **document-accessibility-wizard** agent to:

1. Read both audit reports
2. For each finding, classify it as:
   - **Fixed** - was in the previous report, no longer present
   - **New** - not in the previous report, appears now
   - **Persistent** - present in both reports
   - **Regressed** - was fixed in an interim fix but has returned
3. Generate a comparison report showing:
   - Summary table: total errors/warnings before vs. after
   - Score changes per document (previous score vs. current score)
   - Overall average score change
   - List of fixed issues (celebrate wins)
   - List of new issues (flag for attention)
   - List of persistent issues (prioritize by severity)
   - Any regressions (highlight prominently)
4. Calculate the remediation velocity:
   - Issues fixed per audit cycle
   - Percentage reduction in total issues
   - Estimated cycles to reach zero errors
5. Write the comparison to `DOCUMENT-AUDIT-COMPARISON.md`

## Handoff Transparency

Announce comparison progress:
- **Start:** "Comparing [report1] with [report2] - analyzing [N] findings..."
- **Completion:** "Comparison complete: [N] fixed, [N] new, [N] persistent, [N] regressed"
- **On failure:** "Could not parse [report]: [reason]. Comparison aborted."
