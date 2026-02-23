# Skill: Cognitive Accessibility

**Domain:** Cognitive, learning, and neurological accessibility  
**WCAG scope:** WCAG 2.2 AA + key AAA, COGA W3C guidance  
**Agents that use this skill:** `cognitive-accessibility`, `web-accessibility-wizard`, `accessibility-lead`, `forms-specialist`

---

## Purpose

This skill provides reference tables, scoring formulas, and evaluation patterns for cognitive accessibility review. It covers:

- WCAG 2.2 success criteria with cognitive accessibility relevance
- COGA (Cognitive Accessibility) W3C guidance mapping
- Plain language analysis techniques
- Reading level computation
- Authentication pattern analysis (3.3.8 / 3.3.9)
- Redundant entry detection (3.3.7)
- Timeout and session management analysis

---

## WCAG 2.2 Cognitive Accessibility Criteria Reference

### Level A

| SC | Name | What to Check | Common Failures |
|----|------|--------------|-----------------|
| 2.2.1 | Timing Adjustable | Session timeouts warn >=20s before expiry; user can extend >=10x or disable | Redirect without warning; extension UI exists but does nothing |
| 2.2.2 | Pause, Stop, Hide | Auto-moving/blinking content >5s has pause/stop control | Blinking backgrounds, marquee text, auto-scrolling feeds |
| 2.3.1 | Three Flashes | No content flashes >3 Hz (absolute) | Transition animations that strobe |
| 3.3.1 | Error Identification | Error identified in text, not just color | Red border with no error message |
| 3.3.2 | Labels or Instructions | Format requirements shown *before* error, required fields identified upfront | Format hint only in error state; asterisks with no legend |
| 3.3.7 | Redundant Entry *(2.2 new)* | Previously-entered info not re-requested in same session unless security-essential or stale | Email re-entered on step 3; billing address not pre-filled from shipping |

### Level AA

| SC | Name | What to Check | Common Failures |
|----|------|--------------|-----------------|
| 2.4.6 | Headings and Labels | Headings describe content; labels describe input purpose | "Section 1", "Info", "Details" as heading text |
| 3.2.3 | Consistent Navigation | Nav appears in same relative order across pages | Footer nav changes order on mobile vs desktop |
| 3.2.4 | Consistent Identification | Same-function components have same accessible name across pages | "Search" button on one page, "Find" on another |
| 3.3.3 | Error Suggestion | For detected errors, suggest correction when possible/safe | "Invalid email" with no example or format hint |
| 3.3.4 | Error Prevention (Legal, Financial) | Review step before irreversible submission; allow reversal or confirmation | One-click purchase with no review screen; no undo for account deletion |
| 3.3.8 | Accessible Authentication Min. *(2.2 new)* | Authentication must not require cognitive function test unless an alternative exists | `autocomplete="off"` on login forms; paste disabled in password fields; transcription-only CAPTCHA |

### Level AAA (Advisory - Review and Report)

| SC | Name | What to Check |
|----|------|--------------|
| 2.2.6 | Timeouts | Warn about data loss from inactivity at start of session |
| 3.1.3 | Unusual Words | Jargon/idiom defined on first use |
| 3.1.4 | Abbreviations | Abbreviations expanded on first use |
| 3.1.5 | Reading Level | General content <= Grade 8; see formula below |
| 3.3.9 | Accessible Authentication Enhanced *(2.2 new)* | No cognitive function test _at all_ (removes the object-recognition exception) |

---

## Authentication Pattern Analysis (3.3.8 / 3.3.9)

### Failing Patterns

| Pattern | Failure | SC |
|---------|---------|-----|
| `autocomplete="off"` on `type="password"` | Blocks password manager paste | 3.3.8 |
| JavaScript `onpaste="return false"` on password input | Blocks manual paste | 3.3.8 |
| CAPTCHA with only distorted text option | No cognitive-free alternative | 3.3.8 |
| Security question requiring exact recall | Pure memory test | 3.3.8 |
| Re-entering full card number on the same session order flow | Redundant cognitive work | 3.3.7 |

### Passing Patterns

| Pattern | Why It Passes |
|---------|--------------|
| `<input type="password" autocomplete="current-password">` | Allows password manager autofill |
| Passkey/biometric as login alternative | No cognitive function test |
| "Same as shipping address" checkbox on billing form | Eliminates redundant entry |
| CAPTCHA with audio alternative | Provides non-visual option |
| Email magic link with no password required | Removes cognitive test entirely |

---

## Redundant Entry Patterns (3.3.7)

### Detection Checklist

In multi-step forms or wizards:

1. Map all input fields across all steps
2. Flag any field that requests information already collected in an earlier step
3. Exception: security confirmation (password confirm) and data that can become stale (current vs. new address)

### Common Violations

| Step 1 Collects | Step 3 Also Asks | Violation? |
|----------------|-----------------|-----------|
| Email address | Email for confirmation | Yes - unless security-essential |
| Full name | Billing name | Yes - should pre-fill |
| Shipping address | Billing address | Yes - should offer "same as shipping" |
| Date of birth | DOB for age verification | Yes - same session, same data |
| Password | Password confirm | No - security essential |
| Current address | New address (for change) | No - intentionally different |

---

## Plain Language Analysis

### Sentence Analysis

Evaluate all instructional text, error messages, button labels, and tooltip copy.

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Sentence length | <= 25 words; aim for 15-20 | Count words between periods/question marks |
| Voice | Active preferred | Flag: "was submitted", "is required to be", "will be shown" |
| Double negatives | Zero tolerance | Flag: "not unable", "not required to not", "not without" |
| Jargon | Flag or define | Unexpanded acronyms, technical terms, domain-specific language |
| Consistent terminology | Same term for same concept | Flag: "sign in" + "log in" on same page/flow |

### Error Message Quality Rubric

Score each error message 0-3 on each dimension:

| Dimension | 0 | 1 | 2 | 3 |
|-----------|---|---|---|---|
| **Identification** | No message | Generic ("Error occurred") | Names the field | Names the field and exact problem |
| **Cause** | Absent | Vague | Partial | Full explanation |
| **Solution** | Absent | Vague hint | General guidance | Specific example or format |
| **Tone** | Blame ("You entered...wrong") | Neutral | Neutral + helpful | Supportive and constructive |

**Minimum score to pass:** 2 on Identification, 1 on Solution.

### Error Message Examples

| Rating | Error Text |
|--------|-----------|
|  Fail | "Invalid input." |
|  Fail | "You entered the wrong password." |
|  Marginal | "Password is incorrect." |
|  Pass | "The password doesn't match. Passwords are case-sensitive - check Caps Lock and try again." |
|  Pass | "Email must include @ - for example, name@company.com" |

---

## Reading Level Computation

### Flesch-Kincaid Grade Level Formula

$$GL = 0.39 \times \frac{W}{S} + 11.8 \times \frac{Sy}{W} - 15.59$$

Where:
- $W$ = total words
- $S$ = total sentences
- $Sy$ = total syllables

**Syllable counting rules:**
- Count each vowel cluster (a, e, i, o, u) as one syllable
- Subtract one syllable for silent trailing *e* ("made" = 1, "make" = 1)
- Each word has at least 1 syllable

### Grade Level Targets

| Content Type | Target GL | Rationale |
|-------------|-----------|-----------|
| Consumer web app (general) | <= 8 | ~50% of US adults read at Grade 8 or below |
| Government / public services | <= 6 | Plain language mandate standard |
| Healthcare patient-facing | <= 6 | Low health literacy is common |
| Legal terms of service | <= 10 with plain-language summary | Complex by nature, but summary required |
| Technical developer docs | <= 12 | Expert audience acceptable |

### Quick-Estimate Method (when full computation is impractical)

Flag content for reading level review when:
- Any single sentence exceeds 35 words
- More than 30% of words exceed 3 syllables in a paragraph
- 3 or more Latin abbreviations in a single page ("i.e.", "e.g.", "et al.", "viz.")

---

## Timeout Warning Requirements (2.2.1)

### Detection Pattern

1. Identify any page or application state with session persistence (authenticated areas, multi-step forms with temporary state)
2. Check for: activity monitoring, session expiry timers, auto-logout functionality
3. Verify warning mechanism exists when found

### Compliant Implementation Pattern

```javascript
// PASS: Session warning with extension option
const SESSION_TIMEOUT_MS = 15 * 60 * 1000; // 15 minutes
const WARNING_BEFORE_MS = 2 * 60 * 1000;   // Warn 2 minutes before

let warningShown = false;

sessionTimer = setTimeout(() => {
  if (!warningShown) {
    warningShown = true;
    showSessionWarning({
      message: "Your session will expire in 2 minutes due to inactivity.",
      extendLabel: "Stay signed in",
      logoutLabel: "Sign out now",
      onExtend: () => { resetTimer(); warningShown = false; },
      onLogout: () => endSession()
    });
  }
}, SESSION_TIMEOUT_MS - WARNING_BEFORE_MS);
```

### ARIA for Session Warning

```html
<div role="alertdialog" aria-modal="true" aria-labelledby="session-title" aria-describedby="session-desc">
  <h2 id="session-title">Session expiring</h2>
  <p id="session-desc">Your session will expire in <span id="session-countdown">2:00</span> minutes.</p>
  <button type="button" id="extend-btn" autofocus>Stay signed in</button>
  <button type="button">Sign out</button>
</div>
```

---

## COGA Guidance Mapping

### Making Content Usable - Key Objectives

From the W3C COGA "Making Content Usable for People with Cognitive and Learning Disabilities" guidance:

| Objective | What to Check | Severity |
|-----------|--------------|----------|
| Use a clear and understandable writing style | Reading level, plain language, sentence structure | High |
| Avoid creating excessive cognitive load | Step count in forms, memory demands, auto-advancing content | High |
| Provide reminders and feedback | Confirmation messages, progress indicators ("Step 2 of 4"), success confirmation | Medium |
| Help users avoid mistakes and recover from them | Validation before submit, undo capability, confirm destructive actions | High |
| Make forms easy to fill out | Pre-populate known data, stepwise format, visible format hints | High |
| Use a consistent and predictable layout | Navigation location, interactive element behavior, icon consistency | Medium |
| Use familiar icons and symbols | Standard iconography, labeled icons, no icon-only navigation | Medium |
| Avoid distorting a person's view of reality | No fake urgency timers, no dark patterns | High |

### Severity Assessment for COGA Findings

| Finding Type | Severity | Rationale |
|-------------|----------|-----------|
| 3.3.8 violation (paste disabled / CAPTCHA only) | Critical | Completely blocks authentication for many users |
| 3.3.7 violation (required re-entry of existing data) | High | Significant burden; causes abandonment |
| 2.2.1 violation (no timeout warning) | High | Data loss and user confusion |
| Reading level > Grade 10 (non-technical) | High | Excludes ~20% of adults |
| Error message with no correction guidance | High | Users cannot self-recover |
| Poor error message tone (blame language) | Medium | Anxiety increase; may cause abandonment |
| Inconsistent terminology across same flow | Medium | Confusion; increased cognitive load |
| Missing progress indicator in multi-step | Medium | User cannot gauge effort remaining |
| Reading level Grade 9-10 (general content) | Medium | Partial barrier |
| Jargon without definition | Low-Medium | Depends on density |
| Missing confirmation of success | Low | Uncertainty about whether action completed |

---

## Integration Notes

### When Used by web-accessibility-wizard

The wizard invokes `cognitive-accessibility` as part of Phase 3 (Forms and Input) and Phase 5 (Dynamic Content). Specifically:
- Phase 3: delegates 3.3.7 and 3.3.8 detection + error message quality to this skill
- Phase 5: delegates timeout warning detection to this skill

### When Used Standalone

`cognitive-accessibility` agent loads this skill and applies the full Phase 2 + Phase 3 assessment independently. It accepts page URLs, component files, or plain text content blocks.

### Handoffs from this Skill

- Form validation specifics -> `forms-specialist`
- ARIA state for error announcements -> `aria-specialist`  
- Live region for timeout warnings -> `live-region-controller`
- WCAG criterion explanations -> `wcag-guide`
