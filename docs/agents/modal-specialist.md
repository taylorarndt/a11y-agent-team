# modal-specialist — Dialogs, Drawers, and Overlays

> Handles everything about overlays that appear above page content. Focus trapping, focus return, escape behavior, heading structure, background inertia, and scrolling behavior.

## When to Use It

- Modals and dialogs
- Confirmation prompts
- Drawers and slide-out panels
- Popovers and tooltips
- Alert dialogs
- Cookie consent banners
- Any overlay that requires focus management

## What It Catches

- Focus not trapped inside the modal
- Focus not returning to the trigger on close
- Escape key not closing the modal
- Missing `aria-modal="true"` or `<dialog>` usage
- Background content still interactive (not using `inert`)
- Heading level wrong (must start at H2 inside modals)
- Auto-focus landing on the wrong element
- Nested modals without proper stack management

## What It Will Not Catch

Content issues inside the modal (form accessibility is forms-specialist, contrast is contrast-master). It owns the modal *container* behavior, not the content within it.

## Example Prompts

### Claude Code

```
/modal-specialist review the confirmation dialog in CheckoutModal.tsx
/modal-specialist build an accessible drawer component
/modal-specialist is focus trapping correct in this modal?
/modal-specialist audit all dialogs in this project
```

### GitHub Copilot

```
@modal-specialist review this dialog for focus management
@modal-specialist build a cookie consent banner that meets WCAG
@modal-specialist check the drawer component in this file
```

## Behavioral Constraints

- Requires `<dialog>` with `showModal()` as the preferred implementation. Accepts custom implementations only when `<dialog>` is genuinely insufficient
- Requires focus to return to the trigger element on close — no exceptions
- Will reject modals that can only be closed by clicking outside (must have Escape support)
- Validates both the opening and closing flows
