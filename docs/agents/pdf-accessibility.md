# pdf-accessibility - PDF Document Accessibility

> Scans PDF documents for conformance with PDF/UA (ISO 14289) and the Matterhorn Protocol. Uses the `scan_pdf_document` MCP tool to parse PDF files and check tagged structure, metadata (title, language), bookmarks, form field labels, figure alt text, table structure, font embedding, and encryption restrictions.

## When to Use It

- Reviewing PDFs before publishing or distributing
- Checking PDF conformance for procurement (Section 508, EN 301 549)
- Auditing scanned documents for basic structural accessibility
- Verifying PDF/UA compliance after conversion from Office documents

## Rule Layers

<details>
<summary>Expand - 3 rule layers (56 rules total)</summary>

| Layer | Rules | Purpose |
|-------|-------|---------|
| **PDFUA.*** | 30 rules | PDF/UA conformance - tagged structure, metadata, navigation, forms, tables, fonts |
| **PDFBP.*** | 22 rules | Best practices beyond PDF/UA requirements |
| **PDFQ.*** | 4 rules | Pipeline quality - file size limits, scan detection, encryption checks |

</details>

## Key Checks

<details>
<summary>Expand - 10 key PDF/UA checks</summary>

- Missing tagged structure (PDFUA.TAGS.001)
- No document title in metadata (PDFUA.META.001)
- Missing document language (PDFUA.META.002)
- Figures without alt text (PDFUA.TAGS.004)
- Tables without headers (PDFUA.TAGS.005)
- Unlabeled form fields (PDFUA.FORM.001)
- Missing bookmarks (PDFUA.NAV.001)
- Non-embedded fonts (PDFUA.FONT.001)
- Scanned image PDFs (PDFQ.SCAN.001)
- Encryption restricting assistive technology (PDFQ.ENC.001)

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

```text
/pdf-accessibility scan contract.pdf for PDF/UA compliance
@pdf-accessibility review the annual report PDF
@pdf-accessibility check all PDFs in the legal/ directory
@pdf-accessibility what PDFUA rules does this file violate?
```

</details>

## How to Launch It

**In Claude Code (terminal):**

```text
/pdf-accessibility scan annual-report.pdf
/pdf-accessibility check all PDFs in /legal for PDF/UA compliance
/pdf-accessibility what PDFUA rules does brochure.pdf violate?
```

**In GitHub Copilot Chat:**

```text
@pdf-accessibility scan contract.pdf
@pdf-accessibility check the procurement RFP for Section 508 compliance
```

**Via the prompt picker:** Select `audit-single-document` and enter the `.pdf` path. For government/procurement PDFs, consider using `generate-vpat` afterwards to produce a formal ACR.

**Via document-accessibility-wizard:** For bulk PDF audits or mixed-format collections, the wizard handles PDF scanning alongside Office document scanning.

## Step-by-Step: What a Scan Session Looks Like

**You say:**

```text
/pdf-accessibility scan annual-report.pdf
```

**What the agent does:**

1. **Reads the PDF** using the `scan_pdf_document` MCP tool, which parses the PDF's structure tree, metadata dictionary, content streams, and form definitions.

2. **Runs all applicable rules from the three layers.** The order matters:
   - PDFQ rules run first (pipeline quality - is this a scanned image PDF? Is it encrypted in a way that blocks AT?)
   - PDFUA rules run next (structural conformance - tags, metadata, navigation, forms, fonts)
   - PDFBP rules run last (best practices beyond the standard)

3. **Assigns confidence levels.** PDF/UA conformance checking is more nuanced than Office checking because some rules (e.g., reading order correctness) require human judgment.

4. **Returns findings with PDF object identifiers.** Here is a real example:

```text
PDFUA.TAGS.004 [Error] - High Confidence
Figure without alt text
Location: Page 4, Figure object #142
Remediation: Open in Adobe Acrobat Pro -> Tools -> Accessibility -> Reading Order ->
click the figure -> add alternative text in the Alt Text field. In the source (Word/InDesign),
add alt text before PDF export to avoid needing to retrofit.
```

5. **Delivers the score, grade, rule violation list, and next steps.**

## Understanding Your Results

### Score Interpretation

| Score | Grade | What it means |
|-------|-------|---------------|
| 90-100 | A | Excellent - near PDF/UA conformance |
| 75-89 | B | Good - minor gaps, addressable with Acrobat Pro |
| 50-74 | C | Needs work - multiple structural barriers |
| 25-49 | D | Poor - significant AT barriers, remediation required |
| 0-24 | F | Failing - untagged or scanned-image PDF, essentially inaccessible |

### The Verdict on Scanned PDFs

PDFQ.SCAN.001 triggers when a PDF consists primarily of scanned images with no selectable text. This is the worst possible accessibility outcome for a PDF - a screen reader cannot read a scanned image. The only remediation is OCR (Optical Character Recognition) to convert the scanned pages to selectable text, followed by a full tagging pass. The agent will flag this immediately if detected and recommend stopping the audit until remediation is complete.

### What to Fix First

1. **PDFQ.SCAN.001** (Scanned image PDF) - If this fires, nothing else matters until OCR is complete.
2. **PDFQ.ENC.001** (Encryption blocking AT) - If the PDF's security settings block screen readers, fix the permissions before proceeding.
3. **PDFUA.TAGS.001** (Missing tagged structure) - An untagged PDF is not navigable. All content must be tagged.
4. **PDFUA.META.001/002** (Missing title and language) - Both are required for PDF/UA conformance and are trivially fixed.
5. **PDFUA.FORM.001** (Unlabeled form fields) - If the PDF is a form, every field must have an accessible name.

### PDF Remediation Reality

PDF remediation is more involved than Office document remediation because PDFs are a presentation format, not an authoring format. The best practice is to fix accessibility issues in the source document (Word, InDesign, PowerPoint) and re-export. Retrofitting a complex PDF in Acrobat Pro is time-consuming and error-prone. Use pdf-accessibility to identify issues; use the source document agents to fix them at the root.

## Connections

| Connect to | When |
|------------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | For batch PDF audits, cross-document pattern analysis, and VPAT generation |
| [pdf-scan-config](pdf-scan-config.md) | To configure rule layers - e.g., run PDFUA only (skip PDFBP best practices) for a procurement baseline |
| [word-accessibility](word-accessibility.md) | When the PDF was generated from Word - fix issues at the source before re-exporting |
| [powerpoint-accessibility](powerpoint-accessibility.md) | When the PDF was generated from PowerPoint - same source-first remediation approach |
