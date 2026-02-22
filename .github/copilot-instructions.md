## Accessibility-First Development

This workspace enforces WCAG AA accessibility standards for all web UI code.

### Mandatory Accessibility Check

Before writing or modifying any web UI code — including HTML, JSX, CSS, React components, Tailwind classes, web pages, forms, modals, or any user-facing web content — you MUST:

1. Consider which accessibility specialist agents are needed for the task
2. Apply the relevant specialist knowledge before generating code
3. Verify the output against the appropriate checklists

### Available Specialist Agents

Select these agents from the agents dropdown in Copilot Chat, or type `/agents` to browse:

| Agent | When to Use |
|-------|------------|
| accessibility-lead | Any UI task — coordinates all specialists and runs final review |
| aria-specialist | Interactive components, custom widgets, ARIA usage |
| modal-specialist | Dialogs, drawers, popovers, overlays |
| contrast-master | Colors, themes, CSS styling, visual design |
| keyboard-navigator | Tab order, focus management, keyboard interaction |
| live-region-controller | Dynamic content updates, toasts, loading states |
| forms-specialist | Forms, inputs, validation, error handling, multi-step wizards |
| alt-text-headings | Images, alt text, SVGs, heading structure, page titles, landmarks |
| tables-data-specialist | Data tables, sortable tables, grids, comparison tables, pricing tables |
| link-checker | Ambiguous link text, "click here"/"read more" detection, link purpose |
| accessibility-wizard | Full guided web accessibility audit with step-by-step walkthrough |
| document-accessibility-wizard | Document accessibility audit for .docx, .xlsx, .pptx, .pdf — single files, folders, recursive scanning, delta scanning, severity scoring, remediation tracking, compliance export (VPAT/ACR), CI/CD integration |
| testing-coach | Screen reader testing, keyboard testing, automated testing guidance |
| wcag-guide | WCAG 2.2 criteria explanations, conformance levels, what changed |

### Hidden Helper Sub-Agents

These agents are not user-invokable. They are used internally by the document-accessibility-wizard to parallelize scanning and analysis:

| Agent | Purpose |
|-------|---------|
| document-inventory | File discovery, inventory building, delta detection across folders |
| cross-document-analyzer | Cross-document pattern detection, severity scoring, template analysis |

### Agent Skills

Reusable knowledge modules in `.github/skills/` that agents reference automatically:

| Skill | Domain |
|-------|--------|
| document-scanning | File discovery commands, delta detection, scan configuration profiles |
| accessibility-rules | Cross-format accessibility rule reference with WCAG 2.2 mapping (DOCX, XLSX, PPTX, PDF) |
| report-generation | Audit report formatting, severity scoring formulas, VPAT/ACR compliance export |

### Lifecycle Hooks

Session hooks in `.github/hooks/` that inject context automatically:

| Hook | When | Purpose |
|------|------|---------|
| SessionStart | Beginning of session | Auto-detects scan config files and previous audit reports; injects relevant context |
| SessionEnd | End of session | Quality gate — validates audit report completeness and prompts for missing sections |

### Agent Teams

Team coordination is defined in `.github/agents/AGENTS.md`. Three defined teams:

- **Document Accessibility Audit** — led by document-accessibility-wizard with format-specific sub-agents
- **Web Accessibility Audit** — led by accessibility-lead with all web specialist agents
- **Full Audit** — combined web + document audit workflow

### Decision Matrix

- **New component or page:** Always apply aria-specialist + keyboard-navigator + alt-text-headings guidance. Add forms-specialist for any inputs, contrast-master for styling, modal-specialist for overlays, live-region-controller for dynamic updates, tables-data-specialist for any data tables.
- **Modifying existing UI:** At minimum apply keyboard-navigator (tab order breaks easily). Add others based on what changed.
- **Code review/audit:** Apply all specialist checklists. Use accessibility-wizard for guided web audits.
- **Document audit:** Use document-accessibility-wizard for Office and PDF accessibility audits. Supports single files, folders, recursive scanning, delta scanning (changed files only), severity scoring, template analysis, remediation tracking across re-scans, compliance format export (VPAT/ACR), batch remediation scripts, and CI/CD integration guides.
- **Data tables:** Always apply tables-data-specialist for any tabular data display.
- **Links:** Always apply link-checker when pages contain hyperlinks.
- **Images or media:** Always apply alt-text-headings. The agent can visually analyze images and compare them against their alt text.
- **Testing guidance:** Use testing-coach for screen reader testing, keyboard testing, and automated testing setup.
- **WCAG questions:** Use wcag-guide to understand specific WCAG success criteria and conformance requirements.

### Custom Prompts for Document Accessibility

The following prompt files in `.github/prompts/` provide one-click workflows for common document accessibility tasks. Select them from the prompt picker in Copilot Chat:

| Prompt | What It Does |
|--------|-------------|
| audit-single-document | Scan a single .docx, .xlsx, .pptx, or .pdf with severity scoring |
| audit-document-folder | Recursively scan an entire folder of documents |
| audit-changed-documents | Delta scan — only audit documents changed since last commit |
| generate-vpat | Generate a VPAT 2.5 / ACR compliance report from audit results |
| generate-remediation-scripts | Create PowerShell/Bash scripts to batch-fix common issues |
| compare-audits | Compare two audit reports to track remediation progress |
| setup-document-cicd | Set up CI/CD pipelines for automated document scanning |
| quick-document-check | Fast triage — errors only, pass/fail verdict |
| create-accessible-template | Guidance for creating accessible document templates |

### Scan Configuration Templates

The `templates/` directory contains pre-built scan configuration profiles:

- **strict** — All rules enabled, all severities reported
- **moderate** — All rules enabled, errors and warnings only
- **minimal** — Errors only, for quick triage

Use the VS Code tasks `A11y: Init Office Scan Config` and `A11y: Init PDF Scan Config` to copy a moderate profile into your project root.

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

Additional guides in `.github/docs/`:

- **cross-platform-handoff.md** — Seamless handoff between Claude Code and Copilot agent environments
- **advanced-scanning-patterns.md** — Background scanning, worktree isolation, and large library strategies
- **plugin-packaging.md** — Packaging and distributing agents for different environments
- **platform-references.md** — All external documentation sources used to build this project, with feature-to-source mapping

For tasks that do not involve any user-facing web content (backend logic, scripts, database work), these requirements do not apply.
