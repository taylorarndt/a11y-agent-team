# Agent Teams Configuration

This file defines coordinated multi-agent workflows for enterprise document accessibility scanning.

## Team: Document Accessibility Audit

**Lead:** `document-accessibility-wizard`

**Members:**
- `document-inventory` — File discovery, inventory building, delta detection
- `cross-document-analyzer` — Pattern detection, severity scoring, template analysis
- `word-accessibility` — DOCX scanning and remediation (DOCX-* rules)
- `excel-accessibility` — XLSX scanning and remediation (XLSX-* rules)
- `powerpoint-accessibility` — PPTX scanning and remediation (PPTX-* rules)
- `pdf-accessibility` — PDF scanning and remediation (PDFUA.*, PDFBP.*, PDFQ.* rules)
- `office-scan-config` — Office scan configuration management
- `pdf-scan-config` — PDF scan configuration management

**Workflow:**
1. `document-accessibility-wizard` receives the user request and runs Phase 0 (discovery)
2. `document-inventory` discovers and inventories all matching files
3. File-type specialists (`word-accessibility`, `excel-accessibility`, `powerpoint-accessibility`, `pdf-accessibility`) scan documents in parallel by type
4. `cross-document-analyzer` analyzes patterns, computes severity scores, and detects templates
5. `document-accessibility-wizard` compiles the final report and presents follow-up options

**Handoffs:**
- After audit, user can hand off to any format specialist for targeted remediation
- `accessibility-wizard` handles web audit handoff when document audit is complete

## Team: Web Accessibility Audit

**Lead:** `web-accessibility-wizard`

**Members:**
- `accessibility-lead` — Coordinates specialists, runs final review
- `aria-specialist` — ARIA roles, states, properties
- `modal-specialist` — Dialogs, drawers, overlays
- `contrast-master` — Color contrast, visual design
- `keyboard-navigator` — Tab order, focus management
- `live-region-controller` — Dynamic content, toasts, loading
- `forms-specialist` — Forms, inputs, validation
- `alt-text-headings` — Images, alt text, headings, landmarks
- `tables-data-specialist` — Data tables, grids
- `link-checker` — Link text quality
- `testing-coach` — Testing guidance

**Hidden Helpers:**
- `cross-page-analyzer` — Cross-page pattern detection, severity scoring, remediation tracking
- `web-issue-fixer` — Automated and guided accessibility fix application

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
- After audit, user can invoke `fix-web-issues` prompt for interactive fix mode
- `compare-web-audits` prompt enables remediation tracking between audits
- `audit-web-multi-page` prompt enables cross-page comparison audits

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
