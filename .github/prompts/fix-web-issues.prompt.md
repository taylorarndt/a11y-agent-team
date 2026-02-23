---
description: Fix accessibility issues from a previous audit report. Applies auto-fixable changes and walks through human-judgment fixes one by one.
mode: agent
tools:
  - askQuestions
  - runInTerminal
  - getTerminalOutput
---

# Fix Web Accessibility Issues

Interactive fix mode — reads a previous audit report and applies fixes. Auto-fixable issues are applied automatically; human-judgment issues are presented one at a time for approval.

## Instructions

Use the **web-accessibility-wizard** agent's interactive fix mode:

1. Use askQuestions to ask:
   - "What is the path to the audit report?" — default: `ACCESSIBILITY-AUDIT.md`
   - "What fix mode do you want?"
     - **Fix all auto-fixable issues** — apply safe fixes without asking
     - **Fix issues one by one** — show each fix, let me approve or skip
     - **Fix a specific issue** — let me pick by issue number

2. Read the audit report and categorize issues:

   **Auto-fixable (safe to apply):**
   - Missing `lang` attribute → add `lang="en"`
   - Missing viewport meta → add responsive viewport
   - `<img>` without `alt` → add `alt=""` for decorative
   - Positive `tabindex` values → replace with `tabindex="0"`
   - `outline: none` without alternative → add focus-visible styles
   - Missing `<label>` → add label with `for` attribute
   - Missing `scope` on `<th>` → add `scope="col"` or `scope="row"`
   - Missing `autocomplete` → add appropriate value
   - New tab links without warning → add visually hidden text

   **Human-judgment (present for approval):**
   - Alt text content for meaningful images
   - Heading hierarchy restructuring
   - Link text rewriting
   - ARIA role assignment
   - Live region placement

3. Apply fixes using the detected framework's syntax (React JSX, Vue template, Angular template, etc.)

4. After all fixes, if a URL is available, re-run axe-core to verify:
   ```bash
   npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa
   ```

5. Report results:
   ```
   Fixes Applied: [count]
   Verified by re-scan: [count passed] / [count total]
   Issues remaining: [count] (require manual attention)
   
   Updated score: [previous] → [current] ([+/-] points)
   ```

6. Update the audit report with a "Fixes Applied" section.
