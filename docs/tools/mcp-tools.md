# MCP Tools Reference

The A11y Agent Team MCP server provides tools that agents use automatically. These same tools are available in Claude Desktop (via the .mcpb extension), GitHub Copilot (via `.vscode/mcp.json`), and any MCP-compatible client.

## Web Analysis Tools

### check_contrast

Calculate WCAG contrast ratios between two hex colors. Returns the ratio and pass/fail for normal text (4.5:1), large text (3:1), and UI components (3:1).

### get_accessibility_guidelines

Get detailed WCAG AA guidelines for a specific component type: modal, tabs, accordion, combobox, carousel, form, live-region, navigation, or general. Returns requirements, code examples, and common mistakes.

### check_heading_structure

Analyze HTML for heading hierarchy issues: skipped levels, multiple H1 tags, empty headings, and heading order problems. Returns WCAG criterion references (1.3.1, 2.4.6).

### check_link_text

Scan HTML for link accessibility issues. Detects 17 ambiguous text patterns ("click here", "read more", etc.), URLs used as link text, links opening in new tabs without warning, links to non-HTML resources without file type indication, and repeated identical text pointing to different destinations. WCAG references: 2.4.4, 2.4.9.

### check_form_labels

Validate form input accessibility. Checks every `<input>`, `<select>`, and `<textarea>` for proper labels (`<label for>`, `aria-label`, or `aria-labelledby`), autocomplete attributes on identity/payment fields, and fieldset/legend on radio/checkbox groups. WCAG references: 1.3.1, 1.3.5, 3.3.2, 4.1.2.

### run_axe_scan

Run axe-core against a live URL and return violations grouped by severity (Critical > Serious > Moderate > Minor). Includes affected HTML elements, WCAG criteria, and fix suggestions. Optionally writes a structured markdown report to a file path.

**Prerequisites:** `npm install -g @axe-core/cli`

See [axe-core Integration](axe-core-integration.md) for detailed usage.

## Document Scanning Tools

### scan_office_document

Scan a Microsoft Office document (DOCX, XLSX, PPTX) for accessibility issues. Parses the ZIP/XML structure and checks for alt text, headings, tables, language, reading order, and more. Returns findings as SARIF 2.1.0 or human-readable markdown.

### scan_pdf_document

Scan a PDF document for accessibility conformance against PDF/UA and the Matterhorn Protocol. Checks tagged structure, metadata, bookmarks, form fields, fonts, and encryption. Returns findings as SARIF or markdown.

### extract_document_metadata

Extract metadata from Office or PDF documents including title, author, language, page/slide/sheet count, and creation/modification dates.

### batch_scan_documents

Scan multiple documents in a single operation. Accepts a directory path and scans all supported files recursively, applying relevant config files.

## Compliance Tools

### generate_vpat

Generate a VPAT 2.5 / Accessibility Conformance Report (ACR) template pre-populated with all WCAG 2.2 Level A and AA criteria. Merge in findings from agent reviews to produce a publishable conformance document.

See [VPAT Generation](vpat-generation.md) for detailed usage.

## Using the Tools

The tools accept inputs as described in each tool's parameters. Agents call these automatically during reviews:

```
# Claude Code — agents use tools automatically
/accessibility-lead review index.html
# → The lead reads the file, passes HTML to check_heading_structure,
#   check_link_text, check_form_labels as needed

# Copilot — same behavior
@accessibility-wizard audit the signup page
```
