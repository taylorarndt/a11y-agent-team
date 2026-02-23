# web-severity-scoring Skill

> Severity scoring, scorecard computation, confidence levels, and remediation tracking for web accessibility audits. Covers the page scoring formula (0-100 with A-F grades), confidence-weighted penalty calculations, source correlation rules, scorecard formats (single-page and multi-page), cross-page pattern classification, and change tracking (Fixed / New / Persistent / Regressed).

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [web-accessibility-wizard](../agents/web-accessibility-wizard.md) | Page scoring and audit report output |
| [cross-page-analyzer](../agents/cross-page-analyzer.md) | Cross-page scorecard and pattern scoring |
| [accessibility-lead](../agents/accessibility-lead.md) | Final score in orchestrated audits |

## Severity Scoring Formula

```text
Page Score = 100 - (sum of weighted findings)

Critical, high confidence (both sources): -15
Critical, high confidence (single source): -10
Critical, medium confidence:               - 7
Critical, low confidence:                  - 3
Serious, high confidence:                  - 7
Serious, medium confidence:                - 5
Serious, low confidence:                   - 2
Moderate, high confidence:                 - 3
Moderate, medium confidence:               - 2
Moderate, low confidence:                  - 1
Minor:                                     - 1

Floor: 0
```

## Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - minor or no issues, meets WCAG AA |
| 75-89 | B | Good - some issues, mostly meets WCAG AA |
| 50-74 | C | Needs Work - multiple issues, partial compliance |
| 25-49 | D | Poor - significant accessibility barriers |
| 0-24 | F | Failing - critical barriers, likely unusable with AT |

## Confidence Levels

| Level | Weight | When to Use |
|-------|--------|-------------|
| **High** | 100% | Confirmed by axe-core + agent review, OR definitively structural (missing alt, no labels, no `lang`) |
| **Medium** | 70% | Found by one source - likely issue but needs judgment (heading edge cases, questionable ARIA) |
| **Low** | 30% | Possible issue, needs human review (alt quality, reading order, context-dependent link text) |

**Source correlation rule:** Issues found by both axe-core AND agent code review are automatically upgraded to **high confidence**, regardless of individual confidence ratings.

## Scorecard Formats

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

## Issue Severity Categories

### Critical

- No keyboard access to essential functionality
- Missing form labels on required fields
- Images conveying critical information without alt text
- Color as the sole means of conveying information
- Keyboard traps with no escape

### Serious

- Missing skip navigation
- Poor heading hierarchy (skipped levels)
- Focus not visible on interactive elements
- Form errors not programmatically associated
- Missing ARIA on custom widgets

### Moderate

- Redundant ARIA on semantic elements
- Multiple H1s on one page
- Missing `autocomplete` on identity fields
- Links to new tabs without warning
- Missing table captions

### Minor

- Redundant `title` attributes
- Suboptimal button text
- Missing landmark roles where semantic elements exist
- Decorative images with non-empty `alt`

## Cross-Page Pattern Classification

| Pattern | Definition | Remediation ROI |
|---------|-----------|-----------------|
| **Systemic** | Same issue on every audited page | Highest - fix nav/layout once |
| **Template** | Same issue on pages sharing a component | High - fix the shared component |
| **Page-specific** | Unique to one page | Normal - fix individually |

## Remediation Tracking

| Status | Definition |
|--------|-----------|
|  Fixed | In previous report, no longer present |
|  New | Not in previous report, appears now |
|  Persistent | Remains from previous report |
|  Regressed | Previously fixed, has returned |

### Progress Metrics

- **Issue reduction:** `(fixed / previous_total) x 100`
- **Score change:** `current_score - previous_score`
- **Pages improved:** count of pages with higher scores than previous audit
- **Trend:** Improving (+5), Stable (within 5), Declining (-5)

## Skill Location

`.github/skills/web-severity-scoring/SKILL.md`
