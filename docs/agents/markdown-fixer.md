# markdown-fixer

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [markdown-a11y-assistant](markdown-a11y-assistant.md) after the review gate in Phase 5. You do not need to invoke it directly.

## What It Does

`markdown-fixer` receives a single Markdown file path plus an approved findings list and applies all approved fixes in a single batch edit. It produces a Fix Report showing every change made and the remaining items that need manual attention.

## When It Runs

The `markdown-a11y-assistant` dispatches one instance of this agent per file after the user approves fixes at the Phase 4 review gate. Only approved items are passed to the fixer.

## Fix Rules

### Auto-fixable (applied without per-item confirmation)

| Issue | Fix Applied |
|-------|------------|
| Em-dash `—` or en-dash `–` | Replaced with ` - ` |
| Ambiguous link text ("click here", "read more", bare URL) | Rewrites to descriptive text using surrounding context |
| Table with no preceding description | Inserts descriptive paragraph above the table |
| Heading level skip (H2 → H4) | Adjusts following heading levels to close the gap |
| Duplicate heading text | Appends `(2)`, `(3)` suffix to disambiguate |
| Decorative emoji (default `remove-decorative` mode) | Emoji removed cleanly |
| All emoji (when `remove-all` mode selected) | All emoji removed cleanly |

### Emoji translate mode

When the user selects `translate`, emoji are replaced with their English equivalent in parentheses:

```markdown
🚀 Launch             ✅ Done              ⚠️ Warning
❌ Error              📝 Note              💡 Tip
🔧 Configuration      📋 Prerequisites     🎉 Celebration
```

### Mermaid diagram replacement

When a Mermaid block has no preceding text description, the fixer wraps it:

```markdown
[Text description of the diagram - what entities exist and how they relate]

<details>
<summary>Diagram source (Mermaid)</summary>

```mermaid
[original diagram code]
```

</details>
```

For simple diagrams, the fixer generates the description automatically. For complex diagrams, it produces a draft and marks it `<!-- REVIEW: verify diagram description accuracy -->`.

### ASCII diagram wrapping

When ASCII art has no preceding description:

```markdown
[Text description of the diagram]

<details>
<summary>ASCII diagram</summary>

```
[original ASCII art]
```

</details>
```

## Requires Human Judgment (flagged, not auto-fixed)

| Issue | Why Human Needed |
|-------|-----------------|
| Missing alt text on images | Agent cannot see the image; author must describe it |
| Alt text quality assessment | Requires understanding the image context and purpose |
| Complex Mermaid diagram description | Agent produces draft; author must verify accuracy |
| Broken anchor links | Either the heading or the link anchor may need to change |
| Plain language rewrites | Meaning changes must be author-approved |

## Output Format

After applying fixes the agent returns a Fix Report:

```markdown
### Fix Report: path/to/file.md

**Applied Fixes:** 8
**Flagged for Review:** 2

#### Applied

| Line | Issue | Before | After |
|------|-------|--------|-------|
| 14 | Ambiguous link | `[click here](...)` | `[Download the configuration guide](...)` |
| 32 | Heading skip | `#### Sub-section` | `### Sub-section` |

#### Flagged for Review

| Line | Issue | Action Required |
|------|-------|----------------|
| 7 | `![](diagram.png)` | Add descriptive alt text |
| 45 | Mermaid diagram | Verify auto-generated description accuracy |
```
