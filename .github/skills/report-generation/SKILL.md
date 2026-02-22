---
name: report-generation
description: Audit report formatting, severity scoring, scorecard computation, and compliance export for document accessibility audits. Use when generating DOCUMENT-ACCESSIBILITY-AUDIT.md reports, computing document severity scores (0-100 with A-F grades), creating VPAT/ACR compliance exports, or formatting remediation priorities.
---

# Report Generation

## Report File

Default output: `DOCUMENT-ACCESSIBILITY-AUDIT.md` in the project root.

## Required Sections

Every audit report MUST include these sections:

1. **Audit Information** — date, auditor, profile, scope, counts
2. **Executive Summary** — totals, pass rate, most common issue, effort estimate
3. **Cross-Document Patterns** — recurring issues, systemic failures
4. **Findings by File** — per-document issues with rule ID, severity, location, WCAG, impact, remediation
5. **Findings by Rule (Cross-Reference)** — rule-level aggregation across files
6. **What Passed** — acknowledge clean documents and categories
7. **Remediation Priority** — ordered by impact (Immediate / Soon / When Possible)
8. **Accessibility Scorecard** — per-document scores and grades
9. **Metadata Dashboard** — document properties health
10. **Confidence Summary** — breakdown by confidence level

### Optional Sections (include when applicable)

- **Template Analysis** — when batch scanning detects shared templates
- **Comparison Report** — when re-scanning against a baseline
- **CI/CD Recommendations** — when no config files exist

## Severity Scoring Formula

```
Document Score = 100 - (sum of weighted findings)

Weights:
  Error (high confidence):   -10 points
  Error (medium confidence):  -7 points
  Error (low confidence):     -3 points
  Warning (high confidence):  -3 points
  Warning (medium confidence):-2 points
  Warning (low confidence):   -1 point
  Tips:                        0 points

Floor: 0 (minimum score)
```

## Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent — minor or no issues |
| 75-89 | B | Good — some warnings, few errors |
| 50-74 | C | Needs Work — multiple errors |
| 25-49 | D | Poor — significant accessibility barriers |
| 0-24 | F | Failing — critical barriers, likely unusable with AT |

## Organization Modes

| Mode | Description | Best For |
|------|-------------|----------|
| By file | Group all issues under each document | Small batches (< 10 files) |
| By issue type | Group all instances of each rule across documents | Seeing patterns |
| By severity | Critical first, then serious, moderate, minor | Prioritizing fixes |

## VPAT/ACR Compliance Export

### Conformance Levels

| Level | Criteria |
|-------|----------|
| Supports | No findings for this WCAG criterion across any document |
| Partially Supports | Some documents pass, some fail |
| Does Not Support | All or most documents fail |
| Not Applicable | Criterion does not apply to scanned document types |

### Supported VPAT Editions

- **VPAT 2.5 (WCAG)** — maps to WCAG 2.2 criteria
- **VPAT 2.5 (508)** — maps to Revised Section 508 standards
- **VPAT 2.5 (EN 301 549)** — maps to EU accessibility directive
- **VPAT 2.5 (INT)** — International edition (all three combined)

## Remediation Tracking

When comparing against a baseline audit report:

| Status | Meaning |
|--------|---------|
| Fixed | Issue was in previous report but is now resolved |
| New | Issue was not in previous report but appears now |
| Persistent | Issue remains from previous report |
| Regressed | Issue was previously fixed but has returned |

### Progress Metrics

- Issue reduction percentage: `(fixed / previous_total) * 100`
- Score change: `current_score - previous_score`
- Documents improved: count of documents with higher scores
