# epub-accessibility - ePub Document Accessibility

> ePub accessibility specialist covering EPUB Accessibility 1.1 (WCAG 2.x), navigation documents (TOC/NCX/landmarks), accessibility metadata (schema.org), reading order, image alt text, table structure, and heading hierarchy. Supports EPUB 2 and EPUB 3.

## When to Use It

- Auditing ePub files before publishing or distributing
- Verifying EPUB Accessibility 1.1 / Section 508 conformance of digital books
- Checking educational ePubs or digital textbooks for AT compatibility
- Auditing navigation documents (TOC, page-list, landmarks)
- Reviewing accessibility metadata (`schema:accessibilityFeature`, `schema:accessibilitySummary`)

## Rule Layers

<details>
<summary>Expand - 3 rule categories (16 rules total)</summary>

| Category | Rules | Purpose |
|----------|-------|---------|
| **EPUB-E\*** | 7 rules | Errors - missing required elements that block AT access |
| **EPUB-W\*** | 6 rules | Warnings - present but degraded reading experience |
| **EPUB-T\*** | 3 rules | Tips - best practices for full conformance |

</details>

## Key Checks

<details>
<summary>Expand - all 16 EPUB rules</summary>

**Errors (EPUB-E\*)**

| Rule ID | Name | What it checks |
|---------|------|---------------|
| EPUB-E001 | missing-title | `dc:title` is present in OPF package metadata |
| EPUB-E002 | missing-unique-identifier | `dc:identifier` (ISBN / UUID) is declared |
| EPUB-E003 | missing-language | `dc:language` is set |
| EPUB-E004 | missing-nav-toc | EPUB 3 `nav` document has a `toc` landmark |
| EPUB-E005 | missing-alt-text | All `<img>` and SVG `<image>` elements have `alt` or `aria-label` |
| EPUB-E006 | unordered-spine | Spine items appear in logical reading order |
| EPUB-E007 | missing-a11y-metadata | `schema:accessibilityFeature` or `schema:accessMode` declared |

**Warnings (EPUB-W\*)**

| Rule ID | Name | What it checks |
|---------|------|---------------|
| EPUB-W001 | missing-page-list | A `page-list` nav element exists for paginated content |
| EPUB-W002 | missing-landmarks | `landmarks` nav element present with at least `toc` and `bodymatter` |
| EPUB-W003 | heading-hierarchy | No skipped heading levels (h1->h3 without h2) |
| EPUB-W004 | table-missing-headers | All `<table>` elements have `<th>` or `scope` attributes |
| EPUB-W005 | ambiguous-link-text | No links using "click here", "read more", or similar generic text |
| EPUB-W006 | color-only-info | Content does not convey meaning through color alone |

**Tips (EPUB-T\*)**

| Rule ID | Name | What it checks |
|---------|------|---------------|
| EPUB-T001 | incomplete-a11y-summary | `schema:accessibilitySummary` is present and informative |
| EPUB-T002 | missing-author | `dc:creator` is declared |
| EPUB-T003 | missing-description | `dc:description` provides a text summary of the publication |

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

```text
/epub-accessibility scan textbook.epub
@epub-accessibility check ebook.epub for EPUB Accessibility 1.1 conformance
@epub-accessibility audit the /publications folder (all .epub files)
@epub-accessibility does this epub have valid navigation and accessibility metadata?
```

</details>

## How to Launch It

**In Claude Code:**

```text
/epub-accessibility scan textbook.epub
/epub-accessibility check all .epub files in the publications/ directory
/epub-accessibility does ebook.epub pass EPUB Accessibility 1.1?
```

**In GitHub Copilot Chat:**

```text
@epub-accessibility scan textbook.epub
@epub-accessibility check the digital course materials for AT compatibility
```

**Via document-accessibility-wizard:** For bulk audits of mixed-format collections that include `.epub` files, the wizard discovers and routes each file type to its specialist agent. It will delegate `.epub` files to `epub-accessibility` automatically.

## Step-by-Step: What a Scan Session Looks Like

**You say:**

```text
/epub-accessibility scan textbook.epub
```

**What the agent does:**

1. **Checks for `.a11y-epub-config.json`** in the workspace root. If absent, invokes `epub-scan-config` to create one from the moderate template.

2. **Extracts the ePub container.** ePub files are ZIP archives. The agent reads the OPF package file, spine, manifest, and all content documents.

3. **Evaluates all EPUB-E\* error rules first** (blocking issues that prevent AT access), then EPUB-W\* warnings, then EPUB-T\* tips.

4. **Returns findings with precise locations** - OPF metadata fields, content document filenames and element selectors, and EPUB spine item identifiers.

   ```text
   EPUB-E005 [Error] - High Confidence
   Image missing alt text
   Location: chapter3.xhtml, <img src="../images/figure-3.2.png">
   Remediation: Add alt="[descriptive text]" to the img element in chapter3.xhtml.
   In the source authoring tool (e.g., Word, InDesign), add alt text before EPUB export.
   ```

5. **Delivers score, grade, full findings list, and remediation guidance.**

## Understanding Your Results

### Score Interpretation

| Score | Grade | What it means |
|-------|-------|---------------|
| 90-100 | A | Excellent - meets EPUB Accessibility 1.1 |
| 75-89 | B | Good - minor gaps, addressable in source |
| 50-74 | C | Needs work - multiple barriers for AT users |
| 25-49 | D | Poor - significant structural or metadata issues |
| 0-24 | F | Failing - missing navigation, alt text, or language declarations |

### What to Fix First

1. **EPUB-E003** (missing language) - Required for screen readers to select correct voice and dictionary.
2. **EPUB-E004** (missing nav TOC) - Without a TOC, AT users cannot navigate the publication.
3. **EPUB-E005** (missing alt text) - Every non-decorative image must have a description.
4. **EPUB-E007** (missing accessibility metadata) - Required by EPUB Accessibility 1.1 for discoverable conformance.
5. **EPUB-W003** (heading hierarchy) - Skipped heading levels disorient screen reader users navigating by heading.

## Connections

| Connect to | When |
|------------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | For bulk ePub audits, mixed-format collections, and VPAT generation |
| [epub-scan-config](epub-scan-config.md) | To configure which rules are enabled and which severity levels to report |
| [alt-text-headings](alt-text-headings.md) | For detailed image alt text and heading structure guidance beyond what the scan reports |
| [tables-data-specialist](tables-data-specialist.md) | For complex table structures flagged by EPUB-W004 |

</invoke>
