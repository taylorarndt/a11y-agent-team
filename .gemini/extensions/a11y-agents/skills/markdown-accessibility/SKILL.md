---
name: markdown-accessibility
description: Markdown accessibility rule library covering ambiguous links, anchor validation, emoji handling (remove or translate to English), Mermaid and ASCII diagram replacement templates, heading structure, table descriptions, and severity scoring. Use when auditing or fixing markdown documentation for accessibility.
---

# Markdown Accessibility Skill

Reusable knowledge module for the `markdown-a11y-assistant`, `markdown-scanner`, and `markdown-fixer` agents and the `markdown-accessibility` always-on instructions. Provides pattern libraries, severity scoring, fix templates, emoji translation maps, diagram description templates, and GitHub anchor generation rules for comprehensive markdown accessibility auditing across 9 domains.

## Domains Covered

1. **Descriptive Links** (WCAG 2.4.4) - Ambiguous link text, bare URLs, repeated identical text
2. **Image Alt Text** (WCAG 1.1.1) - Missing, empty, filename-as-alt, generic placeholders
3. **Heading Hierarchy** (WCAG 1.3.1 / 2.4.6) - Skipped levels, multiple H1s, bold-as-heading
4. **Table Accessibility** (WCAG 1.3.1) - Missing descriptions, empty headers, layout tables
5. **Emoji** (WCAG 1.3.3 / Cognitive) - Remove-all, remove-decorative, translate, or leave-unchanged modes
6. **Mermaid and ASCII Diagrams** (WCAG 1.1.1 / 1.3.1) - Replace with accessible text + collapsible source
7. **Em-Dash / En-Dash Normalization** (Cognitive) - Normalize to ` - ` or leave unchanged
8. **Anchor Link Validation** (WCAG 2.4.4) - Validate `#anchor` links against actual headings
9. **Plain Language and List Structure** (Cognitive) - Emoji bullets, passive voice, sentence length

## Severity Scoring

| Issue | Severity | WCAG | Auto-fix? |
|-------|----------|------|-----------|
| Image missing alt text | Critical | 1.1.1 (A) | No - needs visual judgment |
| Mermaid diagram with no text alternative | Critical | 1.1.1 (A) | Partial - simple diagrams auto-described; complex need human |
| ASCII diagram with no text description | Critical | 1.1.1 (A) | Partial - flag and wrap; description needs human or auto-gen |
| Broken anchor link | Serious | 2.4.4 (A) | No - confirm which end changes |
| Ambiguous link text ("here", "click here") | Serious | 2.4.4 (A) | Yes - rewrite using surrounding context |
| Skipped heading level | Serious | 1.3.1 (A) | Yes - interpolate missing level |
| Multiple H1s | Serious | 1.3.1 (A) | Yes - demote all but first |
| Emoji in heading | Moderate | Cognitive | Yes - remove or translate per preference |
| Consecutive emoji (2+) | Moderate | 1.3.3 (A) | Yes - remove sequence or translate |
| Emoji used as bullet | Moderate | 1.3.1 (A) | Yes - replace with `-` |
| Em-dash in prose | Moderate | Cognitive | Yes - replace with ` - ` |
| Table without preceding description | Moderate | 1.3.1 (A) | Yes - add one-sentence summary |
| Bold text used as heading | Minor | 2.4.6 (AA) | Yes - convert to appropriate heading |
| Bare URL in prose | Minor | 2.4.4 (A) | Yes - wrap with descriptive text |
| Emoji used for meaning, single inline | Minor | 1.3.3 (A) | Conditional - remove-all: yes; remove-decorative: flag; translate: translate |

### Scoring Formula

```text
File Score = 100 - (sum of weighted findings)

Critical: -15 pts each
Serious:  - 7 pts each
Moderate: - 3 pts each
Minor:    - 1 pt each

Floor: 0
```

### Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - accessible documentation |
| 75-89 | B | Good - minor issues |
| 50-74 | C | Needs Work - several barriers |
| 25-49 | D | Poor - significant barriers |
| 0-24 | F | Failing - critical AT barriers |

## Emoji Handling Modes

The agent supports four modes configured during Phase 0:

| Mode | Description | Default? |
|------|-------------|----------|
| `remove-all` | Strip every emoji from prose, headings, and bullets | No |
| `remove-decorative` | Remove emoji in headings, bullets, and consecutive sequences; flag single inline for review | **Yes (default)** |
| `translate` | Replace known emoji with `(English)` text; flag unknown for review | No |
| `leave-unchanged` | Do not flag or modify any emoji | No |

### Emoji Translation Map

When using `translate` mode, replace each emoji with the parenthesized English equivalent:

| Emoji | Translation | Emoji | Translation |
|-------|------------|-------|------------|
| 🚀 | (Launch) | ✅ | (Done) |
| ⚠️ | (Warning) | ❌ | (Error) |
| 📝 | (Note) | 💡 | (Tip) |
| 🔧 | (Configuration) | 📚 | (Documentation) |
| 🎯 | (Goal) | ✨ | (New) |
| 🔍 | (Search) | 🛠️ | (Tools) |
| 👋 | (Hello) | 🎉 | (Celebration) |
| ⭐ | (Featured) | 💬 | (Discussion) |
| 🏠 | (Home) | 📊 | (Data) |
| 🔒 | (Security) | 🌐 | (Web) |
| 📦 | (Package) | 🔗 | (Link) |
| 📋 | (Checklist) | 🏆 | (Achievement) |
| ⚡ | (Quick) | 👍 | (Approved) |
| 👎 | (Rejected) | 🐛 | (Bug) |
| 🤝 | (Collaboration) | 🎓 | (Learning) |
| 🔑 | (Key) | 📌 | (Pinned) |
| ℹ️ | (Info) | 🔄 | (Refresh) |
| ➕ | (Add) | ➖ | (Remove) |
| 💻 | (Code) | 🔔 | (Notification) |
| 📣 | (Announcement) | 🧪 | (Test) |
| 🎨 | (Design) | 🌟 | (Highlight) |
| 📈 | (Increase) | 📉 | (Decrease) |
| 🏗️ | (Build) | 🔐 | (Locked) |
| 📂 | (Folder) | 📁 | (Folder) |
| 🗂️ | (Category) | 🗃️ | (Archive) |
| ⚙️ | (Settings) | 🏁 | (Finish) |
| 🚧 | (In Progress) | 🚫 | (Not Allowed) |
| ✔️ | (Check) | ➡️ | (Next) |
| ⬆️ | (Up) | ⬇️ | (Down) |

For emoji not in this table: flag as `needs-human-review`. Do not guess.

### Emoji Detection Unicode Ranges

```
[\u{1F600}-\u{1F64F}]  - Emoticons
[\u{1F300}-\u{1F5FF}]  - Misc symbols and pictographs
[\u{1F680}-\u{1F6FF}]  - Transport and map symbols
[\u{1F700}-\u{1F77F}]  - Alchemical symbols
[\u{1F780}-\u{1F7FF}]  - Geometric shapes extended
[\u{1F900}-\u{1F9FF}]  - Supplemental symbols
[\u{1FA70}-\u{1FAFF}]  - Symbols and pictographs extended
[\u{2600}-\u{26FF}]    - Misc symbols
[\u{2700}-\u{27BF}]    - Dingbats
[\u{1F1E0}-\u{1F1FF}]  - Flags
[\u{FE00}-\u{FE0F}]    - Variation selectors
```

Emoji-as-bullet pattern: list item where the first non-whitespace character is an emoji.

## Pattern Library: Mermaid and ASCII Diagrams

### Mermaid Detection

Lines matching ` ```mermaid` (with optional leading spaces/tabs).

### Mermaid Description Templates

| Type | Description Template |
|------|---------------------|
| `graph TD/LR/RL/BT` / `flowchart` | "The following [direction] diagram shows: [list major nodes and connections from source]" |
| `sequenceDiagram` | "The following sequence diagram shows the interaction between [participants]: [list each message in order]" |
| `classDiagram` | "The following class diagram shows [N] classes: [list class names, key properties, and relationships]" |
| `erDiagram` | "The following entity-relationship diagram shows [entities] with these relationships: [list relationships]" |
| `gantt` | "The following Gantt chart shows project tasks: [list section names and tasks with dates if available]" |
| `pie` | "The following pie chart shows [title] with values: [list each label and percentage/value if available]" |
| `stateDiagram` | "The following state diagram shows [N] states: [list state names and transition triggers]" |
| `mindmap` | "The following mind map shows [root topic] with branches: [list top-level branch names]" |
| `timeline` | "The following timeline shows events: [list events in chronological order]" |

Auto-generate description for: `graph`, `flowchart`, `pie`, `gantt`, `mindmap`, `timeline`.
Flag for human review: `sequenceDiagram`, `classDiagram`, `erDiagram`, `stateDiagram` (complex enough to need human verification).

### Mermaid Replacement Template

```markdown
[Generated or user-provided text description - this is the primary accessible content]

<details>
<summary>Diagram source (Mermaid)</summary>

```mermaid
[original diagram source - unchanged]
```

</details>
```

### ASCII Diagram Detection

ASCII art patterns: non-code-block lines (or unnamed code blocks) containing combinations of `+`, `-`, `|`, `/`, `\`, `>`, `<`, `^`, `v`, `*` forming a visual structure. Minimum 3 lines with consistent column alignment.

### ASCII Diagram Replacement Template

```markdown
[Generated or user-provided text description - this is the primary accessible content]

<details>
<summary>ASCII diagram</summary>

```
[original ASCII art - unchanged]
```

</details>
```

## Pattern Library: Ambiguous Link Detection

Match these patterns (case-insensitive, trim whitespace):

### Exact-match violations

```
here, click here, read more, learn more, more, more info,
link, details, info, go, see more, continue, start, download,
view, open, submit, this, that
```

### Starts-with violations

```
click here to ..., read more about ..., learn more about ...,
here to ..., see more ...
```

### URL-as-text pattern

Any link where visible text matches `https?://` or `www\.`

### Repeated identical text

Multiple `[X](url1)` and `[X](url2)` with same X but different URLs on the same page.

### Safe patterns (do not flag)

- Badge links: `[![text](img)](url)` at top of README
- Section self-references: `[Installation](#installation)` where text matches heading
- Footer resource lists using the resource/tool name as text

## Pattern Library: GitHub Anchor Generation

GitHub converts headings to anchor IDs using these rules:

1. Lowercase entire string
2. Remove all characters except: letters (a-z), digits (0-9), spaces, hyphens
3. Replace spaces with hyphens
4. Remove leading and trailing hyphens

### Examples

| Heading | Anchor |
|---------|--------|
| `# Getting Started` | `#getting-started` |
| `## API: v2.0 Reference` | `#api-v20-reference` |
| `### What's New?` | `#whats-new` |
| `## C# and .NET Support` | `#c-and-net-support` |
| `## Step 1: Installation` | `#step-1-installation` |
| `## FAQ (Frequently Asked Questions)` | `#faq-frequently-asked-questions` |
| `## 🚀 Quick Start` | `#-quick-start` (emoji becomes empty, may vary) |

For headings containing emoji: GitHub strips the emoji character and generates an anchor from the remaining text. Anchors referencing emoji-containing headings are fragile and should be flagged.

## Pattern Library: Emoji Detection

Unicode emoji ranges for regex detection:

```
[\u{1F600}-\u{1F64F}]  # Emoticons
[\u{1F300}-\u{1F5FF}]  # Misc symbols and pictographs
[\u{1F680}-\u{1F6FF}]  # Transport and map symbols
[\u{1F700}-\u{1F77F}]  # Alchemical symbols
[\u{1F780}-\u{1F7FF}]  # Geometric shapes extended
[\u{1F800}-\u{1F8FF}]  # Supplemental arrows-C
[\u{1F900}-\u{1F9FF}]  # Supplemental symbols and pictographs
[\u{1FA00}-\u{1FA6F}]  # Chess symbols
[\u{1FA70}-\u{1FAFF}]  # Symbols and pictographs extended-A
[\u{2600}-\u{26FF}]    # Misc symbols
[\u{2700}-\u{27BF}]    # Dingbats
[\u{FE00}-\u{FE0F}]    # Variation selectors
[\u{1F1E0}-\u{1F1FF}]  # Flags
```

Emoji-as-bullet pattern: List item where first non-whitespace character is an emoji.

## Pattern Library: Em-Dash and En-Dash

Detection patterns:

```
—           Unicode em-dash (U+2014)
–           Unicode en-dash (U+2013)
---         Three hyphens in prose (not on its own line as HR)
--          Two hyphens in prose (used as em-dash substitute)
```

Safe to skip (do not modify):
- Line containing only `---` (horizontal rule)
- Content inside ` ``` ` code fences
- Content inside backtick inline code
- YAML front matter block
- HTML comment blocks `<!-- -->`

Replacement: ` - ` (space + hyphen + space)

En-dash in numeric ranges: `2–4 hours` -> `2 - 4 hours`

## Pattern Library: Mermaid Diagrams

Detection: Lines matching ` ```mermaid` (with optional leading spaces/tabs)

Diagram types and description guidance:

| Type | Description Template |
|------|---------------------|
| `graph TD/LR/RL/BT` | "The following diagram shows a [direction] flowchart: [list major nodes and connections]" |
| `sequenceDiagram` | "The following sequence diagram shows the interaction between [participants]: [list message exchanges]" |
| `classDiagram` | "The following class diagram shows [N] classes: [list class names and key relationships]" |
| `erDiagram` | "The following entity-relationship diagram shows [entities] and their relationships: [list relationships]" |
| `gantt` | "The following Gantt chart shows project phases: [list tasks and timeframes]" |
| `pie` | "The following pie chart shows [title] with values: [list segment names and values if available]" |
| `stateDiagram` | "The following state diagram shows [N] states and transitions: [list states and transition triggers]" |

Wrapping template:

```markdown
[Generated or user-provided text description]

<details>
<summary>Diagram source (Mermaid)</summary>

```mermaid
[original diagram source]
```

</details>
```

## Fix Templates

### Ambiguous link fix

```markdown
# Before
For more information, see [here](https://example.com/guide).

# After
For more information, see the [installation guide](https://example.com/guide).
```

### Emoji bullet fix

```markdown
# Before
- 🚀 Deploy to production
- ✅ Run tests

# After
- Deploy to production
- Run tests
```

### Emoji heading fix

```markdown
# Before
## 🔧 Configuration

# After
## Configuration
```

### Em-dash fix

```markdown
# Before
The agent—when invoked—will scan all files.

# After
The agent - when invoked - will scan all files.
```

### Table description fix

```markdown
# Before
| Rule | Severity | Auto-fix |
|------|----------|----------|

# After
The following table lists rules with their severity level and whether they can be fixed automatically.

| Rule | Severity | Auto-fix |
|------|----------|----------|
```

### Broken anchor fix

```markdown
# Before (broken)
See [Installation](#instalation) for setup steps.

# Heading in file
## Installation

# After (corrected)
See [Installation](#installation) for setup steps.
```

## Markdownlint Rules Reference

| Rule | Name | Accessibility Relevance |
|------|------|------------------------|
| MD001 | heading-increment | Heading hierarchy (WCAG 1.3.1) |
| MD022 | blanks-around-headings | Parsing reliability |
| MD024 | no-duplicate-heading | Unique section identity (WCAG 2.4.6) |
| MD025 | single-title / single-h1 | One H1 per document |
| MD033 | no-inline-html | May hide structure from parsers |
| MD034 | no-bare-urls | Ambiguous links (WCAG 2.4.4) |
| MD041 | first-line-heading | Document structure |
| MD055 | table-pipe-style | Table parsing consistency |
| MD056 | table-column-count | Table structural integrity |

Command: `npx --yes markdownlint-cli2 <filepath>`
