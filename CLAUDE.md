# Accessibility-First Development

This workspace enforces WCAG AA accessibility standards for all web UI code.

## Mandatory Accessibility Check

Before writing or modifying any web UI code - including HTML, JSX, CSS, React components, Tailwind classes, web pages, forms, modals, or any user-facing web content - you MUST:

1. Consider which accessibility specialist agents are needed for the task
2. Apply the relevant specialist knowledge before generating code
3. Verify the output against the appropriate checklists

**Automatic trigger detection:** If a user prompt involves creating, editing, or reviewing any file matching `*.html`, `*.jsx`, `*.tsx`, `*.vue`, `*.svelte`, `*.astro`, or `*.css` - or if the prompt describes building UI components, pages, forms, or visual elements - treat it as a web UI task and apply the Decision Matrix below to determine which specialists are needed. Do not wait for the user to explicitly request accessibility review.

## Available Specialist Agents

Invoke these agents from the Claude Code agent picker (type `/` to browse):

| Agent | When to Use |
|-------|------------|
| Accessibility Lead | Any UI task - coordinates all specialists and runs final review |
| ARIA Specialist | Interactive components, custom widgets, ARIA usage |
| Modal Specialist | Dialogs, drawers, popovers, overlays |
| Contrast Master | Colors, themes, CSS styling, visual design |
| Keyboard Navigator | Tab order, focus management, keyboard interaction |
| Live Region Controller | Dynamic content updates, toasts, loading states |
| Forms Specialist | Forms, inputs, validation, error handling, multi-step wizards |
| Alt Text & Headings | Images, alt text, SVGs, heading structure, page titles, landmarks |
| Tables Specialist | Data tables, sortable tables, grids, comparison tables, pricing tables |
| Link Checker | Ambiguous link text, "click here"/"read more" detection, link purpose |
| Cognitive Accessibility | WCAG 2.2 cognitive SC, COGA guidance, plain language, authentication UX |
| Mobile Accessibility | React Native, Expo, iOS, Android - touch targets, screen reader compatibility |
| Design System Auditor | Color token contrast, focus ring tokens, spacing tokens, Tailwind/MUI/Chakra/shadcn |
| Web Accessibility Wizard | Full guided web accessibility audit with step-by-step walkthrough |
| Document Accessibility Wizard | Document accessibility audit for .docx, .xlsx, .pptx, .pdf - single files, folders, recursive scanning, delta scanning, severity scoring, remediation tracking, compliance export (VPAT/ACR), CSV export with help links, CI/CD integration |
| Testing Coach | Screen reader testing, keyboard testing, automated testing guidance |
| WCAG Guide | WCAG 2.2 criteria explanations, conformance levels, what changed |
| Developer Hub | Python, wxPython, desktop app development - routes to specialist agents, scaffolds, debugs, reviews, builds |
| Python Specialist | Python debugging, packaging (PyInstaller/Nuitka/cx_Freeze), testing, type checking, async, optimization |
| wxPython Specialist | wxPython GUI - sizer layouts, event handling, AUI, custom controls, threading, desktop accessibility |
| Desktop Accessibility Specialist | Desktop application accessibility - platform APIs (UI Automation, MSAA/IAccessible2, ATK/AT-SPI, NSAccessibility), accessible control patterns, screen reader Name/Role/Value/State, focus management, high contrast, and custom widget accessibility for Windows, macOS, and Linux desktop applications |
| Desktop A11y Testing Coach | Desktop accessibility testing - testing with NVDA, JAWS, Narrator, VoiceOver, and Orca screen readers, Accessibility Insights for Windows, automated UIA testing, keyboard-only testing flows, high contrast verification, and creating desktop accessibility test plans |
| Accessibility Tool Builder | Building accessibility scanning tools, rule engines, document parsers, report generators, and audit automation. WCAG criterion mapping, severity scoring algorithms, CLI/GUI scanner architecture, and CI/CD integration for accessibility tooling |

## Hidden Helper Sub-Agents

These agents are not meant to be invoked directly by users. They are used internally by the document-accessibility-wizard, web-accessibility-wizard, and markdown-a11y-assistant to parallelize scanning and analysis:

| Agent | Purpose |
|-------|--------|
| document-inventory | File discovery, inventory building, delta detection across folders |
| cross-document-analyzer | Cross-document pattern detection, severity scoring, template analysis |
| cross-page-analyzer | Cross-page web pattern detection, severity scoring, remediation tracking |
| web-issue-fixer | Automated and guided web accessibility fix application |
| office-scan-config | Office scan config management - invoked internally by document-accessibility-wizard Phase 0 |
| pdf-scan-config | PDF scan config management - invoked internally by document-accessibility-wizard Phase 0 |
| markdown-scanner | Per-file markdown scanning across all 9 accessibility domains - invoked in parallel by markdown-a11y-assistant |
| markdown-fixer | Applies approved markdown fixes and presents human-judgment items - invoked by markdown-a11y-assistant |
| markdown-csv-reporter | Exports markdown audit findings to CSV with WCAG help links and markdownlint rule references - invoked by markdown-a11y-assistant |
| web-csv-reporter | Exports web audit findings to CSV with Deque University help links - invoked by web-accessibility-wizard |
| document-csv-reporter | Exports document audit findings to CSV with Microsoft Office and Adobe PDF help links - invoked by document-accessibility-wizard |
| scanner-bridge | Bridges GitHub Accessibility Scanner CI data into the agent ecosystem - invoked by web-accessibility-wizard Phase 0 |
| lighthouse-bridge | Bridges Lighthouse CI accessibility audit data into the agent ecosystem - invoked by web-accessibility-wizard Phase 0 |

## Knowledge Domains

The following knowledge domains are available across agent files. On Copilot these are formalized as reusable skills in `.github/skills/`; on Claude Code the equivalent knowledge is inlined into each agent's instructions.

| Domain | Coverage |
|--------|----------|
| Document Scanning | File discovery commands, delta detection, scan configuration profiles |
| Accessibility Rules | Cross-format document accessibility rule reference with WCAG 2.2 mapping (DOCX, XLSX, PPTX, PDF) |
| Report Generation | Audit report formatting, severity scoring formulas (0-100, A-F grades), VPAT/ACR compliance export |
| Web Scanning | Web content discovery, URL crawling, axe-core CLI commands, framework detection |
| Web Severity Scoring | Web severity scoring formulas, confidence levels, remediation tracking |
| Framework Accessibility | Framework-specific accessibility patterns and fix templates (React, Vue, Angular, Svelte, Tailwind) |
| Cognitive Accessibility | WCAG 2.2 cognitive SC reference tables, plain language analysis, COGA guidance, auth pattern detection |
| Mobile Accessibility | React Native prop reference, iOS/Android API quick reference, touch target rules, violation patterns |
| Design System | Color token contrast computation, framework token paths (Tailwind/MUI/Chakra/shadcn), focus ring validation, WCAG 2.4.13 Focus Appearance (AAA) |
| Markdown Accessibility | Ambiguous link/anchor patterns, emoji handling modes (remove/translate), Mermaid and ASCII diagram replacement templates, heading structure, severity scoring |
| Help URL Reference | Deque University help topic URLs, Microsoft Office help URLs, Adobe PDF help URLs, WCAG understanding document URLs, application-specific fix steps |
| GitHub A11y Scanner | GitHub Accessibility Scanner detection, issue parsing, severity mapping, axe-core correlation, Copilot fix tracking |
| Lighthouse Scanner | Lighthouse CI accessibility audit detection, score interpretation, weight-to-severity mapping, score regression tracking |
| Python Development | Python and wxPython development patterns, packaging, testing, wxPython sizers/events/threading, cross-platform paths |

## Agent Teams

Team coordination is defined in `.claude/agents/AGENTS.md`. Five defined teams:

- **Document Accessibility Audit** - led by document-accessibility-wizard with format-specific sub-agents
- **Web Accessibility Audit** - led by accessibility-lead with all web specialist agents
- **Full Audit** - combined web + document audit workflow
- **Mobile Accessibility** - led by mobile-accessibility; invoked standalone or as handoff from accessibility-lead
- **Design System Accessibility** - led by design-system-auditor; validates tokens before UI propagation
- **Developer Tools** - led by developer-hub; routes to python-specialist, wxpython-specialist, desktop-a11y-specialist, desktop-a11y-testing-coach, a11y-tool-builder for Python, wxPython, desktop accessibility, and tool building. Cross-team handoffs to web-accessibility-wizard and document-accessibility-wizard.

## Decision Matrix

- **New component or page:** Always apply aria-specialist + keyboard-navigator + alt-text-headings guidance. Add forms-specialist for any inputs, contrast-master for styling, modal-specialist for overlays, live-region-controller for dynamic updates, tables-data-specialist for any data tables.
- **Modifying existing UI:** At minimum apply keyboard-navigator (tab order breaks easily). Add others based on what changed.
- **Code review/audit:** Apply all specialist checklists. Use web-accessibility-wizard for guided web audits.
- **Document audit:** Use document-accessibility-wizard for Office and PDF accessibility audits. Supports single files, folders, recursive scanning, delta scanning (changed files only), severity scoring, template analysis, remediation tracking across re-scans, compliance format export (VPAT/ACR), CSV export with help links, batch remediation scripts, and CI/CD integration guides.
- **Mobile app (React Native / Expo / iOS / Android):** Apply cognitive-accessibility guidance. Use mobile-accessibility for touch target checks, accessibilityLabel/Role/State audits, and platform-specific screen reader testing.
- **Cognitive / UX clarity / plain language:** Use cognitive-accessibility for WCAG 2.2 SC 3.3.7, 3.3.8, 3.3.9, COGA guidance, error message quality, and reading level analysis.
- **Design system / tokens:** Use design-system-auditor to validate color token pairs, focus ring tokens, spacing tokens, and motion tokens before they propagate to UI.
- **Data tables:** Always apply tables-data-specialist for any tabular data display.
- **Links:** Always apply link-checker when pages contain hyperlinks.
- **Images or media:** Always apply alt-text-headings.
- **Testing guidance:** Use testing-coach for screen reader testing, keyboard testing, and automated testing setup.
- **WCAG questions:** Use wcag-guide to understand specific WCAG success criteria and conformance requirements.
- **Python development:** Use developer-hub for any Python, wxPython, or desktop app task. Routes to python-specialist for language work and wxpython-specialist for GUI work.
- **Desktop app packaging:** Use python-specialist for PyInstaller, Nuitka, cx_Freeze builds and troubleshooting.
- **Desktop accessibility:** Use desktop-a11y-specialist for platform API implementation (UIA, MSAA, ATK, NSAccessibility), screen reader interaction, focus management, and high contrast support. Use desktop-a11y-testing-coach for screen reader testing walkthroughs and automated UIA tests.
- **Building accessibility tools:** Use a11y-tool-builder for designing rule engines, document parsers, report generators, severity scoring, and scanner architecture.

## Context Discovery

When starting any accessibility audit, review, or remediation task, proactively check the workspace for existing context before proceeding:

1. **Scan configuration files:** Check the workspace root for `.a11y-office-config.json`, `.a11y-pdf-config.json`, and `.a11y-web-config.json`. If any exist, read them to determine which rules are enabled/disabled, severity filters, and custom settings. Apply these configurations to the audit - do not use defaults when a config file exists.
2. **Previous audit reports:** Check for existing `ACCESSIBILITY-AUDIT.md`, `WEB-ACCESSIBILITY-AUDIT.md`, `DOCUMENT-ACCESSIBILITY-AUDIT.md`, and `MARKDOWN-ACCESSIBILITY-AUDIT.md` in the workspace root. If found, note the date, overall score, and issue count. Offer comparison/delta mode so the user can track remediation progress.
3. **Scan config templates:** If no config file exists and the user is starting a new audit, mention that pre-built profiles (strict, moderate, minimal) are available in the `templates/` directory.

## Scan Configuration

The `templates/` directory contains pre-built scan configuration profiles:

- **strict** - All rules enabled, all severities reported
- **moderate** - All rules enabled, errors and warnings only
- **minimal** - Errors only, for quick triage

Copy the appropriate template to your project root:

- `.a11y-office-config.json` for Office document scanning
- `.a11y-pdf-config.json` for PDF scanning
- `.a11y-web-config.json` for web accessibility scanning

## Audit Report Quality Requirements

When generating any accessibility audit report (web, document, or markdown), the report MUST include all of these sections to be considered complete:

1. **Metadata** - audit date, tool versions, scope (URLs/files audited), scan configuration used
2. **Executive summary** - overall score (0-100, A-F grade), total issues by severity, pass/fail verdict
3. **Findings** - each issue with: rule ID, WCAG criterion, severity, affected element/location, description, remediation guidance
4. **Severity breakdown** - counts by Critical/Serious/Moderate/Minor
5. **Remediation priorities** - ordered list of what to fix first based on impact and effort
6. **Next steps** - recommended follow-up actions, re-scan timeline
7. **Delta tracking** (when a previous report exists) - Fixed/New/Persistent/Regressed issue counts

Do not consider an audit complete until the report contains all applicable sections. If generating a quick check (not a full audit), state explicitly that it is a triage result, not a complete audit report.

## Non-Negotiable Standards

- Semantic HTML before ARIA (`<button>` not `<div role="button">`)
- One H1 per page, never skip heading levels
- Every interactive element reachable and operable by keyboard
- Text contrast 4.5:1, UI component contrast 3:1
- No information conveyed by color alone
- Focus managed on route changes, dynamic content, and deletions
- Modals trap focus and return focus on close
- Live regions for all dynamic content updates

## Advanced Documentation

Additional guides in `docs/`:

- **cross-platform-handoff.md** - Seamless handoff between Claude Code and Copilot agent environments
- **advanced-scanning-patterns.md** - Background scanning, worktree isolation, and large library strategies
- **plugin-packaging.md** - Packaging and distributing agents for different environments
- **platform-references.md** - All external documentation sources used to build this project, with feature-to-source mapping

For tasks that do not involve any user-facing web content (backend logic, scripts, database work), these requirements do not apply.
