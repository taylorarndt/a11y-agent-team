# Example Project — Intentional Accessibility Issues

This is a **deliberately broken** web page with common accessibility problems. Use it to test the A11y Agent Team and see how the agents catch and fix real issues.

## What's Wrong Here?

The `index.html` page contains **20+ intentional accessibility violations** across every category the agents cover:

| Category | Issues |
|---|---|
| **Images & Alt Text** | Missing alt, decorative images not hidden |
| **Headings** | Skipped levels, multiple H1s, empty heading |
| **Links** | Ambiguous text ("click here", "read more"), URL-as-text |
| **Forms** | Missing labels, no autocomplete, no fieldset for radio groups |
| **Keyboard** | Positive tabindex, outline removed, div used as button |
| **ARIA** | Missing live region on dynamic content |
| **Contrast** | Low-contrast text, color-only indicators |
| **Motion** | Animation without prefers-reduced-motion |
| **Focus** | Focus not managed on modal, no skip link |

## How to Use

### With Claude Code
```bash
# Open this example directory
cd example

# Ask Claude to audit it
# "Review index.html for accessibility issues"
# "Run the accessibility-wizard on this page"
```

### With GitHub Copilot
```
@workspace /accessibility-wizard Review example/index.html
@workspace /contrast-master Check the colors in example/index.html
@workspace /forms-specialist Audit the form in example/index.html
```

### With the MCP Tools
```
# Check heading structure
check_heading_structure with the HTML from index.html

# Check link text
check_link_text with the HTML from index.html

# Check form labels
check_form_labels with the HTML from index.html

# Run axe-core scan
run_axe_scan on example/index.html
```

### With the CI Workflow
```bash
# Run the lint script directly
node .github/scripts/a11y-lint.mjs example/
```

## Expected Findings

When all issues are fixed, matching the patterns in `index-fixed.html`, the agents should report a clean audit. Use this as a learning tool — see how many issues you can identify before running the agents, then compare.
