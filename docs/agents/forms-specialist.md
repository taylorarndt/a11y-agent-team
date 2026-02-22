# forms-specialist — Forms, Labels, Validation, and Errors

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

## What It Will Not Catch

Visual styling of errors (contrast-master), ARIA on custom form widgets like comboboxes (aria-specialist), or focus management between form steps (keyboard-navigator).

## Example Prompts

### Claude Code

```
/forms-specialist review the registration form
/forms-specialist build an accessible multi-step checkout wizard
/forms-specialist check error handling on the login form
/forms-specialist audit all form inputs in this file for autocomplete
```

### GitHub Copilot

```
@forms-specialist review this form for label and error handling
@forms-specialist build accessible validation for these inputs
@forms-specialist check the password reset form
```

## Behavioral Constraints

- Requires `<label>` with `for`/`id` for every input — `aria-label` only when visual labels are genuinely inappropriate
- Requires error messages to use text and/or icons, never color alone
- Requires `autocomplete` attributes on all identity/payment fields (WCAG 1.3.5)
- Rejects placeholder text as a replacement for labels
