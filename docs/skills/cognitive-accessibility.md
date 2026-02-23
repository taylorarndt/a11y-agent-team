# cognitive-accessibility Skill

> Cognitive, learning, and neurological accessibility reference covering WCAG 2.2 AA + key AAA criteria, COGA W3C guidance, plain language analysis, reading level computation, authentication pattern detection (SC 3.3.7-3.3.9), timeout analysis, and error message quality rubrics.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [cognitive-accessibility](../agents/cognitive-accessibility.md) | Primary consumer - full cognitive evaluation |
| [web-accessibility-wizard](../agents/web-accessibility-wizard.md) | Phase 3 (forms) and Phase 5 (dynamic content) delegation |
| [accessibility-lead](../agents/accessibility-lead.md) | Cognitive layer in orchestrated audits |
| [forms-specialist](../agents/forms-specialist.md) | Error message quality and redundant entry detection |

## WCAG 2.2 Cognitive Criteria

### Level A (Must Fix)

| SC | Name | What to Check |
|----|------|--------------|
| 2.2.1 | Timing Adjustable | Session timeouts warn >=20s before expiry; user can extend >=10x or disable |
| 2.2.2 | Pause, Stop, Hide | Auto-moving content >5s has pause/stop control |
| 3.3.1 | Error Identification | Errors identified in text, not by color alone |
| 3.3.2 | Labels or Instructions | Format requirements shown before errors occur |
| **3.3.7** | **Redundant Entry** *(new in 2.2)* | Previously-entered info not re-requested in same session unless security-essential |

### Level AA (Should Fix)

| SC | Name | What to Check |
|----|------|--------------|
| 3.2.3 | Consistent Navigation | Nav appears in same relative order across pages |
| 3.2.4 | Consistent Identification | Same-function components have same accessible name across pages |
| 3.3.3 | Error Suggestion | For detected errors, suggest corrections when possible |
| 3.3.4 | Error Prevention | Review step before irreversible submissions |
| **3.3.8** | **Accessible Authentication Min.** *(new in 2.2)* | No cognitive function test unless an alternative exists - no `autocomplete="off"`, no paste-disabled passwords |

### Level AAA (Advisory)

| SC | Name | Target |
|----|------|--------|
| 3.1.5 | Reading Level | <= Grade 8 for general consumer content |
| **3.3.9** | **Accessible Authentication Enhanced** *(new in 2.2)* | No cognitive function test at all |

## Authentication Pattern Detection (SC 3.3.8)

### Failing Patterns

| Pattern | Why It Fails |
|---------|-------------|
| `autocomplete="off"` on `type="password"` | Blocks password manager autofill |
| `onpaste="return false"` on password input | Blocks paste |
| CAPTCHA with only distorted-text option | No cognitive-free alternative |
| Security questions requiring exact recall | Pure memory test |

### Passing Patterns

| Pattern | Why It Passes |
|---------|--------------|
| `<input type="password" autocomplete="current-password">` | Allows password manager |
| Passkey / biometric as login option | No cognitive function test |
| Email magic link | No cognitive test at all |
| CAPTCHA with audio alternative | Non-visual option available |

## Redundant Entry Detection (SC 3.3.7)

Flag any form step that requests data already collected earlier in the same session, unless:

- The re-entry is security-essential (e.g., password confirmation)
- The data could legitimately differ (e.g., current address vs. new address)

Common violations: email re-entered on step 3; billing name not pre-filled from shipping name.

## Plain Language Analysis

| Metric | Target |
|--------|--------|
| Sentence length | <=25 words; aim for 15-20 |
| Voice | Active preferred |
| Double negatives | Zero tolerance |
| Consistent terminology | Same term for same concept throughout |

### Error Message Quality Rubric (0-3 per dimension)

| Dimension | Pass Threshold |
|-----------|---------------|
| Identification - names the field and problem | Score >= 2 |
| Solution - specific guidance or example | Score >= 1 |

 Fail: `"Invalid input."` - no field, no cause, no fix  
 Pass: `"Email must include @ - for example, name@company.com"`

## Reading Level Formula

$$GL = 0.39 \times \frac{W}{S} + 11.8 \times \frac{Sy}{W} - 15.59$$

Where $W$ = words, $S$ = sentences, $Sy$ = syllables. Targets: general consumer <= Grade 8; government <= Grade 6; healthcare <= Grade 6.

## Severity of Cognitive Findings

| Finding | Severity |
|---------|---------|
| 3.3.8 violation (paste disabled / CAPTCHA only) | Critical |
| 3.3.7 violation (redundant required re-entry) | High |
| 2.2.1 violation (no timeout warning) | High |
| Reading level > Grade 10 (non-technical) | High |
| Error message with no correction guidance | High |
| Inconsistent terminology in same flow | Medium |
| Missing progress indicator in multi-step | Medium |

## Skill Location

`.github/skills/cognitive-accessibility/SKILL.md`
