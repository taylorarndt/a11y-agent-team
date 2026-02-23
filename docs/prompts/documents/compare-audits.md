# compare-audits

Compare two document accessibility audit reports to track remediation progress. Shows which issues were fixed, which are new, which persist, and calculates velocity — how many audit cycles will it take to reach zero errors at the current fix rate.

## When to Use It

- You ran a remediation sprint and want to measure the outcome
- You need to report progress to management ("we reduced document errors by 40% this quarter")
- You want to verify that a document template update improved the downstream documents
- You want to catch regressions before they accumulate

## How to Launch It

**In GitHub Copilot Chat:**
```
/compare-audits
```

Then provide the two report paths when prompted. Or specify directly:

```
/compare-audits DOCUMENT-ACCESSIBILITY-AUDIT-jan.md DOCUMENT-ACCESSIBILITY-AUDIT-feb.md
```

The prompt has two required inputs: `previousReport` (the baseline) and `currentReport` (the newer scan).

## What to Expect

### Step 1: Report Reading

The agent reads both audit reports and extracts all findings for comparison.

### Step 2: Classification

Every finding from both reports is classified:

| Classification | Meaning |
|---------------|---------|
| Fixed | In the previous report, absent now — a win |
| New | Not in the previous report, present now — needs attention |
| Persistent | Present in both reports — highest priority for next sprint |
| Regressed | Was fixed at some point but has returned |

### Step 3: Comparison Report

```markdown
# Document Accessibility Comparison Report

## Summary

| Metric | Previous (Jan) | Current (Feb) | Change |
|--------|------------|-----------|--------|
| Total Findings | 47 | 28 | -19 |
| Total Errors | 12 | 5 | -7 |
| Total Warnings | 35 | 23 | -12 |
| Avg. Score | 71/100 | 84/100 | +13 |

## Progress: 40% of previous findings resolved

### Fixed Issues (19) ✓
...

### New Issues (0) ✓
...

### Persistent Issues (28)
[List — prioritize for next sprint]
```

### Step 4: Velocity Calculation

The agent calculates:

- **Issues fixed per cycle** — how many were resolved between the two reports
- **Percentage reduction** — total issue count change
- **Cycles to zero** — estimated time to reach zero errors at the current fix rate (e.g., "At this rate, 2 more audit cycles to reach zero errors")

This gives you a data-driven projection for your compliance timeline.

### Step 5: Output

The comparison is saved to `DOCUMENT-AUDIT-COMPARISON.md`.

## Example Variations

```
/compare-audits AUDIT-Q1.md AUDIT-Q2.md
/compare-audits reports/baseline-2025.md reports/current-2026.md
```

## Output Files

| File | Contents |
|------|----------|
| `DOCUMENT-AUDIT-COMPARISON.md` | Full comparison with Fixed/New/Persistent/Regressed breakdown and velocity metrics |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Reads both reports and generates the comparison |
| [cross-document-analyzer](../../agents/cross-document-analyzer.md) | Performs the classification and velocity calculations |

## Related Prompts

- [audit-document-folder](audit-document-folder.md) — generate new audit reports to compare
- [audit-changed-documents](audit-changed-documents.md) — incremental comparison on each commit
- [generate-vpat](generate-vpat.md) — export the current state as a VPAT after improvement
