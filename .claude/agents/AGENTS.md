# Agent Teams Configuration

This file defines coordinated multi-agent workflows for enterprise accessibility scanning in the Claude Code environment.

## Team: Markdown Accessibility Audit

**Lead:** `markdown-a11y-assistant`

**Members:**
- `markdown-scanner` *(hidden helper)* - Per-file scanning across all 9 accessibility domains; returns structured findings
- `markdown-fixer` *(hidden helper)* - Applies auto-fixes and presents human-judgment items for approval
- `markdown-csv-reporter` *(hidden helper)* - Exports findings to CSV with WCAG help links and markdownlint rule references

**Workflow:**
1. `markdown-a11y-assistant` receives the user request and runs Phase 0 (discovery + configuration)
2. `markdown-scanner` is dispatched **in parallel** via the Task tool for each discovered file
3. All scan results are aggregated; cross-file patterns are identified
4. Review gate is presented to the user with auto-fix list + human-judgment items
5. `markdown-fixer` applies approved fixes in a single edit pass per file
6. Final `MARKDOWN-ACCESSIBILITY-AUDIT.md` report is generated with per-file scores and grades

**Handoffs:**
- `markdown-csv-reporter` for CSV export with WCAG help links
- `web-accessibility-wizard` after markdown audit is complete for HTML/JSX/TSX files
- `document-accessibility-wizard` for Office/PDF documents after markdown audit

## Team: Document Accessibility Audit

**Lead:** `document-accessibility-wizard`

**Members:**
- `document-inventory` - File discovery, inventory building, delta detection
- `cross-document-analyzer` - Pattern detection, severity scoring, template analysis
- `word-accessibility` - DOCX scanning and remediation (DOCX-* rules)
- `excel-accessibility` - XLSX scanning and remediation (XLSX-* rules)
- `powerpoint-accessibility` - PPTX scanning and remediation (PPTX-* rules)
- `pdf-accessibility` - PDF scanning and remediation (PDFUA.*, PDFBP.*, PDFQ.* rules)
- `office-scan-config` - Office scan configuration management
- `pdf-scan-config` - PDF scan configuration management
- `epub-scan-config` - ePub scan configuration management
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
- `web-accessibility-wizard` handles web audit handoff when document audit is complete

## Team: ePub Document Accessibility

**Lead:** `epub-accessibility`

**Internal Helpers:**
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

**Workflow:**
1. `web-accessibility-wizard` receives the user request and runs Phase 0 (discovery)
2. Parallel specialist scanning groups execute based on content:
   - **Group 1:** `aria-specialist` + `keyboard-navigator` + `forms-specialist`
   - **Group 2:** `contrast-master` + `alt-text-headings` + `link-checker`
   - **Group 3:** `modal-specialist` + `live-region-controller` + `tables-data-specialist`
3. `cross-page-analyzer` detects cross-page patterns, computes severity scores, and tracks remediation
4. `web-issue-fixer` applies auto-fixable corrections and presents human-judgment items
5. `web-accessibility-wizard` compiles the final report with scorecard and follow-up options
6. `testing-coach` provides manual testing instructions for issues that require human verification

**Handoffs:**
- After audit, user can ask for interactive fix mode to apply corrections from the report
- Remediation tracking is available by comparing audit reports across runs
- Multi-page comparison audits scan multiple pages and detect cross-cutting patterns

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
2. Generate VPAT/ACR export from audit results
3. Track remediation progress by comparing successive audit reports
4. Export SARIF for integration with compliance tracking systems

### Web Audit Patterns

**Single-Page Deep Audit:**
1. Run a combined axe-core scan + manual code review
2. Framework-specific patterns are detected automatically (React, Vue, Angular, Svelte, Tailwind)
3. Severity scoring produces a 0-100 score with A-F grade

**Multi-Page Comparison:**
1. Provide a base URL and page paths for multi-page scanning
2. `cross-page-analyzer` identifies systemic vs template vs page-specific issues
3. Comparative scorecard shows per-page scores and cross-cutting patterns

**Remediation Workflow:**
1. Run initial audit
2. Apply fixes interactively (auto-fixable + human-judgment items)
3. Track progress by comparing audit reports between runs
4. Use quick triage mode for fast axe-core scans between full audits

## Team: GitHub Workflow Management

**Lead:** `github-hub` or `nexus` (alternative entry points - same team, both orchestrate all GitHub workflow agents)

**Members:**
- `daily-briefing` - Daily GitHub command center: issues, PRs, reviews, releases, discussions, accessibility updates
- `issue-tracker` - Issue search, triage, deep-dive, commenting, management, and dual-format workspace documents
- `pr-review` - PR diff analysis, before/after snapshots, review comments, code suggestions, and review documents
- `analytics` - Team velocity, review turnaround, issue resolution metrics, bottleneck detection, code churn
- `insiders-a11y-tracker` - Tracks accessibility changes in VS Code Insiders and custom repos with delta tracking
- `repo-admin` - Collaborator management, access auditing, branch protection, label sync, repo settings
- `team-manager` - Org team member management, onboarding/offboarding checklists, cross-repo access sync
- `contributions-hub` - Discussion management, community health, contributor insights, first-time contributor support
- `template-builder` - Interactive issue/PR/workflow template wizard with YAML frontmatter generation
- `repo-manager` - Repo infrastructure scaffolding: templates, CI/CD, labels, README, CONTRIBUTING, licenses

**Skills:**
- `github-workflow-standards` - Auth, smart defaults, dual MD+HTML output, HTML accessibility, safety rules, parallel execution
- `github-scanning` - Search query patterns, date range handling, cross-repo intelligence, auto-recovery
- `github-analytics-scoring` - Repo health scoring (0-100/A-F), priority scoring, confidence levels, delta tracking

**Workflow:**
1. User invokes `github-hub` or `nexus` with any natural language request about GitHub
2. The orchestrator identifies the authenticated user, discovers repos/orgs, and loads `preferences.md`
3. The orchestrator classifies user intent and routes to the appropriate specialist agent
4. Specialist agents run their workflow, announce steps with / pattern, collect data in parallel
5. All reports saved as dual `.md` + `.html` outputs to `.github/reviews/` subdirectories
6. Agents surface relevant handoffs (e.g., `issue-tracker` -> `pr-review` for linked PRs)

**Parallel Execution Model:**
- `daily-briefing` runs Batch 1 streams simultaneously: issues, PRs, CI/security, accessibility
- `analytics` collects PR metrics, issue metrics, contribution activity, churn, and bottleneck data in parallel
- `github-hub` routes to multiple sub-agents in one session without repeating context
- `nexus` routes identically - both orchestrators share the same team and handoff logic

**Confidence & Delta Tracking:**
- All agents tag findings with **High / Medium / Low** confidence
- `analytics`, `issue-tracker`, `pr-review`, and `insiders-a11y-tracker` support delta tracking across reports:  Resolved /  New /  Persistent /  Regressed
- Persistent bottlenecks (3+ consecutive reports) trigger escalation flags

**Handoffs:**
- `github-hub`/`nexus` -> any specialist via intent routing
- `daily-briefing` -> `issue-tracker` (deep dive on issue), `pr-review` (full review), `analytics` (team metrics), `insiders-a11y-tracker` (a11y detail)
- `issue-tracker` <-> `pr-review` (bidirectional: linked PRs/issues)
- Any agent -> `github-hub` or `nexus` for scope changes or re-routing

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
