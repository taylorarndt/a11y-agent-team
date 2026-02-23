# word-accessibility — Microsoft Word (DOCX) Accessibility

> Scans Microsoft Word documents for accessibility issues. Uses the `scan_office_document` MCP tool to parse DOCX files (ZIP/XML structure) and check for tagged content, alt text on images, heading structure, table markup, reading order, language settings, and color-only formatting.

## When to Use It

- Reviewing Word documents before publishing or distributing
- Checking templates for accessibility compliance
- Auditing existing DOCX files as part of a document accessibility program
- Preparing documents for PDF conversion (accessibility issues carry over)

## What It Catches

<details>
<summary>Expand — 11 Word accessibility rules (DOCX-E001 – DOCX-W005)</summary>

| Rule | Severity | Description |
|------|----------|--------------|
| DOCX-E001 | Error | Images without alt text |
| DOCX-E002 | Error | Missing document title in properties |
| DOCX-E003 | Error | No headings used for document structure |
| DOCX-E004 | Error | Tables without header rows |
| DOCX-E005 | Error | Missing document language |
| DOCX-E006 | Error | Color-only formatting conveying meaning |
| DOCX-W001 | Warning | Very long alt text that needs summarization |
| DOCX-W002 | Warning | Skipped heading levels |
| DOCX-W003 | Warning | Merged cells in tables |
| DOCX-W004 | Warning | Small font sizes below 10pt |
| DOCX-W005 | Warning | Empty paragraphs used for spacing |

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

```
/word-accessibility scan report.docx for accessibility issues
@word-accessibility review the quarterly report template
@word-accessibility check all Word documents in the docs/ directory
```

</details>

## How to Launch It

**In Claude Code (terminal):**
```
/word-accessibility scan report.docx
/word-accessibility review the quarterly report template
/word-accessibility check all .docx files in /docs
```

**In GitHub Copilot Chat:**
```
@word-accessibility scan report.docx for accessibility issues
@word-accessibility check the employee handbook
```

**Via the prompt picker:** Select `audit-single-document` from the prompt picker and enter the `.docx` file path. This pre-configures the full strict scan profile and generates a `DOCUMENT-ACCESSIBILITY-AUDIT.md` report.

**Via document-accessibility-wizard:** For multi-document audits, the wizard orchestrates word-accessibility automatically — you do not invoke it directly.

## Step-by-Step: What a Scan Session Looks Like

Here is a complete scan from start to finish so you know exactly what to expect.

**You say:**
```
/word-accessibility scan quarterly-report.docx
```

**What the agent does:**

1. **Reads the DOCX file** using the `scan_office_document` MCP tool, which parses the ZIP/XML structure of the .docx format and extracts the document body, styles, properties, and relationships.

2. **Runs all 11 accessibility rules** against the XML. For each rule:
   - Checks the relevant XML elements (e.g., every `<a:blip>` for alt text, `<w:pStyle>` for heading styles, `<w:tr>` for table header rows)
   - Determines whether a violation exists
   - Assigns a confidence level: High (definitely a violation), Medium (likely), Low (possible)

3. **Computes the severity score** using the weighted formula: errors = −10 points each (high confidence), warnings = −3 points each (high confidence), floor at 0.

4. **Generates a structured report** with findings grouped by severity. Here is what a real finding looks like:

```
DOCX-E001 [Error] — High Confidence
Image without alt text
Location: Paragraph 14, inline image
Remediation: Right-click the image in Word → select "Edit Alt Text" → describe what
the image shows. If the image is purely decorative (borders, dividers, backgrounds),
check "Mark as decorative" to suppress screen reader announcement instead.
```

5. **Presents the score and grade**, then offers next steps: generate a full VPAT report, run a folder audit, or hand off to the document-accessibility-wizard for deeper analysis.

## Understanding Your Results

### Score Interpretation

| Score | Grade | What it means |
|-------|-------|---------------|
| 90–100 | A | Excellent — minor issues only, safe to distribute |
| 75–89 | B | Good — some warnings, fix before wide distribution |
| 50–74 | C | Needs work — multiple errors affecting AT users |
| 25–49 | D | Poor — significant barriers, remediate before sharing |
| 0–24 | F | Failing — likely unusable with screen readers |

### What to Fix First

Follow this order for maximum impact with minimum effort:

1. **DOCX-E003** (No headings) — Affects all navigation. Screen reader users rely on the heading hierarchy to jump through long documents. Without headings, they must read linearly.
2. **DOCX-E001** (Images without alt text) — Every image missing alt text is a content gap for blind users.
3. **DOCX-E002** (Missing document title) — The document title is announced when the file opens. Missing it is a confusing first experience.
4. **DOCX-E004/E005** (Tables without headers, missing language) — Affects table reading order and text-to-speech pronunciation.
5. **DOCX-W002** (Skipped heading levels) — H1 → H3 with no H2 confuses navigation; screen readers announce the level jump.

### Confidence Levels

Not every finding is equally certain from static XML analysis alone:
- **High confidence** — The issue is definitively present in the XML (e.g., an image element with no alt text attribute).
- **Medium confidence** — The issue is likely present but context matters (e.g., a very long alt text string that may need summarization).
- **Low confidence** — A pattern that *might* be a problem depending on intent (e.g., empty paragraphs may be intentional spacing or may indicate a structural issue).

Focus your manual review effort on medium and low confidence items. High confidence findings can be addressed mechanically.

## Connections

| Connect to | When |
|------------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | For full multi-document audits with cross-document scoring, VPAT generation, and CI/CD setup |
| [office-scan-config](office-scan-config.md) | To configure which rules run and suppress rules that do not apply to your document type |
| [excel-accessibility](excel-accessibility.md) | For spreadsheets embedded in Word documents or when auditing a mixed Office collection |
| [pdf-accessibility](pdf-accessibility.md) | Word documents are often exported to PDF — audit both if the PDF is distributed |
