# Example Documents for Testing the Document Accessibility Wizard

This folder contains guidance and sample document descriptions for testing the **document-accessibility-wizard** agent. Since binary document files (.docx, .xlsx, .pptx, .pdf) cannot be meaningfully stored as code, this guide describes how to create test documents with intentional accessibility issues.

## Quick Start

1. Create a folder called `test-docs/` in your project
2. Create the test documents described below
3. Run the document accessibility wizard: `@document-accessibility-wizard` in Copilot Chat
4. Or use the prompt: **Audit Document Folder** and point it at `test-docs/`

## Test Document Set

Create these documents with the **intentional issues** listed. The wizard should catch every one of them.

---

### 1. `bad-report.docx` (Word document with 7+ issues)

Create a Word document with these problems:

| Issue | How to Create It | Expected Rule |
|-------|-----------------|---------------|
| Missing alt text | Insert an image, leave alt text blank | DOCX-E001 |
| Heading skip | Use Heading 1, then jump to Heading 3 (skip H2) | DOCX-E003 |
| No document title | Leave File > Properties > Title empty | DOCX-E005 |
| No language set | Clear the document language in File > Options | DOCX-E007 |
| Manual numbered list | Type "1. First 2. Second" as plain text instead of using list styles | DOCX-W003 |
| Ambiguous link text | Add a hyperlink with text "click here" | DOCX-W004 |
| No table headers | Insert a table without marking the header row | DOCX-E004 |

**Expected score:** D or F (25-49 or below)

---

### 2. `bad-data.xlsx` (Excel workbook with 5+ issues)

Create an Excel workbook with these problems:

| Issue | How to Create It | Expected Rule |
|-------|-----------------|---------------|
| Generic sheet name | Leave the default "Sheet1" tab name | XLSX-E001 |
| No table headers | Enter data without using Insert > Table | XLSX-E002 |
| Merged cells | Merge cells A1:C1 for a "title" | XLSX-E003 |
| Chart without alt text | Insert a chart, leave alt text blank | XLSX-E005 |
| Color-only data | Use red/green cell colors to indicate pass/fail with no text labels | XLSX-E006 |

**Expected score:** D (25-49)

---

### 3. `bad-presentation.pptx` (PowerPoint with 6+ issues)

Create a PowerPoint with these problems:

| Issue | How to Create It | Expected Rule |
|-------|-----------------|---------------|
| Missing slide title | Delete the title placeholder from a slide | PPTX-E001 |
| Wrong reading order | Rearrange objects in the selection pane so text reads out of order | PPTX-E002 |
| Image without alt text | Insert an image, leave alt text blank | PPTX-E003 |
| Auto-advancing slides | Set slides to auto-advance every 5 seconds | PPTX-E005 |
| No slide numbers | Disable slide numbers | PPTX-W002 |
| Low contrast text | Use light gray text on a white background | PPTX-W004 |

**Expected score:** D (25-49)

---

### 4. `bad-policy.pdf` (PDF with 5+ issues)

Create a PDF with these problems (export from Word without accessibility settings, or use a scanner):

| Issue | How to Create It | Expected Rule |
|-------|-----------------|---------------|
| Untagged PDF | Save/export without "Tagged PDF" option | PDFUA.01.001-004 |
| No document title | Leave the PDF title metadata empty | PDFBP.META.TITLE |
| No language set | Don't set the document language property | PDFBP.META.LANG |
| Scanned image PDF | Scan a page and save as PDF (no OCR) | PDFUA.01.003 |
| No bookmarks | Export a long document without bookmarks | PDFBP.NAV.BOOKMARKS |

**Expected score:** F (0-24)

---

### 5. `good-report.docx` (Clean Word document)

Create a properly accessible Word document:

- Document title set in File > Properties
- Language set to en-US
- Heading 1 > Heading 2 > Heading 3 hierarchy
- All images have descriptive alt text
- Tables have header rows marked
- Links use descriptive text
- Lists use built-in list styles

**Expected score:** A (90-100)

---

## Testing Scenarios

### Scenario 1: Single File Quick Check
```
Use prompt: Quick Document Check
Path: test-docs/bad-report.docx
Expected: FAIL with 7 errors
```

### Scenario 2: Full Folder Audit
```
Use prompt: Audit Document Folder
Path: test-docs/
Expected: 5 files found, 23+ total issues, cross-document patterns detected
```

### Scenario 3: Delta Scan
```
1. Run full audit first
2. Fix one issue in bad-report.docx (add alt text to the image)
3. Commit and run: Audit Changed Documents
Expected: 1 fixed issue, score improvement shown
```

### Scenario 4: Template Detection
```
1. Create bad-report.docx and bad-report-2.docx from the same Word template
2. Both should have the same template-inherited issues
3. Run folder audit
Expected: Template analysis section groups the 2 files and identifies template-level issues
```

### Scenario 5: Mixed Types
```
Use prompt: Audit Document Folder
Path: test-docs/ (contains .docx, .xlsx, .pptx, .pdf)
Expected: All 4 sub-agents invoked, cross-document patterns span types (e.g., "missing alt text in Word, Excel, and PowerPoint")
```

### Scenario 6: VPAT Generation
```
1. Run full folder audit first
2. Use prompt: Generate VPAT
3. Path: DOCUMENT-ACCESSIBILITY-AUDIT.md
Expected: VPAT 2.5 with criteria mapped, conformance levels set
```

## Expected Cross-Document Patterns

When scanning all 5 test documents, the wizard should detect:

1. **Missing alt text** in 3/5 documents (Word, Excel, PowerPoint)
2. **Missing document title** in 3/5 documents (Word, PDF, and possibly Excel)
3. **No language set** in 2/5 documents (Word, PDF)
4. **Structural issues** in 4/5 documents (headings, tables, reading order, tags)

## Validation

After running the wizard, verify:

- [ ] All listed issues were caught
- [ ] Severity scores match expected ranges
- [ ] Confidence levels are assigned (high for structural, medium for quality)
- [ ] The clean document (good-report.docx) scores A
- [ ] Cross-document patterns are detected and grouped
- [ ] The report is well-formatted markdown
- [ ] Follow-up options are offered
