# aria-specialist — ARIA Roles, States, and Properties

> Reviews and writes correct ARIA markup. Enforces the First Rule of ARIA: do not use ARIA if native HTML works. Knows every WAI-ARIA role, state, and property. Implements complex widget patterns (combobox, tabs, treegrid, menu).

## When to Use It

- Custom interactive components (dropdowns, tabs, accordions, carousels, comboboxes)
- Any time you see `role=`, `aria-`, or plan to add them
- When native HTML is insufficient and ARIA is genuinely needed
- Reviewing existing ARIA for correctness

## What It Catches

- Redundant ARIA on semantic elements (`role="button"` on `<button>`)
- Missing required ARIA attributes (e.g., `role="tabpanel"` without `aria-labelledby`)
- Invalid ARIA attribute combinations
- ARIA states not updating with interactions
- Wrong widget patterns (using `role="menu"` for navigation)
- Missing relationship attributes (`aria-controls`, `aria-describedby`)

## What It Will Not Catch

Visual issues (contrast), focus management (that is keyboard-navigator), or form labeling specifics (that is forms-specialist). It focuses purely on ARIA correctness.

## Example Prompts

### Claude Code

```
/aria-specialist review the ARIA on this combobox component
/aria-specialist build an accessible tab interface for these 4 sections
/aria-specialist is role="menu" correct for this navigation dropdown?
/aria-specialist check all ARIA attributes in src/components/
```

### GitHub Copilot

```
@aria-specialist review the ARIA in this dropdown component
@aria-specialist what role should I use for this custom widget?
@aria-specialist audit all ARIA usage in this file
```

## Behavioral Constraints

- Will always prefer native HTML over ARIA. If you can use `<button>`, `<dialog>`, `<details>`, `<select>`, or any other native element, it will insist on that
- Will reject ARIA that contradicts native semantics
- References specific WAI-ARIA Authoring Practices patterns with links
- Verifies that ARIA IDs referenced by `aria-controls`, `aria-labelledby`, `aria-describedby` actually exist in the DOM
