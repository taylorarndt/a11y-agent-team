---
description: Audit multiple web pages and compare their accessibility scores. Generates a scorecard showing which pages need the most attention.
mode: agent
tools:
  - askQuestions
  - runInTerminal
  - getTerminalOutput
---

# Multi-Page Web Accessibility Comparison

Audit multiple pages of a web application and generate a comparative scorecard. Identifies systemic issues (shared across pages) vs page-specific issues.

## Instructions

Use the **web-accessibility-wizard** agent workflow:

1. Use askQuestions to ask the user:
   - "What is the base URL of your application?"
   - "Which pages should I audit? List the paths (e.g., /, /login, /dashboard, /settings)"
   - "What framework/tech stack?" - Options: React, Vue, Angular, Next.js, Svelte, Vanilla HTML/CSS/JS
   - "Audit method?" - Options: Runtime scan only, Code review only, Both

2. For each page, run the selected audit method:
   - **Runtime scan:** `npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa`
   - **Code review:** Run specialist sub-agents on the page components

3. Compute per-page severity scores (0-100) and letter grades

4. Generate the comparative report to `ACCESSIBILITY-AUDIT.md` including:
   - **Page Scorecard** - side-by-side comparison table
   - **Systemic Issues** - problems found on every page (layout/nav issues)
   - **Template Issues** - problems from shared components (fix once, fix everywhere)
   - **Page-Specific Issues** - unique to individual pages
   - **Remediation Priority** - ordered by ROI (systemic fixes first)

5. Ask: "Would you like me to fix the systemic issues that affect all pages?"
