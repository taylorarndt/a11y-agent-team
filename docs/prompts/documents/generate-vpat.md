# generate-vpat

Convert a document accessibility audit report into a formal **VPAT 2.5 Accessibility Conformance Report (ACR)**. Maps findings to WCAG success criteria and generates the standard conformance tables used in procurement and regulatory compliance.

## When to Use It

- Your organization requires VPAT documentation for software or content procurement
- You are responding to an RFP that requires an Accessibility Conformance Report
- You need to demonstrate Section 508 or EN 301 549 compliance for government work
- You want to produce stakeholder-ready compliance documentation from an audit you already completed

## How to Launch It

**In GitHub Copilot Chat:**

```text
/generate-vpat
```

Then provide the audit report path when prompted. Or specify directly:

```text
/generate-vpat DOCUMENT-ACCESSIBILITY-AUDIT.md
```

## What to Expect

### Step 1: Report Reading

The agent reads the audit report and extracts all findings with their WCAG criterion mappings.

### Step 2: VPAT Edition Selection

The agent asks which VPAT edition to generate:

| Edition | Use For |
|---------|---------|
| WCAG | Private sector; WCAG 2.2 criteria only |
| Section 508 | US federal government procurement |
| EN 301 549 | European procurement and public sector |
| International | All three combined - maximum coverage |

### Step 3: Criterion Mapping

For each WCAG success criterion in scope, the agent determines the conformance level:

| Conformance Level | Meaning |
|------------------|---------|
| Supports | Zero findings for this criterion |
| Partially Supports | Some documents/instances pass, some fail |
| Does Not Support | All or most instances fail |
| Not Applicable | This criterion does not apply to the document types scanned |

### Step 4: VPAT Generation

The VPAT is written to `VPAT-DOCUMENT-ACCESSIBILITY.md` in proper VPAT 2.5 format:

- **Product information section** - name, version, description, date of evaluation
- **Evaluation methods** - tools used, scope of testing, assumptions
- **Table 1: Success Criteria, Level A** - with conformance level and remarks per criterion
- **Table 2: Success Criteria, Level AA** - same format
- **Notes** - known limitations, items not evaluated, and guidance for administrators
- **Evaluation methodology** - reproducibility information

### Remarks Column

The remarks for each criterion come directly from your audit findings - explaining specifically what works, what fails, and on which documents.

## Example Variations

```text
/generate-vpat DOCUMENT-ACCESSIBILITY-AUDIT.md
-> Edition: Section 508

/generate-vpat reports/library-audit-2026.md
-> Edition: International (WCAG + 508 + EN 301 549)

/generate-vpat
-> Use existing audit report in workspace
-> Edition: EN 301 549 (European procurement)
```

## Output Files

| File | Contents |
|------|----------|
| `VPAT-DOCUMENT-ACCESSIBILITY.md` | Full VPAT 2.5 conformance report ready for submission |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Orchestrates VPAT generation from audit data |
| [cross-document-analyzer](../../agents/cross-document-analyzer.md) | Provides the per-criterion analysis needed for conformance levels |

## Related Prompts

- [audit-single-document](audit-single-document.md) - generate the audit report this prompt reads
- [audit-document-folder](audit-document-folder.md) - for VPAT covering a library of documents
- [compare-audits](compare-audits.md) - track remediation progress before regenerating the VPAT
