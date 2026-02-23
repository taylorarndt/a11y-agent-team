---
name: accessibility-rules
description: Cross-format document accessibility rule reference with WCAG 2.2 mapping. Use when looking up accessibility rules for Word (DOCX-*), Excel (XLSX-*), PowerPoint (PPTX-*), or PDF (PDFUA.*, PDFBP.*, PDFQ.*) documents, or when mapping findings to WCAG success criteria for compliance reporting.
---

# Document Accessibility Rules Reference

## Rule ID Prefixes

| Prefix | Format | Sub-Agent | Count |
|--------|--------|-----------|-------|
| DOCX-E* | Word errors | word-accessibility | 7 rules |
| DOCX-W* | Word warnings | word-accessibility | 6 rules |
| DOCX-T* | Word tips | word-accessibility | 3 rules |
| XLSX-E* | Excel errors | excel-accessibility | 6 rules |
| XLSX-W* | Excel warnings | excel-accessibility | 5 rules |
| XLSX-T* | Excel tips | excel-accessibility | 3 rules |
| PPTX-E* | PowerPoint errors | powerpoint-accessibility | 6 rules |
| PPTX-W* | PowerPoint warnings | powerpoint-accessibility | 6 rules |
| PPTX-T* | PowerPoint tips | powerpoint-accessibility | 4 rules |
| PDFUA.* | PDF/UA conformance | pdf-accessibility | 30 rules |
| PDFBP.* | PDF best practices | pdf-accessibility | 22 rules |
| PDFQ.* | PDF quality/pipeline | pdf-accessibility | 4 rules |

## WCAG 2.2 Criterion Mapping

### Level A (Must Fix)

| WCAG | Criterion | Related Rules |
|------|-----------|---------------|
| 1.1.1 | Non-text Content | DOCX-E001, XLSX-E004, PPTX-E003, PDFUA.IMG.ALT |
| 1.3.1 | Info and Relationships | DOCX-E002, DOCX-E004, XLSX-E001, XLSX-E003, PPTX-E001, PDFUA.TAGGED, PDFUA.HEADINGS |
| 1.3.2 | Meaningful Sequence | PPTX-E004, PDFUA.READING_ORDER |
| 2.4.1 | Bypass Blocks | PDFUA.BOOKMARKS, PDFBP.NAV |
| 2.4.2 | Page Titled | DOCX-E005, PPTX-E001, PDFUA.TITLE |
| 2.4.6 | Headings and Labels | DOCX-E002, DOCX-E003, XLSX-E001, PDFUA.HEADINGS |
| 3.1.1 | Language of Page | DOCX-E006, PDFUA.LANG |
| 4.1.2 | Name, Role, Value | PDFUA.FORMS, PDFUA.TAGS |

### Level AA (Should Fix)

| WCAG | Criterion | Related Rules |
|------|-----------|---------------|
| 1.4.3 | Contrast (Minimum) | DOCX-W004, PPTX-W003 |
| 1.4.5 | Images of Text | PDFBP.IMG_TEXT |
| 2.4.7 | Focus Visible | PDFUA.FORMS |
| 3.1.2 | Language of Parts | DOCX-W005, PDFUA.LANG_PARTS |

## Severity Definitions

| Severity | Meaning | Impact on AT Users |
|----------|---------|-------------------|
| Error | Blocks access | Content is inaccessible or unusable with assistive technology |
| Warning | Degrades experience | Content is accessible but the experience is poor or confusing |
| Tip | Best practice | Content works but could be improved for better AT experience |

## Confidence Levels

| Level | Weight | Meaning |
|-------|--------|---------|
| High | 1.0 | Sub-agent is certain this is a real issue |
| Medium | 0.7 | Likely an issue but requires human judgment |
| Low | 0.3 | Possible issue - flagged for review |

## Compliance Standards

| Standard | Scope | Key Rules |
|----------|-------|-----------|
| WCAG 2.2 Level A | International | All error-level rules |
| WCAG 2.2 Level AA | International | All error + warning rules |
| Section 508 | US Federal | Mapped to WCAG 2.0 Level AA |
| EN 301 549 | European Union | Mapped to WCAG 2.1 Level AA |
| PDF/UA (ISO 14289) | PDF-specific | All PDFUA.* rules |
