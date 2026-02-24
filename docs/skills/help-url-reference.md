# help-url-reference Skill

> Centralized mapping of accessibility rule IDs to their official help documentation URLs. Covers Deque University (axe-core web rules), Microsoft Office support (Word, Excel, PowerPoint accessibility), Adobe PDF accessibility, and WCAG 2.2 Understanding documents. Used by CSV reporter agents to generate actionable links alongside findings.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [web-csv-reporter](../agents/web-csv-reporter.md) | Maps axe-core rule IDs to Deque University help URLs in CSV exports |
| [document-csv-reporter](../agents/document-csv-reporter.md) | Maps Office/PDF rule IDs to Microsoft and Adobe help URLs in CSV exports |

## Coverage

### Deque University (Web)

Maps axe-core rule IDs to `https://dequeuniversity.com/rules/axe/4.10/{rule-id}` URLs. Covers 20+ common rules including `color-contrast`, `image-alt`, `label`, `button-name`, `link-name`, `html-has-lang`, `document-title`, `heading-order`, and more.

Also includes Deque topic page URLs for agent-detected issues without axe-core rule IDs:
- Focus management: `https://dequeuniversity.com/class/focus-management2/focus/overview`
- Live regions: `https://dequeuniversity.com/library/aria/liveregion-playground`
- Modal dialogs: `https://dequeuniversity.com/library/aria/modal-dialog/sf-modal-dialog`
- Data tables: `https://dequeuniversity.com/class/tables2/simple/overview`

### Microsoft Office (Documents)

Maps rule IDs to Microsoft support article URLs:

| Format | Rules Covered | Example URL Pattern |
|--------|--------------|-------------------|
| Word (DOCX-*) | 13 rules | `https://support.microsoft.com/en-us/office/...` |
| Excel (XLSX-*) | 11 rules | `https://support.microsoft.com/en-us/office/...` |
| PowerPoint (PPTX-*) | 12 rules | `https://support.microsoft.com/en-us/office/...` |

### Adobe PDF

Maps PDF rule IDs (PDFUA.*, PDFBP.*, PDFQ.*) to Adobe Acrobat help URLs. Covers 12 categories including tagged PDF, reading order, document title, alt text, form fields, bookmarks, document language, color contrast, logical structure, links, tables, and metadata.

### WCAG 2.2 Understanding Documents

Maps WCAG success criteria (e.g., `1.1.1`, `1.4.3`, `2.1.1`) to their W3C Understanding document URLs following the pattern `https://www.w3.org/WAI/WCAG22/Understanding/{slug}`. Covers 25 commonly cited success criteria.

## Application-Specific Fix Steps

The skill also provides templated fix step text for each application:

- **Word:** Step-by-step instructions referencing Word UI (e.g., "Right-click image, select Edit Alt Text")
- **Excel:** Instructions referencing Excel UI (e.g., "Right-click sheet tab, select Rename")
- **PowerPoint:** Instructions referencing PowerPoint UI (e.g., "Select slide, Arrange, Reading Order pane")
- **PDF (Acrobat Pro):** Instructions referencing Acrobat Pro UI (e.g., "Accessibility panel, Autotag Document")

## Skill Location

The full skill file with all URL mappings and fix step templates is at:

```
.github/skills/help-url-reference/SKILL.md
```
