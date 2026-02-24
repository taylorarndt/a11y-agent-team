---
name: accessibility-rules
description: Cross-format document accessibility rule reference with WCAG 2.2 mapping. Use when looking up accessibility rules for Word (DOCX-*), Excel (XLSX-*), PowerPoint (PPTX-*), or PDF (PDFUA.*, PDFBP.*, PDFQ.*) documents, or when mapping findings to WCAG success criteria for compliance reporting.
---

# Document Accessibility Rules Reference

## Rule ID Prefixes

| Prefix | Format | Sub-Agent | Count |
|--------|--------|-----------|-------|
| DOCX-E* | Word errors | word-accessibility | 9 rules |
| DOCX-W* | Word warnings | word-accessibility | 6 rules |
| DOCX-T* | Word tips | word-accessibility | 3 rules |
| XLSX-E* | Excel errors | excel-accessibility | 8 rules |
| XLSX-W* | Excel warnings | excel-accessibility | 5 rules |
| XLSX-T* | Excel tips | excel-accessibility | 3 rules |
| PPTX-E* | PowerPoint errors | powerpoint-accessibility | 7 rules |
| PPTX-W* | PowerPoint warnings | powerpoint-accessibility | 6 rules |
| PPTX-T* | PowerPoint tips | powerpoint-accessibility | 4 rules |
| PDFUA.* | PDF/UA conformance | pdf-accessibility | 30 rules |
| PDFBP.* | PDF best practices | pdf-accessibility | 22 rules |
| PDFQ.* | PDF quality/pipeline | pdf-accessibility | 4 rules |
| EPUB-E* | ePub errors | epub-accessibility | 7 rules |
| EPUB-W* | ePub warnings | epub-accessibility | 6 rules |
| EPUB-T* | ePub tips | epub-accessibility | 3 rules |

## WCAG 2.2 Criterion Mapping

Complete tracking of all WCAG 2.2 Level A and AA success criteria. Criteria with document-specific rules list the rule IDs. Criteria requiring human judgment show "Manual review". Criteria that apply only to web/app contexts show a dash. See the **wcag-guide** agent for full explanations of each criterion.

> **Note:** WCAG 2.2 removed 4.1.1 Parsing (it is "always satisfied" in modern user agents and no longer tested).

### Level A (Must Fix)

| WCAG | Criterion | Related Rules |
|------|-----------|---------------|
| 1.1.1 | Non-text Content | DOCX-E001, XLSX-E001, PPTX-E001, PDFUA.IMG.ALT, EPUB-E005 |
| 1.2.1 | Audio-only and Video-only (Prerecorded) | Manual review (embedded media) |
| 1.2.2 | Captions (Prerecorded) | Manual review (embedded video) |
| 1.2.3 | Audio Description or Media Alternative (Prerecorded) | Manual review (embedded video) |
| 1.3.1 | Info and Relationships | DOCX-E002, DOCX-E003, DOCX-E005, XLSX-E002, XLSX-E004, PPTX-E004, PDFUA.TAGGED, PDFUA.HEADINGS |
| 1.3.2 | Meaningful Sequence | PPTX-E006, PDFUA.READING_ORDER, EPUB-E006 |
| 1.3.3 | Sensory Characteristics | Manual review (all formats) |
| 1.4.1 | Use of Color | XLSX-E007, Manual review (other formats) |
| 1.4.2 | Audio Control | Manual review (embedded audio) |
| 2.1.1 | Keyboard | PDFUA.FORMS (interactive PDFs) |
| 2.1.2 | No Keyboard Trap | PDFUA.FORMS (interactive PDFs) |
| 2.1.4 | Character Key Shortcuts | --- (web/app-specific) |
| 2.2.1 | Timing Adjustable | --- (web/app-specific) |
| 2.2.2 | Pause, Stop, Hide | Manual review (animated content in documents) |
| 2.3.1 | Three Flashes or Below Threshold | Manual review (animated content) |
| 2.4.1 | Bypass Blocks | PDFUA.BOOKMARKS, PDFBP.NAV, EPUB-E004 |
| 2.4.2 | Page Titled | DOCX-E004, XLSX-E006, PPTX-E002, PDFUA.TITLE, EPUB-E001 |
| 2.4.3 | Focus Order | PDFUA.FORMS (interactive PDFs) |
| 2.4.4 | Link Purpose (In Context) | DOCX-E006, XLSX-E005, PPTX-E005 |
| 2.5.1 | Pointer Gestures | --- (web/app-specific) |
| 2.5.2 | Pointer Cancellation | --- (web/app-specific) |
| 2.5.3 | Label in Name | PDFUA.FORMS (interactive PDFs) |
| 2.5.4 | Motion Actuation | --- (web/app-specific) |
| 3.1.1 | Language of Page | DOCX-T001, XLSX-T003, PPTX-T004, PDFUA.LANG, EPUB-E003 |
| 3.2.1 | On Focus | --- (web/app-specific) |
| 3.2.2 | On Input | --- (web/app-specific) |
| 3.2.6 | Consistent Help | --- (web/app-specific) |
| 3.3.1 | Error Identification | PDFUA.FORMS (interactive PDFs) |
| 3.3.2 | Labels or Instructions | PDFUA.FORMS (interactive PDFs) |
| 3.3.7 | Redundant Entry | --- (web/app-specific) |
| 4.1.2 | Name, Role, Value | DOCX-E009, PDFUA.FORMS, PDFUA.TAGS |

### Level AA (Should Fix)

| WCAG | Criterion | Related Rules |
|------|-----------|---------------|
| 1.2.4 | Captions (Live) | --- (web/app-specific) |
| 1.2.5 | Audio Description (Prerecorded) | Manual review (embedded video) |
| 1.3.4 | Orientation | --- (web/mobile-specific) |
| 1.3.5 | Identify Input Purpose | PDFUA.FORMS (interactive PDFs) |
| 1.4.3 | Contrast (Minimum) | Manual review (Office formats), PDFBP.Contrast |
| 1.4.4 | Resize Text | Manual review (PDF reflow) |
| 1.4.5 | Images of Text | PDFBP.IMG_TEXT |
| 1.4.10 | Reflow | Manual review (PDF reflow) |
| 1.4.11 | Non-text Contrast | Manual review (all formats) |
| 1.4.12 | Text Spacing | Manual review (PDF text spacing) |
| 1.4.13 | Content on Hover or Focus | --- (web/app-specific) |
| 2.4.5 | Multiple Ways | Manual review (multi-page documents) |
| 2.4.6 | Headings and Labels | DOCX-E003, DOCX-E007, PDFUA.HEADINGS |
| 2.4.7 | Focus Visible | PDFUA.FORMS (interactive PDFs) |
| 2.4.11 | Focus Not Obscured (Minimum) | --- (web/app-specific) |
| 2.5.7 | Dragging Movements | --- (web/app-specific) |
| 2.5.8 | Target Size (Minimum) | Manual review (interactive PDFs) |
| 3.1.2 | Language of Parts | Manual review (Office formats), PDFUA.LANG_PARTS |
| 3.2.3 | Consistent Navigation | --- (web/app-specific) |
| 3.2.4 | Consistent Identification | --- (web/app-specific) |
| 3.3.3 | Error Suggestion | PDFUA.FORMS (interactive PDFs) |
| 3.3.4 | Error Prevention (Legal, Financial, Data) | PDFUA.FORMS (interactive PDFs) |
| 3.3.8 | Accessible Authentication (Minimum) | --- (web/app-specific) |
| 4.1.3 | Status Messages | --- (web/app-specific) |

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
