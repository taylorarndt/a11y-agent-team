# Code Review Standards

Shared reference for code review quality across all agents. Import this from any agent that performs code review.

---

## Comment Priority Levels

Use these levels when flagging issues in code reviews:

| Level | Label | Meaning | Merge? |
|-------|-------|---------|--------|
| **Critical** | `CRITICAL` | Bug, security flaw, data loss risk, broken logic. Must be fixed. | Block -- do not merge |
| **Important** | `IMPORTANT` | Significant improvement needed -- missing edge case, poor error handling, naming confusion. Should be fixed. | Prefer fix before merge |
| **Suggestion** | `SUGGESTION` | Nice-to-have improvement -- readability, minor optimization, style preference. Author decides. | OK to merge as-is |
| **Nitpick** | `NIT` | Purely cosmetic or trivial -- typo, whitespace, minor naming. Don't block for these. | OK to merge as-is |
| **Praise** | `PRAISE` | Something well done -- clever solution, good test coverage, clean architecture. Always include at least one. | OK to merge |

**Format review comments as:**
```text
CRITICAL: {description}

{explanation with code reference}

**Suggested fix:**
```suggestion
{code}
```
```text

---

## Community Sentiment in Reviews

When reviewing a PR, consider community reactions as a signal:

| Sentiment | Reactions | Review Implication |
|-----------|-----------|-------------------|
| **Popular** | 5+ positive reactions on PR description | Community endorses this change -- prioritize review, look for quick approval path |
| **Controversial** | Mixed positive and negative reactions | Extra scrutiny needed -- check discussions for concerns raised |
| **Quiet** | 0-1 reactions | Normal review -- follow standard checklist |

**When writing review comments:**
- If the PR has high community interest, note it: _"This PR has significant community interest (N reactions). Prioritizing a thorough but timely review."_
- If specific comments from community members (non-maintainers) raise valid concerns in reactions, acknowledge them.

---

## Release Context in Reviews

When a PR is targeted for an upcoming release:

| Context | Review Guidance |
|---------|----------------|
| **Release-bound** (PR in release milestone) | Focus on blocking issues only. Defer SUGGESTION and NIT items to follow-up. Note the release deadline. |
| **Post-release** (no milestone pressure) | Full review depth -- all priority levels apply. |
| **Hotfix** (targets a release/hotfix branch) | Maximum scrutiny on scope -- ensure minimal changes. Flag any feature creep. |

---

## Review Checklist Categories

### 1. Correctness
- [ ] Logic handles all expected inputs and edge cases
- [ ] Error conditions are caught and handled gracefully
- [ ] No off-by-one errors, null dereferences, or race conditions
- [ ] State mutations are intentional and well-scoped

### 2. Security
- [ ] No secrets, tokens, or API keys in code
- [ ] User input is validated and sanitized
- [ ] Authentication/authorization checks are correct
- [ ] SQL/NoSQL injection, XSS, CSRF protections where applicable
- [ ] Sensitive data is not logged

### 3. Performance
- [ ] No N+1 queries or unbounded iterations
- [ ] Large data sets are paginated or streamed
- [ ] Expensive operations are cached where appropriate
- [ ] No unintentional re-renders or redundant computations

### 4. Architecture & Design
- [ ] Changes follow existing codebase patterns and conventions
- [ ] No unnecessary coupling between modules
- [ ] Public API surfaces are minimal and well-defined
- [ ] Breaking changes are documented and versioned

### 5. Testing
- [ ] New functionality has test coverage
- [ ] Edge cases and error paths are tested
- [ ] Tests are deterministic (no time dependencies, no flaky assertions)
- [ ] Test names describe the scenario being validated

### 6. Documentation
- [ ] Public APIs have doc comments
- [ ] Complex logic has inline comments explaining "why" (not "what")
- [ ] README or docs updated for user-facing changes
- [ ] Breaking changes noted in changelog if applicable

### 7. Dependencies
- [ ] New dependencies are justified and vetted
- [ ] No known vulnerabilities in added packages
- [ ] License compatibility verified
- [ ] Lock file is updated consistently

### 8. Accessibility (for UI changes)
- [ ] Keyboard navigation works for all new interactive elements
- [ ] ARIA attributes are correct and follow WAI-ARIA patterns
- [ ] Color is not the sole means of conveying information
- [ ] Focus management is correct (no trapped focus, logical order)
- [ ] Screen reader announcements are appropriate (tested or reviewed)
- [ ] Contrast ratios meet WCAG AA standards

---

## Risk Assessment Matrix

| Factor | High Risk | Medium Risk | Low Risk |
|--------|-----------|-------------|----------|
| **Scope** | Core business logic, auth, payments | Shared utilities, API contracts | Tests, docs, config |
| **Blast radius** | Many consumers depend on changed code | Some consumers | Self-contained |
| **Reversibility** | Database migrations, public API changes | Feature flags available | Easily rolled back |
| **Complexity** | Large single-file changes, complex algorithms | Moderate changes | Small, isolated changes |
| **Test coverage** | No tests for changed code | Partial coverage | Full coverage |
| **Community interest** | High reaction count (5+), controversial | Moderate reactions | Quiet |
| **Release pressure** | In current release milestone | Next milestone | No milestone |

---

## Review Verdicts

| Verdict | When to Use | GitHub Action |
|---------|-------------|---------------|
| **Approve** | No critical/important findings. Suggestions are optional. | `APPROVE` |
| **Request Changes** | At least one CRITICAL or multiple IMPORTANT findings. | `REQUEST_CHANGES` |
| **Comment** | Observations and suggestions only. No blocking issues. | `COMMENT` |

**Rule of thumb:** If you wouldn't be comfortable with this code running in production as-is, request changes.

**Release context rule:** If the PR is release-bound and only has SUGGESTION/NIT findings, prefer Approve with comments rather than blocking the release.

---

## Review Etiquette

- **Be kind, be specific.** "This might cause a null reference on line 42 when X is empty" > "This is wrong."
- **Explain the why.** Don't just say what to change -- explain what risk or problem you're preventing.
- **Suggest, don't demand** (when it's a SUGGESTION). "Consider using X here for readability" > "Use X."
- **Acknowledge good work.** At least one PRAISE comment per review.
- **Ask questions when unsure.** "I'm not sure I follow this approach -- could you explain the reasoning?" is always valid.
- **Separate blocking from non-blocking.** Use the priority levels consistently so the author knows what must change vs. what's optional.
- **Acknowledge community input.** If community members have reacted or commented, reference their input when relevant.
- **Be mindful of release timelines.** If a PR is release-bound, clearly separate blocking issues from nice-to-haves.
