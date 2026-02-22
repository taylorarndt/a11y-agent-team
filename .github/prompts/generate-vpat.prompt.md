---
description: Generate a VPAT 2.5 Accessibility Conformance Report from a previous document audit. Maps findings to WCAG criteria in the standard VPAT format.
mode: agent
tools:
  - askQuestions
---

# Generate VPAT / Accessibility Conformance Report

Convert a document accessibility audit report into a formal **VPAT 2.5 Accessibility Conformance Report (ACR)**.

## Source audit report

**Path:** `${input:auditReportPath}`

## Instructions

Use the **document-accessibility-wizard** agent to:

1. Read the audit report at the specified path
2. Ask which VPAT edition to generate:
   - **WCAG** — WCAG 2.2 criteria only
   - **Section 508** — Revised Section 508 standards
   - **EN 301 549** — European accessibility standard
   - **International** — All three combined
3. Map each finding to its WCAG success criterion
4. For each WCAG criterion, determine the conformance level:
   - **Supports** — zero findings for this criterion
   - **Partially Supports** — some documents pass, some fail
   - **Does Not Support** — all/most documents fail
   - **Not Applicable** — criterion does not apply to document types scanned
5. Generate the VPAT in markdown format with:
   - Product information section
   - Evaluation methods section
   - Full criteria table with conformance levels and remarks
   - Notes and evaluation methodology
6. Write to `VPAT-DOCUMENT-ACCESSIBILITY.md`
