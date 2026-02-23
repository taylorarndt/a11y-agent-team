---
description: Create accessible document templates (.docx, .xlsx, .pptx) with proper heading structure, alt text placeholders, language settings, and metadata. Prevents accessibility issues at the source.
mode: agent
tools:
  - askQuestions
---

# Create Accessible Document Template

Generate guidance for creating an accessible document template that prevents common accessibility issues from the start.

## Instructions

Use the **document-accessibility-wizard** agent to:

1. Ask which document type to create a template for:
   - Word document (.docx)
   - Excel workbook (.xlsx)
   - PowerPoint presentation (.pptx)
   - All three
2. Ask about the document's purpose:
   - Corporate report
   - Meeting minutes
   - Policy document
   - Training materials
   - Data dashboard
   - Marketing presentation
   - Custom (describe)
3. For each template type, provide step-by-step creation instructions covering:

### Word Template Checklist
- Document title set in File > Properties
- Language set (File > Options > Language)
- Built-in heading styles (Heading 1, 2, 3) used - never manual formatting
- Table of Contents generated from headings
- Alt text placeholder text on all image placeholders ("REPLACE: Describe this image")
- Table header rows marked (Table Design > Header Row checked)
- Links use descriptive text (never raw URLs)
- Color contrast verified for any colored text
- No content that relies on color alone

### Excel Template Checklist
- Descriptive sheet tab names (never "Sheet1")
- Data formatted as Tables (Insert > Table) with headers
- No merged cells in data regions
- Chart titles and alt text on all charts
- Cell comments use accessible formatting
- Frozen panes for large data sets
- No blank rows/columns breaking data regions

### PowerPoint Template Checklist
- Every slide layout has a title placeholder
- Reading order set correctly on all slide masters
- Alt text on all image placeholders in masters
- Slide numbers enabled
- High-contrast color palette in the theme
- No auto-advancing slides or animations without user control
- Notes pane includes content descriptions

4. Offer to generate a starter config file that enforces these standards:
   - `.a11y-office-config.json` with strict profile
