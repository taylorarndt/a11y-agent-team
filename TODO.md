# Project TODO - Web Wizard Parity & Completion

**Created:** 2026-02-22
**Branch:** `feature/web-wizard-enhancements`
**Goal:** Bring all document-accessibility-wizard lessons/capabilities into the web-accessibility-wizard, fill remaining repo gaps, and update PRD.

---

## Phase E: Web Wizard Feature Parity with Document Wizard

Enhance both `.claude/agents/web-accessibility-wizard.md` AND `.github/agents/web-accessibility-wizard.agent.md` with features the document wizard has but the web wizard lacks.

- [x] **E1: Sub-Agent Delegation Model** - Add formal sub-agent table, delegation rules (never apply rules directly, pass full context, collect structured results, aggregate/deduplicate, hand off remediation questions), and Context Passing Format block (equivalent to the document wizard's "Document Scan Context" block but for web pages).

- [x] **E2: Reporting Preferences (Phase 0 Step)** - Add Step 6 to Phase 0 asking: (1) Where to write the audit report (default or custom path), (2) How to organize findings (by page, by issue type, by severity), (3) Whether to include remediation steps (detailed, summary only, none).

- [x] **E3: Re-scan & Delta Options (Phase 0 Step)** - Add "Re-scan with comparison" and "Changed files only (delta scan)" as Phase 0 Step 1 options. Add Step 7 for incremental/delta scan configuration: git diff detection, since last audit, since specific date, against baseline report.

- [x] **E4: Large Crawl Handling** - Add explicit handling for sites with 50+ pages: warn user, offer sampling (10-20 pages proportionally across page types/sections), extrapolation from sample, option to exclude URL patterns.

- [x] **E5: Page Metadata Dashboard** - Add metadata collection phase: gather page titles, lang attributes, meta descriptions, Open Graph tags, viewport settings, canonical URLs across all audited pages. Present a dashboard summarizing metadata health (like document wizard's metadata dashboard but for web pages).

- [x] **E6: Component/Template Analysis** - Add structured template/component detection: identify shared layout components, shared navigation, shared footer, design system components. Group issues as template-level (shared component), layout-level (page template), or page-specific. Recommend fixing shared components first for highest ROI.

- [x] **E7: Follow-Up Actions Phase (Phase 11)** - Add a dedicated follow-up phase after the report, offering: fix issues on a specific page, set up web scan configuration, re-scan a subset of pages, export findings as CSV/JSON, export in compliance format (VPAT/ACR), generate remediation scripts, compare with previous audit, run the document-accessibility-wizard for any documents, nothing - end session.

- [x] **E8: VPAT/ACR Compliance Export** - Add compliance format export capability: VPAT 2.5 WCAG edition, Section 508 edition, EN 301 549 edition, International edition. Map web findings to WCAG criteria with conformance levels (Supports, Partially Supports, Does Not Support, Not Applicable, Not Evaluated). Include summary statistics.

- [x] **E9: Batch Remediation Scripts** - Add generation of PowerShell/Bash scripts for automatable web fixes. Automatable: add lang attribute, add viewport meta, add missing alt="" for decorative images, remove positive tabindex, add focus styles, add autocomplete attributes. Non-automatable: meaningful alt text, heading restructuring, ARIA role assignment. Scripts must include dry-run mode, backup creation, and change log.

- [x] **E10: CI/CD Integration Guide (Phase 12)** - Add dedicated CI/CD phase offering GitHub Actions, Azure DevOps, and generic CI configurations for automated web accessibility scanning. Include axe-core integration, SARIF output for code scanning, scheduled re-scans, and PR blocking on critical violations.

- [x] **E11: Edge Cases Section** - Add edge case handling: single-page applications (hash routing, history API), iframes and embedded content, shadow DOM components, web components, dynamic lazy-loaded content, third-party widgets (chat, analytics, ads), PDF links and downloads, password-protected staging environments, content behind authentication, sites requiring cookies/session.

- [x] **E12: Report Enhancements** - Add: (1) Organization Modes (by page, by issue type, by severity) honoring Phase 0 preference, (2) Findings by Rule Cross-Reference table (rule -> pages affected -> count), (3) Configuration Recommendations section (suggest scan profiles and CI config based on findings), (4) What Passed section expansion with specific WCAG criteria that passed.

- [x] **E13: Web Scan Config (.a11y-web-config.json)** - Add support for a `.a11y-web-config.json` configuration file with: enabled rules, disabled rules, severity filter, excluded URL patterns, page timeout, viewport settings, authentication config. Update SessionStart hook to check for this file. Add config resolution (check project root, then parent directories).

---

## Phase F: Missing Agent Files

Fill gaps identified in the PRD audit where agents exist on one platform but not the other.

- [x] **F1: Create cross-document-analyzer.md (Claude)** - The Copilot version `.github/agents/cross-document-analyzer.agent.md` exists but the Claude Code version `.claude/agents/cross-document-analyzer.md` does not. Create the Claude version as a hidden helper sub-agent (not user-invokable) for cross-document pattern detection, severity scoring, and template analysis.

- [x] **F2: Create document-inventory.md (Claude)** - The Copilot version `.github/agents/document-inventory.agent.md` exists but the Claude Code version `.claude/agents/document-inventory.md` does not. Create the Claude version as a hidden helper sub-agent for file discovery, inventory building, and delta detection.

---

## Phase G: PRD Update

- [x] **G1: Update PRD.md** - Update the PRD to reflect all additions since the original spec: new agents (24 per platform, not 19), new MCP tools (11, not 9), skills system (6 skills), prompt system (14 prompts), hooks system (session hooks), AGENTS.md orchestration, sub-agents (document-inventory, cross-document-analyzer, cross-page-analyzer, web-issue-fixer), web scan config, updated file inventory, updated quantitative summary.

---

## Phase H: Commit & Push

- [x] **H1: Commit Phase E changes** - Stage and commit web wizard enhancements with descriptive message, push to both origin and upstream.
- [x] **H2: Commit Phase F changes** - Stage and commit missing agent files, push to both remotes.
- [x] **H3: Commit Phase G changes** - Stage and commit PRD update, push to both remotes.

---

## Phase I: Claude/Copilot Parity

Close platform parity gaps identified by cross-platform audit.

- [x] **I1: Create CLAUDE.md** - Create root-level `CLAUDE.md` mirroring `.github/copilot-instructions.md` with Claude-specific adaptations (agent table, knowledge domains, hooks, teams, decision matrix, non-negotiable standards).

- [x] **I2: Create .claude/agents/AGENTS.md** - Create Claude equivalent of `.github/agents/AGENTS.md` with 3 teams, workflows, handoffs, and enterprise scanning patterns adapted for Claude Code tooling.

- [x] **I3: Update TODO.md** - Mark all completed items (E1-E13, F1-F2, G1, H1-H3) as done.

---

## Status Key

- [ ] Not started
- [x] Complete
- [-] In progress
