---
name: web-severity-scoring
description: Severity scoring, scorecard computation, confidence levels, and remediation tracking for web accessibility audits. Use when computing page accessibility scores (0-100 with A-F grades), tracking remediation progress across audits, or generating cross-page comparison scorecards.
---

# Web Severity Scoring

## Severity Scoring Formula

```text
Page Score = 100 - (sum of weighted findings)

Weights:
  Critical (high confidence, both sources):  -15 points
  Critical (high confidence, single source): -10 points
  Critical (medium confidence):               -7 points
  Critical (low confidence):                  -3 points
  Serious (high confidence):                  -7 points
  Serious (medium confidence):                -5 points
  Serious (low confidence):                   -2 points
  Moderate (high confidence):                 -3 points
  Moderate (medium confidence):               -2 points
  Moderate (low confidence):                  -1 point
  Minor:                                      -1 point

Floor: 0 (minimum score)
```

## Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - minor or no issues, meets WCAG AA |
| 75-89 | B | Good - some issues, mostly meets WCAG AA |
| 50-74 | C | Needs Work - multiple issues, partial WCAG AA compliance |
| 25-49 | D | Poor - significant accessibility barriers |
| 0-24 | F | Failing - critical barriers, likely unusable with AT |

## Confidence Levels

| Level | Weight | When to Use |
|-------|--------|-------------|
| High | 100% | Confirmed by axe-core + agent, or definitively structural (missing alt, no labels, no lang) |
| Medium | 70% | Found by one source, likely issue (heading edge cases, questionable ARIA, possible keyboard traps) |
| Low | 30% | Possible issue, needs human review (alt text quality, reading order, context-dependent link text) |

### Source Correlation

Issues found by both axe-core AND agent review are automatically upgraded to **high confidence** regardless of individual confidence ratings.

## Scorecard Format

### Single Page

```markdown
## Accessibility Score

| Metric | Value |
|--------|-------|
| Page | [URL] |
| Score | [0-100] |
| Grade | [A-F] |
| Critical | [count] |
| Serious | [count] |
| Moderate | [count] |
| Minor | [count] |
```

### Multi-Page

```markdown
## Accessibility Scorecard

| Page | Score | Grade | Critical | Serious | Moderate | Minor |
|------|-------|-------|----------|---------|----------|-------|
| / | 82 | B | 0 | 2 | 3 | 1 |
| /login | 91 | A | 0 | 0 | 2 | 1 |
| /dashboard | 45 | D | 2 | 4 | 3 | 2 |
| **Average** | **72.7** | **C** | **2** | **6** | **8** | **4** |
```

## Cross-Page Pattern Classification

| Pattern Type | Definition | Remediation ROI |
|-------------|-----------|-----------------|
| Systemic | Same issue on every audited page | Highest - usually layout/nav, fix once |
| Template | Same issue on pages sharing a component | High - fix the shared component |
| Page-specific | Unique to one page | Normal - fix individually |

## Remediation Tracking

### Change Classification

| Status | Definition |
|--------|-----------|
| Fixed | Issue was in previous report but no longer present |
| New | Issue not in previous report, appears now |
| Persistent | Issue remains from previous report |
| Regressed | Issue was previously fixed but has returned |

### Progress Metrics

- **Issue reduction:** `(fixed / previous_total) * 100`
- **Score change:** `current_score - previous_score`
- **Pages improved:** count of pages with higher scores than previous audit
- **Trend:** improving (score up 5+), stable (within 5), declining (score down 5+)

## Issue Severity Categories

### Critical
- No keyboard access to essential functionality
- Missing form labels on required fields
- Images conveying critical information have no alt text
- Color is the sole means of conveying information
- Keyboard traps with no escape

### Serious
- Missing skip navigation
- Poor heading hierarchy (skipped levels)
- Focus not visible on interactive elements
- Form errors not programmatically associated
- Missing ARIA on custom widgets

### Moderate
- Redundant ARIA on semantic elements
- Suboptimal heading structure (multiple H1s)
- Missing autocomplete on identity fields
- Links to new tabs without warning
- Missing table captions

### Minor
- Redundant title attributes
- Suboptimal button text
- Missing landmark roles where semantic elements exist
- Decorative images with non-empty alt text
