# alt-text-headings - Alt Text, SVGs, Headings, and Landmarks

> Manages alternative text for images, SVG accessibility, icon handling, heading hierarchy, landmark regions, page titles, and language attributes. Can visually analyze images and compare them against their existing alt text to determine if the description is accurate.

## When to Use It

- Any page with images, photos, or illustrations
- SVG icons or inline SVGs
- Heading structure review
- Landmark structure (`<header>`, `<nav>`, `<main>`, `<footer>`)
- Page title verification
- Document language attributes
- Charts and infographics

## What It Catches

<details>
<summary>Expand - 12 image, heading, and landmark issues detected</summary>

- Missing `alt` attributes
- Generic alt text ("image", "photo", filename-based alt text)
- Decorative images missing `alt=""`
- SVGs without `role="img"` and `<title>`
- Icons not hidden from screen readers (`aria-hidden="true"` missing)
- Skipped heading levels (H1 -> H3)
- Multiple H1 tags on a page
- Missing landmarks
- Multiple `<nav>` elements without unique labels
- Missing or generic page titles
- Missing `lang` attribute on `<html>`

</details>

## What It Will Not Catch

Interactive behavior (aria-specialist, keyboard-navigator), form content (forms-specialist), or color/contrast of images (contrast-master).

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Claude Code

```text
/alt-text-headings audit all images and heading structure
/alt-text-headings is this alt text accurate for the hero image?
/alt-text-headings review SVG accessibility in the icon library
/alt-text-headings check landmark structure on the homepage
```

### GitHub Copilot

```text
@alt-text-headings check alt text on all images in this page
@alt-text-headings review heading hierarchy in this template
@alt-text-headings audit SVG icons in the component library
```

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Evaluates alt text based on context, not just image content - the same image may need different alt text on different pages
- Requires `alt=""` on decorative images (not the absence of the `alt` attribute)
- Enforces strict heading sequence: one H1 per page, no skipped levels
- Requires all `<nav>` elements to have unique `aria-label` when multiple exist

</details>
