# a11y-tool-builder - Accessibility Tool Building

> Expert in building accessibility scanning tools, rule engines, document parsers, report generators, and audit automation. WCAG criterion mapping, severity scoring algorithms, CLI/GUI scanner architecture, and CI/CD integration for accessibility tooling.

## When to Use It

- Designing an accessibility scanning tool or rule engine
- Building document parsers for DOCX, XLSX, PPTX, or PDF accessibility checking
- Creating report generators with severity scoring and WCAG criterion mapping
- Architecting CLI or GUI scanner applications
- Integrating accessibility scanning into CI/CD pipelines
- Designing severity scoring algorithms (0-100 with A-F grades)

## What It Does NOT Do

- Does not perform accessibility audits itself (use the wizard agents for that)
- Does not build general-purpose Python applications (routes to python-specialist for language help)
- Does not implement platform accessibility APIs (routes to desktop-a11y-specialist)

## What It Covers

<details>
<summary>Expand - full tool building coverage</summary>

- Rule engine architecture: rule definition, severity levels, WCAG criterion mapping
- Document parsing: python-docx, openpyxl, python-pptx, PyPDF2/pdfplumber
- Report generation: markdown, HTML, CSV, VPAT/ACR compliance formats
- Severity scoring: weighted formulas, confidence levels, grade computation
- CLI scanner design: argument parsing, progress reporting, exit codes
- GUI scanner design: wxPython integration, real-time scanning feedback
- CI/CD integration: GitHub Actions, Azure DevOps, pre-commit hooks
- Cross-format pattern detection: systemic issues across document libraries

</details>

## Example Prompts

- "Design a rule engine for scanning DOCX files"
- "Build a severity scoring algorithm"
- "Create a CLI scanner with WCAG criterion mapping"
- "Add CI/CD integration for document accessibility scanning"
- "Generate a VPAT compliance report from scan results"

## Skills Used

| Skill | Purpose |
|-------|---------|
| [python-development](../skills/python-development.md) | Python patterns, packaging, testing for tool development |

## Related Agents

- [python-specialist](python-specialist.md) -- bidirectional handoffs for tool code needing Python expertise
- [developer-hub](developer-hub.md) -- routes here for tool building tasks
- [document-accessibility-wizard](document-accessibility-wizard.md) -- reference implementation for document scanning
- [web-accessibility-wizard](web-accessibility-wizard.md) -- reference implementation for web scanning
