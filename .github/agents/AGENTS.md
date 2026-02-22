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

**Lead:** `accessibility-lead`

**Members:**
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

**Workflow:**
1. `accessibility-lead` coordinates specialists based on the content being reviewed
2. Relevant specialists are invoked based on the code context (forms, modals, tables, etc.)
3. `accessibility-lead` compiles findings and resolves any conflicting guidance
4. `testing-coach` provides manual testing instructions for issues that require human verification

## Team: Full Audit (Web + Documents)

**Lead:** `accessibility-lead`

**Workflow:**
1. `accessibility-wizard` runs the web accessibility audit
2. `document-accessibility-wizard` runs the document accessibility audit
3. `accessibility-lead` compiles a unified report covering both web and document findings

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
