# quick-web-check

Fast accessibility triage - runs axe-core against a live URL and returns an inline pass/fail verdict with a score. No code review, no saved file. The fastest way to check a page.

## When to Use It

- You want a quick sanity check before a demo or release
- You need a fast signal on whether a page has critical issues
- You are triaging a list of pages to know which ones need deeper review
- You want to check a page during development without the full audit overhead

## How to Launch It

**In GitHub Copilot Chat:**

```text
/quick-web-check https://example.com
```

**In Claude Code:**

```text
@quick-web-check https://myapp.com/login
```

## What to Expect

The agent runs axe-core immediately - no setup questions, no configuration:

```bash
npx @axe-core/cli <pageUrl> --tags wcag2a,wcag2aa,wcag21a,wcag21aa
```

Results appear inline in chat within seconds:

```text
Quick Check: https://example.com/login
Score: 74 (C)

Violations: 5
  Critical: 1
  Serious:  2
  Moderate: 1
  Minor:    1

Top Issues:
  1. color-contrast - Insufficient contrast on input placeholder text - Serious
  2. label - Missing accessible name on password input - Critical
  3. button-name - Icon button has no accessible name - Serious

Rules Passed: 38

Verdict: NEEDS WORK - 1 critical violation found
```

**Verdict thresholds:**

| Verdict | Condition |
|---------|-----------|
| PASS | Zero critical and zero serious violations |
| NEEDS WORK | 1-3 serious violations, no critical |
| FAIL | Any critical violation, or 4+ serious |

## The Escalation Offer

If issues are found, the agent asks: "Want to run a full audit with code review and remediation steps?" - one word to launch [audit-web-page](audit-web-page.md) on the same URL.

## Example Variations

```text
/quick-web-check https://myapp.com                    # Check the home page
/quick-web-check https://myapp.com/checkout/step-2   # Check a specific step
/quick-web-check https://staging.myapp.com           # Check staging before push
```

## Connected Agents

| Agent | Role |
|-------|------|
| [web-accessibility-wizard](../../agents/web-accessibility-wizard.md) | Executes the axe-core scan and formats the result |

## Related Prompts

- [audit-web-page](audit-web-page.md) - full audit with code review and saved report
- [audit-web-multi-page](audit-web-multi-page.md) - run quick checks across multiple pages
