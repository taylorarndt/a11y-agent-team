# Agent Teams Configuration

This file defines coordinated multi-agent workflows for enterprise accessibility scanning.

## Team: Markdown Accessibility Audit

**Lead:** `markdown-a11y-assistant`

**Members:**
- `markdown-scanner` *(hidden helper)* - Per-file scanning across all 9 accessibility domains
- `markdown-fixer` *(hidden helper)* - Applies auto-fixes and presents human-judgment items for approval
- `markdown-csv-reporter` *(hidden helper)* - Exports findings to CSV with WCAG help links and markdownlint rule references

**Workflow:**
1. `markdown-a11y-assistant` receives the user request and runs Phase 0 (discovery + configuration)
2. `markdown-scanner` is dispatched **in parallel** for each discovered file using runSubagent
3. All scan results are aggregated; cross-file patterns are identified
4. Review gate is presented: auto-fix list + human-judgment items
5. `markdown-fixer` applies approved fixes in a single edit pass per file
6. Final `MARKDOWN-ACCESSIBILITY-AUDIT.md` report is generated with per-file scores

**Handoffs:**
- `fix-markdown-issues` prompt for interactive fix mode from a saved report
- `compare-markdown-audits` prompt for tracking progress between audit runs
- `quick-markdown-check` prompt for fast triage without a full report
- `export-markdown-csv` prompt for CSV export with WCAG help links
- `web-accessibility-wizard` for web UI after markdown audit is complete

## Team: Document Accessibility Audit

**Lead:** `document-accessibility-wizard`

**Members:**
- `document-inventory` - File discovery, inventory building, delta detection
- `cross-document-analyzer` - Pattern detection, severity scoring, template analysis
- `word-accessibility` - DOCX scanning and remediation (DOCX-* rules)
- `excel-accessibility` - XLSX scanning and remediation (XLSX-* rules)
- `powerpoint-accessibility` - PPTX scanning and remediation (PPTX-* rules)
- `pdf-accessibility` - PDF scanning and remediation (PDFUA.*, PDFBP.*, PDFQ.* rules)

**Internal Helpers (not user-invokable):**
- `office-scan-config` - Office scan config management (invoked via document-accessibility-wizard Phase 0)
- `pdf-scan-config` - PDF scan config management (invoked via document-accessibility-wizard Phase 0)
- `epub-scan-config` - ePub scan config management (invoked via document-accessibility-wizard Phase 0)
- `document-csv-reporter` - Exports document audit findings to CSV with Microsoft Office and Adobe PDF help links

**Members (ePub):**
- `epub-accessibility` - EPUB scanning and remediation (EPUB-E*, EPUB-W*, EPUB-T* rules)

**Workflow:**
1. `document-accessibility-wizard` receives the user request and runs Phase 0 (discovery)
2. `document-inventory` discovers and inventories all matching files
3. File-type specialists (`word-accessibility`, `excel-accessibility`, `powerpoint-accessibility`, `pdf-accessibility`) scan documents in parallel by type
4. `cross-document-analyzer` analyzes patterns, computes severity scores, and detects templates
5. `document-accessibility-wizard` compiles the final report and presents follow-up options

**Handoffs:**
- After audit, user can hand off to any format specialist for targeted remediation
- `accessibility-wizard` handles web audit handoff when document audit is complete

## Team: ePub Document Accessibility

**Lead:** `epub-accessibility`

**Internal Helpers (not user-invokable):**
- `epub-scan-config` - ePub scan configuration management (invoked via document-accessibility-wizard Phase 0)

**Workflow:**
1. `document-accessibility-wizard` detects `.epub` files in scope and invokes `epub-scan-config` to locate or create `.a11y-epub-config.json`
2. `epub-accessibility` unpacks the EPUB archive, locates the OPF package document, audits metadata, navigation, and content documents
3. Findings are reported using EPUB-E*, EPUB-W*, EPUB-T* rule IDs with WCAG mappings
4. Results feed into `document-accessibility-wizard` for the unified document audit report

**Handoffs:**
- `document-accessibility-wizard` orchestrates EPUB scanning as part of the broader document audit
- `pdf-accessibility` if the user also has PDF documents to scan

## Team: Web Accessibility Audit

**Lead:** `web-accessibility-wizard`

**Members:**
- `accessibility-lead` - Coordinates specialists, runs final review
- `aria-specialist` - ARIA roles, states, properties
- `modal-specialist` - Dialogs, drawers, overlays
- `contrast-master` - Color contrast, visual design
- `keyboard-navigator` - Tab order, focus management
- `live-region-controller` - Dynamic content, toasts, loading
- `forms-specialist` - Forms, inputs, validation
- `alt-text-headings` - Images, alt text, headings, landmarks
- `tables-data-specialist` - Data tables, grids
- `link-checker` - Link text quality
- `testing-coach` - Testing guidance
- `cognitive-accessibility` - WCAG 2.2 cognitive SC, COGA guidance, plain language analysis

**Hidden Helpers:**
- `cross-page-analyzer` - Cross-page pattern detection, severity scoring, remediation tracking
- `web-issue-fixer` - Automated and guided accessibility fix application
- `web-csv-reporter` - Exports web audit findings to CSV with Deque University help links
- `scanner-bridge` - Bridges GitHub Accessibility Scanner CI data into the agent ecosystem
- `lighthouse-bridge` - Bridges Lighthouse CI accessibility audit data into the agent ecosystem

**Workflow:**
1. `web-accessibility-wizard` receives the user request and runs Phase 0 (discovery)
2. Phase 0 Step 0: Auto-detects CI scanners (GitHub Scanner, Lighthouse) and dispatches `scanner-bridge` and `lighthouse-bridge` to fetch findings
3. Parallel specialist scanning groups execute based on content:
   - **Group 1:** `aria-specialist` + `keyboard-navigator` + `forms-specialist`
   - **Group 2:** `contrast-master` + `alt-text-headings` + `link-checker`
   - **Group 3:** `modal-specialist` + `live-region-controller` + `tables-data-specialist`
3. `cross-page-analyzer` detects cross-page patterns, computes severity scores, and tracks remediation
4. `web-issue-fixer` applies auto-fixable corrections and presents human-judgment items
5. `web-accessibility-wizard` compiles the final report with scorecard and follow-up options
6. `testing-coach` provides manual testing instructions for issues that require human verification

**Handoffs:**
- After audit, user can invoke `fix-web-issues` prompt for interactive fix mode
- `compare-web-audits` prompt enables remediation tracking between audits
- `audit-web-multi-page` prompt enables cross-page comparison audits

## Team: Mobile Accessibility

**Lead:** `mobile-accessibility`

**Scope:** React Native, Expo, iOS (SwiftUI/UIKit), Android (Jetpack Compose/Views). Invoked standalone for any mobile code review or as a handoff from `accessibility-lead`.

**Workflow:**
1. `mobile-accessibility` identifies platform (React Native / iOS / Android)
2. Audits accessibility props, touch target sizes, screen reader compatibility, focus order
3. Produces a findings report with platform-specific rule IDs and fix code
4. Handoffs: `design-system-auditor` for token-level issues; `accessibility-lead` for web companion audits

## Team: Design System Accessibility

**Lead:** `design-system-auditor`

**Scope:** Tailwind config, CSS custom properties, Style Dictionary token files, MUI/Chakra/Radix themes. Invoked standalone or as a Phase 0 step before web or mobile audits.

**Workflow:**
1. `design-system-auditor` locates token files and identifies design system type
2. Audits color token pairs for WCAG contrast compliance
3. Audits focus ring tokens (WCAG 2.4.13 Focus Appearance), spacing/touch-target tokens, motion tokens
4. Produces a token-level findings report with compliant replacement values
5. Handoffs: `contrast-master` for runtime verification; `mobile-accessibility` for spacing tokens

## Team: Full Audit (Web + Documents)

**Lead:** `accessibility-lead`

**Workflow:**
1. `web-accessibility-wizard` runs the web accessibility audit (with severity scoring and framework detection)
2. `document-accessibility-wizard` runs the document accessibility audit
3. `accessibility-lead` compiles a unified report covering both web and document findings
4. Cross-cutting patterns (e.g., shared templates, design system issues) are highlighted across both audits

## Team: GitHub Workflow Management

**Lead:** `github-hub` (primary entry point; `nexus` is an alias that routes to the same team)

**Members:**
- `daily-briefing` - Morning overview of issues, PRs, CI, and security alerts
- `pr-review` - Pull request review, diff analysis, inline commenting
- `issue-tracker` - Issue triage, priority scoring, response drafting, project board management
- `analytics` - Repository health scoring, velocity metrics, bottleneck detection
- `insiders-a11y-tracker` - Accessibility change tracking and WCAG regression detection
- `repo-admin` - Collaborator management, branch protection, label sync, access audits
- `team-manager` - Team onboarding, offboarding, permissions, org membership
- `contributions-hub` - Discussions, community health, contributor insights
- `template-builder` - Guided wizard for issue, PR, and discussion templates

**Skills:**
- `github-workflow-standards` - Core standards: auth, dual output, progress announcements, parallel execution, safety rules
- `github-scanning` - Search patterns by intent, parallel stream collection, auto-recovery
- `github-analytics-scoring` - Health scoring, priority scoring, confidence levels, delta tracking

**Workflow:**
1. `github-hub` or `nexus` receives the user request, discovers repos/orgs
2. The orchestrator classifies intent and routes to the appropriate specialist agent with full context
3. Specialist agents run their workflows (data collection, analysis, reporting)
4. Results are returned to the user; the orchestrator offers contextual follow-on actions
5. Any state-changing operation (comment, merge, add collaborator) requires explicit user confirmation before execution

**Handoffs:**
- `github-hub`/`nexus` -> `daily-briefing` for overview and morning briefings
- `github-hub`/`nexus` -> `pr-review` for code review work
- `github-hub`/`nexus` -> `issue-tracker` for issue triage and response
- `github-hub`/`nexus` -> `analytics` for metrics and health reports
- `github-hub`/`nexus` -> `repo-admin` for access and settings management
- `github-hub`/`nexus` -> `team-manager` for people and team management
- `github-hub`/`nexus` -> `contributions-hub` for community and discussions
- `github-hub`/`nexus` -> `insiders-a11y-tracker` for accessibility tracking
- `github-hub`/`nexus` -> `template-builder` for creating GitHub templates
- Any agent -> `github-hub` or `nexus` when the user wants to switch tasks or repos

---

## Team: Developer Tools

**Lead:** `developer-hub`

**Members:**
- `python-specialist` - Python language expert: debugging, packaging, testing, type checking, async, optimization
- `wxpython-specialist` - wxPython GUI expert: sizers, events, AUI, custom controls, threading, desktop accessibility
- `desktop-a11y-specialist` - Desktop application accessibility: platform APIs (UIA, MSAA, ATK, NSAccessibility), screen reader interaction, focus management, custom widget accessibility
- `desktop-a11y-testing-coach` - Desktop accessibility testing: NVDA, JAWS, Narrator, VoiceOver, Orca, Accessibility Insights, automated UIA testing, keyboard-only testing
- `a11y-tool-builder` - Accessibility tool building: rule engines, document parsers, report generators, WCAG mapping, severity scoring, CLI/GUI scanner architecture

**Skills:**
- `python-development` - Python version reference, pyproject.toml patterns, PyInstaller modes, wxPython sizer/event/threading cheat sheets, desktop accessibility API reference, common pitfalls, cross-platform paths, testing, logging

**Workflow:**
1. `developer-hub` receives the user request and classifies intent (debug, package, scaffold, review, optimize, GUI work, desktop a11y, tool building)
2. For pure Python tasks, routes to `python-specialist` with full context
3. For wxPython/GUI tasks, routes to `wxpython-specialist` with full context
4. For desktop accessibility API work, routes to `desktop-a11y-specialist`
5. For screen reader testing, routes to `desktop-a11y-testing-coach`
6. For building a11y scanning tools, routes to `a11y-tool-builder`
7. For web accessibility audits, hands off to `web-accessibility-wizard` (Web Accessibility team)
8. For document accessibility audits, hands off to `document-accessibility-wizard` (Document Accessibility team)
9. For mixed tasks, starts with the primary domain specialist and hands off as needed
10. All agents can hand back to `developer-hub` for broader coordination

**Handoffs:**
- `developer-hub` -> `python-specialist` for debugging, packaging, testing, type checking, async, optimization
- `developer-hub` -> `wxpython-specialist` for GUI construction, sizer layouts, event handling, threading, accessibility
- `developer-hub` -> `desktop-a11y-specialist` for platform API implementation, screen reader interaction model, custom widget patterns
- `developer-hub` -> `desktop-a11y-testing-coach` for screen reader testing walkthroughs, Accessibility Insights, automated UIA tests
- `developer-hub` -> `a11y-tool-builder` for rule engine design, document parsers, report generators, severity scoring
- `python-specialist` <-> `wxpython-specialist` (bidirectional: Python-in-GUI and GUI-needing-Python)
- `wxpython-specialist` <-> `desktop-a11y-specialist` (bidirectional: GUI accessibility patterns)
- `desktop-a11y-specialist` <-> `desktop-a11y-testing-coach` (bidirectional: implement then test)
- `a11y-tool-builder` <-> `python-specialist` (bidirectional: tool code needs Python expertise)
- Any developer agent -> `web-accessibility-wizard` for web content auditing (cross-team)
- Any developer agent -> `document-accessibility-wizard` for document auditing (cross-team)
- Any agent -> `developer-hub` for task completion or scope changes

---

## Enterprise Scanning Patterns

### Large Repository Scanning

For repositories with 100+ documents:

1. Use `document-inventory` with delta scanning to identify changed files
2. Scan changed files first with strict profile
3. Use moderate profile for full repository baseline scans
4. Schedule weekly re-scans via CI/CD (see Phase 6 in document-accessibility-wizard)

### Multi-Team Coordination

When multiple teams own different document folders:

1. Create per-folder `.a11y-office-config.json` with team-appropriate profiles
2. Use folder-scoped scans to generate per-team reports
3. Use `cross-document-analyzer` to detect organization-wide patterns
4. Generate per-team scorecards and a rollup organizational scorecard

### Compliance Reporting

For Section 508, EN 301 549, or organizational compliance:

1. Run strict profile scan across all document types
2. Generate VPAT/ACR using `generate-vpat` prompt
3. Track remediation progress with `compare-audits` prompt
4. Export SARIF for integration with compliance tracking systems

### Web Audit Patterns

**Single-Page Deep Audit:**
1. Use `audit-web-page` prompt for combined axe-core + code review
2. Framework-specific patterns are detected automatically (React, Vue, Angular, Svelte, Tailwind)
3. Severity scoring produces a 0-100 score with A-F grade

**Multi-Page Comparison:**
1. Use `audit-web-multi-page` prompt with base URL and page paths
2. `cross-page-analyzer` identifies systemic vs template vs page-specific issues
3. Comparative scorecard shows per-page scores and cross-cutting patterns

**Remediation Workflow:**
1. Run initial audit with `audit-web-page` or `audit-web-multi-page`
2. Apply fixes with `fix-web-issues` prompt (auto-fixable + human-judgment items)
3. Track progress with `compare-web-audits` prompt between audit runs
4. Use `quick-web-check` for fast axe-core triage between full audits

---

## Multi-Agent Workflow Reliability Standards

All teams in this workspace follow the engineering patterns from [Multi-agent workflows often fail. Here's how to engineer ones that don't.](https://github.blog/ai-and-ml/generative-ai/multi-agent-workflows-often-fail-heres-how-to-engineer-ones-that-dont/) Treat agents as distributed system components, not chat interfaces.

### Structured Outputs at Every Boundary

Agents MUST return structured data at handoff points. Never pass unstructured prose between agents.

**Accessibility finding:**
- Rule ID, severity (`critical`|`serious`|`moderate`|`minor`), location, description, remediation, confidence (`high`|`medium`|`low`)

**Scored output:**
- Score (0-100), grade (A-F), issue counts by severity, pass/fail verdict

**Action result:**
- Action taken, target, result (`success`|`failure`|`skipped`), reason (if not success)

### Constrained Action Sets

Each agent operates within explicitly defined boundaries:

- **Read-only agents** (scanners, analyzers, reporters): read files, fetch data, produce findings. May NOT edit files or make state changes.
- **State-changing agents** (fixers, admin agents): perform their defined mutations ONLY after explicit user confirmation.
- **Orchestrators** (github-hub, nexus, accessibility-lead, wizards): route, aggregate, and present. State changes require user approval before delegation.

If an agent encounters a task outside its action set, it MUST refuse, name the correct agent, and offer to hand off.

### Boundary Validation

At every handoff:

1. **Before delegating:** Confirm all required inputs (file paths, URLs, config, scope) are available. Resolve missing inputs before delegating. Never delegate with partial context.
2. **After receiving results:** Verify structured fields are present (findings, scores, verdicts). Retry once if incomplete. Report partial results with clear gap notes if retry fails.
3. **Orchestrator checklist:** Intent classified, scope resolved, config loaded, sub-agent inputs complete, user confirmation obtained (for state changes).

### Failure Handling

- Tool call fails: report, explain, offer alternatives. Max 2 retries.
- Partial scan results: report what succeeded, list failures with reasons, offer targeted retry.
- Missing context: state defaults being used. Never assume unverified context.
- Graceful degradation: full workflow, then simpler alternative, then partial results with gaps noted. Never return empty output without explanation.

### Progress and Intermediate State

- Phase start: announce what is starting, scope size, expected complexity.
- Phase end: state what was found/accomplished, counts, what comes next.
- Workflow end: recap phases, aggregate counts, present final deliverable.

### Agent Isolation and Ordering

- Dependent agents run sequentially. Independent agents run in parallel.
- Each agent operates on its defined scope. Parallel groups work on distinct concerns.
- Same inputs produce same structured outputs (idempotent).
- Output format changes must be backward-compatible.
