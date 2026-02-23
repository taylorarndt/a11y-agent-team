# aria-specialist — ARIA Roles, States, and Properties

> Reviews and writes correct ARIA markup. Enforces the First Rule of ARIA: do not use ARIA if native HTML works. Knows every WAI-ARIA role, state, and property. Implements complex widget patterns (combobox, tabs, treegrid, menu).

## When to Use It

- Custom interactive components (dropdowns, tabs, accordions, carousels, comboboxes)
- Any time you see `role=`, `aria-`, or plan to add them
- When native HTML is insufficient and ARIA is genuinely needed
- Reviewing existing ARIA for correctness

## What It Catches

<details>
<summary>Expand — 6 ARIA issues detected</summary>

- Redundant ARIA on semantic elements (`role="button"` on `<button>`)
- Missing required ARIA attributes (e.g., `role="tabpanel"` without `aria-labelledby`)
- Invalid ARIA attribute combinations
- ARIA states not updating with interactions
- Wrong widget patterns (using `role="menu"` for navigation)
- Missing relationship attributes (`aria-controls`, `aria-describedby`)

</details>

## What It Will Not Catch

Visual issues (contrast), focus management (that is keyboard-navigator), or form labeling specifics (that is forms-specialist). It focuses purely on ARIA correctness.

## How to Launch It

**In Claude Code:**
```
/aria-specialist review the ARIA on this combobox component
/aria-specialist build an accessible tab interface for these 4 sections
/aria-specialist is role="menu" correct for this navigation dropdown?
```

**In GitHub Copilot Chat:**
```
@aria-specialist review the ARIA in this dropdown component
@aria-specialist what role should I use for this custom widget?
@aria-specialist audit all ARIA usage in this file
```

## Step-by-Step: Reviewing ARIA on a Component

**You say:**
```
/aria-specialist review the ARIA on this combobox
```

```html
<div role="combobox" aria-expanded="false">
  <input type="text" />
  <ul role="listbox">
    <li role="option">Option 1</li>
  </ul>
</div>
```

**What the agent does:**

1. **Identifies the widget pattern.** Combobox = the ARIA 1.2 combobox pattern. The agent loads the specific requirements from the WAI-ARIA Authoring Practices Guide.

2. **Validates against the pattern checklist:**
   - `role="combobox"` on the wrapper — ✓ Valid
   - The `<input>` must be the combobox element, not the wrapper — ✗ Wrong. In ARIA 1.2, `role="combobox"` belongs on the `<input>` itself.
   - `aria-expanded` must be on the `role="combobox"` element — ✗ Wrong placement (it is on the wrapper, not the input)
   - `aria-controls` pointing to the listbox — ✗ Missing
   - `aria-activedescendant` for current selection — ✗ Missing
   - `aria-autocomplete` — ✗ Missing (required when filtering)

3. **Returns findings with the corrected code:**

```html
<!-- Corrected: ARIA 1.2 combobox pattern -->
<div>
  <input
    type="text"
    role="combobox"
    aria-expanded="false"
    aria-controls="my-listbox"
    aria-autocomplete="list"
    aria-activedescendant=""
  />
  <ul id="my-listbox" role="listbox">
    <li id="opt-1" role="option">Option 1</li>
  </ul>
</div>
```

4. **References the authoritative pattern:** [ARIA 1.2 Combobox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/)

## The First Rule of ARIA

The agent enforces this before anything else: **Do not use ARIA if native HTML works.**

| Instead of | Use |
|-----------|-----|
| `<div role="button" tabindex="0">` | `<button>` |
| `<div role="dialog">` | `<dialog>` |
| `<div role="checkbox">` | `<input type="checkbox">` |
| `<div role="navigation">` | `<nav>` |
| `<div role="main">` | `<main>` |
| `<span role="heading" aria-level="2">` | `<h2>` |

When native HTML is available, ARIA is not only unnecessary — it is often harmful because it does not automatically inherit the keyboard behavior that native elements have. You must implement all interaction patterns manually.

## Common ARIA Mistakes the Agent Catches

- **Redundant roles:** `<button role="button">` — the role is already implicit
- **Broken references:** `aria-labelledby="header-title"` where `id="header-title"` does not exist in the DOM
- **Wrong role for the widget:** `role="menu"` used for navigation (menu is for application-style menus, not nav links)
- **States not updating:** `aria-expanded="false"` that is never changed to `true` when the element opens
- **Missing required owned elements:** `role="list"` without any `role="listitem"` children
- **Missing required parent:** `role="option"` without a `role="listbox"` ancestor

## Connections

| Connect to | When |
|------------|------|
| [keyboard-navigator](keyboard-navigator.md) | ARIA widgets require matching keyboard behavior — the navigator ensures it is implemented |
| [forms-specialist](forms-specialist.md) | Form-related ARIA (`aria-invalid`, `aria-describedby` on error messages) |
| [modal-specialist](modal-specialist.md) | Dialog ARIA (`aria-modal`, `aria-labelledby` on `<dialog>`) |
| [accessibility-lead](accessibility-lead.md) | For full component audits that combine ARIA with other specialist domains |
| [wcag-guide](wcag-guide.md) | To understand the WCAG success criteria that ARIA correctness affects (primarily 4.1.2) |

<details>
<summary>Show example prompts</summary>

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

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Will always prefer native HTML over ARIA. If you can use `<button>`, `<dialog>`, `<details>`, `<select>`, or any other native element, it will insist on that
- Will reject ARIA that contradicts native semantics
- References specific WAI-ARIA Authoring Practices patterns with links
- Verifies that ARIA IDs referenced by `aria-controls`, `aria-labelledby`, `aria-describedby` actually exist in the DOM

</details>
