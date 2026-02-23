# cross-document-analyzer

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [document-accessibility-wizard](document-accessibility-wizard.md) when auditing multiple documents at once. You do not need to invoke it directly.

## What It Does

`cross-document-analyzer` receives aggregated scan findings from multiple document audits and does three things:

1. **Pattern detection** - finds accessibility rules that fail across many files, identifies template-level issues, and classifies issues as systemic (all files), folder-level (one directory), or isolated (single document)
2. **Severity scoring** - computes a weighted 0-100 accessibility risk score for each document and assigns an A-F grade
3. **Remediation tracking** - when a baseline report is available, classifies every finding as Fixed, New, Persistent, or Regressed

## When It Runs

The `document-accessibility-wizard` calls this agent whenever a multi-document audit is in progress:

- `audit-document-folder` prompt - after scanning all documents in the folder
- `audit-changed-documents` prompt - after scanning the git-changed files
- `compare-audits` prompt - when comparing two audit reports across time
- `generate-vpat` prompt - when aggregating conformance data across a library of documents

## Scoring Formula

The agent computes a risk score for each document:

```text
Score = 100 - (sum of weighted findings)
Minimum score: 0
```

| Finding Type | Confidence | Deduction |
|-------------|-----------|-----------|
| Error | High | -10 points |
| Error | Medium | -7 points |
| Error | Low | -3 points |
| Warning | High | -3 points |
| Warning | Medium | -2 points |
| Warning | Low | -1 point |
| Tip | Any | 0 points |

### Grade Table

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - minor or no issues |
| 75-89 | B | Good - some warnings, few errors |
| 50-74 | C | Needs Work - multiple errors |
| 25-49 | D | Poor - significant accessibility barriers |
| 0-24 | F | Failing - critical barriers, likely unusable with assistive technology |

## Pattern Detection

The agent analyzes findings across all documents in the batch and classifies them:

- **Systemic** - the same rule fails in 90%+ of documents (e.g., no document has a title set, or all documents lack the language property). Fix the template or the authoring process, not individual files.
- **Folder-level** - the pattern is confined to a directory (e.g., all files under `/legacy/` have image alt text missing). Suggests a batch from the same source or author.
- **Isolated** - the issue appears in only one or two documents. Address individually.

The pattern summary in the audit report groups issues in this order: systemic -> folder-level -> isolated. This ordering matches remediation priority: fix what affects the most people first.

## Template Analysis

If document metadata reveals shared templates (Word's `Template` property, PowerPoint slide master names), the agent groups documents by template and calculates the proportion of documents per template that share each failing rule.

A "template-level fix" is flagged when the same rule fails across all documents sharing a template - this means fixing the template source will remediate all child documents automatically.

## Remediation Tracking

When baseline report data is provided (by the `compare-audits` or `audit-changed-documents` prompts), every finding is classified:

| Classification | Meaning |
|---------------|---------|
| Fixed | Present in baseline, absent in current scan |
| New | Absent in baseline, present in current scan |
| Persistent | Present in both scans |
| Regressed | A Fixed issue has returned |

Progress metrics computed:

- Total findings: baseline count -> current count -> delta
- Score: baseline average -> current average -> delta
- Velocity: projected cycles to reach zero at current fix rate

## Output Format

The agent returns a structured analysis ready for inclusion in the audit report markdown:

- Cross-document pattern summary with frequencies and classifications
- Per-document severity scores and grades (scorecard table)
- Overall average score and grade
- Template analysis section (if templates detected)
- Remediation progress summary (if baseline provided)

## Connections

| Component | Role |
|-----------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | Orchestrating wizard that calls this agent and incorporates its output into the final report |
| [document-inventory](document-inventory.md) | Runs before this agent - provides the file list the wizard scans |
| [report-generation skill](../../.github/skills/report-generation/SKILL.md) | Scoring formulas and grade table this agent implements |
| [compare-audits prompt](../prompts/documents/compare-audits.md) | User-facing prompt that triggers remediation tracking analysis |
