# web-scanning Skill

> Web content discovery, URL crawling, and page inventory for accessibility audits. Covers supported audit methods (runtime vs. code review), axe-core CLI commands and tag reference, screenshot capture, page discovery modes (sitemap and link-based crawling), framework detection from workspace files, source code file patterns, and the `.a11y-web-config.json` configuration schema.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [web-accessibility-wizard](../agents/web-accessibility-wizard.md) | Page scanning, URL crawling, audit orchestration |
| [cross-page-analyzer](../agents/cross-page-analyzer.md) | Page inventory and cross-page pattern detection |

## Supported Audit Methods

| Method | Tool | When to Use |
|--------|------|-------------|
| Runtime scan | axe-core CLI | Live URL available (dev server or production) |
| Code review | Agent specialists | Source code available in workspace |
| Both | axe-core + agents | Most comprehensive - catches issues from both angles |

Issues found by **both** axe-core and code review are automatically upgraded to **high confidence**.

## axe-core CLI Commands

```bash
# Single page - WCAG 2.2 AA
npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa

# Save results to JSON
npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa --save ACCESSIBILITY-SCAN.json

# Multiple pages
npx @axe-core/cli <URL1> <URL2> <URL3> --tags wcag2a,wcag2aa,wcag21a,wcag21aa --save ACCESSIBILITY-SCAN.json

# Headless Chrome
npx @axe-core/cli <URL> --tags wcag2a,wcag2aa,wcag21a,wcag21aa --chrome-flags="--headless --no-sandbox"
```

### Tag Reference

| Tag | Standard |
|-----|----------|
| `wcag2a` | WCAG 2.0 Level A |
| `wcag2aa` | WCAG 2.0 Level AA |
| `wcag21a` | WCAG 2.1 Level A |
| `wcag21aa` | WCAG 2.1 Level AA |
| `wcag22aa` | WCAG 2.2 Level AA |
| `best-practice` | Best practices (not required by WCAG) |

## Screenshot Capture

```bash
# Full-page screenshot
npx capture-website-cli "<URL>" --output="screenshots/<page>.png" --full-page

# With delay for JS-rendered content
npx capture-website-cli "<URL>" --output="screenshots/<page>.png" --full-page --delay=3

# Mobile viewport
npx capture-website-cli "<URL>" --output="screenshots/<page>-mobile.png" --full-page --width=375 --height=812
```

## Page Discovery

### Crawl Depth Modes

| Mode | Behavior | Cap |
|------|----------|-----|
| Current page only | Single URL | 1 |
| Key pages | User-provided list | User-defined |
| Full site crawl | Follow internal links | 50 (default) |

### Sitemap-based Discovery

```bash
curl -s <BASE_URL>/sitemap.xml | grep -oP '<loc>\K[^<]+' | head -50
```

### Link-based Crawling Rules

- Follow same-domain links only
- Skip `#`, `mailto:`, `tel:`, `javascript:`, file downloads
- Respect `robots.txt`
- Track visited URLs to avoid duplicates
- Cap at 50 pages unless overridden

## Framework Detection

| Indicator | Framework |
|-----------|-----------|
| `package.json` -> `react` | React |
| `package.json` -> `next` | Next.js |
| `package.json` -> `vue` | Vue |
| `package.json` -> `@angular/core` | Angular |
| `package.json` -> `svelte` | Svelte |
| `.vue` files present | Vue |
| `angular.json` present | Angular |
| `.svelte` files present | Svelte |
| Only `.html` files | Vanilla HTML |

## Source Code File Patterns

```text
**/*.html
**/*.jsx, **/*.tsx
**/*.vue, **/*.svelte
**/*.component.ts, **/*.component.html
**/*.css, **/*.scss, **/*.less, **/*.module.css
```

## Scan Configuration - `.a11y-web-config.json`

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

| Profile | Thoroughness |
|---------|-------------|
| Quick | Errors and critical issues only (phases 1, 3, 4, 9) |
| Standard | Errors and warnings (all phases 1-9) |
| Deep | All severities including animation, cognitive, and touch |

## Skill Location

`.github/skills/web-scanning/SKILL.md`
