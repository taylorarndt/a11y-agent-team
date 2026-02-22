# wcag-guide — Understanding the Standard

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

## Example Prompts

### Claude Code

```
/wcag-guide explain WCAG 1.4.11 non-text contrast
/wcag-guide what changed between WCAG 2.1 and 2.2?
/wcag-guide does 2.5.8 target size apply to inline text links?
/wcag-guide what is the difference between Level A and AA?
/wcag-guide do disabled controls need to meet contrast requirements?
```

### GitHub Copilot

```
@wcag-guide what does WCAG 2.5.8 target size require?
@wcag-guide what new criteria were added in WCAG 2.2?
@wcag-guide explain accessible authentication (3.3.8)
@wcag-guide when does the orientation criterion (1.3.4) not apply?
```

## Behavioral Constraints

- Answers with the criterion number, name, conformance level, plain-language explanation, pass/fail examples, and what the criterion does NOT require
- References the correct specialist agent when the user needs code help after understanding the requirement
- Targets AA conformance unless the user specifically asks about AAA
- Corrects common misconceptions explicitly (e.g., "WCAG only applies to screen readers" is false)
