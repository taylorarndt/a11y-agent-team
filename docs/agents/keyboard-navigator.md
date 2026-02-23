# keyboard-navigator — Tab Order and Focus Management

> Ensures every interactive element is reachable and operable by keyboard alone. Manages tab order, focus movement on dynamic content changes, skip links, SPA route changes, and arrow key patterns for custom widgets.

## When to Use It

- Any interactive element (buttons, links, inputs, custom controls)
- Page navigation and routing (especially SPAs)
- Dynamic content that appears or disappears
- Deletion flows (where does focus go after an item is removed?)
- Modal opening/closing (focus management)
- Custom widgets that need arrow key navigation

## What It Catches

<details>
<summary>Expand — 9 keyboard navigation issues detected</summary>

- Interactive elements not in the tab order
- Positive `tabindex` values (breaks natural tab order)
- Focus lost after dynamic content changes
- Keyboard traps (cannot Tab out of a section)
- Missing skip link
- `outline: none` without a replacement focus style
- Click handlers without keyboard equivalents
- Focus not managed on SPA route changes
- Missing Home/End/arrow key support in custom widgets

</details>

## What It Will Not Catch

Visual appearance of focus indicators (that is contrast-master), ARIA role correctness (aria-specialist), or modal focus trapping specifics (modal-specialist). It owns the *navigation* dimension.

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Claude Code

```
/keyboard-navigator audit tab order on the settings page
/keyboard-navigator check focus management in this SPA router
/keyboard-navigator where should focus go after deleting a list item?
/keyboard-navigator review skip link implementation
```

### GitHub Copilot

```
@keyboard-navigator check tab order for this component
@keyboard-navigator build focus management for this route change
@keyboard-navigator review keyboard interaction patterns in this dropdown
```

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Rejects any `tabindex` with a value greater than 0
- Requires a skip navigation link as the first focusable element on every page
- Requires focus management on every route change, modal open/close, and content deletion
- Tests focus order against visual layout order

</details>
