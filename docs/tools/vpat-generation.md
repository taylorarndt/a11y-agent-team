# VPAT / ACR Template Generation

The MCP server includes a `generate_vpat` tool that produces a [VPAT 2.5](https://www.itic.org/policy/accessibility/vpat) / Accessibility Conformance Report (ACR) template.

## What It Generates

- Product name, version, and evaluation date
- All WCAG 2.2 Level A criteria (30 criteria) in a structured table
- All WCAG 2.2 Level AA criteria (20 criteria) in a structured table
- Conformance levels: Supports, Partially Supports, Does Not Support, Not Applicable, Not Evaluated
- Remarks and explanations for each criterion
- Summary statistics (how many criteria at each conformance level)
- Terms and definitions section

## How to Use

**With the accessibility-wizard:**

```text
/accessibility-wizard I need to prepare for a VPAT assessment
@accessibility-wizard generate a VPAT for this project
```

The wizard runs its full audit, then uses `generate_vpat` to produce a VPAT pre-populated with findings.

**Directly via the MCP tool:**

```text
generate_vpat with:
  productName: "My App"
  productVersion: "2.1.0"
  evaluationDate: "2025-01-15"
  findings: [
    { criterion: "1.1.1", level: "A", conformance: "Partially Supports",
      remarks: "Most images have alt text, but user-uploaded images lack alt" }
  ]
  reportPath: "VPAT-MyApp-2.1.0.md"
```

## Integration with Agent Reviews

1. Run `accessibility-wizard` for a comprehensive audit
2. The wizard produces `ACCESSIBILITY-AUDIT.md` with all findings
3. Use `generate_vpat` to map findings to WCAG criteria and generate the formal VPAT
4. Review and adjust conformance levels as needed (agents provide evidence, you make the final call)
