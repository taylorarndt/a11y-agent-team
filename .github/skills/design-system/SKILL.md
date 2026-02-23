# Design System Accessibility Skill

This skill provides reference data for design token contrast validation, focus ring compliance, and spacing audits. Used by `design-system-auditor.agent.md`.

---

## WCAG Contrast Ratio - Computation Reference

### Step 1: Linearize sRGB Channel

For each channel `C` in `[0, 255]`:

```text
c = C / 255
c_lin = c / 12.92              if c <= 0.04045
c_lin = ((c + 0.055) / 1.055)^2.4   otherwise
```

### Step 2: Relative Luminance

```text
L = 0.2126 * R_lin + 0.7152 * G_lin + 0.0722 * B_lin
```

### Step 3: Contrast Ratio

```text
ratio = (L_lighter + 0.05) / (L_darker + 0.05)
```

### Quick JavaScript Implementation

```js
function relativeLuminance(hex) {
  const c = hex.replace('#', '').match(/.{2}/g)
    .map(h => parseInt(h, 16) / 255)
    .map(c => c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
}

function contrastRatio(hex1, hex2) {
  const L1 = relativeLuminance(hex1);
  const L2 = relativeLuminance(hex2);
  const lighter = Math.max(L1, L2);
  const darker = Math.min(L1, L2);
  return (lighter + 0.05) / (darker + 0.05);
}

// Example
contrastRatio('#6B7280', '#FFFFFF'); // 5.74:1 - PASSES AA (was a common misconception)
contrastRatio('#9CA3AF', '#FFFFFF'); // 2.85:1 - FAILS AA
```

### HSL to Hex Conversion (for CSS variable tokens)

Many design systems store colors as HSL triplets (e.g., shadcn/ui, Radix):

```js
function hslToHex(h, s, l) {
  s /= 100; l /= 100;
  const a = s * Math.min(l, 1 - l);
  const f = n => {
    const k = (n + h / 30) % 12;
    return l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
  };
  return '#' + [f(0), f(8), f(4)]
    .map(x => Math.round(x * 255).toString(16).padStart(2, '0'))
    .join('');
}

// shadcn/ui: --muted-foreground: 215.4 16.3% 46.9%
hslToHex(215.4, 16.3, 46.9); // -> approximately #6B7280
```

---

## WCAG Contrast Thresholds

| Use Case | AA | AAA | Notes |
|----------|-----|-----|-------|
| Normal text (< 18pt / < 14pt bold) | 4.5:1 | 7:1 | Most body text |
| Large text (>= 18pt / >= 14pt bold) | 3:1 | 4.5:1 | Headings, display text |
| UI components (borders, icons) | 3:1 | - | Input borders, icon buttons |
| Focus indicators (WCAG 2.4.11, 2.2) | 3:1 | - | Against adjacent colors |
| Placeholder text | 4.5:1 | - | Counts as normal text |
| Disabled state | Exempt | Exempt | Documented exemption |
| Logo / brand | Exempt | Exempt | No requirement |
| Decorative content | Exempt | Exempt | Must be marked decorative |

---

## Framework Token Paths - Complete Reference

### Tailwind CSS

```js
// tailwind.config.js / tailwind.config.ts
module.exports = {
  theme: {
    // Base colors (Tailwind default palette)
    colors: {
      // All color scales: slate, gray, zinc, neutral, stone, red, orange, amber,
      // yellow, lime, green, emerald, teal, cyan, sky, blue, indigo, violet,
      // purple, fuchsia, pink, rose
      // Each scale: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950
    },
    extend: {
      colors: {
        // Custom semantic colors - CHECK ALL PAIRS
        brand: { primary: '#...', secondary: '#...' },
        background: '#...',
        foreground: '#...',
        muted: '#...',
        'muted-foreground': '#...',
        accent: '#...',
        'accent-foreground': '#...',
        destructive: '#...',
        'destructive-foreground': '#...',
        card: '#...',
        'card-foreground': '#...',
        popover: '#...',
        'popover-foreground': '#...',
        border: '#...',    // UI component - check 3:1 against background
        input: '#...',     // UI component - check 3:1 against background
        ring: '#...',      // Focus ring - check 3:1 against background
        primary: '#...',
        'primary-foreground': '#...',
        secondary: '#...',
        'secondary-foreground': '#...',
      },
      ringColor: { DEFAULT: '...' },  // Focus state
      ringWidth: { DEFAULT: '2px' },  // Must be >= 2px for WCAG 2.4.11
    }
  }
}
```

### shadcn/ui / Radix CSS Variables

```css
/* globals.css - HSL triplets without hsl() wrapper */
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --card: 0 0% 100%;
  --card-foreground: 222.2 84% 4.9%;
  --popover: 0 0% 100%;
  --popover-foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;
  --secondary: 210 40% 96.1%;
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;     /* HIGH RISK - check on --background */
  --accent: 210 40% 96.1%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 84.2% 60.2%;               /* HIGH RISK - red on white */
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;               /* UI component - check 3:1 */
  --input: 214.3 31.8% 91.4%;                /* UI component - check 3:1 */
  --ring: 222.2 84% 4.9%;                    /* Focus ring - check 3:1 */
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  /* ... all dark mode variants */
}
```

### Material UI (MUI) v5+

```js
// Token paths in createTheme()
palette: {
  primary: {
    main: '#1976d2',            // text-on-white: 4.56:1 
    light: '#42a5f5',           // text-on-white: 2.86:1  (do not use as text color)
    dark: '#1565c0',            // text-on-white: 5.91:1 
    contrastText: '#fff',       // check on main
  },
  secondary: {
    main: '#9c27b0',            // text-on-white: 4.56:1  (barely)
    light: '#ba68c8',           // text-on-white: 2.55:1 
    dark: '#7b1fa2',
    contrastText: '#fff',
  },
  error: {
    main: '#d32f2f',            // text-on-white: 5.08:1 
    light: '#ef5350',           // text-on-white: 3.04:1 
  },
  warning: {
    main: '#ed6c02',            // text-on-white: 2.94:1  COMMON FAILURE
    light: '#ff9800',           // text-on-white: 2.02:1 
    dark: '#e65100',            // text-on-white: 3.84:1  (still fails!)
    contrastText: 'rgba(0, 0, 0, 0.87)',  // check on warning.main
  },
  info: {
    main: '#0288d1',            // text-on-white: 4.54:1  (barely)
    light: '#03a9f4',           // text-on-white: 2.88:1 
  },
  success: {
    main: '#2e7d32',            // text-on-white: 7.24:1 
    light: '#4caf50',           // text-on-white: 2.52:1 
  },
  text: {
    primary: 'rgba(0,0,0,0.87)',   // -> ~#212121: 16.07:1 on white 
    secondary: 'rgba(0,0,0,0.6)', // -> ~#666: 5.74:1 on white 
    disabled: 'rgba(0,0,0,0.38)', // -> ~#9E9E9E: 2.34:1  (exempt when disabled)
  },
  background: { paper: '#fff', default: '#fafafa' },
  action: {
    active: 'rgba(0,0,0,0.54)',   // ~4.48:1  for small icons
    disabled: 'rgba(0,0,0,0.26)', // exempt when disabled
  }
}
```

### Chakra UI v2/v3

```js
// Token paths in extendTheme()
const theme = extendTheme({
  colors: {
    // Direct palette values
    brand: { 50: '#f5f3ff', 500: '#7C3AED', 600: '#6D28D9', 700: '#5B21B6', 900: '#2E1065' },
    gray: { 50: '#F9FAFB', 100: '#F3F4F6', 200: '#E5E7EB', 300: '#D1D5DB',
            400: '#9CA3AF',  // text-on-white: 2.85:1 
            500: '#6B7280',  // text-on-white: 4.48:1  (near-miss)
            600: '#4B5563',  // text-on-white: 7.44:1 
            700: '#374151', 800: '#1F2937', 900: '#111827' },
  },
  semanticTokens: {
    colors: {
      'chakra-body-text': { default: 'gray.800', _dark: 'whiteAlpha.900' },
      'chakra-body-bg': { default: 'white', _dark: 'gray.800' },
      'chakra-placeholder-color': { default: 'gray.400', _dark: 'whiteAlpha.400' },
      // gray.400 on white = 2.85:1  - placeholder fails AA
    }
  },
  components: {
    Button: {
      variants: {
        solid: (props) => ({
          bg: `${props.colorScheme}.500`,  // check colorScheme.500 on white
          color: 'white',                  // white on colorScheme.500 - check 3:1
        }),
        ghost: (props) => ({
          color: `${props.colorScheme}.600`,  // text-on-white variant
        }),
      }
    }
  }
});
```

### Style Dictionary (W3C Design Tokens)

```json
{
  "color": {
    "text": {
      "primary": { "$value": "#111827", "$type": "color" },
      "secondary": { "$value": "#6B7280", "$type": "color" },   // 4.48:1 on white 
      "muted": { "$value": "#9CA3AF", "$type": "color" },       // 2.85:1 on white 
      "inverse": { "$value": "#FFFFFF", "$type": "color" },
      "on-primary": { "$value": "#FFFFFF", "$type": "color" }
    },
    "background": {
      "default": { "$value": "#FFFFFF", "$type": "color" },
      "subtle": { "$value": "#F9FAFB", "$type": "color" },
      "primary": { "$value": "#1D4ED8", "$type": "color" }
    },
    "status": {
      "error": { "$value": "#DC2626", "$type": "color" },
      "warning": { "$value": "#D97706", "$type": "color" },     // 3:1 on white  for normal text
      "success": { "$value": "#16A34A", "$type": "color" },
      "info": { "$value": "#2563EB", "$type": "color" }
    },
    "border": {
      "default": { "$value": "#D1D5DB", "$type": "color" },     // 1.44:1 on white  UI component
      "focus": { "$value": "#2563EB", "$type": "color" }        // focus ring
    }
  }
}
```

---

## High-Risk Token Pairs - Known Failures

| Token pair | Common value | Ratio on white | Status | Notes |
|-----------|-------------|----------------|--------|-------|
| MUI `warning.main` | `#ed6c02` | 2.94:1 |  FAIL | Orange on white - always fails |
| MUI `warning.light` | `#ff9800` | 2.02:1 |  FAIL | Light orange - critical failure |
| Tailwind `amber-400` | `#FBBF24` | 1.73:1 |  FAIL | Never use amber-400 as text |
| Tailwind `yellow-400` | `#FACC15` | 1.60:1 |  FAIL | Yellow always fails on white |
| gray-400 (Tailwind) | `#9CA3AF` | 2.85:1 |  FAIL | Common placeholder color |
| gray-500 (Tailwind) | `#6B7280` | 4.48:1 |  FAIL | Near-miss - very common |
| Chakra `gray.400` | `#9CA3AF` | 2.85:1 |  FAIL | Chakra placeholder default |
| MUI `text.disabled` | `rgba(0,0,0,0.38)` | ~2.34:1 |  (exempt) | Disabled = exempt per WCAG |
| MUI `action.active` | `rgba(0,0,0,0.54)` | ~4.48:1 |  FAIL | Icon color on white |
| shadcn `--muted-foreground` | `hsl(215.4 16.3% 46.9%)` | ~4.48:1 |  FAIL | Default shadcn theme |
| shadcn `--destructive` | `hsl(0 84.2% 60.2%)` | ~3.13:1 |  FAIL | Red badge on white |
| Style Dictionary `text.secondary` | `#6B7280` | 4.48:1 |  FAIL | Ubiquitous - always check |

### Compliant Replacements

| Failing token | Replacement | New ratio | Notes |
|--------------|-------------|-----------|-------|
| `#9CA3AF` (gray-400) | `#6B7280` (gray-500) | 4.48:1 | Still near-miss; use `#595959` for safety |
| `#6B7280` (gray-500) | `#4B5563` (gray-600) | 7.44:1 | Safest option |
| `#ed6c02` (MUI warning) | `#b45309` (amber-700) | 4.57:1 | Minimum pass |
| `#ff9800` (MUI warning.light) | `#b45309` (amber-700) | 4.57:1 | |
| `#FBBF24` (amber-400) | `#92400e` (amber-800) | 8.80:1 | Use as background, not text |
| `#FACC15` (yellow-400) | `#713f12` (yellow-900) | 12.04:1 | Use as background, not text |
| `hsl(0 84.2% 60.2%)` (shadcn destructive) | `#b91c1c` (red-700) | 5.56:1 | |

---

## Storybook addon-a11y Configuration

```bash
npm install --save-dev @storybook/addon-a11y
```

```js
// .storybook/main.js
module.exports = {
  addons: ['@storybook/addon-a11y'],
};

// .storybook/preview.js - global configuration
export const parameters = {
  a11y: {
    config: {
      rules: [
        { id: 'color-contrast', enabled: true },
        { id: 'button-name', enabled: true },
        { id: 'image-alt', enabled: true },
        { id: 'focus-visible', enabled: true },    // Requires axe-core 4.4+
        { id: 'target-size', enabled: true },       // WCAG 2.5.5 / 2.5.8
      ],
    },
    // Disable for specific stories (use sparingly)
    disable: false,
  },
};

// Per-story override
export const MyStory = {
  parameters: {
    a11y: {
      config: {
        rules: [{ id: 'color-contrast', enabled: false }],  // Document WHY
      }
    }
  }
};
```

### Running Storybook a11y Checks in CI

```bash
# Install storybook test runner
npm install --save-dev @storybook/test-runner

# package.json scripts
{
  "scripts": {
    "storybook:test": "test-storybook",
    "storybook:test:a11y": "test-storybook --ci"
  }
}

# Run in CI
npx storybook dev --port 6006 &
npx wait-on tcp:6006
npx test-storybook --ci
```

---

## WCAG 2.4.11 Focus Appearance Requirements (AA, 2.2)

**WCAG 2.4.11 Focus Appearance (Level AA in WCAG 2.2):**

1. **Area:** Focus indicator encloses the component OR has a perimeter >= component's perimeter x 2px
2. **Contrast change:** The focus indicator area must change contrast by >= 3:1 between focused and unfocused states
3. **Not obscured:** The focus indicator must not be entirely hidden by author-created content

### Minimum Compliant Focus Ring Implementation

```css
/* Minimum WCAG 2.4.11 compliant focus ring */
:focus-visible {
  outline: 2px solid #0054B3;      /* >= 2px width */
  outline-offset: 2px;             /* Separates from component edge */
  /* #0054B3 on #FFF = 8.28:1 -> passes 3:1 for UI components */
}

/* Dark mode variant */
@media (prefers-color-scheme: dark) {
  :focus-visible {
    outline-color: #7CAFFF;        /* lighter blue on dark background */
    /* #7CAFFF on #1E1E1E = 5.74:1  */
  }
}

/* VIOLATION patterns to detect */
:focus { outline: none; }                           /* Hard fail */
:focus { outline: 0; }                              /* Hard fail */
:focus-visible { box-shadow: none; outline: none; } /* Hard fail */
button:focus { outline: none; }                     /* Hard fail */
*:focus { outline-color: transparent; }             /* Hard fail */
```

### Focus Ring Token Validation Checklist

| Check | Requirement | Tool |
|-------|------------|------|
| `outline-width` >= 2px | WCAG 2.4.11 area requirement | CSS audit |
| Focus color contrast >= 3:1 | Against adjacent background | Contrast calculator |
| Focus state differs from unfocused | Visible change required | Visual inspection |
| No `outline: none` without replacement | N/A | grep / CSS audit |
| Present in both light and dark modes | Consistent | Visual inspection |

---

## Design Token File Discovery Commands

```bash
# Find all token files in a project
find . -type f \( \
  -name "tokens.json" \
  -o -name "design-tokens.json" \
  -o -name "colors.json" \
  -o -name "variables.css" \
  -o -name "tokens.css" \
  -o -name "_variables.scss" \
  -o -name "theme.ts" \
  -o -name "theme.js" \
  -o -name "tailwind.config.*" \
\) \
-not -path "*/node_modules/*" \
-not -path "*/.next/*" \
-not -path "*/dist/*"

# PowerShell equivalent
Get-ChildItem -Recurse -File -Include tokens.json,design-tokens.json,colors.json,`
  variables.css,tokens.css,_variables.scss,theme.ts,theme.js,tailwind.config.js,tailwind.config.ts `
  | Where-Object { $_.FullName -notmatch 'node_modules|\.next|dist' }
```

---

## Severity Classification

| Finding | Severity |
|---------|---------|
| Text token below 3:1 | Critical |
| Text token 3:1-4.49:1 (normal text) | Error |
| Text token 4.5:1-6.99:1, AAA target | Warning |
| UI component token below 3:1 | Error |
| Focus ring missing completely | Critical |
| Focus ring below 2px | Error |
| Focus ring contrast below 3:1 | Error |
| Touch target token below 24 x 24px (WCAG 2.5.8) | Error |
| Touch target token below 44 x 44px (WCAG 2.5.5) | Warning |
| No `prefers-reduced-motion` reset | Warning |
| Placeholder color below 4.5:1 | Error |
| Disabled token below 3:1 | Info (documented exemption, note for transparency) |
