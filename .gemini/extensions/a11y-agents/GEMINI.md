# Accessibility-First Development

This workspace enforces WCAG AA accessibility standards for all web UI code.

## Mandatory Accessibility Check

Before writing or modifying any web UI code - including HTML, JSX, CSS, React components, Tailwind classes, web pages, forms, modals, or any user-facing web content - you MUST:

1. Consider which accessibility skills are needed for the task
2. Apply the relevant specialist knowledge before generating code
3. Verify the output against the appropriate checklists

**Automatic trigger detection:** If a user prompt involves creating, editing, or reviewing any file matching `*.html`, `*.jsx`, `*.tsx`, `*.vue`, `*.svelte`, `*.astro`, or `*.css` - or if the prompt describes building UI components, pages, forms, or visual elements - treat it as a web UI task and apply the Decision Matrix below to determine which skills are needed. Do not wait for the user to explicitly request accessibility review.

## Available Skills

The following skills are available in `skills/` and provide domain-specific accessibility knowledge:

- **accessibility-lead** - Orchestrator. Decides which specialists to invoke and runs the final review.
- **aria-specialist** - ARIA roles, states, properties, widget patterns. Enforces the first rule of ARIA.
- **modal-specialist** - Dialogs, drawers, popovers, alerts. Focus trapping, focus return, escape behavior.
- **contrast-master** - Color contrast ratios, dark mode, focus indicators, color independence.
- **keyboard-navigator** - Tab order, focus management, skip links, arrow key patterns, SPA route changes.
- **live-region-controller** - Dynamic content announcements, toasts, loading states, search results.
- **forms-specialist** - Labels, errors, validation, fieldsets, autocomplete, multi-step wizards.
- **alt-text-headings** - Alt text, SVGs, icons, heading hierarchy, landmarks, page titles.
- **tables-data-specialist** - Table markup, scope, caption, headers, sortable columns, ARIA grids.
- **link-checker** - Ambiguous link text, "click here" detection, missing new-tab warnings.
- **cognitive-accessibility** - WCAG 2.2 cognitive SC, COGA guidance, plain language, authentication UX.
- **mobile-accessibility** - React Native, Expo, iOS, Android touch targets, screen reader compatibility.
- **design-system-auditor** - Color token contrast, focus ring tokens, spacing tokens for WCAG compliance.
- **web-accessibility-wizard** - Full guided web accessibility audit with step-by-step walkthrough.
- **document-accessibility-wizard** - Office and PDF document accessibility audit.
- **markdown-a11y-assistant** - Markdown documentation audit covering links, alt text, headings, tables, emoji, diagrams.
- **testing-coach** - Screen reader testing, keyboard testing, automated testing guidance.
- **wcag-guide** - WCAG 2.2 criteria explanations, conformance levels, what changed.
- **word-accessibility** - Microsoft Word (DOCX) document accessibility scanning.
- **excel-accessibility** - Microsoft Excel (XLSX) spreadsheet accessibility scanning.
- **powerpoint-accessibility** - Microsoft PowerPoint (PPTX) presentation accessibility scanning.
- **pdf-accessibility** - PDF conformance per PDF/UA and the Matterhorn Protocol.
- **epub-accessibility** - ePub document accessibility scanning per EPUB Accessibility 1.1.

### GitHub Workflow Skills

- **github-hub** - Routes GitHub management tasks to the right specialist from plain English.
- **daily-briefing** - Morning overview of open issues, PR queue, CI status, security alerts.
- **pr-review** - PR diff analysis with confidence per finding, delta tracking, and inline comments.
- **issue-tracker** - Issue triage with priority scoring, duplicate detection, action inference.
- **analytics** - Repository health scoring (0-100/A-F), velocity metrics, bottleneck detection.
- **insiders-a11y-tracker** - Track accessibility changes in VS Code Insiders and custom repos.
- **repo-admin** - Collaborator management, branch protection rules, access audits.
- **team-manager** - Onboarding, offboarding, org team membership, permission management.
- **contributions-hub** - Discussions, community health metrics, first-time contributor insights.
- **template-builder** - Guided wizard for issue/PR/discussion templates.
- **repo-manager** - Repository scaffolding with labels, CI, CONTRIBUTING, SECURITY, issue templates.

## Decision Matrix

- **New component or page:** Always apply aria-specialist + keyboard-navigator + alt-text-headings guidance. Add forms-specialist for any inputs, contrast-master for styling, modal-specialist for overlays, live-region-controller for dynamic updates, tables-data-specialist for any data tables.
- **Modifying existing UI:** At minimum apply keyboard-navigator (tab order breaks easily). Add others based on what changed.
- **Code review/audit:** Apply all specialist checklists. Use web-accessibility-wizard for guided web audits.
- **Document audit:** Use document-accessibility-wizard for Office and PDF accessibility audits.
- **Mobile app (React Native / Expo / iOS / Android):** Apply cognitive-accessibility guidance. Use mobile-accessibility for touch target checks.
- **Cognitive / UX clarity / plain language:** Use cognitive-accessibility for WCAG 2.2 SC 3.3.7, 3.3.8, 3.3.9, COGA guidance, error message quality, and reading level analysis.
- **Design system / tokens:** Use design-system-auditor to validate color token pairs, focus ring tokens, spacing tokens, and motion tokens.
- **Data tables:** Always apply tables-data-specialist for any tabular data display.
- **Links:** Always apply link-checker when pages contain hyperlinks.
- **Images or media:** Always apply alt-text-headings.
- **Testing guidance:** Use testing-coach for screen reader testing, keyboard testing, and automated testing setup.
- **WCAG questions:** Use wcag-guide to understand specific WCAG success criteria and conformance requirements.

## Context Discovery

When starting any accessibility audit, review, or remediation task, proactively check the workspace for existing context before proceeding:

1. **Scan configuration files:** Check the workspace root for `.a11y-office-config.json`, `.a11y-pdf-config.json`, and `.a11y-web-config.json`. If any exist, read them to determine which rules are enabled/disabled, severity filters, and custom settings.
2. **Previous audit reports:** Check for existing `ACCESSIBILITY-AUDIT.md`, `WEB-ACCESSIBILITY-AUDIT.md`, `DOCUMENT-ACCESSIBILITY-AUDIT.md`, and `MARKDOWN-ACCESSIBILITY-AUDIT.md` in the workspace root. If found, note the date, overall score, and issue count. Offer comparison/delta mode.
3. **Scan config templates:** If no config file exists, mention that pre-built profiles (strict, moderate, minimal) are available in the `templates/` directory.

## Non-Negotiable Standards

- Semantic HTML before ARIA (`<button>` not `<div role="button">`)
- One H1 per page, never skip heading levels
- Every interactive element reachable and operable by keyboard
- Text contrast 4.5:1, UI component contrast 3:1
- No information conveyed by color alone
- Focus managed on route changes, dynamic content, and deletions
- Modals trap focus and return focus on close
- Live regions for all dynamic content updates

For tasks that do not involve any user-facing web content (backend logic, scripts, database work), these requirements do not apply.
