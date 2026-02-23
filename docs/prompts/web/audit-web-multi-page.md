# audit-web-multi-page

Audit multiple pages of a web application in a single session. Generates a comparative scorecard and classifies issues as systemic (affects all pages), template-level (shared component), or page-specific.

## When to Use It

- You want to compare accessibility health across your key user journeys
- You need to know which pages have the most critical issues to prioritize remediation
- You want to identify shared component issues that can be fixed once and applied everywhere
- You are evaluating a site before a compliance deadline

## How to Launch It

**In GitHub Copilot Chat:**

```text
/audit-web-multi-page
```

The agent will collect the URLs interactively. Or provide context upfront:

```text
/audit-web-multi-page audit the main user flows: /, /login, /dashboard, /checkout
```

## What to Expect

### Step 1: Information Collection

The agent asks four questions:

1. **Base URL** - e.g., `https://myapp.com`
2. **Pages to audit** - list the paths (e.g., `/`, `/login`, `/dashboard`, `/settings`)
3. **Framework** - React, Vue, Angular, Next.js, Svelte, or Vanilla HTML/CSS/JS
4. **Audit method** - Runtime scan only, Code review only, or Both

### Step 2: Per-Page Audit

For each page, the agent runs the selected audit method and computes a severity score (0-100) and letter grade.

### Step 3: Cross-Page Analysis

The [cross-page-analyzer](../../agents/cross-page-analyzer.md) classifies all findings:

| Type | Meaning | Fix Strategy |
|------|---------|-------------|
| Systemic | Same issue on every page | Fix in shared layout - highest ROI |
| Template-level | Same issue on pages sharing a component | Fix that shared component |
| Page-specific | Unique to one page | Fix individually |

### Step 4: Comparative Report

The report is saved to `ACCESSIBILITY-AUDIT.md` with:

- **Page Scorecard** - side-by-side score table (example below)
- **Systemic Issues** - problems in the navigation, header, footer - fix once, fix everywhere
- **Template Issues** - shared component problems
- **Page-Specific Issues** - unique to individual pages
- **Remediation Priority** - ordered by ROI

**Example scorecard:**

| Page | Score | Grade | Critical | Serious | Moderate | Minor |
|------|-------|-------|---------|---------|---------|-------|
| / (Home) | 88 | B | 0 | 2 | 1 | 2 |
| /login | 72 | C | 2 | 1 | 0 | 3 |
| /dashboard | 91 | A | 0 | 1 | 0 | 1 |
| /checkout | 58 | C | 3 | 3 | 1 | 2 |

### Step 5: Remediation Offer

After the report, the agent asks: "Would you like me to fix the systemic issues that affect all pages?" - systemic fixes yield the largest improvement with the smallest effort.

## Example Variations

```text
/audit-web-multi-page
-> Base URL: https://myapp.com
-> Pages: /, /login, /dashboard, /profile, /settings
-> Framework: React
-> Method: Both
```

```text
/audit-web-multi-page
-> Pages: just the checkout flow: /cart, /checkout/shipping, /checkout/payment, /confirmation
-> Runtime scan only for speed
```

## Output Files

| File | Contents |
|------|----------|
| `ACCESSIBILITY-AUDIT.md` | Full multi-page report with scorecard and pattern classification |

## Connected Agents

| Agent | Role |
|-------|------|
| [web-accessibility-wizard](../../agents/web-accessibility-wizard.md) | Orchestrates the per-page audits |
| [cross-page-analyzer](../../agents/cross-page-analyzer.md) | Classifies systemic vs page-specific issues and builds the scorecard |

## Related Prompts

- [audit-web-page](audit-web-page.md) - single-page deep audit
- [compare-web-audits](compare-web-audits.md) - track improvement after fixing systemic issues
- [fix-web-issues](fix-web-issues.md) - apply fixes from the multi-page report
