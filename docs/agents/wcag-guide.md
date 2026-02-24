# wcag-guide - Understanding the Standard

> Explains WCAG 2.0, 2.1, and 2.2 success criteria in plain language with practical examples. Covers conformance levels, what changed between versions, when criteria apply and do not apply, common misconceptions, and the intent behind the rules.

## When to Use It

- Understanding a specific WCAG success criterion
- Learning what changed between WCAG 2.1 and 2.2
- Clarifying when a criterion applies vs does not apply
- Settling debates about what WCAG actually requires
- Understanding conformance levels (A, AA, AAA)
- Getting plain-language explanations of technical spec language

## What It Does NOT Do

- Does not write or review code (use the specialist agents for that)
- Does not run tests (use testing-coach for that)
- Does not make legal claims about compliance
- Does not cover WCAG AAA unless specifically asked (the team targets AA)

## How to Launch It

**In Claude Code:**

```text
/wcag-guide explain WCAG 1.4.11 non-text contrast
/wcag-guide what changed between WCAG 2.1 and 2.2?
/wcag-guide does 2.5.8 target size apply to inline text links?
```

**In GitHub Copilot Chat:**

```text
@wcag-guide what does WCAG 2.5.8 target size require?
@wcag-guide explain accessible authentication (3.3.8)
@wcag-guide when does the orientation criterion (1.3.4) not apply?
```

## How to Get the Most Out of wcag-guide

The agent answers three types of questions: **what it requires**, **when it applies**, and **what it does NOT require** (common misconceptions).

**The most useful query format:**

```text
/wcag-guide [criterion number or name] - does [specific scenario] pass or fail?
```

For example:

- `/wcag-guide 1.4.3 - does 4.4:1 contrast pass for large text?`
- `/wcag-guide 2.4.7 - does :focus-visible with outline: 0 pass?`
- `/wcag-guide 4.1.2 - does a custom button with only onclick pass?`

## WCAG 2.2 New Criteria (for Quick Reference)

WCAG 2.2 added several criteria not present in 2.1. These are the ones teams most frequently ask about:

| Criterion | Level | What it requires |
|-----------|-------|------------------|
| 2.4.11 Focus Not Obscured (Minimum) | AA | Focused element must not be entirely hidden by sticky headers, banners, or other content |
| 2.4.12 Focus Not Obscured (Enhanced) | AAA | No part of the focused element may be hidden by author-created content |
| 2.4.13 Focus Appearance | AAA | Focus indicator must have minimum 2px outline, 3:1 contrast from unfocused state |
| 2.5.7 Dragging Movements | AA | Any dragging action must have a single-pointer alternative |
| 2.5.8 Target Size (Minimum) | AA | Interactive targets must be at least 24x24 CSS pixels |
| 3.2.6 Consistent Help | A | Help mechanisms in same location across pages |
| 3.3.7 Redundant Entry | A | Don't ask users to re-enter information already provided |
| 3.3.8 Accessible Authentication | AA | Cannot require cognitive tests (CAPTCHA) without accessible alternative |
| 3.3.9 Accessible Authentication (No Exception) | AAA | Stricter version |

**Removed from WCAG 2.2:** 4.1.1 Parsing (deprecated - modern browsers handle the issues it addressed).

## The Standard Answer Format

When you ask the agent about a criterion, the response always includes:

1. **Criterion number and name** (e.g., `1.4.11 Non-Text Contrast, Level AA`)
2. **Plain-language explanation** of what it requires
3. **What passes** - specific examples
4. **What fails** - specific examples
5. **What it does NOT require** - clearing up common misconceptions
6. **Which specialist agent handles code implementation**

## Conformance Level Quick Reference

| Level | Must meet? | Notes |
|-------|-----------|-------|
| A | Yes | Minimum. Failing A criteria creates absolute barriers. |
| AA | Yes | The team target. Legal compliance requires A + AA in most jurisdictions. |
| AAA | No (unless committed) | Aspirational. Not required for overall conformance. |

Meeting WCAG AA means: zero Level A failures + zero Level AA failures. Level AAA criteria are not required for a conformance claim but are excellent improvements where achievable.

## Connections

| Connect to | When |
|------------|------|
| [accessibility-lead](accessibility-lead.md) | When you have understood the requirement and need code implementation |
| [aria-specialist](aria-specialist.md) | WCAG 4.1.2 Name, Role, Value - the primary criterion ARIA correctness affects |
| [contrast-master](contrast-master.md) | WCAG 1.4.3, 1.4.6, 1.4.11 - all contrast criteria |
| [keyboard-navigator](keyboard-navigator.md) | WCAG 2.1.1 Keyboard, 2.4.3 Focus Order, 2.4.7 Focus Visible |
| [forms-specialist](forms-specialist.md) | WCAG 1.3.1, 1.3.5, 3.3.1, 3.3.2 - form labeling and error criteria |
| [testing-coach](testing-coach.md) | For guidance on how to test whether a criterion is met |

<details>
<summary>Show example prompts</summary>

### Claude Code

```text
/wcag-guide explain WCAG 1.4.11 non-text contrast
/wcag-guide what changed between WCAG 2.1 and 2.2?
/wcag-guide does 2.5.8 target size apply to inline text links?
/wcag-guide what is the difference between Level A and AA?
/wcag-guide do disabled controls need to meet contrast requirements?
```

### GitHub Copilot

```text
@wcag-guide what does WCAG 2.5.8 target size require?
@wcag-guide what new criteria were added in WCAG 2.2?
@wcag-guide explain accessible authentication (3.3.8)
@wcag-guide when does the orientation criterion (1.3.4) not apply?
```

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Answers with the criterion number, name, conformance level, plain-language explanation, pass/fail examples, and what the criterion does NOT require
- References the correct specialist agent when the user needs code help after understanding the requirement
- Targets AA conformance unless the user specifically asks about AAA
- Corrects common misconceptions explicitly (e.g., "WCAG only applies to screen readers" is false)

</details>
