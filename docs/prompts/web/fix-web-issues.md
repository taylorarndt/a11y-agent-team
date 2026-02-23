# fix-web-issues

Interactive fix mode - reads an audit report and applies accessibility fixes. Safe, deterministic issues are applied automatically. Issues requiring judgment are shown one at a time for your approval.

## When to Use It

- You have an audit report and want to start fixing
- You want a guided, issue-by-issue fix workflow without manually hunting through files
- You want to apply safe fixes automatically and then review the trickier ones
- You want the agent to re-verify fixes by re-running axe-core after applying them

## How to Launch It

**In GitHub Copilot Chat:**

```text
/fix-web-issues
```

Or specify the report path:

```text
/fix-web-issues ACCESSIBILITY-AUDIT.md
```

## What to Expect

### Step 1: Configuration

The agent asks two questions:

1. **Report path** - which audit report to use (default: `ACCESSIBILITY-AUDIT.md`)
2. **Fix mode:**
   - **Fix all auto-fixable issues** - apply safe fixes without asking (fastest)
   - **Fix issues one by one** - show each fix for approval before applying
   - **Fix a specific issue** - pick by issue number from the report

### Step 2: Categorization

The agent reads the report and divides all issues into two buckets:

**Auto-fixable (applied without asking):**

| Issue | Fix |
|-------|-----|
| Missing `lang` on `<html>` | Add `lang="en"` |
| Missing viewport meta | Add responsive viewport meta tag |
| `<img>` without `alt` | Add `alt=""` for decorative; prompt for content images |
| Positive `tabindex` | Replace with `tabindex="0"` or remove |
| `outline: none` | Add `outline: 2px solid` with `:focus-visible` |
| Missing `<label>` | Add label with matching `for`/`id` |
| Missing `scope` on `<th>` | Add `scope="col"` or `scope="row"` |
| Missing `autocomplete` | Add appropriate value |
| New-tab link without warning | Add visually hidden `(opens in new tab)` text |

**Human-judgment (shown for approval):**

- Alt text content for meaningful images - only you know the purpose
- Heading hierarchy restructuring - affects visual design
- Link text rewriting - UX copy decision
- ARIA role assignment - depends on intended interaction
- Live region placement - depends on UX intent

### Step 3: Framework-Aware Fixes

The agent detects your stack (React, Vue, Angular, Svelte, HTML) and generates correct syntax for each fix. No JSX in Vue files, no `for` attributes as `htmlFor` in plain HTML.

### Step 4: Fix Output

Each applied fix is reported:

```text
Fix #1: label - Missing label for email input
  File: src/components/LoginForm.jsx:18
  Before: <input type="email" placeholder="Email" />
  After:  <label htmlFor="email">Email address</label>
          <input type="email" id="email" placeholder="Email" autoComplete="email" />
  Status: Applied

Fix #2: color-contrast - Placeholder text low contrast
  File: src/styles/forms.css:42
  Status: Needs approval - color changes may conflict with brand guidelines
```

### Step 5: Verification

After applying fixes, if a URL is available, the agent re-runs axe-core to confirm the issues are resolved and reports the updated score.

```text
Fixes Applied: 8
Verified by re-scan: 7/8 passed
Issues remaining: 4 (require manual attention)

Updated score: 72 -> 91 (+19 points, C -> A)
```

The audit report is updated with a "Fixes Applied" section.

## Example Variations

```text
/fix-web-issues                                  # Use default ACCESSIBILITY-AUDIT.md
/fix-web-issues reports/audit-jan.md             # Use a specific report
/fix-web-issues -> Fix mode: Fix all auto-fixable  # Apply auto-fixes without prompts
/fix-web-issues -> Fix mode: Fix issues one by one # Approve each before applying
```

## Connected Agents

| Agent | Role |
|-------|------|
| [web-issue-fixer](../../agents/web-issue-fixer.md) | Applies the actual code changes |
| [web-accessibility-wizard](../../agents/web-accessibility-wizard.md) | Orchestrates the workflow and verification scan |

## Related Prompts

- [audit-web-page](audit-web-page.md) - generate the audit report this prompt reads
- [compare-web-audits](compare-web-audits.md) - track progress after running fixes
