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

<details>
<summary>Expand — 8 modal issues detected</summary>

- Focus not trapped inside the modal
- Focus not returning to the trigger on close
- Escape key not closing the modal
- Missing `aria-modal="true"` or `<dialog>` usage
- Background content still interactive (not using `inert`)
- Heading level wrong (must start at H2 inside modals)
- Auto-focus landing on the wrong element
- Nested modals without proper stack management

</details>

## What It Will Not Catch

Content issues inside the modal (form accessibility is forms-specialist, contrast is contrast-master). It owns the modal *container* behavior, not the content within it.

## How to Launch It

**In Claude Code:**
```
/modal-specialist review the confirmation dialog in CheckoutModal.tsx
/modal-specialist build an accessible drawer component
/modal-specialist is focus trapping correct in this modal?
```

**In GitHub Copilot Chat:**
```
@modal-specialist review this dialog for focus management
@modal-specialist build a cookie consent banner that meets WCAG
@modal-specialist check the drawer component in this file
```

## Step-by-Step: What a Review Covers

When you ask the modal-specialist to review a dialog, here is the exact checklist it works through.

**The five behaviors every modal must have:**

**1. Focus moves into the modal on open.**
When the modal opens, focus must move inside it — either to the first focusable element, the close button, or the dialog heading, depending on the context. Focus staying behind on the trigger is a critical failure.

**2. Focus is trapped inside the modal.**
While the modal is open, pressing Tab must cycle through only the modal's interactive elements. Focus must never reach the content behind the overlay. The correct, modern implementation uses the `inert` attribute on everything outside the modal, rather than manual focus trap event listeners.

**3. Escape closes the modal.**
No exceptions. Every modal must close on `Escape`. This is a hard standard from WCAG Success Criterion 2.1.2 (No Keyboard Trap). If the modal is a destructive action, it may ask for confirmation, but it must respond to Escape.

**4. Focus returns to the trigger on close.**
When the modal closes, focus returns to the element that opened it. Without this, keyboard users are left disoriented in the page.

**5. Background content is not interactive.**
While the modal is open, links, buttons, and form elements behind the overlay must not be reachable. Use `inert` on the background container; do not rely only on `pointer-events: none` (that only affects mouse, not keyboard).

**Additional checks:**
- `<dialog>` element with `showModal()` is preferred over custom `<div role="dialog">`
- `aria-modal="true"` when using the `<dialog>` element
- Heading level: The first heading inside a modal should be H2 (the page H1 still exists in the background)
- Auto-focus: The correct element should receive initial focus based on the modal's purpose

**Example: Before and After**

```jsx
// Before — common broken pattern
function Modal({ onClose }) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal">
        <button onClick={onClose}>X</button>  {/* No accessible label */}
        <h1>Confirm delete</h1>               {/* Wrong heading level */}
        <p>Are you sure?</p>
        <button onClick={onClose}>Cancel</button>
        <button>Delete</button>
        {/* No focus trap, no Escape handler, no inert on background */}
      </div>
    </div>
  );
}

// After — correct implementation
function Modal({ onClose, triggerRef }) {
  const dialogRef = useRef(null);

  useEffect(() => {
    document.getElementById('page-content').inert = true;
    dialogRef.current.showModal();             // Native focus trap + Escape
    return () => {
      document.getElementById('page-content').inert = false;
      triggerRef.current?.focus();             // Return focus to trigger
    };
  }, []);

  return (
    <dialog ref={dialogRef} aria-modal="true" aria-labelledby="dialog-title">
      <h2 id="dialog-title">Confirm delete</h2>
      <p>Are you sure?</p>
      <button onClick={onClose}>Cancel</button>
      <button>Delete</button>
      <button onClick={onClose} aria-label="Close dialog">✕</button>
    </dialog>
  );
}
```

## Connections

| Connect to | When |
|------------|------|
| [forms-specialist](forms-specialist.md) | When the modal contains a form — the specialist reviews the form content separately |
| [keyboard-navigator](keyboard-navigator.md) | For complex focus management scenarios and tab order within the modal |
| [aria-specialist](aria-specialist.md) | For ARIA attributes on the dialog element itself (`aria-labelledby`, `aria-describedby`) |
| [live-region-controller](live-region-controller.md) | For modals that display dynamic status messages after submission |
| [accessibility-lead](accessibility-lead.md) | For full audits that combine the modal with its surrounding page context |

<details>
<summary>Show example prompts</summary>

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

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Requires `<dialog>` with `showModal()` as the preferred implementation. Accepts custom implementations only when `<dialog>` is genuinely insufficient
- Requires focus to return to the trigger element on close — no exceptions
- Will reject modals that can only be closed by clicking outside (must have Escape support)
- Validates both the opening and closing flows

</details>
