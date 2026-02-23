# report-generation Skill

> Audit report formatting, severity scoring, scorecard computation, and compliance export for document accessibility audits. Covers the required sections for `DOCUMENT-ACCESSIBILITY-AUDIT.md`, the severity scoring formula (0-100 with A-F grades), confidence-weighted penalty calculations, VPAT/ACR conformance levels and edition support, remediation tracking, and cross-run progress metrics.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [document-accessibility-wizard](../agents/document-accessibility-wizard.md) | Generates all document audit reports |
| [cross-document-analyzer](../agents/cross-document-analyzer.md) | Produces cross-document pattern sections and scorecards |

## Required Report Sections

Every `DOCUMENT-ACCESSIBILITY-AUDIT.md` must include these sections in order:

| # | Section | Contents |
|---|---------|----------|
| 1 | **Audit Information** | Date, auditor, profile, scope, file counts |
| 2 | **Executive Summary** | Totals, pass rate, most common issue, effort estimate |
| 3 | **Cross-Document Patterns** | Recurring issues, systemic failures across files |
| 4 | **Findings by File** | Per-document issues: rule ID, severity, location, WCAG SC, impact, remediation |
| 5 | **Findings by Rule (Cross-Reference)** | Rule-level aggregation across all files |
| 6 | **What Passed** | Acknowledge clean documents and clean categories |
| 7 | **Remediation Priority** | Ordered by impact: Immediate / Soon / When Possible |
| 8 | **Accessibility Scorecard** | Per-document scores and grades |
| 9 | **Metadata Dashboard** | Document property health (title, language, author) |
| 10 | **Confidence Summary** | Breakdown of findings by High / Medium / Low confidence |

### Optional Sections

Include when applicable:

- **Template Analysis** - when batch scanning detects shared templates
- **Comparison Report** - when re-scanning against a baseline
- **CI/CD Recommendations** - when no scan config files exist

## Severity Scoring Formula

```text
Document Score = 100 - (sum of weighted findings)

Error, high confidence:    -10 points
Error, medium confidence:  - 7 points
Error, low confidence:     - 3 points
Warning, high confidence:  - 3 points
Warning, medium confidence:- 2 points
Warning, low confidence:   - 1 point
Tips:                        0 points

Floor: 0
```

## Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - minor or no issues |
| 75-89 | B | Good - some warnings, few errors |
| 50-74 | C | Needs Work - multiple errors |
| 25-49 | D | Poor - significant accessibility barriers |
| 0-24 | F | Failing - critical barriers, likely unusable with AT |

## Scorecard Format

```markdown
## Accessibility Scorecard

| Document | Score | Grade | Errors | Warnings | Tips |
|----------|-------|-------|--------|----------|------|
| report.docx | 84 | B | 1 | 3 | 2 |
| data.xlsx | 62 | C | 3 | 4 | 1 |
| slides.pptx | 91 | A | 0 | 2 | 3 |
| **Average** | **79** | **B** | **4** | **9** | **6** |
```

## VPAT/ACR Compliance Export

### Conformance Levels

| Level | When to Use |
|-------|------------|
| Supports | No findings for this WCAG criterion across any document |
| Partially Supports | Some documents pass, some fail |
| Does Not Support | All or most documents fail |
| Not Applicable | Criterion does not apply to scanned document types |

### Supported VPAT Editions

| Edition | Standard |
|---------|---------|
| VPAT 2.5 (WCAG) | WCAG 2.2 criteria |
| VPAT 2.5 (508) | Revised Section 508 |
| VPAT 2.5 (EN 301 549) | EU Accessibility Directive |
| VPAT 2.5 (INT) | All three combined |

## Remediation Tracking

When re-scanning against a baseline:

| Status | Definition |
|--------|-----------|
|  Fixed | In previous report, resolved now |
|  New | Not in previous report, appears now |
|  Persistent | Remains from previous report |
|  Regressed | Previously fixed, has returned |

### Progress Metrics

- **Issue reduction:** `(fixed / previous_total) x 100`
- **Score change:** `current_score - previous_score`
- **Documents improved:** count with higher scores than previous scan

## Organization Modes

| Mode | Best For |
|------|----------|
| By file | Small batches (< 10 files) |
| By issue type | Spotting systemic patterns |
| By severity | Prioritizing the fix order |

## Skill Location

`.github/skills/report-generation/SKILL.md`
