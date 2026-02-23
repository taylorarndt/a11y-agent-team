# compare-web-audits

Compare a current web accessibility audit against a previous one. Shows exactly which issues were fixed, which are new, which persist, and which have regressed — with an overall progress percentage and trend assessment.

## When to Use It

- You completed a remediation sprint and want to measure the improvement
- You want to verify that a deployment did not introduce new accessibility regressions
- You need to report progress to a stakeholder ("we reduced critical issues by 67%")
- You want to track accessibility health over multiple development cycles

## How to Launch It

**In GitHub Copilot Chat:**
```
/compare-web-audits
```

The agent will ask for both report paths. Or specify them directly:

```
/compare-web-audits previous: ACCESSIBILITY-AUDIT-jan.md current: ACCESSIBILITY-AUDIT-feb.md
```

## What to Expect

### Step 1: Report Selection

The agent asks:
1. **Previous audit** — path to the baseline report (default: looks for an existing `ACCESSIBILITY-AUDIT.md`)
2. **Current audit** — path to the new report, or "run a new audit now" to scan the live URL first

### Step 2: Issue Classification

Every finding from both reports is classified:

| Classification | Meaning |
|---------------|---------|
| Fixed | Was in the previous report, gone now — a win |
| New | Not in the previous report, appeared now — needs attention |
| Persistent | In both reports — highest priority for the next sprint |
| Regressed | Was fixed at some point but has returned |

### Step 3: Progress Report

```markdown
# Accessibility Remediation Progress

## Summary

| Metric | Previous | Current | Change |
|--------|----------|---------|--------|
| Total Issues | 24 | 11 | -13 |
| Critical | 4 | 1 | -3 |
| Serious | 8 | 4 | -4 |
| Overall Score | 61/100 | 83/100 | +22 |

## Progress: 54% of previous issues resolved

### Fixed Issues (13) ✓
...

### New Issues (0) ✓
...

### Persistent Issues (11)
[List — prioritize these for next sprint]

### Regressed Issues (0) ✓

## Trend: Improving
```

### Step 4: Remediation Offer

After the comparison, the agent asks: "Want to focus on fixing the persistent issues now?" — launching [fix-web-issues](fix-web-issues.md) pre-loaded with the persistent finding list.

## Example Variations

```
/compare-web-audits
→ Use ACCESSIBILITY-AUDIT-2026-01.md as baseline
→ Run a new audit on https://myapp.com now

/compare-web-audits
→ Compare ACCESSIBILITY-AUDIT-sprint-12.md vs ACCESSIBILITY-AUDIT-sprint-13.md
```

## Connected Agents

| Agent | Role |
|-------|------|
| [web-accessibility-wizard](../../agents/web-accessibility-wizard.md) | Parses both reports and runs any new audits needed |
| [cross-page-analyzer](../../agents/cross-page-analyzer.md) | Performs the Fixed/New/Persistent/Regressed classification |

## Related Prompts

- [audit-web-page](audit-web-page.md) — run the new audit to compare
- [fix-web-issues](fix-web-issues.md) — fix the persistent issues identified in the comparison
- [audit-web-multi-page](audit-web-multi-page.md) — compare across multiple pages
