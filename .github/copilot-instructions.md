## Accessibility-First Development

This workspace enforces WCAG AA accessibility standards for all web UI code.

### Mandatory Accessibility Check

Before writing or modifying any web UI code - including HTML, JSX, CSS, React components, Tailwind classes, web pages, forms, modals, or any user-facing web content - you MUST:

1. Consider which accessibility specialist agents are needed for the task
2. Apply the relevant specialist knowledge before generating code
3. Verify the output against the appropriate checklists

**Automatic trigger detection:** If a user prompt involves creating, editing, or reviewing any file matching `*.html`, `*.jsx`, `*.tsx`, `*.vue`, `*.svelte`, `*.astro`, or `*.css` - or if the prompt describes building UI components, pages, forms, or visual elements - treat it as a web UI task and apply the Decision Matrix below to determine which specialists are needed. Do not wait for the user to explicitly request accessibility review.

### Available Specialist Agents

Select these agents from the agents dropdown in Copilot Chat, or type `/agents` to browse:

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
| Markdown Accessibility | Markdown document accessibility - links, alt text, headings, tables, emoji, mermaid diagrams, dashes, anchors |
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

### Hidden Helper Sub-Agents

These agents are not user-invokable. They are used internally by the document-accessibility-wizard, web-accessibility-wizard, and markdown-a11y-assistant to parallelize scanning and analysis:

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

### Agent Skills

Reusable knowledge modules in `.github/skills/` that agents reference automatically:

| Skill | Domain |
|-------|--------|
| document-scanning | File discovery commands, delta detection, scan configuration profiles |
| accessibility-rules | Cross-format accessibility rule reference with WCAG 2.2 mapping (DOCX, XLSX, PPTX, PDF) |
| report-generation | Audit report formatting, severity scoring formulas, VPAT/ACR compliance export |
| web-scanning | Web content discovery, URL crawling, axe-core CLI commands, framework detection |
| web-severity-scoring | Web severity scoring formulas (0-100, A-F grades), confidence levels, remediation tracking |
| framework-accessibility | Framework-specific accessibility patterns and fix templates (React, Vue, Angular, Svelte, Tailwind) |
| cognitive-accessibility | WCAG 2.2 cognitive SC reference tables, plain language analysis, COGA guidance, auth pattern detection |
| mobile-accessibility | React Native prop reference, iOS/Android API quick reference, touch target rules, violation patterns |
| design-system | Color token contrast computation, framework token paths (Tailwind/MUI/Chakra/shadcn), focus ring validation, WCAG 2.4.13 Focus Appearance (AAA) |
| markdown-accessibility | Markdown rule library: ambiguous links, anchor validation, emoji modes (remove/translate), Mermaid and ASCII diagram replacement templates, heading structure, table descriptions, severity scoring |
| github-workflow-standards | Core standards for all GitHub workflow agents: auth, discovery, dual MD+HTML output, HTML accessibility, safety rules, progress announcements, parallel execution |
| github-scanning | GitHub search patterns by intent, date range handling, parallel stream collection, cross-repo intelligence, auto-recovery |
| github-analytics-scoring | Repo health scoring (0-100/A-F), issue/PR priority scoring, confidence levels, delta tracking, velocity metrics, bottleneck detection |
| help-url-reference | Deque University help topic URLs, Microsoft Office help URLs, Adobe PDF help URLs, WCAG understanding document URLs, application-specific fix steps |
| github-a11y-scanner | GitHub Accessibility Scanner detection, issue parsing, severity mapping, axe-core correlation, Copilot fix tracking |
| lighthouse-scanner | Lighthouse CI accessibility audit detection, score interpretation, weight-to-severity mapping, score regression tracking |
| python-development | Python and wxPython development patterns, packaging, testing, wxPython sizers/events/threading, cross-platform paths |

### Agent Teams

Team coordination is defined in `.github/agents/AGENTS.md`. Four defined teams:

- **Document Accessibility Audit** - led by document-accessibility-wizard with format-specific sub-agents
- **Web Accessibility Audit** - led by accessibility-lead with all web specialist agents
- **Full Audit** - combined web + document audit workflow
- **GitHub Workflow** - led by github-hub; routes to daily-briefing, pr-review, issue-tracker, analytics, repo-admin, team-manager, contributions-hub, insiders-a11y-tracker, template-builder
- **Developer Tools** - led by developer-hub; routes to python-specialist, wxpython-specialist, desktop-a11y-specialist, desktop-a11y-testing-coach, a11y-tool-builder for Python, wxPython, desktop accessibility, and tool building. Cross-team handoffs to web-accessibility-wizard and document-accessibility-wizard.

### Decision Matrix

- **New component or page:** Always apply aria-specialist + keyboard-navigator + alt-text-headings guidance. Add forms-specialist for any inputs, contrast-master for styling, modal-specialist for overlays, live-region-controller for dynamic updates, tables-data-specialist for any data tables.
- **Modifying existing UI:** At minimum apply keyboard-navigator (tab order breaks easily). Add others based on what changed.
- **Code review/audit:** Apply all specialist checklists. Use accessibility-wizard for guided web audits. Use `audit-web-page` prompt for one-click full audits.
- **Document audit:** Use document-accessibility-wizard for Office and PDF accessibility audits. Supports single files, folders, recursive scanning, delta scanning (changed files only), severity scoring, template analysis, remediation tracking across re-scans, compliance format export (VPAT/ACR), CSV export with help links, batch remediation scripts, and CI/CD integration guides.
- **Web remediation:** Use `fix-web-issues` prompt to interactively apply fixes from an audit report. Use `compare-web-audits` to track progress between audits.
- **Mobile app (React Native / Expo / iOS / Android):** Apply cognitive-accessibility guidance. Use mobile-accessibility for touch target checks, accessibilityLabel/Role/State audits, and platform-specific screen reader testing.
- **Cognitive / UX clarity / plain language:** Use cognitive-accessibility for WCAG 2.2 SC 3.3.7, 3.3.8, 3.3.9, COGA guidance, error message quality, and reading level analysis.
- **Design system / tokens:** Use design-system-auditor to validate color token pairs, focus ring tokens, spacing tokens, and motion tokens before they propagate to UI.
- **Data tables:** Always apply tables-data-specialist for any tabular data display.
- **Links:** Always apply link-checker when pages contain hyperlinks.
- **Markdown documentation:** Use markdown-a11y-assistant to audit and fix .md files - catches ambiguous links, broken anchors, missing table descriptions, emoji in headings, mermaid diagrams without alternatives, and em-dash normalization.
- **Images or media:** Always apply alt-text-headings. The agent can visually analyze images and compare them against their alt text.
- **Testing guidance:** Use testing-coach for screen reader testing, keyboard testing, and automated testing setup.
- **WCAG questions:** Use wcag-guide to understand specific WCAG success criteria and conformance requirements.
- **Python development:** Use developer-hub for any Python, wxPython, or desktop app task. Routes to python-specialist for language work and wxpython-specialist for GUI work.
- **Desktop app packaging:** Use python-specialist for PyInstaller, Nuitka, cx_Freeze builds and troubleshooting.
- **Desktop accessibility:** Use desktop-a11y-specialist for platform API implementation (UIA, MSAA, ATK, NSAccessibility), screen reader interaction, focus management, and high contrast support. Use desktop-a11y-testing-coach for screen reader testing walkthroughs and automated UIA tests.
- **Building accessibility tools:** Use a11y-tool-builder for designing rule engines, document parsers, report generators, severity scoring, and scanner architecture.

### Custom Prompts for Document Accessibility

The following prompt files in `.github/prompts/` provide one-click workflows for common document accessibility tasks. Select them from the prompt picker in Copilot Chat:

| Prompt | What It Does |
|--------|-------------|
| audit-single-document | Scan a single .docx, .xlsx, .pptx, or .pdf with severity scoring |
| audit-document-folder | Recursively scan an entire folder of documents |
| audit-changed-documents | Delta scan - only audit documents changed since last commit |
| generate-vpat | Generate a VPAT 2.5 / ACR compliance report from audit results |
| generate-remediation-scripts | Create PowerShell/Bash scripts to batch-fix common issues |
| compare-audits | Compare two audit reports to track remediation progress |
| setup-document-cicd | Set up CI/CD pipelines for automated document scanning |
| quick-document-check | Fast triage - errors only, pass/fail verdict |
| create-accessible-template | Guidance for creating accessible document templates |
| export-document-csv | Export document audit findings to CSV with Microsoft Office and Adobe PDF help links |

### Custom Prompts for Web Accessibility

One-click workflows for web accessibility auditing tasks:

| Prompt | What It Does |
|--------|-------------|
| audit-web-page | Full single-page audit with axe-core scan and code review |
| quick-web-check | Fast axe-core triage - runtime scan only, pass/fail verdict |
| audit-web-multi-page | Multi-page comparison audit with cross-page pattern detection |
| compare-web-audits | Compare two web audit reports to track remediation progress |
| fix-web-issues | Interactive fix mode - auto-fixable and human-judgment items from audit report |
| audit-markdown | Full markdown accessibility audit with Phase 0 config, parallel scanning, and saved scored report |
| quick-markdown-check | Fast markdown triage - errors only, inline pass/fail verdict, no report file |
| fix-markdown-issues | Interactive fix mode - auto-fix table and human-judgment items from saved report |
| compare-markdown-audits | Track markdown remediation progress between two audit snapshots |
| export-web-csv | Export web audit findings to CSV with Deque University help links |
| export-markdown-csv | Export markdown audit findings to CSV with WCAG help links and markdownlint rule references |
| setup-github-scanner | Set up the GitHub Accessibility Scanner in your repository with agent ecosystem integration |
| setup-lighthouse-scanner | Set up Lighthouse CI accessibility scanning in your repository with agent ecosystem integration |

### Context Discovery

When starting any accessibility audit, review, or remediation task, proactively check the workspace for existing context before proceeding:

1. **Scan configuration files:** Check the workspace root for `.a11y-office-config.json`, `.a11y-pdf-config.json`, and `.a11y-web-config.json`. If any exist, read them to determine which rules are enabled/disabled, severity filters, and custom settings. Apply these configurations to the audit - do not use defaults when a config file exists.
2. **Previous audit reports:** Check for existing `ACCESSIBILITY-AUDIT.md`, `WEB-ACCESSIBILITY-AUDIT.md`, `DOCUMENT-ACCESSIBILITY-AUDIT.md`, and `MARKDOWN-ACCESSIBILITY-AUDIT.md` in the workspace root. If found, note the date, overall score, and issue count. Offer comparison/delta mode so the user can track remediation progress.
3. **Scan config templates:** If no config file exists and the user is starting a new audit, mention that pre-built profiles (strict, moderate, minimal) are available in the `templates/` directory.

### Scan Configuration Templates

The `templates/` directory contains pre-built scan configuration profiles:

- **strict** - All rules enabled, all severities reported
- **moderate** - All rules enabled, errors and warnings only
- **minimal** - Errors only, for quick triage

Use the VS Code tasks `A11y: Init Office Scan Config` and `A11y: Init PDF Scan Config` to copy a moderate profile into your project root.

### Always-On Instructions

Three instruction files in `.github/instructions/` fire automatically on every Copilot completion for web UI files - no agent invocation required:

| File | Applies To | What It Enforces |
|------|-----------|------------------|
| `web-accessibility-baseline.instructions.md` | `**/*.{html,jsx,tsx,vue,svelte,astro}` | Interactive elements, images, form inputs, heading structure, color/contrast, live regions, ARIA rules, motion |
| `semantic-html.instructions.md` | `**/*.{html,jsx,tsx,vue,svelte,astro}` | Landmark structure, buttons vs links, lists, tables, forms, disclosure widgets, heading hierarchy |
| `markdown-accessibility.instructions.md` | `**/*.md` | Ambiguous links, alt text, heading hierarchy, tables, emoji, mermaid diagrams, em-dashes, anchor link validation |

These instructions are the highest-leverage accessiblity enforcement mechanism - they provide correction guidance at the point of code generation without requiring any agent to be invoked.

### Audit Report Quality Requirements

When generating any accessibility audit report (web, document, or markdown), the report MUST include all of these sections to be considered complete:

1. **Metadata** - audit date, tool versions, scope (URLs/files audited), scan configuration used
2. **Executive summary** - overall score (0-100, A-F grade), total issues by severity, pass/fail verdict
3. **Findings** - each issue with: rule ID, WCAG criterion, severity, affected element/location, description, remediation guidance
4. **Severity breakdown** - counts by Critical/Serious/Moderate/Minor
5. **Remediation priorities** - ordered list of what to fix first based on impact and effort
6. **Next steps** - recommended follow-up actions, re-scan timeline
7. **Delta tracking** (when a previous report exists) - Fixed/New/Persistent/Regressed issue counts

Do not consider an audit complete until the report contains all applicable sections. If generating a quick check (not a full audit), state explicitly that it is a triage result, not a complete audit report.

### Non-Negotiable Standards

- Semantic HTML before ARIA (`<button>` not `<div role="button">`)
- One H1 per page, never skip heading levels
- Every interactive element reachable and operable by keyboard
- Text contrast 4.5:1, UI component contrast 3:1
- No information conveyed by color alone
- Focus managed on route changes, dynamic content, and deletions
- Modals trap focus and return focus on close
- Live regions for all dynamic content updates

### Advanced Documentation

Additional guides in `docs/`:

- **cross-platform-handoff.md** - Seamless handoff between Claude Code and Copilot agent environments
- **advanced-scanning-patterns.md** - Background scanning, worktree isolation, and large library strategies
- **plugin-packaging.md** - Packaging and distributing agents for different environments
- **platform-references.md** - All external documentation sources used to build this project, with feature-to-source mapping

For tasks that do not involve any user-facing web content (backend logic, scripts, database work), these requirements do not apply.
