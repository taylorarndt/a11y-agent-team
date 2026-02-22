# axe-core Integration

The agents review your code and enforce accessibility patterns during development. [axe-core](https://github.com/dequelabs/axe-core) tests the rendered page in a real browser. Together, they cover both sides: code-time enforcement and runtime verification.

## Three Levels of Integration

1. **MCP tool (`run_axe_scan`)** — Agents trigger axe-core scans programmatically via the MCP server
2. **Agent instructions** — The testing-coach and accessibility-wizard know when and how to run scans
3. **VS Code task** — Manual scan trigger in the VS Code command palette

## How the MCP Tool Works

The `run_axe_scan` tool:

1. Takes a URL (your running dev server), an optional CSS selector, and an optional report file path
2. Runs `@axe-core/cli` against the live page
3. Parses the JSON results
4. Returns violations grouped by severity (Critical > Serious > Moderate > Minor)
5. Includes affected HTML elements, WCAG criteria, and fix suggestions
6. When `reportPath` is provided, writes a structured markdown report to that file

**Prerequisites:**

```bash
npm install -g @axe-core/cli
```

## Report Generation

The tool generates markdown reports with:

- Scan metadata (URL, date, standard, scanner)
- Summary table of violations by severity
- Each violation with WCAG criteria, help link, and affected elements
- HTML snippets showing problematic code
- Fix suggestions from axe-core

**Output files:**

| File | Written By | Contents |
|------|-----------|----------|
| `ACCESSIBILITY-SCAN.md` | `run_axe_scan` tool | Raw axe-core scan results |
| `ACCESSIBILITY-AUDIT.md` | accessibility-wizard | Consolidated: agent review + axe-core, deduplicated, with fixes |

## How Agents Use It

The **accessibility-wizard** (Phase 9) asks if you have a dev server running and triggers a scan:

```
/accessibility-wizard run a full audit on this project
@accessibility-wizard audit this project for accessibility
```

The **testing-coach** runs ad-hoc scans:

```
/testing-coach run an axe-core scan on http://localhost:3000/dashboard
@testing-coach scan http://localhost:3000/checkout for accessibility issues
```

**Any agent** can interpret results you feed manually:

```bash
npx @axe-core/cli http://localhost:3000 --save results.json
```

```
/accessibility-lead triage the violations in results.json
```

## CI/CD Pipeline

**GitHub Actions:**

```yaml
- name: Run axe-core accessibility tests
  run: |
    npx @axe-core/cli http://localhost:3000 \
      --tags wcag2a,wcag2aa,wcag21a,wcag21aa \
      --exit
```

**Test framework packages:**

```bash
npm install --save-dev @axe-core/playwright   # Playwright
npm install --save-dev cypress-axe axe-core   # Cypress
npm install --save-dev jest-axe               # Jest (React)
```

## What Catches What

| Issue Type | Agents | axe-core | Manual Testing |
|-----------|--------|---------|----------------|
| Missing alt text | Yes | Yes | Yes |
| ARIA pattern correctness | Yes | Partial | Yes |
| Computed contrast ratios | No | Yes | Yes |
| Focus management logic | Yes | No | Yes |
| Live region timing | Yes | No | Yes |
| Tab order design | Yes | No | Yes |
| Keyboard trap detection | Yes | No | Yes |
| Third-party widget issues | No | Yes | Yes |
| Screen reader UX | No | No | Yes |

**Agents** catch ~70% of issues during code generation. **axe-core** catches some of the remaining issues by testing the rendered DOM. **Manual testing** covers what tools cannot.
