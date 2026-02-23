## Accessibility Code Review Instructions

When reviewing pull requests, enforce the following WCAG 2.1 AA accessibility standards on all web UI code (HTML, JSX, CSS, React components, Tailwind classes, web pages, forms, modals, or any user-facing web content). Flag violations as required changes, not suggestions.

### Structure
- Verify exactly one `<h1>` per page with no skipped heading levels
- Verify correct landmark elements (`<header>`, `<nav>`, `<main>`, `<footer>`)
- Verify `<html lang="...">` is set with the correct language code
- Verify page `<title>` is descriptive and unique

### Semantic HTML
- Flag `<div>` or `<span>` used as buttons or links - require `<button>` or `<a href>`
- Flag redundant ARIA on native semantic elements (e.g., `role="button"` on `<button>`)
- Verify links have descriptive text - flag "Click here", "Read more" without context

### Images and Icons
- Every `<img>` must have an `alt` attribute
- Meaningful images must have descriptive `alt` text (not "image", "photo", or a filename)
- Decorative images must have `alt=""`
- Icons must have `aria-hidden="true"` when adjacent to text
- Icon-only buttons must have `aria-label`
- SVGs must have `role="img"` with `<title>` and `<desc>`, or `aria-hidden="true"` if decorative

### Forms
- Every input must have a `<label>` with matching `for`/`id`
- Required fields must use the `required` attribute
- Error messages must be associated with `aria-describedby`
- Fields with errors must have `aria-invalid="true"`
- Radio and checkbox groups must use `<fieldset>` and `<legend>`
- Identity and payment fields must have appropriate `autocomplete` attributes

### Interactive Elements
- Every interactive element must be reachable and operable by keyboard
- Flag positive `tabindex` values (> 0)
- Flag `outline: none` or `outline: 0` without an alternative visible focus style
- Flag click handlers on non-interactive elements without keyboard equivalents
- Flag hover-only interactions without keyboard triggers

### Modals and Overlays
- Modals must use `<dialog>` with `showModal()` (or equivalent focus trapping)
- Focus must land on the Close button when modal opens
- Escape must close the modal
- Focus must return to the trigger element on close
- Modal headings must start at H2

### Color and Contrast
- Text contrast must meet 4.5:1 (normal text) or 3:1 (large text)
- UI component contrast must meet 3:1
- No information conveyed by color alone
- Focus indicators must be visible with 3:1 contrast
- `prefers-reduced-motion` must be respected for animations

### Dynamic Content
- Content that updates without page reload must have `aria-live` regions
- Use `aria-live="polite"` for routine updates, `aria-live="assertive"` only for critical alerts
- Live regions must exist in the DOM before content changes
- Loading states must be announced for operations over 2 seconds
- Search/filter result counts must be announced

### Focus Management
- Focus must be managed on route changes (SPA)
- Focus must be managed when content is added or removed dynamically
- Deleted items must move focus to the next item (not lose focus)
- Skip link to main content must be present and functional

### Data Tables
- Data tables must use `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>` - not `<div>` grids
- Every data table must have a `<caption>` or `aria-label`
- Column headers must use `<th scope="col">`, row headers `<th scope="row">`
- Sortable columns must use `aria-sort` on the `<th>` element
- Complex tables with merged cells must use `headers` attribute for cell/header association
- Interactive data grids must use `role="grid"` only when cells contain interactive elements
- Responsive tables must use `role="region"` with `tabindex="0"` for horizontal scroll
- Layout tables (if they must exist) must use `role="presentation"`

### Links
- Flag ambiguous link text: "click here", "read more", "learn more", "here", "more", "link", "details"
- Flag multiple links with identical text pointing to different destinations
- Flag links opening in new tabs without warning (`target="_blank"` without "(opens in new tab)")
- Flag links to non-HTML resources (PDFs, documents) without file type indication
- Flag adjacent duplicate links (image + text link to same destination - combine them)
- Flag URLs used as visible link text

### What to Ignore
- Backend-only code, scripts, database queries, and API logic
- Test files (unless testing accessibility behavior)
- Configuration files
