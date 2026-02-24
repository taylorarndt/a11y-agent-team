# design-system Skill

> Reference data for design token contrast validation, focus ring compliance, touch target audits, and spacing checks. Covers the WCAG contrast ratio computation formula, per-framework token paths (Tailwind, shadcn/ui, MUI, Chakra, Style Dictionary), a known-failing token pair table, and WCAG 2.4.13 Focus Appearance requirements.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [design-system-auditor](../agents/design-system-auditor.md) | Primary consumer - full token contrast and focus ring audit |
| [contrast-master](../agents/contrast-master.md) | Contrast computation for web color checks |

## WCAG Contrast Thresholds

| Use Case | AA | AAA |
|----------|-----|-----|
| Normal text (< 18pt / < 14pt bold) | 4.5:1 | 7:1 |
| Large text (>= 18pt / >= 14pt bold) | 3:1 | 4.5:1 |
| UI components (borders, icons) | 3:1 | - |
| Focus indicators (WCAG 2.4.13, 2.2) | 3:1 change | - |
| Placeholder text | 4.5:1 | - |
| Disabled state | Exempt | Exempt |

## Contrast Ratio Computation

**Step 1 - Linearize each sRGB channel C  in  [0,255]:**

$$c_{lin} = \frac{c}{12.92} \quad \text{if } c \le 0.04045, \quad\text{else}\quad c_{lin} = \left(\frac{c + 0.055}{1.055}\right)^{2.4}$$

**Step 2 - Relative luminance:**

$$L = 0.2126 \cdot R_{lin} + 0.7152 \cdot G_{lin} + 0.0722 \cdot B_{lin}$$

**Step 3 - Contrast ratio:**

$$\text{ratio} = \frac{L_{\text{lighter}} + 0.05}{L_{\text{darker}} + 0.05}$$

## High-Risk Token Pairs (Known Failures)

| Token | Common Value | Ratio on White | Status |
|-------|-------------|----------------|--------|
| MUI `warning.main` | `#ed6c02` | 2.94:1 |  FAIL |
| MUI `warning.light` | `#ff9800` | 2.02:1 |  FAIL |
| Tailwind `amber-400` | `#FBBF24` | 1.73:1 |  FAIL |
| Tailwind `yellow-400` | `#FACC15` | 1.60:1 |  FAIL |
| Tailwind `gray-400` | `#9CA3AF` | 2.85:1 |  FAIL |
| Tailwind `gray-500` | `#6B7280` | 4.48:1 |  FAIL (near-miss) |
| Chakra `gray.400` | `#9CA3AF` | 2.85:1 |  FAIL |
| shadcn `--muted-foreground` | `hsl(215.4 16.3% 46.9%)` | ~4.48:1 |  FAIL |
| shadcn `--destructive` | `hsl(0 84.2% 60.2%)` | ~3.13:1 |  FAIL |
| MUI `action.active` | `rgba(0,0,0,0.54)` | ~4.48:1 |  FAIL |

### Safe Replacements

| Failing | Replacement | Ratio |
|---------|-------------|-------|
| `#9CA3AF` (gray-400) | `#4B5563` (gray-600) | 7.44:1 |
| `#6B7280` (gray-500) | `#4B5563` (gray-600) | 7.44:1 |
| `#ed6c02` (MUI warning) | `#b45309` (amber-700) | 4.57:1 |
| `hsl(0 84.2% 60.2%)` (shadcn destructive) | `#b91c1c` (red-700) | 5.56:1 |

## Framework Token Paths

| Framework | Key File | Color Token Location |
|-----------|----------|---------------------|
| Tailwind CSS | `tailwind.config.js` or `tailwind.config.ts` | `theme.extend.colors` |
| shadcn/ui / Radix | `globals.css` | CSS custom properties (`--primary`, `--muted-foreground`, etc.) |
| Material UI v5+ | `createTheme()` call | `palette.*` |
| Chakra UI | `extendTheme()` call | `colors.*`, `semanticTokens.colors.*` |
| Style Dictionary | `tokens.json` | `color.text.*`, `color.background.*`, `color.border.*` |

## WCAG 2.4.13 Focus Appearance (AAA, WCAG 2.2)

Requirements:

1. **Area** - focus indicator encloses the component OR has perimeter >= component perimeter x 2px
2. **Contrast change** - focus area changes by >= 3:1 between focused and unfocused states
3. **Not obscured** - not entirely hidden by author-created content

### Minimum Compliant Focus Ring

```css
:focus-visible {
  outline: 2px solid #0054B3;  /* >= 2px; #0054B3 on white = 8.28:1  */
  outline-offset: 2px;
}
```

### Violation Patterns to Flag

```css
:focus { outline: none; }           /* Hard fail */
:focus { outline: 0; }              /* Hard fail */
button:focus { outline: none; }     /* Hard fail */
*:focus { outline-color: transparent; } /* Hard fail */
```

## Token Audit Severity

| Finding | Severity |
|---------|---------|
| Normal text token below 3:1 | Critical |
| Normal text token 3-4.49:1 | Error |
| UI component token below 3:1 | Error |
| Focus ring missing entirely | Critical |
| Focus ring below 2px | Error |
| Focus ring contrast below 3:1 | Error |
| Touch target below 24 x 24px (WCAG 2.5.8) | Error |
| Touch target below 44 x 44px (WCAG 2.5.5) | Warning |
| No `prefers-reduced-motion` reset | Warning |
| Placeholder color below 4.5:1 | Error |

## Skill Location

`.github/skills/design-system/SKILL.md`
