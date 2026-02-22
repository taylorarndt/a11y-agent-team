# link-checker — Ambiguous Link Text Detection

> Scans your code for link text that would confuse a screen reader user. Screen reader users often navigate by pulling up a list of all links on the page — when every link says "click here" or "read more," that list is useless. This agent finds those patterns and rewrites them so every link makes sense out of context.

## When to Use It

- You have pages with repeated "Learn more," "Click here," or "Read more" links
- You want to verify all links pass WCAG 2.4.4 (Link Purpose in Context)
- You are building navigation, footers, or content pages with many links
- You want to audit existing link text across an entire codebase
- A screen reader user or QA tester reported that links are confusing

## What It Catches

| Pattern | Example | Why It Fails |
|---------|---------|-------------|
| Generic exact match | `<a href="/pricing">Click here</a>` | No purpose in link list |
| Generic prefix | `<a href="/docs">Read more about setup</a>` | Starts with filler |
| Repeated identical text | Three links all saying "Learn more" | Indistinguishable in link list |
| URL as link text | `<a href="https://example.com">https://example.com</a>` | Screen reader reads every character |
| Adjacent duplicate links | Image + text link to same URL | Announced twice, confusing |
| Missing new-window warning | `<a href="/file.pdf" target="_blank">Report</a>` | No indication behavior changes |
| Non-HTML resource | `<a href="/file.xlsx">Download</a>` | User does not know the file type or size |

## Example Prompts

### Claude Code

```
/link-checker scan this page for ambiguous link text
/link-checker review the footer component for link accessibility
/link-checker audit all links in the marketing pages directory
/link-checker fix the "read more" links in this blog listing
```

### GitHub Copilot

```
@link-checker review the navigation links in this component
@link-checker find all ambiguous link text in the project
@link-checker fix the "click here" links in this file
@link-checker audit links across the entire src/ directory
```

## Behavioral Constraints

- Never suggests `aria-label` as a first fix — always rewrites the visible text first
- Does not flag links with 4+ descriptive words (e.g., "View quarterly earnings report" is fine)
- Catches bare URLs as link text — requires human-readable text instead
- Flags adjacent image + text links to the same destination as requiring combination into a single `<a>`
- Adds `(opens in new tab)` visually and via `aria-label` for `target="_blank"` links
- Adds file type and size for non-HTML resources (e.g., "Annual report (PDF, 2.4 MB)")
