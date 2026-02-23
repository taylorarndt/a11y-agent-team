# audit-web-page

Run a comprehensive accessibility audit on a single web page. Combines axe-core runtime scanning with a full agent-driven code review across all specialist domains.

## When to Use It

- You have a page URL and want a complete, scored audit report
- You need to produce documentation of a page's accessibility state
- You are preparing a compliance review or stakeholder report
- You want to capture a baseline before starting remediation work

## How to Launch It

**In GitHub Copilot Chat** - select from the prompt picker:

```text
/audit-web-page
```

Then provide the URL when prompted.

**Direct invocation:**

```text
/audit-web-page https://example.com/login
```

**In Claude Code:**

```text
@audit-web-page https://example.com/dashboard
```

## What to Expect

### Step 1: axe-core Runtime Scan

The agent runs axe-core against the live URL:

```bash
npx @axe-core/cli <pageUrl> --tags wcag2a,wcag2aa,wcag21a,wcag21aa --save ACCESSIBILITY-SCAN.json
```

This catches violations that appear at runtime - dynamic content, rendered ARIA states, and JavaScript-driven components that static analysis misses.

### Step 2: Code Review Phases

The web-accessibility-wizard runs 8 code review phases using specialist sub-agents:

1. DOM structure and landmark regions
2. Heading hierarchy
3. Images and alt text
4. Forms, labels, and error handling
5. Interactive elements and keyboard support
6. ARIA usage
7. Color contrast and visual design
8. Dynamic content and live regions

### Step 3: Scoring

Issues are weighted by severity and confidence. The page receives a 0-100 score and an A-F grade. See [web-severity-scoring](../../../.github/skills/web-severity-scoring/SKILL.md) for the full formula.

### Step 4: Report Generation

The full audit is written to `ACCESSIBILITY-AUDIT.md` in your workspace. The report includes:

- Page score and grade
- Severity breakdown (Critical / Serious / Moderate / Minor)
- Each finding: description, WCAG criterion, affected element, fix guidance
- Confidence levels (High / Medium / Low)
- Framework-specific fix examples (React / Vue / Angular / Svelte)

### Step 5: Interactive Fix Mode

After the report is generated, the agent offers: "Want me to apply auto-fixable issues?" - triggering the [web-issue-fixer](../../agents/web-issue-fixer.md) for safe, deterministic fixes.

## Example Variations

```text
/audit-web-page https://myapp.com                        # Home page
/audit-web-page https://myapp.com/checkout              # Checkout flow
/audit-web-page https://myapp.com/admin/users           # Admin page
/audit-web-page https://staging.myapp.com/product/123   # Staging URL
```

## Output Files

| File | Contents |
|------|----------|
| `ACCESSIBILITY-AUDIT.md` | Full report with findings, scores, and fix guidance |
| `ACCESSIBILITY-SCAN.json` | Raw axe-core output (intermediate file, can be deleted) |

## Connected Agents

| Agent | Role |
|-------|------|
| [web-accessibility-wizard](../../agents/web-accessibility-wizard.md) | The agent that executes this prompt |
| [web-issue-fixer](../../agents/web-issue-fixer.md) | Applies fixes after the audit |
| [cross-page-analyzer](../../agents/cross-page-analyzer.md) | Used when auditing multiple pages |

## Related Prompts

- [quick-web-check](quick-web-check.md) - faster, no code review, no saved file
- [audit-web-multi-page](audit-web-multi-page.md) - audit multiple pages at once
- [fix-web-issues](fix-web-issues.md) - apply fixes from an existing audit report
- [compare-web-audits](compare-web-audits.md) - track progress after remediation
