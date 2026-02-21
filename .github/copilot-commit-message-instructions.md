## Accessibility Commit Message Instructions

When generating commit messages for changes that involve web UI code, follow these guidelines:

### Include Accessibility Context

If the commit modifies accessibility-related code, prefix the scope with `a11y`:

- `fix(a11y): add missing alt text to product images`
- `feat(a11y): add aria-live region for search results`
- `fix(a11y): restore focus management on modal close`
- `refactor(a11y): replace div buttons with native button elements`

### What Counts as Accessibility-Related

- Adding or fixing `alt` text, `aria-*` attributes, or `role` attributes
- Adding or fixing keyboard navigation, focus management, or skip links
- Adding or fixing form labels, error handling, or fieldset grouping
- Fixing heading hierarchy or landmark structure
- Adding or fixing live regions for dynamic content
- Fixing color contrast or adding `prefers-reduced-motion` support
- Replacing non-semantic HTML with semantic elements

### General Commit Messages

For commits that include accessibility fixes alongside other changes, mention the accessibility improvement in the commit body:

```
feat: redesign checkout flow

- Updated layout to single-column for better mobile experience
- Added fieldset/legend grouping for payment fields
- Fixed missing autocomplete attributes on address inputs
- Added error summary with focus management on form submit
```
