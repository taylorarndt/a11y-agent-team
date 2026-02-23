# forms-specialist - Forms, Labels, Validation, and Errors

> Owns every aspect of form accessibility. Labels, error messages, validation, required fields, fieldsets, autocomplete, multi-step wizards, search forms, file uploads, custom controls, and date pickers.

## When to Use It

- Any form, input, select, textarea, checkbox, radio button
- Login/signup forms
- Search interfaces
- Multi-step wizards and checkout flows
- File uploads
- Date/time pickers
- Custom form controls
- Form validation and error handling

## What It Catches

<details>
<summary>Expand - 10 form accessibility issues detected</summary>

- Inputs without labels (or with placeholder-only "labels")
- Error messages not associated with the field via `aria-describedby`
- Missing `required` attribute on required fields
- No `aria-invalid` on fields with errors
- Radio/checkbox groups without `<fieldset>` and `<legend>`
- Missing `autocomplete` attributes for identity/payment fields
- Focus not moving to the first error on invalid submission
- Multi-step wizards without step announcements
- Search forms without proper roles and announcements
- File upload controls without accessible status feedback

</details>

## What It Will Not Catch

Visual styling of errors (contrast-master), ARIA on custom form widgets like comboboxes (aria-specialist), or focus management between form steps (keyboard-navigator).

## How to Launch It

**In Claude Code:**

```text
/forms-specialist review the registration form
/forms-specialist build an accessible multi-step checkout wizard
/forms-specialist check error handling on the login form
```

**In GitHub Copilot Chat:**

```text
@forms-specialist review this form for label and error handling
@forms-specialist build accessible validation for these inputs
@forms-specialist check the password reset form
```

## Step-by-Step: What a Form Review Covers

**You say:**

```text
/forms-specialist review this login form
```

```html
<form>
  <input type="email" placeholder="Email" />
  <input type="password" placeholder="Password" />
  <div class="error" style="color: red">Invalid credentials</div>
  <button>Sign in</button>
</form>
```

**What the agent finds:**

1. **No `<label>` elements** (WCAG 1.3.1, 3.3.2) - Placeholders disappear when the user types. Screen readers use labels, not placeholders. A user filling in a complex form cannot refer back to what a field is asking for once they have started typing.

2. **Error not associated with any field** (WCAG 3.3.1) - The `<div class="error">` has no `id`, the inputs have no `aria-describedby`. Screen readers will not announce the error message when the user is focused on the inputs.

3. **Color-only error indicator** (WCAG 1.4.1) - Red text alone is not sufficient. A user with red-green color blindness may not perceive the error state.

4. **No `autocomplete` on email and password** (WCAG 1.3.5) - Autocomplete attributes allow password managers and assistive technology to fill identity fields automatically, reducing the cognitive and motor burden on users.

**What the agent produces:**

```html
<form novalidate>
  <div class="field">
    <label for="email">Email address</label>
    <input
      type="email"
      id="email"
      name="email"
      autocomplete="email"
      aria-describedby="email-error"
      aria-invalid="false"
      required
    />
    <span id="email-error" role="alert" hidden></span>
  </div>

  <div class="field">
    <label for="password">Password</label>
    <input
      type="password"
      id="password"
      name="password"
      autocomplete="current-password"
      aria-describedby="password-error credentials-error"
      aria-invalid="false"
      required
    />
    <span id="password-error" role="alert" hidden></span>
  </div>

  <!-- Server-side error (invalid credentials) -->
  <div id="credentials-error" role="alert" hidden>
    <svg aria-hidden="true"><use href="#icon-error"/></svg>
    Invalid email or password. Please check your credentials and try again.
  </div>

  <button type="submit">Sign in</button>
</form>
```

**Why each change:**

- `<label for="...">` - Every input has an explicit label that persists while typing
- `aria-describedby` - Connects each input to its error message; screen readers announce the error after the field name when focus lands on the input
- `aria-invalid="false"` - Set to `true` when validation fails
- `autocomplete` - WCAG 1.3.5 Identify Input Purpose; enables password managers and assistive technology
- `role="alert"` on error messages - Announces immediately when `hidden` is removed
- SVG icon is `aria-hidden` - The text does the communicating; the icon is decorative

## The Autocomplete Reference

WCAG 1.3.5 requires `autocomplete` on all personal data fields. The most common ones:

| Field | autocomplete value |
|-------|-------------------|
| Full name | `name` |
| First name | `given-name` |
| Last name | `family-name` |
| Email | `email` |
| Phone | `tel` |
| Address line 1 | `address-line1` |
| City | `address-level2` |
| State/Province | `address-level1` |
| ZIP/Postal code | `postal-code` |
| Country | `country-name` |
| Credit card number | `cc-number` |
| Credit card expiry | `cc-exp` |
| Credit card CVV | `cc-csc` |
| Current password | `current-password` |
| New password | `new-password` |
| Username | `username` |

## Multi-Step Wizard Checklist

For checkout flows, onboarding wizards, and multi-step forms:

- Step indicator must be accessible (current step announced, total steps known)
- Each step should have a page `<title>` or heading update
- Navigation between steps must be keyboard accessible
- Progress is announced to screen readers when advancing/reversing
- Errors on the current step are resolved before advancing (or the user is warned)
- On "Back," data is preserved
- Final submission has a summary the user can review

## Connections

| Connect to | When |
|------------|------|
| [aria-specialist](aria-specialist.md) | Custom form controls (comboboxes, custom selects, date pickers) |
| [keyboard-navigator](keyboard-navigator.md) | Focus management between form steps and on error |
| [live-region-controller](live-region-controller.md) | Announcing validation results and submission status |
| [contrast-master](contrast-master.md) | Error indicator color contrast |
| [modal-specialist](modal-specialist.md) | Confirmation dialogs within checkout flows |
| [accessibility-lead](accessibility-lead.md) | Full form + page audits |

<details>
<summary>Show example prompts</summary>

### Claude Code

```text
/forms-specialist review the registration form
/forms-specialist build an accessible multi-step checkout wizard
/forms-specialist check error handling on the login form
/forms-specialist audit all form inputs in this file for autocomplete
```

### GitHub Copilot

```text
@forms-specialist review this form for label and error handling
@forms-specialist build accessible validation for these inputs
@forms-specialist check the password reset form
```

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Requires `<label>` with `for`/`id` for every input - `aria-label` only when visual labels are genuinely inappropriate
- Requires error messages to use text and/or icons, never color alone
- Requires `autocomplete` attributes on all identity/payment fields (WCAG 1.3.5)
- Rejects placeholder text as a replacement for labels

</details>
