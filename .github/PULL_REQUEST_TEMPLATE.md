## Accessibility Checklist

Before submitting, verify all applicable items. If an item doesn't apply, mark it N/A.

### Structure
- [ ] Exactly one `<h1>` per page, no skipped heading levels
- [ ] Semantic landmarks used (`<header>`, `<nav>`, `<main>`, `<footer>`)
- [ ] Page `<title>` is descriptive and unique
- [ ] `<html lang="...">` is set correctly

### Images & Media
- [ ] Every `<img>` has an `alt` attribute
- [ ] Meaningful images have descriptive alt text
- [ ] Decorative images have `alt=""`
- [ ] SVGs are labeled (`role="img"` + `<title>`) or hidden (`aria-hidden="true"`)
- [ ] Videos have captions; audio has transcripts

### Forms
- [ ] Every input has a programmatically associated `<label>`
- [ ] Required fields use the `required` attribute
- [ ] Error messages are linked via `aria-describedby` with `aria-invalid="true"`
- [ ] Radio/checkbox groups use `<fieldset>` and `<legend>`
- [ ] Identity/payment fields have `autocomplete` attributes

### Keyboard & Focus
- [ ] All interactive elements reachable and operable by keyboard
- [ ] No positive `tabindex` values (> 0)
- [ ] Visible focus indicators on every interactive element
- [ ] Focus managed on route changes, dynamic content, and deletions
- [ ] Skip link to main content is present and functional

### Modals & Overlays
- [ ] Uses `<dialog>` with `showModal()` (or equivalent focus trapping)
- [ ] Focus lands on Close button on open
- [ ] Escape closes the modal
- [ ] Focus returns to trigger on close

### Color & Contrast
- [ ] Text contrast meets 4.5:1 (normal) or 3:1 (large text)
- [ ] UI components meet 3:1 contrast
- [ ] No information conveyed by color alone
- [ ] `prefers-reduced-motion` respected for animations

### Dynamic Content
- [ ] Live regions announce content updates (`aria-live="polite"`)
- [ ] Loading states announced for operations over 2 seconds
- [ ] Search/filter result counts announced

### Testing
- [ ] Tested with keyboard-only navigation (Tab, Enter, Escape, Arrow keys)
- [ ] Tested with screen reader (VoiceOver, NVDA, or JAWS) if available
- [ ] No new accessibility linting warnings
