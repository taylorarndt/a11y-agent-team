# Cognitive Accessibility Agent

The `cognitive-accessibility` agent audits web content for WCAG 2.2 cognitive success criteria, COGA (Cognitive and Learning Disabilities Accessibility) guidance, and plain language principles. It is part of the Web Accessibility Audit team.

## When to Use

- Auditing forms, error messages, and multi-step workflows for cognitive load
- Checking authentication flows for WCAG 2.2 SC 3.3.7, 3.3.8, and 3.3.9 compliance
- Reviewing content reading level and plain language quality
- Evaluating timeout warnings, session management, and predictable navigation
- Requesting COGA guidance for users with cognitive and learning disabilities

## Trigger Phrases

- "Check cognitive accessibility"
- "Audit for plain language"
- "Review my error messages for WCAG"
- "Check the authentication flow for accessibility"
- "Does this form meet WCAG 2.2 cognitive requirements?"
- "Analyze reading level"
- "Review timeout handling"

## What it Audits

### WCAG 2.2 Cognitive Success Criteria

| Success Criterion | Level | Description |
|------------------|-------|-------------|
| 2.2.1 Timing Adjustable | A | Users can turn off, adjust, or extend time limits |
| 2.2.2 Pause, Stop, Hide | A | Moving/blinking content can be paused or stopped |
| 2.4.6 Headings and Labels | AA | Headings and labels describe topic or purpose |
| 3.1.3 Unusual Words | AAA | Mechanism to identify definitions of unusual words |
| 3.1.4 Abbreviations | AAA | Mechanism to expand abbreviations |
| 3.1.5 Reading Level | AAA | Supplemental content for content above Grade 9 |
| 3.2.3 Consistent Navigation | AA | Navigation patterns are consistent across pages |
| 3.2.4 Consistent Identification | AA | Components are identified consistently across pages |
| 3.3.2 Labels or Instructions | A | Labels or instructions for user input |
| 3.3.4 Error Prevention | AA | Submissions are reversible, checked, or confirmed |
| **3.3.7 Redundant Entry** | **A** | **Previously entered info is auto-populated or selectable (New in 2.2)** |
| **3.3.8 Accessible Authentication (Minimum)** | **AA** | **No cognitive function test required for authentication (New in 2.2)** |
| **3.3.9 Accessible Authentication (Enhanced)** | **AAA** | **No cognitive function test required, no exceptions (New in 2.2)** |

### COGA Guidance Areas

- **Plain language:** Sentence length, passive voice, jargon density, reading grade level
- **Error messages:** Specific, human-readable, non-apologetic, actionable
- **Instructions:** Visible, persistent, not dependent on sensory characteristics
- **Memory demands:** Auto-fill support, visible history, breadcrumbs, progress indicators
- **Distractions:** Unnecessary animation, auto-playing media, busy layouts

## Phase Structure

1. **Identify review type** - Single page / form / auth flow / full audit
2. **WCAG 2.2 SC assessment** - Evaluates each applicable criterion with evidence
3. **COGA analysis** - Plain language, error quality, instruction clarity, memory load
4. **Report** - Structured findings with WCAG SC citations, impact descriptions, and remediation guidance

## Handoffs

- Complete web audit -> `accessibility-lead`
- WCAG criterion questions -> `wcag-guide`
- Form accessibility issues -> `forms-specialist`
- Testing guidance -> `testing-coach`

## Skill Reference

This agent uses the `cognitive-accessibility` skill in `.github/skills/cognitive-accessibility/SKILL.md`, which contains:

- Full WCAG 2.2 cognitive SC reference tables (Level A/AA/AAA with descriptions and links)
- Authentication pattern analysis tables (failing patterns: CAPTCHA, riddles, puzzles; passing patterns: email magic link, OAuth, passkey, copy-paste from manager)
- Redundant entry detection checklist and violation table
- Plain language analysis metrics (sentence length targets, passive voice thresholds, error message quality rubric 0-3 scale)
- Flesch-Kincaid reading level formula with grade targets by content type
- Timeout warning requirements with compliant JavaScript/HTML code examples
- COGA guidance mapping (8 objectives with severity ratings)

## Example Output

```markdown
## Cognitive Accessibility Audit - Checkout Flow

### WCAG 3.3.8 Accessible Authentication (Minimum) - FAIL
- **Evidence:** Login form requires solving a math CAPTCHA ("7 + 4 = ?")
- **Impact:** Users with dyscalculia, working memory impairments, or cognitive disabilities may be unable to authenticate.
- **Fix:** Replace with: magic link via email, OAuth (Google/GitHub), or copy-paste-compatible CAPTCHA (do not block clipboard).

### WCAG 3.3.7 Redundant Entry - FAIL
- **Evidence:** Billing address form doesn't offer to reuse the shipping address entered in Step 1.
- **Impact:** Users with motor and cognitive disabilities must re-type identical information.
- **Fix:** Add "Same as shipping address" checkbox that auto-populates billing fields.

### Plain Language - WARNING
- **Evidence:** Average sentence length = 28 words; target <= 20 words for body copy.
- **Impact:** Elevated cognitive load for users with reading disabilities, low literacy, or English as a second language.
- **Fix:** Break long sentences at conjunctions. Target a Grade 8 reading level for general audiences.
```
