---
name: web-scanning
description: Web content discovery, URL crawling, and page inventory for accessibility audits. Use when scanning web pages, crawling sites for audit scope, or building page inventories for multi-page audits.
---

# Web Scanning

## Supported Audit Methods

| Method | Tool | When to Use |
|--------|------|-------------|
| Runtime scan | axe-core CLI | Live URL available (dev server or production) |
| Code review | Agent specialists | Source code available in workspace |
| Both | axe-core + agents | Most comprehensive — catches issues from both angles |

## Runtime Scanning Commands

### axe-core CLI

```bash
# Single page scan (WCAG 2.2 AA)
npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa

# Save results to JSON
npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa --save ACCESSIBILITY-SCAN.json

# Multiple pages
npx @axe-core/cli <URL1> <URL2> <URL3> --tags wcag2a,wcag2aa,wcag21a,wcag21aa --save ACCESSIBILITY-SCAN.json

# With Chrome flags (headless)
npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa --chrome-flags="--headless --no-sandbox"
```

### axe-core Tag Reference

| Tag | Standard |
|-----|----------|
| wcag2a | WCAG 2.0 Level A |
| wcag2aa | WCAG 2.0 Level AA |
| wcag21a | WCAG 2.1 Level A |
| wcag21aa | WCAG 2.1 Level AA |
| wcag22aa | WCAG 2.2 Level AA |
| best-practice | Best practices (not WCAG required) |

## Screenshot Capture

### capture-website-cli (preferred — lightweight)

```bash
# Full-page screenshot
npx capture-website-cli "<URL>" --output="screenshots/<page>.png" --full-page --type=png

# With viewport
npx capture-website-cli "<URL>" --output="screenshots/<page>.png" --full-page --width=1280 --height=720

# Mobile viewport
npx capture-website-cli "<URL>" --output="screenshots/<page>-mobile.png" --full-page --width=375 --height=812

# With delay for JS-rendered content
npx capture-website-cli "<URL>" --output="screenshots/<page>.png" --full-page --delay=3
```

### Playwright (fallback)

```bash
npx playwright screenshot --browser chromium --full-page --wait-for-timeout 3000 "<URL>" "screenshots/<page>.png"
```

## Page Discovery for Multi-Page Audits

### Crawl Depth Modes

| Mode | Behavior | Max Pages |
|------|----------|-----------|
| Current page only | Scan single URL | 1 |
| Key pages | User-provided list | User-defined |
| Full site crawl | Follow internal links | 50 (default cap) |

### Sitemap-based Discovery

```bash
# Check for sitemap
curl -s <BASE_URL>/sitemap.xml | head -20

# Extract URLs from sitemap
curl -s <BASE_URL>/sitemap.xml | grep -oP '<loc>\K[^<]+' | head -50
```

### Link-based Crawling

When crawling from a start URL:
- Follow only same-domain links
- Skip anchor links (#), mailto:, tel:, javascript: links
- Skip file downloads (.pdf, .zip, .doc, etc.)
- Respect robots.txt
- Cap at 50 pages unless user overrides
- Track visited URLs to avoid duplicates

## Framework Detection

Detect the framework from workspace files to enable framework-specific scanning:

| Indicator | Framework |
|-----------|-----------|
| `package.json` contains `react` | React |
| `package.json` contains `next` | Next.js |
| `package.json` contains `vue` | Vue |
| `package.json` contains `@angular/core` | Angular |
| `package.json` contains `svelte` | Svelte |
| `.jsx` / `.tsx` files present | React/Next.js |
| `.vue` files present | Vue |
| `angular.json` present | Angular |
| `.svelte` files present | Svelte |
| Only `.html` files | Vanilla HTML |

## Source Code File Patterns

When doing code review, scan these file patterns:

```bash
# HTML files
**/*.html

# Component files (framework-specific)
**/*.jsx
**/*.tsx
**/*.vue
**/*.svelte
**/*.component.ts
**/*.component.html

# Style files (for contrast/visual checks)
**/*.css
**/*.scss
**/*.less
**/*.module.css

# Config files (for framework detection)
package.json
next.config.*
nuxt.config.*
angular.json
svelte.config.*
tailwind.config.*
```

## Scan Configuration

### Web Scan Config File: `.a11y-web-config.json`

```json
{
  "profile": "standard",
  "wcagLevel": "AA",
  "wcagVersion": "2.2",
  "axeTags": ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"],
  "maxPages": 50,
  "screenshots": false,
  "framework": "auto",
  "ignore": {
    "paths": ["node_modules/**", "dist/**", "build/**", ".next/**"],
    "rules": []
  }
}
```

### Scan Profiles

| Profile | Phases | Thoroughness |
|---------|--------|-------------|
| Quick | 1, 3, 4, 9 | Errors and critical only |
| Standard | All (1-9) | Errors and warnings |
| Deep | All + extras | All severities + animation, cognitive, touch |
