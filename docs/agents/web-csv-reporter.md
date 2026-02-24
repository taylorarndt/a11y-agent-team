# web-csv-reporter

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [web-accessibility-wizard](web-accessibility-wizard.md) and [cross-page-analyzer](cross-page-analyzer.md) during CSV export workflows. You do not need to invoke it directly - use the `export-web-csv` prompt instead.

## What It Does

`web-csv-reporter` converts web accessibility audit findings into structured CSV files with Deque University help documentation links for every issue. It reads a completed `ACCESSIBILITY-AUDIT.md` report and produces up to three CSV files that can be opened in Excel, Google Sheets, or imported into issue trackers.

Each row includes a direct link to the Deque University help page for the specific axe-core rule, giving teams immediate access to remediation guidance without leaving their spreadsheet.

## When It Runs

This agent is called by:

- `export-web-csv` prompt - the primary user-facing CSV export workflow
- `web-accessibility-wizard` - when CSV export is requested after an audit
- `cross-page-analyzer` - when exporting multi-page comparison data

## CSV Schemas

The agent produces three CSV file types:

### Findings CSV (`web-findings.csv`)

One row per issue found in the audit:

| Column | Description |
|--------|-------------|
| Page URL | The page where the issue was found |
| Element | CSS selector or HTML snippet identifying the element |
| Rule ID | axe-core rule identifier (e.g., `color-contrast`, `image-alt`) |
| Rule Description | Human-readable description of the violation |
| WCAG SC | WCAG success criterion (e.g., `1.4.3`) |
| Impact | Critical, Serious, Moderate, or Minor |
| Confidence | High, Medium, or Low |
| Help URL | Deque University documentation link for the rule |
| Remediation | Suggested fix description |
| Element HTML | The HTML of the failing element |

### Scorecard CSV (`web-scorecard.csv`)

One row per audited page:

| Column | Description |
|--------|-------------|
| Page URL | The audited page |
| Score | Numeric score (0-100) |
| Grade | Letter grade (A-F) |
| Critical | Count of critical issues |
| Serious | Count of serious issues |
| Moderate | Count of moderate issues |
| Minor | Count of minor issues |
| Top Issue | Most impactful finding on this page |

### Remediation CSV (`web-remediation.csv`)

Prioritized action items:

| Column | Description |
|--------|-------------|
| Priority | Immediate, Soon, or When Possible |
| Rule ID | axe-core rule identifier |
| Affected Pages | Count of pages with this issue |
| Impact | Severity level |
| Effort | Estimated effort (Low, Medium, High) |
| ROI Score | Impact-to-effort ratio |
| Help URL | Deque University documentation link |
| Fix Description | What to do |

## Help URL Pattern

All Deque University links follow the pattern:

```
https://dequeuniversity.com/rules/axe/4.10/{rule-id}
```

For example, `color-contrast` maps to `https://dequeuniversity.com/rules/axe/4.10/color-contrast`.

## CSV Conventions

- **Encoding:** UTF-8 with BOM (byte order mark) for Excel compatibility
- **Line endings:** CRLF
- **Text fields:** Double-quoted
- **Internal quotes:** Escaped by doubling (`""`)
- **HTML in cells:** Stripped to plain text except in Element HTML column

## Connections

| Component | Role |
|-----------|------|
| [web-accessibility-wizard](web-accessibility-wizard.md) | Parent orchestrator that triggers CSV export |
| [cross-page-analyzer](cross-page-analyzer.md) | Provides multi-page data for export |
| [help-url-reference](../skills/help-url-reference.md) | Skill providing Deque University URL mappings |
| [export-web-csv](../prompts/web/export-web-csv.md) | User-facing prompt that invokes this agent |
