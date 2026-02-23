# markdown-scanner

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [markdown-a11y-assistant](markdown-a11y-assistant.md) during parallel scan phases. You do not need to invoke it directly.

## What It Does

`markdown-scanner` receives a single Markdown file path and scans it across all 9 accessibility domains, returning a structured findings object with per-domain issue lists, severity classifications, and a computed score.

## When It Runs

The `markdown-a11y-assistant` dispatches one instance of this agent per discovered file during Phase 2 of the audit. All instances run simultaneously.

## Domains Scanned

| # | Domain | WCAG | Finds |
|---|--------|------|-------|
| 1 | Links | 2.4.4 | Ambiguous text: "click here", "read more", "here", "this", bare URLs |
| 2 | Alt Text | 1.1.1 | Missing alt on `![]()`, file-name alt text, uninformative alt text |
| 3 | Headings | 1.3.1 | Skipped levels, multiple H1s, duplicate heading text |
| 4 | Tables | 1.3.1 | No preceding description paragraph, complex tables without summaries |
| 5 | Emoji | 1.3.3 | Emoji in headings, emoji as sole bullet content, consecutive emoji sequences |
| 6 | Diagrams | 1.1.1 | Mermaid blocks without preceding text description, ASCII art without description |
| 7 | Em-dashes | Cognitive | `—` and `–` without spaces (screen reader concatenation) |
| 8 | Anchors | 2.4.4 | `[text](#anchor)` links where the target heading does not exist in the file |
| 9 | Plain Language | Cognitive | Passive voice density, unexpanded acronyms on first use, very long sentences |

## Output Format

The agent returns a structured findings block the orchestrator aggregates:

```markdown
### Scan: path/to/file.md

**Score:** 82 (B)

| Domain | Severity | Line | Issue | Suggested Fix |
|--------|----------|------|-------|---------------|
| Links | Serious | 14 | "click here" - non-descriptive link text | "Download the configuration guide" |
| Headings | Critical | 32 | H2 followed by H4 - skipped H3 | Add an H3 section or change H4 to H3 |
| Emoji | Moderate | 5 | 🚀 in H1 heading - breaks anchor IDs | Remove emoji or replace with text |
```

## Scoring Formula

```text
File Score = 100 - (Critical×15 + Serious×7 + Moderate×3 + Minor×1)
Floor: 0
```
