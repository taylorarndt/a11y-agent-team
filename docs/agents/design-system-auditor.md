# Design System Auditor Agent

The `design-system-auditor` agent validates design tokens, CSS custom properties, Tailwind configuration, and component library theme files for WCAG accessibility compliance - catching contrast failures, missing focus styles, and spacing violations **at the token source**, before they reach deployed UI.

## When to Use

- Validating a Tailwind config before deploying a new color palette
- Auditing a `tokens.json` or Style Dictionary file for contract compliance
- Checking MUI, Chakra UI, Radix, or shadcn/ui theme tokens for WCAG AA
- Verifying focus ring tokens meet WCAG 2.4.13 Focus Appearance (new in 2.2)
- Confirming spacing tokens provide adequate touch target sizes
- Checking motion tokens for `prefers-reduced-motion` compliance

## Trigger Phrases

- "Audit my design tokens"
- "Check my Tailwind colors for contrast"
- "Are my MUI theme tokens WCAG compliant?"
- "Validate my focus ring tokens"
- "Check shadcn/ui default theme for accessibility"
- "Does my tokens.json pass WCAG AA?"
- "Find contrast failures in my color scale"

## Why Token-Level Auditing Matters

Traditional accessibility scanning catches contrast failures at runtime - after tokens have been compiled into CSS and rendered in a browser. By that point, the same bad token may already be used in hundreds of components across the application.

Token-level auditing interrupts this failure **at the source**: a failing token is identified once and fixed once, rather than being caught (and re-fixed) in every component that uses it.

This approach is particularly valuable when:

- Building or migrating a design system
- Adding dark mode or theme variants
- Onboarding a third-party component library
- Running accessibility checks in CI/CD before tokens are published

## Frameworks Supported

| Framework | Token File / Config Path |
|-----------|------------------------|
| Tailwind CSS | `tailwind.config.js` / `tailwind.config.ts` |
| shadcn/ui + Radix | `globals.css` (CSS custom properties as HSL triplets) |
| Material UI (MUI) v5+ | `createTheme()` palette object |
| Chakra UI v2/v3 | `extendTheme()` colors + semanticTokens |
| Style Dictionary | `tokens.json`, `design-tokens.json` |
| CSS custom properties | `variables.css`, `_variables.scss` |

## What it Audits

### Color Contrast (WCAG 1.4.3, 1.4.6, 1.4.11)

Every color token pair is evaluated using the WCAG relative luminance algorithm:

| Use Case | AA Threshold | AAA Threshold |
|----------|-------------|--------------|
| Normal text (< 18pt) | 4.5:1 | 7:1 |
| Large text (>= 18pt / >= 14pt bold) | 3:1 | 4.5:1 |
| UI components (borders, icons, input outlines) | 3:1 | - |
| Focus indicators | 3:1 | - |
| Placeholder text | 4.5:1 | - |

**Known high-risk tokens flagged automatically:**

- MUI `warning.main` (`#ed6c02`) - 2.94:1 on white -> always fails
- Tailwind `amber-400` / `yellow-400` - below 2:1 on white
- Tailwind `gray-500` (`#6B7280`) - 4.48:1 on white (near-miss, fails AA)
- Chakra `gray.400` / shadcn `--muted-foreground` - common placeholder failures

### Focus Ring Tokens (WCAG 2.4.13 - New in 2.2)

Focus indicators must:

1. Have a minimum area of perimeter x 2px
2. Change contrast by >= 3:1 between focused and unfocused states
3. Not be entirely obscured

The agent checks:

- `--ring`, `ring`, or `ringColor` token values
- `--ring-width` / `ringWidth` - must be >= 2px
- Absence of `outline: none` without a visible replacement
- Presence of `prefers-color-scheme` and dark mode variants

### Spacing / Touch Target Tokens (WCAG 2.5.5, 2.5.8)

Spacing tokens that contribute to interactive element height and width are evaluated against:

- WCAG 2.5.8 (AA, 2.2): 24 x 24 CSS px minimum
- WCAG 2.5.5 (AAA): 44 x 44 CSS px recommended
- iOS HIG: 44 x 44 pt
- Material Design: 48 x 48 dp

### Motion Tokens (WCAG 2.3.3)

The agent checks for:

- Presence of a `prefers-reduced-motion` CSS media query reset
- Animation tokens that may cause vestibular disorders without motion opt-out

## Phase Structure

1. **Identify design system** - auto-detect or user specifies framework/file type
2. **Locate token files** - file discovery command across the workspace
3. **Color contrast analysis** - evaluate all applicable pairs, compute WCAG ratios
4. **Focus ring validation** - check ring tokens, outline rules, and CSS patterns
5. **Spacing/touch target check** - evaluate padding/sizing tokens against minimums
6. **Motion check** - verify `prefers-reduced-motion` global reset
7. **Report** - token-violation table with current values, ratios, required threshold, and compliant replacements

## Handoffs

- Runtime contrast verification after token fixes -> `contrast-master`
- Full web accessibility audit -> `accessibility-lead`
- Mobile touch target validation -> `mobile-accessibility`
- WCAG criterion explanations -> `wcag-guide`

## Skill Reference

This agent uses the `design-system` skill in `.github/skills/design-system/SKILL.md`, which contains:

- WCAG relative luminance algorithm and contrast ratio formula with JavaScript implementation
- HSL -> Hex conversion for shadcn/ui and Radix HSL triplet tokens
- Complete framework token path tables (Tailwind, shadcn/ui, MUI, Chakra, Style Dictionary)
- High-risk token library: 15 known-failing tokens with their exact contrast ratios and compliant replacements
- Storybook `addon-a11y` configuration reference and CI integration commands
- WCAG 2.4.13 focus ring requirements with CSS compliant implementation examples
- Token file discovery commands (bash and PowerShell)
- Severity classification table for all violation types

## Example Output

```markdown
## Design System Accessibility Audit
**Design System:** Material UI v5
**Date:** 2025-01-15
**Target:** WCAG AA

### Color Token Violations

| Token Pair | Foreground | Background | Ratio | Required | Status | Severity |
|------------|-----------|-----------|-------|---------|--------|---------|
| warning.main on white | #ed6c02 | #FFFFFF | 2.94:1 | 4.5:1 |  FAIL | Error |
| action.active on white | rgba(0,0,0,0.54) | #FFFFFF | 4.48:1 | 4.5:1 |  FAIL | Error |
| text.secondary on white | rgba(0,0,0,0.6) | #FFFFFF | 5.74:1 | 4.5:1 |  PASS | - |

### Suggested Fixes

**warning.main:** `#ed6c02` -> `#b45309` (amber-700, 4.57:1) - minimum passing value
**action.active:** `rgba(0,0,0,0.54)` -> `rgba(0,0,0,0.60)` (5.74:1) - matches text.secondary

### Focus Ring Violations

| Token | Current Value | Issue | Fix |
|-------|--------------|-------|-----|
| Global focus style | `outline: none` (found in index.css:L14) | Removes all focus visibility | Replace with `outline: 2px solid var(--ring); outline-offset: 2px;` |
```
