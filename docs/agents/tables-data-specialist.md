# tables-data-specialist — Data Tables, Grids, and Sortable Columns

> Ensures data tables are properly structured for screen reader navigation. Covers table markup, header scope, captions, complex multi-level headers, sortable columns, interactive data grids, responsive table patterns, select-all checkboxes, pagination, and empty states.

## When to Use It

- Any data table or grid
- Sortable/filterable tables
- Comparison tables or pricing tables
- Dashboard data displays
- Spreadsheet-like interfaces
- Tables with interactive elements (checkboxes, edit buttons, dropdowns)
- Responsive tables on mobile

## What It Catches

<details>
<summary>Expand — 11 table and grid issues detected</summary>

- `<div>` grids styled to look like tables (screen readers cannot navigate these)
- `<td>` elements styled as headers instead of `<th>` with `scope`
- Missing `<caption>` on data tables
- Missing `scope="col"` / `scope="row"` on headers
- `aria-sort` not updating when sort changes
- Sortable column buttons outside the `<th>` element
- `role="grid"` on non-interactive tables (adds unnecessary complexity)
- Interactive elements in cells without descriptive `aria-label` (50 "Edit" buttons — edit what?)
- Pagination without `aria-current="page"`
- Layout tables without `role="presentation"`
- Responsive tables that hide columns incorrectly

</details>

## What It Will Not Catch

Content within table cells (form inputs are forms-specialist, links are aria-specialist), visual contrast of table borders (contrast-master), or focus management between pages (keyboard-navigator).

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Claude Code

```
/tables-data-specialist review the pricing comparison table
/tables-data-specialist build an accessible sortable data grid
/tables-data-specialist check the admin user table for screen reader nav
/tables-data-specialist audit all tables in the dashboard
```

### GitHub Copilot

```
@tables-data-specialist review the data table in this component
@tables-data-specialist add proper headers and scope to this table
@tables-data-specialist make this sortable table accessible
```

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Requires `<table>` for tabular data — will never accept `<div>` grid patterns as accessible
- Requires `<caption>` or `aria-label` on every data table
- Requires `scope` on every `<th>` — does not trust screen reader guessing
- Only allows `role="grid"` when cells contain interactive elements

</details>
