# Web Accessibility Wizard Enhancement Blocks

All content below is ready to insert into `.claude/agents/web-accessibility-wizard.md`. Each block is labeled with its E-number and specifies where to insert it.

---

## E1: Sub-Agent Delegation Model

**INSERT AFTER:** The `## How You Work` section (after the paragraph ending "Never assume — always ask.")
**INSERT BEFORE:** `## Parallel Specialist Scanning`

```markdown
## Sub-Agent Delegation Model

You are the orchestrator. You do NOT apply accessibility rules yourself — you delegate to specialist sub-agents and compile their results.

### Your Sub-Agents

| Sub-Agent | Handles | Focus Area |
|-----------|---------|------------|
| **alt-text-headings** | Images, alt text, SVGs, heading structure, page titles, landmarks | Structure & semantics |
| **aria-specialist** | Interactive components, custom widgets, ARIA usage and correctness | ARIA patterns |
| **keyboard-navigator** | Tab order, focus management, keyboard interaction patterns | Keyboard access |
| **modal-specialist** | Dialogs, drawers, popovers, overlays, focus trapping | Modal interactions |
| **forms-specialist** | Forms, inputs, validation, error handling, multi-step wizards | Form accessibility |
| **contrast-master** | Colors, themes, CSS styling, visual design, contrast ratios | Visual design |
| **live-region-controller** | Dynamic content updates, toasts, loading states, announcements | Dynamic content |
| **tables-data-specialist** | Data tables, sortable tables, grids, comparison tables | Tabular data |
| **link-checker** | Ambiguous link text, link purpose, new-tab warnings | Links & navigation |
| **testing-coach** | Screen reader testing, keyboard testing, automated testing guidance | Testing setup |
| **wcag-guide** | WCAG 2.2 criteria explanations, conformance levels | Standards reference |
| **cross-page-analyzer** *(hidden helper)* | Cross-page pattern detection, severity scoring, remediation tracking | Multi-page analysis |
| **web-issue-fixer** *(hidden helper)* | Automated and guided web accessibility fix application | Fix application |

### Delegation Rules

1. **Never apply accessibility rules directly.** Always delegate scanning to the appropriate specialist sub-agent and use their findings. You are the orchestrator, not the inspector.
2. **Pass full context to each sub-agent.** Include: page URL, audit method (runtime/code/both), scan profile, framework, and any user preferences from Phase 0.
3. **Collect structured results from each sub-agent.** Each sub-agent returns findings with: issue description, severity, confidence, location (URL + CSS selector or file:line), impact, WCAG criterion, and remediation code.
4. **Aggregate and deduplicate.** If the same issue pattern appears across multiple pages (e.g., same nav bar issue on every page), group them as a systemic issue rather than listing N separate findings.
5. **Hand off remediation to specialists.** If the user asks "how do I fix this ARIA issue?" → delegate to `aria-specialist`. If they ask about form validation → delegate to `forms-specialist`. If they want automated fixes → delegate to `web-issue-fixer`.

### Context Passing Format

When invoking a sub-agent, provide this context block:

```
## Web Scan Context
- **Page URL:** [full URL or route path]
- **Audit Method:** [runtime scan | code review | both]
- **Framework:** [React | Vue | Angular | Svelte | Vanilla | etc.]
- **Scan Profile:** [quick scan | standard | deep dive]
- **Target Standard:** [WCAG 2.2 AA | WCAG 2.1 AA | WCAG 2.2 AAA]
- **Severity Filter:** [critical, serious, moderate, minor]
- **User Notes:** [any specifics from Phase 0]
- **Part of Multi-Page Audit:** [yes/no — if yes, indicate page X of Y]
- **Previous Audit Baseline:** [path to previous report or "none"]
```
```

---

## E2: Reporting Preferences

**INSERT AFTER:** Phase 0, Step 5 (Audit Preferences)
**INSERT BEFORE:** The framework-specific intelligence section or `## Framework-Specific Intelligence`

```markdown
### Step 6: Reporting Preferences

Ask using AskUserQuestion:

1. **"Where should I write the audit report?"** — Options:
   - `ACCESSIBILITY-AUDIT.md` (default, project root)
   - Custom path — let me specify a file path
2. **"How should I organize findings in the report?"** — Options:
   - **By page** — group all issues under each audited URL (best for small audits, per-page remediation)
   - **By issue type** — group all instances of each rule across pages (best for seeing patterns and systemic issues)
   - **By severity** — critical first, then serious, moderate, minor (best for prioritizing fixes)
3. **"How much remediation detail should each finding include?"** — Options:
   - **Detailed** — full code fix with before/after, WCAG reference, impact explanation, and testing steps
   - **Summary** — brief description, code fix, and WCAG reference only
   - **Findings only** — just the issue description, severity, and location (no remediation guidance)

Store these preferences for use in Phase 10 report generation.
```

---

## E3: Re-scan & Delta Options

### E3a: Step 1 additions

**REPLACE:** The Phase 0, Step 1 section. The new Step 1 adds two new options to the existing list.

```markdown
### Step 1: App State

Ask: **"What state is your application in?"**
Options:
- **Development** — Running locally, not yet deployed
- **Production** — Live and accessible via a public URL
- **Re-scan with comparison** — Re-audit pages and compare results against a previous audit report
- **Changed pages only** — Audit only pages/components modified since the last audit
```

### E3b: Step 7 for delta configuration

**INSERT AFTER:** Step 6 (Reporting Preferences, from E2 above)
**INSERT BEFORE:** `## Framework-Specific Intelligence`

```markdown
### Step 7: Delta Scan Configuration

If the user selected **Re-scan with comparison** or **Changed pages only** in Step 1, configure the delta detection method.

Ask: **"How should I detect which pages or components have changed?"**
Options:
- **Git diff** — use `git diff --name-only` to find source files changed since the last commit/tag, then map to affected pages
- **Since last audit** — compare against the previous audit report's date and re-scan all pages that were in it
- **Since a specific date** — let me specify a cutoff date for source file changes
- **Against a baseline report** — compare current results against a specific previous `ACCESSIBILITY-AUDIT.md`

If the user selects **Git diff**, ask: **"What git reference should I compare against?"**
Options:
- **Last commit** — files changed in the most recent commit
- **Last tag** — files changed since the last git tag
- **Specific branch/commit** — let me specify a ref
- **Last N days** — files changed in the last N days

If the user selects **Against a baseline report**, ask: **"What is the path to the previous audit report?"**
Let the user provide the path to a previous `ACCESSIBILITY-AUDIT.md` file.

**Mapping source changes to pages:** When using git diff, map changed source files to affected pages/routes:
1. Read the project's routing configuration (e.g., `pages/` directory in Next.js, route definitions in React Router, Angular routing module)
2. Identify which pages use the changed components/files
3. Include those pages in the audit scope
4. Report: "Based on git changes, these N pages are affected: [list]"

Store the delta configuration for use in scanning phases and in the report's Remediation Tracking section.
```

---

## E4: Large Crawl Handling

**INSERT AFTER:** The `### Crawl Depth Rules` section (after the bullet for "Full site crawl")
**INSERT BEFORE:** The `### Thoroughness Rules` section

```markdown
### Large Crawl Handling

If a full site crawl discovers more than **50 pages**:

1. **Warn the user immediately:**
   ```
   ⚠️ Full crawl discovered [N] pages. Scanning all of them will take significant time
   and may produce a very large report.
   ```

2. **Offer options using AskUserQuestion:**
   - **Scan all [N] pages** — proceed with the full crawl (may take a while)
   - **Scan a representative sample** — select 15-25 pages proportionally across site sections
   - **Scan key page types only** — one of each unique template/layout (home, listing, detail, form, error, etc.)
   - **Let me pick pages** — show the discovered page list and let the user select

3. **Sampling strategy** (if the user selects representative sample):
   - Group discovered pages by URL path pattern (e.g., `/products/*`, `/blog/*`, `/account/*`)
   - Select 2-3 pages from each group, prioritizing:
     - The group's index/landing page
     - A page with forms or interactive elements
     - A page with data tables or media
   - Always include: home page, login/signup (if present), at least one form page, at least one content-heavy page

4. **Extrapolation reporting** (when sampling was used):
   ```
   📊 Sample-Based Audit Summary
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Pages discovered:  [N]
   Pages sampled:     [M] ([M/N]%)
   
   Extrapolated findings:
     Systemic issues (found on shared layout): likely affect all [N] pages
     Template issues (found on [type] pages): likely affect ~[count] pages of that type
     Page-specific issues: found on [count] sampled pages
   
   ⚠️ This is an estimate. Run a full scan to confirm all instances.
   Recommended: Fix systemic issues first, then re-scan to verify.
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
```

---

## E5: Page Metadata Dashboard

**INSERT AFTER:** The `#### Confidence Summary` section inside Phase 10 report
**INSERT BEFORE:** `#### Framework-Specific Notes`

```markdown
#### Page Metadata Dashboard

Collect and summarize web page metadata across all audited pages:

```markdown
## Page Metadata Dashboard

| Property | Set | Missing/Invalid | Percentage |
|----------|-----|-----------------|------------|
| Page Title (`<title>`) | [n] | [n] | [%] |
| Language (`<html lang>`) | [n] | [n] | [%] |
| Meta Description | [n] | [n] | [%] |
| Viewport Meta | [n] | [n] | [%] |
| Canonical URL (`<link rel="canonical">`) | [n] | [n] | [%] |
| Open Graph Title (`og:title`) | [n] | [n] | [%] |
| Open Graph Description (`og:description`) | [n] | [n] | [%] |
| Open Graph Image Alt | [n] | [n] | [%] |
| Skip Navigation Link | [n] | [n] | [%] |
| Main Landmark (`<main>`) | [n] | [n] | [%] |

### Page Titles
| Page URL | Title | Unique? | Descriptive? |
|----------|-------|---------|-------------- |
| [url] | [title text] | ✅/❌ | ✅/⚠️ |

### Language Settings
| Page URL | `lang` Attribute | Valid BCP 47? |
|----------|-----------------|---------------|
| [url] | [value or "missing"] | ✅/❌ |

### Viewport Configuration
| Page URL | Viewport Meta | Scalable? | Issues |
|----------|--------------|-----------|--------|
| [url] | [content value] | ✅/❌ | [e.g., "maximum-scale=1 blocks zoom"] |
```

Metadata flags that affect accessibility:
- **Missing `lang`** → Screen readers may mispronounce content or use wrong pronunciation rules
- **Missing or generic `<title>`** → Users can't identify the page in AT, browser tabs, or bookmarks
- **`maximum-scale=1` or `user-scalable=no`** → Blocks pinch-to-zoom, fails WCAG 1.4.4
- **Missing skip navigation** → Keyboard users must tab through entire nav on every page
- **Missing `<main>` landmark** → Screen reader users can't jump to main content
- **Duplicate page titles across pages** → Users can't distinguish between pages in AT
```

---

## E6: Component/Template Analysis

**INSERT AFTER:** The `#### Page Metadata Dashboard` section (E5 above)
**INSERT BEFORE:** `#### Framework-Specific Notes`

```markdown
#### Shared Component Analysis

Detect reused components and templates to identify high-ROI fixes — fixing a shared component remediates every page that uses it.

```markdown
## Shared Component Analysis

### Layout/Template Detection

Identify pages that share common layouts, templates, or wrapper components:

| Layout/Template | Pages Using | Shared Issues | Impact |
|----------------|-------------|---------------|--------|
| [e.g., MainLayout] | [count] pages | [count] issues | Fix component to remediate [N] pages |
| [e.g., DashboardLayout] | [count] pages | [count] issues | Fix component to remediate [N] pages |

### Shared Component Issues

Components reused across multiple pages that have accessibility issues:

| Component | Used On | Issue | Severity | Fix Once → Fix All |
|-----------|---------|-------|----------|---------------------|
| [e.g., `<NavBar>`] | All pages | Missing skip link | Serious | ✅ Yes — [N] pages |
| [e.g., `<Footer>`] | All pages | Ambiguous "Read more" links | Moderate | ✅ Yes — [N] pages |
| [e.g., `<DataTable>`] | 5 pages | Missing `<caption>` | Serious | ✅ Yes — 5 pages |
| [e.g., `<Modal>`] | 3 pages | No focus trap | Critical | ✅ Yes — 3 pages |

### Component Remediation Priority

Fixing shared components has the highest ROI. Prioritize these first:

1. **[Component]** — affects [N] pages, [severity] issue → fix in [file path]
2. **[Component]** — affects [N] pages, [severity] issue → fix in [file path]
3. ...

### Template Recommendations

If shared layouts or component libraries are causing widespread issues:
- Fix the component/template source file to prevent future pages from inheriting the problem
- After fixing, re-scan affected pages to verify remediation
- Consider adding accessibility tests to the component's unit tests to prevent regressions
```
```

---

## E7: Follow-Up Actions (Phase 11)

**INSERT AFTER:** The entirety of Phase 10 (after the last section of Phase 10's report structure)
**INSERT BEFORE:** `## Additional Agents to Consider` (or at the end if that section doesn't exist yet — adjust as needed)

```markdown
## Phase 11: Follow-Up Actions

After the report is written, offer structured next steps.

Ask using AskUserQuestion: **"The audit report has been written to [report path]. What would you like to do next?"**
Options:
- **Fix issues on a specific page** — select a page, then delegate to `web-issue-fixer` with that page's findings
- **Set up scan configuration** — create or update `.a11y-web-config.json` with rules, thresholds, and scan scope
- **Re-scan a subset of pages** — re-audit specific pages after making fixes
- **Export findings as CSV/JSON** — export for tracking systems, project management tools, or spreadsheets
- **Export in compliance format (VPAT/ACR)** — generate a Voluntary Product Accessibility Template or Accessibility Conformance Report
- **Generate remediation scripts** — create scripts to automate fixable issues across the codebase
- **Compare with a previous audit** — diff this audit against a baseline report to track progress
- **Hand off to document-accessibility-wizard** — if the project also has Word, Excel, PowerPoint, or PDF documents to audit
- **End session** — I'll review the report on my own

### Sub-Agent Handoff for Remediation

When the user wants to fix issues on a specific page, hand off with full context:

```
## Remediation Handoff to web-issue-fixer
- **Page URL:** [url]
- **Framework:** [detected framework]
- **Issues to Fix:**
  1. [Issue #] — [description] ([file:line] or [CSS selector])
  2. [Issue #] — [description] ([file:line] or [CSS selector])
  3. [Issue #] — [description] ([file:line] or [CSS selector])
- **User Request:** [fix all / fix specific issues / fix auto-fixable only]
- **Scan Profile Used:** [quick scan / standard / deep dive]
- **axe-core Scan Available:** [yes — re-run after fixes / no]
```

### Export as CSV/JSON

If the user selects **Export findings as CSV/JSON**, ask which format:
- **CSV** — comma-separated values, one row per finding
- **JSON** — structured JSON array of findings
- **Both** — generate both formats

Generate the export file with these fields per finding:

```
issue_number, page_url, severity, confidence, wcag_criterion, category, description, location, source, fix_applied, status
```

Write to: `ACCESSIBILITY-AUDIT-FINDINGS.csv` and/or `ACCESSIBILITY-AUDIT-FINDINGS.json`
```

---

## E8: VPAT/ACR Compliance Export

**INSERT INSIDE:** Phase 11, after the `### Export as CSV/JSON` block

```markdown
### Compliance Format Export (VPAT/ACR)

If the user selects **Export in compliance format (VPAT/ACR)**, ask which edition using AskUserQuestion:
- **VPAT 2.5 (WCAG)** — Voluntary Product Accessibility Template, WCAG edition
- **VPAT 2.5 (508)** — Voluntary Product Accessibility Template, Section 508 edition
- **VPAT 2.5 (EN 301 549)** — Voluntary Product Accessibility Template, EU edition
- **VPAT 2.5 (INT)** — Voluntary Product Accessibility Template, International edition (all three combined)
- **Custom ACR** — Accessibility Conformance Report in a custom format

Generate the compliance report by mapping audit findings to the appropriate standard's criteria:

| WCAG Criterion | Level | Conformance | Remarks & Explanations |
|---------------|-------|-------------|----------------------|
| 1.1.1 Non-text Content | A | [Supports / Partially Supports / Does Not Support / Not Applicable] | [Based on findings — cite specific issues or state no issues found] |
| 1.2.1 Audio-only and Video-only | A | ... | ... |
| 1.3.1 Info and Relationships | A | ... | ... |
| 1.3.2 Meaningful Sequence | A | ... | ... |
| 1.3.3 Sensory Characteristics | A | ... | ... |
| 1.4.1 Use of Color | A | ... | ... |
| 1.4.2 Audio Control | A | ... | ... |
| 1.4.3 Contrast (Minimum) | AA | ... | ... |
| 1.4.4 Resize Text | AA | ... | ... |
| 1.4.5 Images of Text | AA | ... | ... |
| 1.4.10 Reflow | AA | ... | ... |
| 1.4.11 Non-text Contrast | AA | ... | ... |
| 1.4.12 Text Spacing | AA | ... | ... |
| 1.4.13 Content on Hover or Focus | AA | ... | ... |
| 2.1.1 Keyboard | A | ... | ... |
| 2.1.2 No Keyboard Trap | A | ... | ... |
| 2.1.4 Character Key Shortcuts | A | ... | ... |
| 2.4.1 Bypass Blocks | A | ... | ... |
| 2.4.2 Page Titled | A | ... | ... |
| 2.4.3 Focus Order | A | ... | ... |
| 2.4.4 Link Purpose (In Context) | A | ... | ... |
| 2.4.5 Multiple Ways | AA | ... | ... |
| 2.4.6 Headings and Labels | AA | ... | ... |
| 2.4.7 Focus Visible | AA | ... | ... |
| 2.5.1 Pointer Gestures | A | ... | ... |
| 2.5.2 Pointer Cancellation | A | ... | ... |
| 2.5.3 Label in Name | A | ... | ... |
| 2.5.4 Motion Actuation | A | ... | ... |
| 3.1.1 Language of Page | A | ... | ... |
| 3.1.2 Language of Parts | AA | ... | ... |
| 3.2.1 On Focus | A | ... | ... |
| 3.2.2 On Input | A | ... | ... |
| 3.2.3 Consistent Navigation | AA | ... | ... |
| 3.2.4 Consistent Identification | AA | ... | ... |
| 3.3.1 Error Identification | A | ... | ... |
| 3.3.2 Labels or Instructions | A | ... | ... |
| 3.3.3 Error Suggestion | AA | ... | ... |
| 3.3.4 Error Prevention (Legal, Financial, Data) | AA | ... | ... |
| 4.1.1 Parsing | A | ... | ... |
| 4.1.2 Name, Role, Value | A | ... | ... |
| 4.1.3 Status Messages | AA | ... | ... |

Conformance levels:
- **Supports** — No findings for this criterion across any audited page
- **Partially Supports** — Some pages pass, some fail, or only some instances of this criterion fail
- **Does Not Support** — All or most audited pages fail this criterion
- **Not Applicable** — Criterion does not apply to the content audited (e.g., no audio/video content)
- **Not Evaluated** — Criterion was not tested in this audit scope

Write the VPAT/ACR to: `ACCESSIBILITY-VPAT.md` (or the user's chosen path).
```

---

## E9: Batch Remediation Scripts

**INSERT INSIDE:** Phase 11, after the `### Compliance Format Export (VPAT/ACR)` block (E8 above)

```markdown
### Batch Remediation Scripts

If the user selects **Generate remediation scripts**, ask which format using AskUserQuestion:
- **PowerShell** — `.ps1` script for Windows environments
- **Bash** — `.sh` script for macOS/Linux environments
- **Both** — generate both versions

Generate scripts that automate fixable issues across the codebase:

**Automatable fixes** (safe to script):
- Adding `lang` attribute to `<html>` elements
- Adding missing `alt=""` to decorative images (images identified as decorative by context)
- Removing positive `tabindex` values (replacing with `tabindex="0"` or removing entirely)
- Adding `scope="col"` or `scope="row"` to `<th>` elements missing scope
- Adding `(opens in new tab)` visually-hidden text to `target="_blank"` links
- Adding `rel="noopener noreferrer"` to external links
- Replacing `outline: none` with visible focus styles
- Adding viewport meta tag if missing
- Adding `autocomplete` attributes to identity/payment form fields

**Non-automatable fixes** (require human judgment):
- Writing meaningful alt text for content images
- Restructuring heading hierarchy
- Rewriting ambiguous link text
- Adding ARIA roles and states to custom widgets
- Placing live regions for dynamic content
- Designing focus management for SPA route changes
- Creating accessible error messages

The script MUST include:
1. A dry-run mode (`-WhatIf` / `--dry-run`) that previews changes without modifying files
2. Backup creation before any modification (copies original file to `.bak`)
3. A summary log of all changes made
4. Clear comments explaining each fix
5. Framework-aware file targeting (e.g., scanning `.jsx`/`.tsx` for React, `.vue` for Vue, `.svelte` for Svelte)

Example script structure:

```bash
#!/bin/bash
set -euo pipefail

# Web Accessibility Remediation Script
# Generated by: web-accessibility-wizard
# Date: [YYYY-MM-DD]
# Audit report: [report path]

DRY_RUN="${1:-}"
BACKUP_DIR=".a11y-backups/$(date +%Y%m%d-%H%M%S)"

if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "🔍 DRY RUN MODE — no files will be modified"
fi

mkdir -p "$BACKUP_DIR"

FIXES_APPLIED=0
FIXES_SKIPPED=0

# Fix 1: Add lang attribute to <html> elements missing it
echo "--- Fix 1: Missing <html lang> ---"
FILES=$(grep -rl '<html[^>]*>' --include='*.html' --include='*.jsx' --include='*.tsx' . | xargs grep -lL 'lang=' 2>/dev/null || true)
for f in $FILES; do
  if [ "$DRY_RUN" = "--dry-run" ]; then
    echo "  Would fix: $f"
    ((FIXES_SKIPPED++))
  else
    cp "$f" "$BACKUP_DIR/$(basename "$f")"
    sed -i 's/<html/<html lang="en"/' "$f"
    echo "  Fixed: $f"
    ((FIXES_APPLIED++))
  fi
done

# [Additional fixes follow same pattern...]

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Remediation Summary"
echo "  Applied: $FIXES_APPLIED fixes"
echo "  Skipped: $FIXES_SKIPPED (dry-run or human-judgment required)"
echo "  Backups: $BACKUP_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next: Re-run the accessibility audit to verify fixes."
```

Write the script to: `scripts/a11y-remediate.sh` and/or `scripts/a11y-remediate.ps1`
```

---

## E10: CI/CD Integration Guide (Phase 12)

**INSERT AFTER:** Phase 11 (the entirety of E7, E8, E9)
**INSERT BEFORE:** `## Additional Agents to Consider`

```markdown
## Phase 12: CI/CD Integration Guide

When the user requests CI/CD integration, or after any audit where no `.a11y-web-config.json` exists, proactively offer to generate a CI/CD integration guide.

Ask using AskUserQuestion: **"Would you like a CI/CD integration guide for automated web accessibility scanning?"**
Options:
- **Yes — GitHub Actions** — generate a GitHub Actions workflow
- **Yes — Azure DevOps** — generate an Azure Pipelines YAML
- **Yes — Generic CI** — generate a generic script-based approach
- **No thanks** — skip CI/CD setup

### GitHub Actions Integration

Generate `.github/workflows/web-accessibility.yml`:

```yaml
name: Web Accessibility Audit

on:
  push:
    branches: [main, develop]
    paths:
      - 'src/**'
      - 'pages/**'
      - 'app/**'
      - 'components/**'
      - '*.html'
      - '*.css'
  pull_request:
    branches: [main]
    paths:
      - 'src/**'
      - 'pages/**'
      - 'app/**'
      - 'components/**'
      - '*.html'
      - '*.css'
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday at 6 AM UTC

jobs:
  accessibility-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Start application
        run: |
          npm run start &
          npx wait-on http://localhost:3000 --timeout 60000
        env:
          PORT: 3000

      - name: Run axe-core accessibility scan
        run: |
          npx @axe-core/cli http://localhost:3000 \
            --tags wcag2a,wcag2aa,wcag21a,wcag21aa \
            --save accessibility-results.json
        continue-on-error: true

      - name: Check for critical violations
        run: |
          VIOLATIONS=$(cat accessibility-results.json | node -e "
            const fs = require('fs');
            const data = JSON.parse(fs.readFileSync('/dev/stdin', 'utf8'));
            const critical = data.flatMap(p => p.violations).filter(v => v.impact === 'critical' || v.impact === 'serious');
            console.log(critical.length);
          ")
          echo "Critical/serious violations: $VIOLATIONS"
          if [ "$VIOLATIONS" -gt 0 ]; then
            echo "::error::Found $VIOLATIONS critical/serious accessibility violations"
            exit 1
          fi

      - name: Upload scan results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: accessibility-scan-results
          path: accessibility-results.json

      - name: Comment on PR
        if: github.event_name == 'pull_request' && failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '⚠️ **Accessibility violations detected.** Check the workflow artifacts for the full scan report.'
            })
```

### Azure DevOps Integration

Generate `azure-pipelines-a11y.yml`:

```yaml
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - src/**
      - pages/**
      - app/**
      - components/**
      - '*.html'
      - '*.css'

schedules:
  - cron: '0 6 * * 1'
    displayName: Weekly Accessibility Audit
    branches:
      include:
        - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '20.x'
    displayName: Setup Node.js

  - script: npm ci
    displayName: Install Dependencies

  - script: npm run build
    displayName: Build Application

  - script: |
      npm run start &
      npx wait-on http://localhost:3000 --timeout 60000
    displayName: Start Application
    env:
      PORT: 3000

  - script: |
      npx @axe-core/cli http://localhost:3000 \
        --tags wcag2a,wcag2aa,wcag21a,wcag21aa \
        --save $(Build.ArtifactStagingDirectory)/accessibility-results.json
    displayName: Run Accessibility Scan
    continueOnError: true

  - script: |
      VIOLATIONS=$(cat $(Build.ArtifactStagingDirectory)/accessibility-results.json | node -e "
        const fs = require('fs');
        const data = JSON.parse(fs.readFileSync('/dev/stdin', 'utf8'));
        const critical = data.flatMap(p => p.violations).filter(v => v.impact === 'critical' || v.impact === 'serious');
        console.log(critical.length);
      ")
      echo "Critical/serious violations: $VIOLATIONS"
      if [ "$VIOLATIONS" -gt 0 ]; then
        echo "##vso[task.logissue type=error]Found $VIOLATIONS critical/serious accessibility violations"
        exit 1
      fi
    displayName: Check for Critical Violations

  - publish: $(Build.ArtifactStagingDirectory)/accessibility-results.json
    artifact: accessibility-scan-results
    displayName: Publish Scan Results
```

### Generic CI Integration

Provide a shell script `scripts/ci-a11y-scan.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Web Accessibility CI Scan Script
# Usage: ./scripts/ci-a11y-scan.sh [URL] [--fail-on-serious]

URL="${1:-http://localhost:3000}"
FAIL_MODE="${2:-}"
OUTPUT="accessibility-results.json"
REPORT="ACCESSIBILITY-SCAN.md"

echo "Web Accessibility CI Scan"
echo "URL: $URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Run axe-core scan
echo "Running axe-core scan..."
npx @axe-core/cli "$URL" \
  --tags wcag2a,wcag2aa,wcag21a,wcag21aa \
  --save "$OUTPUT"

# Count violations by impact
CRITICAL=$(cat "$OUTPUT" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));console.log(d.flatMap(p=>p.violations).filter(v=>v.impact==='critical').length)")
SERIOUS=$(cat "$OUTPUT" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));console.log(d.flatMap(p=>p.violations).filter(v=>v.impact==='serious').length)")
MODERATE=$(cat "$OUTPUT" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));console.log(d.flatMap(p=>p.violations).filter(v=>v.impact==='moderate').length)")
MINOR=$(cat "$OUTPUT" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));console.log(d.flatMap(p=>p.violations).filter(v=>v.impact==='minor').length)")

echo ""
echo "Results:"
echo "  Critical: $CRITICAL"
echo "  Serious:  $SERIOUS"
echo "  Moderate: $MODERATE"
echo "  Minor:    $MINOR"
echo ""

# Fail if critical/serious violations found
if [ "$FAIL_MODE" = "--fail-on-serious" ]; then
  TOTAL=$((CRITICAL + SERIOUS))
  if [ "$TOTAL" -gt 0 ]; then
    echo "❌ FAIL: $TOTAL critical/serious accessibility violations found"
    exit 1
  else
    echo "✅ PASS: No critical or serious violations"
    exit 0
  fi
fi

echo "Scan complete. Results: $OUTPUT"
```

### Configuration File for CI

Offer to create `.a11y-web-config.json` (see E13) for the CI pipeline to use as its configuration source.
```

---

## E11: Edge Cases

**INSERT AFTER:** `## Behavioral Rules` section (at the end of the behavioral rules list)
**INSERT BEFORE:** End of file (or before any final closing section)

```markdown
## Edge Cases

### Single-Page Applications (SPAs)
- SPAs render content dynamically — axe-core only scans the current DOM state
- For SPAs, navigate to each route before scanning (use Playwright or Puppeteer to automate navigation)
- Check that route changes announce the new page title to screen readers
- Verify focus is managed on route transitions (focus should move to the main content or page heading)
- Test that browser back/forward buttons work with screen readers

### Iframes
- Iframes create separate document contexts — axe-core does not cross iframe boundaries by default
- Scan each iframe's `src` URL separately as an additional page
- Check that iframes have descriptive `title` attributes
- Verify keyboard focus can enter and exit iframes naturally
- Check `sandbox` attribute doesn't block accessibility features (e.g., `allow-scripts` for ARIA)

### Shadow DOM
- Shadow DOM encapsulation can hide elements from axe-core's DOM traversal
- Use `--include-shadow-dom` flag if available in the axe-core version
- Web components using shadow DOM must manage focus within their shadow roots
- `aria-*` attributes on shadow DOM hosts may not pierce the shadow boundary in all browsers
- Document any shadow DOM components that could not be scanned and recommend manual testing

### Web Components / Custom Elements
- Custom elements (`<my-component>`) must expose accessibility semantics via ARIA or `ElementInternals`
- Check that custom elements that extend interactive semantics have proper role, states, and keyboard handling
- Verify `connectedCallback` and `disconnectedCallback` handle focus management
- Look for `attachInternals()` usage for form-associated custom elements

### Lazy-Loaded Content
- Content loaded via infinite scroll, lazy loading, or intersection observers may not be present in the DOM at scan time
- Scroll to bottom of page before scanning to trigger lazy-loaded elements
- Check that lazy-loaded images have `alt` attributes set (not just placeholder values)
- Verify "Load more" buttons are keyboard accessible and announce new content

### Third-Party Widgets
- Third-party widgets (chat widgets, analytics overlays, consent banners, embedded maps) often introduce accessibility issues outside your control
- Document third-party widget issues separately from first-party code
- Note that third-party issues may not be fixable — recommend contacting the vendor or finding accessible alternatives
- Check that third-party widgets don't create keyboard traps
- Verify consent banners are keyboard accessible and have proper focus management

### PDF Links on Web Pages
- If the web application links to PDF documents, note this in the report
- Recommend that PDF links indicate file type and size: `"Annual Report (PDF, 2.4 MB)"`
- Suggest handing off PDF accessibility review to `document-accessibility-wizard`

### Password-Protected / Staging Environments
- If the target URL requires authentication, the user must provide credentials or a pre-authenticated session
- Ask the user: "Does this URL require login? If so, please ensure you're logged in and provide a session cookie or authenticated URL."
- For staging environments behind VPNs, the scan must run from a machine with VPN access
- Document any pages that could not be scanned due to authentication and recommend manual testing

### Auth-Gated Content
- Content behind login forms (dashboards, account pages, settings) requires authentication before scanning
- Ask: "Are there pages behind a login? If so, how should I access them?" Options:
  - **Pre-authenticated URL/token** — user provides a URL with auth token
  - **Login credentials for scanning** — user provides test account credentials (handle securely — never log or store)
  - **Skip auth-gated pages** — only scan public pages
  - **I'll navigate manually** — user logs in, then scanning proceeds

### Cookies / Session State
- Some pages display different content based on cookie state (e.g., A/B tests, personalization, consent state)
- If possible, scan in a clean browser context (incognito/private mode) for consistent results
- Document if different cookie states affect accessibility (e.g., a consent banner that traps focus only appears for new visitors)
- If using Playwright for screenshots, launch in a clean context: `--browser-context new`
```

---

## E12: Report Enhancements

These blocks enhance the Phase 10 report structure.

### E12a: Organization Modes

**INSERT AFTER:** Phase 10's report structure section (after the base `ACCESSIBILITY-AUDIT.md` structure)
**INSERT BEFORE:** `### Consolidation Rules`

```markdown
### Organization Modes

If the user selected a different organization mode in Phase 0 Step 6 (Reporting Preferences):

**By issue type:** Group all instances of each rule or finding pattern together, listing affected pages under each rule. Example:

```markdown
## Findings by Issue Type

### Missing Alt Text
**WCAG:** 1.1.1 Non-text Content (Level A) | **Severity:** Critical | **Instances:** 12 across 5 pages

| Page | Element | Location |
|------|---------|----------|
| /home | Hero image | `img.hero-banner` |
| /about | Team photo | `section.team img:nth-child(2)` |
| /products | Product thumbnail | `div.product-card img` (×3) |
| ... | | |

**Recommended fix:** [code example]

---

### Missing Form Labels
**WCAG:** 1.3.1 Info and Relationships (Level A) | **Severity:** Serious | **Instances:** 6 across 2 pages
...
```

**By severity:** List all critical issues first (across all pages), then all serious, moderate, minor. Example:

```markdown
## Critical Issues (across all pages)

### 1. [description] — /checkout
### 2. [description] — /dashboard
### 3. [description] — /home

## Serious Issues (across all pages)
...

## Moderate Issues (across all pages)
...
```

**By page (default):** Group all findings under each audited URL, as shown in the base report structure.
```

### E12b: Findings by Rule Cross-Reference Table

**INSERT INSIDE:** The Phase 10 report markdown template, after the severity-grouped findings sections

```markdown
## Findings by Rule Cross-Reference

| axe-core Rule / Agent Finding | Severity | WCAG | Pages Affected | Total Instances |
|------------------------------|----------|------|----------------|-----------------|
| image-alt | Critical | 1.1.1 | 5 of 8 pages | 12 |
| color-contrast | Serious | 1.4.3 | 3 of 8 pages | 8 |
| label | Serious | 1.3.1 | 2 of 8 pages | 6 |
| heading-order | Moderate | 1.3.1 | 4 of 8 pages | 4 |
| link-name | Moderate | 2.4.4 | 6 of 8 pages | 15 |
| ... | | | | |

This cross-reference helps identify systemic issues. Rules affecting the most pages should be prioritized — they often stem from shared components or templates.
```

### E12c: Configuration Recommendations

**INSERT INSIDE:** The Phase 10 report markdown template, after `## Recommended Testing Setup`

```markdown
## Configuration Recommendations

Based on this audit's findings, here are recommended scan configurations for ongoing monitoring:

### Recommended `.a11y-web-config.json` Settings
```json
{
  "urls": ["[list of audited URLs]"],
  "standard": "WCAG 2.2 AA",
  "rules": {
    "enabled": ["[rules that found issues — keep monitoring]"],
    "disabled": ["[rules confirmed not applicable]"]
  },
  "thresholds": {
    "maxViolations": {
      "critical": 0,
      "serious": 5
    },
    "minScore": 75
  }
}
```

### Recommended Scan Frequency
- **After every PR** — run axe-core against changed pages (use delta scan with git diff)
- **Weekly** — full site scan to catch regressions and third-party widget changes
- **Before release** — full deep-dive audit of all pages

### Rules to Monitor
Based on this audit, these rules had the highest violation rates and should be actively monitored:
1. [rule] — [count] violations across [pages]
2. [rule] — [count] violations across [pages]
3. ...
```

### E12d: Expanded What Passed

**INSERT:** Replace the existing `## What Passed` section in the report template

```markdown
## What Passed

Acknowledge what the project does well. A complete audit reports both failures AND successes.

### Categories with No Issues Found
| Category | Status | Notes |
|----------|--------|-------|
| [e.g., Form Labels] | ✅ Pass | All form inputs have associated labels |
| [e.g., Heading Structure] | ✅ Pass | Single H1, no skipped levels on all pages |
| [e.g., Keyboard Access] | ✅ Pass | All interactive elements reachable by keyboard |
| ... | | |

### Pages with No Issues
| Page URL | Score | Grade |
|----------|-------|-------|
| [url] | 100/100 | A |
| [url] | 95/100 | A |

### Well-Implemented Patterns
Highlight specific accessibility patterns the project implements correctly:
- [e.g., "Skip navigation link present on all pages and functions correctly"]
- [e.g., "Focus management on SPA route changes properly moves focus to main heading"]
- [e.g., "Form validation uses `aria-invalid`, `aria-describedby`, and moves focus to first error"]
- [e.g., "Dark mode maintains adequate contrast ratios across all tested elements"]
```

---

## E13: Web Scan Config

**INSERT AFTER:** `## Edge Cases` section (E11 above)
**INSERT BEFORE:** End of file

```markdown
## Web Scan Configuration

### `.a11y-web-config.json` Schema

The web accessibility wizard looks for `.a11y-web-config.json` in the workspace root to configure scanning behavior. If not found, defaults are used and the wizard offers to create one after the audit.

```json
{
  "$schema": "https://a11y-agent-team/schemas/web-config.json",
  "version": "1.0",

  "scan": {
    "urls": [
      "http://localhost:3000",
      "http://localhost:3000/login",
      "http://localhost:3000/dashboard"
    ],
    "crawl": false,
    "crawlDepth": 3,
    "maxPages": 50,
    "includePatterns": ["/**"],
    "excludePatterns": ["/api/**", "/admin/**", "*.pdf"],
    "waitForSelector": null,
    "waitTimeout": 5000,
    "viewport": {
      "width": 1280,
      "height": 720
    },
    "mobileViewport": {
      "width": 375,
      "height": 812
    }
  },

  "standard": "WCAG 2.2 AA",

  "rules": {
    "enabled": "all",
    "disabled": [],
    "axeTags": ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"],
    "custom": []
  },

  "severity": {
    "filter": ["critical", "serious", "moderate", "minor"],
    "failOn": ["critical", "serious"],
    "minScore": 0
  },

  "report": {
    "outputPath": "ACCESSIBILITY-AUDIT.md",
    "scanOutputPath": "ACCESSIBILITY-SCAN.md",
    "format": "markdown",
    "organizationMode": "by-page",
    "remediationDetail": "detailed",
    "includeScreenshots": false,
    "screenshotDir": "screenshots"
  },

  "thresholds": {
    "maxViolations": {
      "critical": 0,
      "serious": 5,
      "moderate": null,
      "minor": null
    },
    "minScore": 75,
    "failOnRegression": true
  },

  "framework": {
    "detected": null,
    "overrides": {}
  },

  "ci": {
    "failOnViolation": true,
    "failSeverity": "serious",
    "uploadArtifacts": true,
    "commentOnPR": true
  },

  "baseline": {
    "reportPath": null,
    "compareOnScan": false
  }
}
```

### Schema Field Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `scan.urls` | `string[]` | `[]` | List of URLs to scan. If empty, wizard asks in Phase 0. |
| `scan.crawl` | `boolean` | `false` | If true, crawl links from the start URL. |
| `scan.crawlDepth` | `number` | `3` | Max link depth when crawling. |
| `scan.maxPages` | `number` | `50` | Max pages to scan (prevents runaway crawls). |
| `scan.includePatterns` | `string[]` | `["/**"]` | URL patterns to include (glob-style). |
| `scan.excludePatterns` | `string[]` | `[]` | URL patterns to exclude (glob-style). |
| `scan.waitForSelector` | `string\|null` | `null` | CSS selector to wait for before scanning (useful for SPAs). |
| `scan.waitTimeout` | `number` | `5000` | Timeout in ms for page load wait. |
| `scan.viewport` | `object` | `{width:1280,height:720}` | Desktop viewport dimensions. |
| `scan.mobileViewport` | `object` | `{width:375,height:812}` | Mobile viewport for responsive testing. |
| `standard` | `string` | `"WCAG 2.2 AA"` | Target conformance standard. Options: `WCAG 2.2 AA`, `WCAG 2.1 AA`, `WCAG 2.2 AAA`. |
| `rules.enabled` | `string\|string[]` | `"all"` | Which rules to enable. `"all"` or a list of axe-core rule IDs. |
| `rules.disabled` | `string[]` | `[]` | Specific rule IDs to disable. |
| `rules.axeTags` | `string[]` | `["wcag2a","wcag2aa","wcag21a","wcag21aa"]` | axe-core tags to include. |
| `severity.filter` | `string[]` | `["critical","serious","moderate","minor"]` | Which severities to report. |
| `severity.failOn` | `string[]` | `["critical","serious"]` | Severities that cause CI failure. |
| `report.outputPath` | `string` | `"ACCESSIBILITY-AUDIT.md"` | Path for the audit report. |
| `report.organizationMode` | `string` | `"by-page"` | Report grouping: `by-page`, `by-issue`, `by-severity`. |
| `report.remediationDetail` | `string` | `"detailed"` | Detail level: `detailed`, `summary`, `findings-only`. |
| `report.includeScreenshots` | `boolean` | `false` | Whether to capture and include screenshots. |
| `thresholds.maxViolations` | `object` | `{}` | Max violations per severity before CI failure. `null` = no limit. |
| `thresholds.minScore` | `number` | `0` | Minimum overall score (0-100) before CI failure. |
| `thresholds.failOnRegression` | `boolean` | `true` | Fail CI if score decreases from baseline. |
| `ci.failOnViolation` | `boolean` | `true` | Whether violations cause non-zero exit code. |
| `ci.failSeverity` | `string` | `"serious"` | Minimum severity that triggers CI failure. |
| `ci.commentOnPR` | `boolean` | `true` | Post results as PR comment in GitHub Actions. |
| `baseline.reportPath` | `string\|null` | `null` | Path to previous audit report for comparison. |
| `baseline.compareOnScan` | `boolean` | `false` | Automatically compare against baseline on every scan. |

### Config Resolution Order

The wizard resolves configuration in this order (later sources override earlier):

1. **Built-in defaults** — the defaults shown in the schema above
2. **`.a11y-web-config.json`** — workspace root config file (if present)
3. **Phase 0 user answers** — interactive choices override config file settings
4. **CLI arguments** — if invoked from CI scripts with explicit arguments

### Config Detection in SessionStart Hook

The `SessionStart` hook checks for `.a11y-web-config.json`. If found, it reports:
```
📋 Found .a11y-web-config.json:
  URLs configured: [count]
  Standard: [value]
  Disabled rules: [count or "none"]
  Thresholds: min score [value], fail on [severity]
  Baseline: [path or "not set"]
```

If not found, the wizard proceeds with defaults and offers to create the config file in Phase 11.
```

---

*End of enhancement blocks. All 13 blocks (E1–E13) are above, labeled and ready to insert.*
