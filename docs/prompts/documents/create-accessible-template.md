# create-accessible-template

Get step-by-step guidance for creating an accessible Word, Excel, or PowerPoint template from scratch. Prevents the most common accessibility issues at the source — before any documents are created from the template.

## When to Use It

- You are creating a new document template for your organization
- You want to fix a template so every document created from it starts accessible
- You are training authors on accessibility best practices for their document type
- You want to establish accessible defaults that prevent common issues from recurring

## How to Launch It

**In GitHub Copilot Chat:**
```
/create-accessible-template
```

The agent guides you through selecting document type and purpose.

## What to Expect

### Step 1: Document Type

The agent asks which type of template:
- Word (.docx)
- Excel (.xlsx)
- PowerPoint (.pptx)
- All three

### Step 2: Document Purpose

The agent asks about the document's purpose to tailor the guidance:

- Corporate report / Policy document
- Meeting minutes
- Training materials / Procedures
- Data dashboard / Financial model
- Marketing presentation

### Step 3: Format-Specific Checklist

**Word template guidance:**

| Requirement | How to Set It |
|-------------|---------------|
| Document title | File → Properties → Summary → Title |
| Language | File → Options → Language → Set as default |
| Heading styles | Use built-in Heading 1/2/3 — never manual font size changes |
| Table header rows | Table Design → Check "Header Row" |
| Alt text placeholder | Image placeholders should say "REPLACE: Describe this image" |
| Link text | Never use raw URLs as link text |

**Excel template guidance:**

| Requirement | How to Set It |
|-------------|---------------|
| Descriptive sheet names | Right-click tab → Rename (never leave "Sheet1") |
| Table format | Insert → Table on all data regions |
| Chart alt text | Right-click chart → Edit Alt Text |
| No merged cells | Use cell alignment instead of merging in data regions |

**PowerPoint template guidance:**

| Requirement | How to Set It |
|-------------|---------------|
| Title placeholder on every layout | View → Slide Master → verify each layout has a title |
| Reading order | View → Slide Master → Tab through each element, set order in Selection Pane |
| Alt text on image masters | Right-click image placeholder → Edit Alt Text |
| High-contrast theme | Design → Colors → choose or customize for 4.5:1 ratio |

### Step 4: Config File Offer

The agent offers to generate a `.a11y-office-config.json` set to strict profile — so future scans of documents created from this template will enforce these standards automatically.

## Example Variations

```
/create-accessible-template
→ Type: Word
→ Purpose: Policy document — needs to be formal and must meet Section 508

/create-accessible-template
→ Type: PowerPoint
→ Purpose: Training materials

/create-accessible-template
→ Type: All three
→ Purpose: Corporate standard templates for all document types
```

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Provides the guidance and optional config generation |
| [word-accessibility](../../agents/word-accessibility.md) | Word-specific rule knowledge |
| [excel-accessibility](../../agents/excel-accessibility.md) | Excel-specific rule knowledge |
| [powerpoint-accessibility](../../agents/powerpoint-accessibility.md) | PowerPoint-specific rule knowledge |

## Related Prompts

- [audit-single-document](audit-single-document.md) — scan the template after creating it
- [office-scan-config](../../agents/office-scan-config.md) — configure what gets checked during scanning
