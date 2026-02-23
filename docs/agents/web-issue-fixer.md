# web-issue-fixer

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [web-accessibility-wizard](web-accessibility-wizard.md) and the accessibility-lead team during fix workflows. You do not need to invoke it directly - use the `fix-web-issues` prompt instead.

## What It Does

`web-issue-fixer` applies accessibility fixes directly to web source code. It receives a list of issues with file paths and line numbers, determines which fixes are safe to apply automatically and which require human judgment, and generates framework-correct code for the detected stack.

It handles two categories of work:

1. **Auto-fixable issues** - deterministic, low-risk fixes applied immediately (missing `alt`, missing `lang`, positive `tabindex`, etc.)
2. **Human-judgment issues** - fixes that depend on context only the developer knows (alt text content, heading hierarchy restructuring, link text rewriting)

## When It Runs

This agent is called by:

- `fix-web-issues` prompt - the primary user-facing fix workflow
- `audit-web-page` prompt - when "apply auto-fixable issues" is selected after an audit
- The web-accessibility-wizard during interactive fix mode

## Auto-Fixable Issues

These fixes are applied without asking. They are deterministic and have no risk of breaking functionality or changing behavior:

| Issue | Fix Applied |
|-------|------------|
| Missing `lang` on `<html>` | Add `lang="en"` (or detected page language) |
| Missing viewport meta | Add `<meta name="viewport" content="width=device-width, initial-scale=1">` |
| `<img>` without `alt` attribute | Add `alt=""` (decorative) - content images prompt for description |
| Positive `tabindex` (1, 2, 3…) | Replace with `tabindex="0"` or remove |
| `outline: none` without alternative focus style | Add `outline: 2px solid` with `:focus-visible` |
| Missing `<label>` for named input | Add `<label>` with matching `for`/`id` |
| Icon-only button without accessible name | Add `aria-label` |
| Missing `autocomplete` on identity fields | Add `autocomplete="email"`, `"name"`, etc. |
| New-tab link without warning | Add `<span class="sr-only">(opens in new tab)</span>` |
| `<th>` without `scope` | Add `scope="col"` or `scope="row"` |
| `<button>` without `type` | Add `type="button"` |

## Human-Judgment Issues

These are shown to the user with a suggested fix, but applied only after approval:

| Issue | Why Approval Is Needed |
|-------|----------------------|
| Alt text for content images | Only the developer knows the image's communicative purpose |
| Heading hierarchy restructuring | Changing heading levels can affect visual design and content flow |
| Link text rewriting (e.g., "click here") | UX copy decision - the new text must make sense in context |
| ARIA role assignment on custom widgets | Depends on the intended interaction pattern |
| Live region placement and politeness level | Depends on UX intent for the notification |
| Color/contrast changes | May conflict with brand color guidelines |

## Framework Detection and Syntax

The agent detects the framework from the file extension, syntax, and imports, then generates fixes using correct syntax for that stack:

| Framework | Label Syntax | Event Handlers | Conditional Rendering |
|-----------|-------------|---------------|----------------------|
| React / Next.js | `htmlFor` | `onClick`, `onKeyDown` | `{condition && <Element />}` |
| Vue | `for` | `@click`, `@keydown` | `v-if`, `v-show` |
| Angular | `for` | `(click)`, `(keydown)` | `*ngIf` |
| Svelte | `for` | `on:click`, `on:keydown` | `{#if condition}` |
| Plain HTML | `for` | `onclick`, `onkeydown` | N/A |

Getting this wrong (e.g., writing `htmlFor` in a Vue file) would introduce syntax errors. The detection step is checked before any edit is applied.

## Fix Workflow

For each issue in the list:

1. Read the issue details (file path, line number, axe-core rule ID, description)
2. Open the source file and read surrounding context
3. Determine the framework and correct fix syntax
4. If auto-fixable: apply the fix immediately
5. If human-judgment: show the before/after diff and wait for approval
6. After all fixes: re-run axe-core (if available) to verify the issue is resolved

## Output Format

Each applied fix is reported as:

```text
Fix #1: img-alt - Missing alt attribute
  File: src/components/HeroImage.jsx:14
  Before: <img src="/hero.jpg" className="hero" />
  After:  <img src="/hero.jpg" className="hero" alt="Team collaborating around a whiteboard" />
  Status: Applied

Fix #2: label - Missing label for input
  File: src/components/SearchBar.vue:8
  Before: <input type="text" v-model="query" />
  After:  <label for="search-input">Search</label>
            <input type="text" id="search-input" v-model="query" />
  Status: Applied
```

After all fixes, a summary shows total auto-fixed, total awaiting approval, and total skipped with reasons.

## Connections

| Component | Role |
|-----------|------|
| [web-accessibility-wizard](web-accessibility-wizard.md) | Orchestrating wizard that calls this agent and presents summary to user |
| [fix-web-issues prompt](../prompts/web/fix-web-issues.md) | User-facing prompt that triggers the full fix workflow |
| [audit-web-page prompt](../prompts/web/audit-web-page.md) | Users can opt in to auto-fix immediately after an audit |
| [framework-accessibility skill](../../.github/skills/framework-accessibility/SKILL.md) | Framework-specific fix patterns and anti-patterns this agent draws from |
