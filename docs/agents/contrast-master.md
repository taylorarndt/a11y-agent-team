# contrast-master — Color Contrast and Visual Accessibility

> Verifies color contrast ratios, checks dark mode, ensures focus indicators are visible, validates that no information is conveyed by color alone, and provides comprehensive guidance on user preference media queries.

## When to Use It

- Choosing colors or creating themes
- CSS styling, Tailwind classes, or design tokens
- Dark mode implementation
- Focus indicator design
- Any use of color to convey state (error, success, warning)
- Design system compliance

## What It Catches

- Text below 4.5:1 contrast ratio (3:1 for large text)
- UI components below 3:1 contrast
- Focus indicators below 3:1 contrast
- Information conveyed by color alone (red/green for error/success without text or icons)
- Disabled state contrast issues
- Dark mode regressions
- Transparent backgrounds that change with context
- Opacity levels that reduce effective contrast

## What It Will Not Catch

Non-visual issues (ARIA, keyboard, live regions). It owns the visual/color domain exclusively.

## User Preference Media Query Coverage

- `prefers-reduced-motion` — disabling animations, handling JS-driven motion, framework patterns
- `prefers-contrast: more` — upgrading subtle colors, removing transparency, increasing borders
- `prefers-color-scheme` — dark mode with proper contrast re-verification
- `forced-colors` — Windows Contrast Themes, system color keywords, SVG handling
- `prefers-reduced-transparency` — solid fallbacks for frosted glass and overlays
- Combined preferences (e.g., dark + high contrast) and JavaScript detection

## Example Prompts

### Claude Code

```
/contrast-master check all color combinations in globals.css
/contrast-master is #767676 on white accessible for body text?
/contrast-master review the dark mode theme
/contrast-master check focus indicator visibility in this component
```

### GitHub Copilot

```
@contrast-master review the color palette in this design system
@contrast-master are these Tailwind colors accessible for text?
@contrast-master check contrast in the error state
```

## Behavioral Constraints

- Uses exact WCAG contrast ratio math (relative luminance formula, not eyeballing)
- Reports exact ratios, not just pass/fail
- Checks both light and dark modes when both exist
- Flags `opacity` and `rgba` values that may reduce contrast below the context background
