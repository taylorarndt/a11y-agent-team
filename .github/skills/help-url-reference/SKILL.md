---
name: help-url-reference
description: Centralized help URL reference for accessibility remediation. Maps axe-core rule IDs to Deque University topics, document rule IDs to Microsoft Office and Adobe PDF help pages, and WCAG criteria to W3C Understanding documents. Use when generating CSV exports, markdown reports, or any output that links findings to external remediation documentation.
---

# Help URL Reference

Centralized mapping of accessibility rule IDs and WCAG criteria to external help documentation. Used by CSV reporters, audit report generators, and any agent that links findings to remediation guidance.

## Deque University (Web Accessibility)

### axe-core Rule URL Pattern

```text
Base URL: https://dequeuniversity.com/rules/axe/4.10/
Pattern:  {base_url}{rule-id}
Example:  https://dequeuniversity.com/rules/axe/4.10/image-alt
```

For any axe-core rule, construct the URL by appending the rule ID to the base URL. This pattern covers all axe-core rules.

### Common axe-core Rules

| Rule ID | Issue | WCAG | Deque Help URL |
|---------|-------|------|---------------|
| `image-alt` | Image missing alternative text | 1.1.1 | `https://dequeuniversity.com/rules/axe/4.10/image-alt` |
| `button-name` | Button has no accessible name | 4.1.2 | `https://dequeuniversity.com/rules/axe/4.10/button-name` |
| `color-contrast` | Text has insufficient contrast | 1.4.3 | `https://dequeuniversity.com/rules/axe/4.10/color-contrast` |
| `label` | Form element has no label | 1.3.1 | `https://dequeuniversity.com/rules/axe/4.10/label` |
| `link-name` | Link has no discernible text | 4.1.2 | `https://dequeuniversity.com/rules/axe/4.10/link-name` |
| `html-has-lang` | Page missing lang attribute | 3.1.1 | `https://dequeuniversity.com/rules/axe/4.10/html-has-lang` |
| `document-title` | Page missing title | 2.4.2 | `https://dequeuniversity.com/rules/axe/4.10/document-title` |
| `heading-order` | Heading levels skipped | 1.3.1 | `https://dequeuniversity.com/rules/axe/4.10/heading-order` |
| `aria-roles` | Invalid ARIA role | 4.1.2 | `https://dequeuniversity.com/rules/axe/4.10/aria-roles` |
| `aria-required-attr` | Missing required ARIA attribute | 4.1.2 | `https://dequeuniversity.com/rules/axe/4.10/aria-required-attr` |
| `aria-valid-attr` | Invalid ARIA attribute | 4.1.2 | `https://dequeuniversity.com/rules/axe/4.10/aria-valid-attr` |
| `bypass` | No skip navigation link | 2.4.1 | `https://dequeuniversity.com/rules/axe/4.10/bypass` |
| `region` | Content not in landmark | 1.3.1 | `https://dequeuniversity.com/rules/axe/4.10/region` |
| `tabindex` | Positive tabindex used | 2.4.3 | `https://dequeuniversity.com/rules/axe/4.10/tabindex` |
| `duplicate-id` | Duplicate element ID | 4.1.1 | `https://dequeuniversity.com/rules/axe/4.10/duplicate-id` |
| `focus-order-semantics` | Focus order issue | 2.4.3 | `https://dequeuniversity.com/rules/axe/4.10/focus-order-semantics` |
| `input-image-alt` | Input image missing alt | 1.1.1 | `https://dequeuniversity.com/rules/axe/4.10/input-image-alt` |
| `meta-viewport` | Viewport disables zoom | 1.4.4 | `https://dequeuniversity.com/rules/axe/4.10/meta-viewport` |
| `select-name` | Select element has no label | 4.1.2 | `https://dequeuniversity.com/rules/axe/4.10/select-name` |
| `autocomplete-valid` | Invalid autocomplete value | 1.3.5 | `https://dequeuniversity.com/rules/axe/4.10/autocomplete-valid` |

### Deque University Topic Pages (Non-axe Issues)

For agent-detected issues without axe-core rule IDs, use these topic pages:

| Topic | URL |
|-------|-----|
| Focus management | `https://dequeuniversity.com/class/focus-management2/focus/overview` |
| Live regions | `https://dequeuniversity.com/library/aria/liveregion-playground` |
| Modal dialogs | `https://dequeuniversity.com/library/aria/modal-dialog/sf-modal-dialog` |
| Data tables | `https://dequeuniversity.com/class/tables2/simple/overview` |

## Microsoft Office (Document Accessibility)

### Word (DOCX) Rules

| Rule ID | Issue | Help URL |
|---------|-------|----------|
| `DOCX-E001` | Missing document title | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_doctitle` |
| `DOCX-E002` | Missing alt text on images | `https://support.microsoft.com/en-us/office/add-alternative-text-to-a-shape-picture-chart-smartart-graphic-or-other-object-44989b2a-903c-4d9a-b742-6a75b451c669` |
| `DOCX-E003` | Missing table headers | `https://support.microsoft.com/en-us/office/create-accessible-tables-in-word-cb464015-59dc-46a0-ac01-6217c62210e5` |
| `DOCX-E004` | Empty heading tags | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_headings` |
| `DOCX-E005` | Skipped heading levels | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_headings` |
| `DOCX-W001` | Low contrast text | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_contrast` |
| `DOCX-W002` | Missing document language | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_language` |
| `DOCX-W003` | Ambiguous link text | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_links` |
| `DOCX-W004` | Color-only formatting | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_color` |
| `DOCX-W005` | Floating objects | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_layout` |
| `DOCX-T001` | Missing table of contents | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_toc` |
| `DOCX-T002` | Using spaces for formatting | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_whitespace` |
| `DOCX-T003` | Watermarks present | `https://support.microsoft.com/en-us/office/create-accessible-word-documents-d9bf3683-87ac-47ea-b91a-78dcacb3c66d#bkmk_watermarks` |

### Excel (XLSX) Rules

| Rule ID | Issue | Help URL |
|---------|-------|----------|
| `XLSX-E001` | Missing sheet names | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593#bkmk_sheettabs` |
| `XLSX-E002` | Missing alt text on charts | `https://support.microsoft.com/en-us/office/add-alternative-text-to-a-shape-picture-chart-smartart-graphic-or-other-object-44989b2a-903c-4d9a-b742-6a75b451c669` |
| `XLSX-E003` | Missing table headers | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593#bkmk_tableheaders` |
| `XLSX-E004` | Merged cells in data tables | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593#bkmk_mergedcells` |
| `XLSX-E005` | Empty worksheet | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593` |
| `XLSX-W001` | Default sheet names | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593#bkmk_sheettabs` |
| `XLSX-W002` | Missing document title | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593#bkmk_doctitle` |
| `XLSX-W003` | Color-only data differentiation | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593#bkmk_color` |
| `XLSX-W004` | Missing cell input messages | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593#bkmk_validation` |
| `XLSX-T001` | Complex formulas without docs | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593` |
| `XLSX-T002` | Hidden rows or columns | `https://support.microsoft.com/en-us/office/create-accessible-excel-workbooks-6cc05fc5-1314-48b5-8eb3-683e49b3e593` |

### PowerPoint (PPTX) Rules

| Rule ID | Issue | Help URL |
|---------|-------|----------|
| `PPTX-E001` | Missing slide titles | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_slidetitles` |
| `PPTX-E002` | Missing alt text on images | `https://support.microsoft.com/en-us/office/add-alternative-text-to-a-shape-picture-chart-smartart-graphic-or-other-object-44989b2a-903c-4d9a-b742-6a75b451c669` |
| `PPTX-E003` | Incorrect reading order | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_readingorder` |
| `PPTX-E004` | Missing table headers | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_tableheaders` |
| `PPTX-E005` | Duplicate slide titles | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_slidetitles` |
| `PPTX-W001` | Low contrast text | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_contrast` |
| `PPTX-W002` | Missing document language | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25` |
| `PPTX-W003` | Ambiguous link text | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_links` |
| `PPTX-W004` | Audio/video without captions | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_captions` |
| `PPTX-W005` | Color-only formatting | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_color` |
| `PPTX-T001` | Complex animations | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_animations` |
| `PPTX-T002` | Automatic slide transitions | `https://support.microsoft.com/en-us/office/create-accessible-powerpoint-presentations-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25#bkmk_transitions` |

## Adobe PDF

| Rule ID | Issue | Help URL |
|---------|-------|----------|
| `PDFUA.TaggedPDF` | Document not tagged | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#tag_pdf` |
| `PDFUA.Title` | Missing document title | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#add_title` |
| `PDFUA.Language` | Missing document language | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#set_language` |
| `PDFUA.BookmarksPresent` | Missing bookmarks | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#bookmarks` |
| `PDFUA.AltText` | Missing alt text | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#alt_text` |
| `PDFUA.TableHeaders` | Missing table headers | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#tables` |
| `PDFUA.ReadingOrder` | Incorrect reading order | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#reading_order` |
| `PDFUA.Headings` | Heading structure issues | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#headings` |
| `PDFUA.ListTags` | Missing list tags | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#lists` |
| `PDFBP.Contrast` | Low contrast text | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#contrast` |
| `PDFBP.Scanned` | Scanned (image-only) PDF | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#scanned` |
| `PDFQ.Searchable` | Text not searchable | `https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html#ocr` |

## WCAG 2.2 Understanding Documents

### URL Pattern

```text
Base: https://www.w3.org/WAI/WCAG22/Understanding/
Pattern: {base}{slug}
```

### Criterion-to-Slug Mapping

| WCAG | Criterion Name | Slug |
|------|---------------|------|
| 1.1.1 | Non-text Content | `non-text-content` |
| 1.3.1 | Info and Relationships | `info-and-relationships` |
| 1.3.2 | Meaningful Sequence | `meaningful-sequence` |
| 1.3.5 | Identify Input Purpose | `identify-input-purpose` |
| 1.4.1 | Use of Color | `use-of-color` |
| 1.4.3 | Contrast (Minimum) | `contrast-minimum` |
| 1.4.4 | Resize Text | `resize-text` |
| 1.4.5 | Images of Text | `images-of-text` |
| 1.4.11 | Non-text Contrast | `non-text-contrast` |
| 2.1.1 | Keyboard | `keyboard` |
| 2.1.2 | No Keyboard Trap | `no-keyboard-trap` |
| 2.4.1 | Bypass Blocks | `bypass-blocks` |
| 2.4.2 | Page Titled | `page-titled` |
| 2.4.3 | Focus Order | `focus-order` |
| 2.4.6 | Headings and Labels | `headings-and-labels` |
| 2.4.7 | Focus Visible | `focus-visible` |
| 2.4.11 | Focus Not Obscured (Minimum) | `focus-not-obscured-minimum` |
| 2.5.8 | Target Size (Minimum) | `target-size-minimum` |
| 3.1.1 | Language of Page | `language-of-page` |
| 3.1.2 | Language of Parts | `language-of-parts` |
| 3.3.1 | Error Identification | `error-identification` |
| 3.3.2 | Labels or Instructions | `labels-or-instructions` |
| 3.3.7 | Redundant Entry | `redundant-entry` |
| 3.3.8 | Accessible Authentication (Minimum) | `accessible-authentication-minimum` |
| 4.1.2 | Name, Role, Value | `name-role-value` |

## Application-Specific Fix Steps Templates

### Word

| Rule | Fix Steps |
|------|-----------|
| `DOCX-E001` | File, Info, Properties, Title field |
| `DOCX-E002` | Right-click image, Edit Alt Text, enter description |
| `DOCX-E003` | Table Design tab, check Header Row checkbox |
| `DOCX-E004` | Click heading, type content or delete empty paragraph |
| `DOCX-E005` | Apply correct heading style (Home tab, Styles group) |

### Excel

| Rule | Fix Steps |
|------|-----------|
| `XLSX-E001` | Right-click sheet tab, Rename, enter descriptive name |
| `XLSX-E002` | Right-click chart, Edit Alt Text, enter description |
| `XLSX-E003` | Home, Format as Table (ensure header row option checked) |
| `XLSX-E004` | Unmerge cells, restructure data layout |

### PowerPoint

| Rule | Fix Steps |
|------|-----------|
| `PPTX-E001` | Home, Layout, choose layout with title placeholder |
| `PPTX-E002` | Right-click image, Edit Alt Text, enter description |
| `PPTX-E003` | Home, Arrange, Selection Pane, reorder items bottom-to-top |
| `PPTX-E004` | Select table, Table Design, check Header Row |

### PDF (Acrobat Pro)

| Rule | Fix Steps |
|------|-----------|
| `PDFUA.TaggedPDF` | Accessibility, Add Tags to Document |
| `PDFUA.Title` | File, Properties, Description tab, Title field |
| `PDFUA.Language` | File, Properties, Advanced tab, Language dropdown |
| `PDFUA.ReadingOrder` | Tools, Accessibility, Reading Order tool |
