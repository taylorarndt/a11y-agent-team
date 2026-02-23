# refine-issue

Improve an existing GitHub issue by adding acceptance criteria, technical considerations, edge cases, out-of-scope notes, and a testing strategy. Uses community discussion context to enrich the issue.

## When to Use It

- Preparing an issue for sprint planning by adding "done" criteria
- Turning a vague feature request into an implementable spec
- Adding technical notes so a developer can start without guesswork
- Documenting edge cases and exclusions before implementation begins

## How to Launch It

**In GitHub Copilot Chat:**

```text
/refine-issue owner/repo#89
```

## What to Expect

1. **Read full issue** - Fetches the issue body, all comments, and linked issues
2. **Extract intent** - Understands the core request from the title, description, and comments
3. **Generate refinements** - Writes structured additions to the issue
4. **Preview draft** - Shows all proposed additions before modifying anything
5. **Apply with confirmation** - Appends the refinements as a new comment or edits the issue body

### Refinements Added

| Section | What the agent writes |
|---------|----------------------|
| Acceptance criteria | "Given/When/Then" or checklist of done conditions |
| Technical considerations | Relevant parts of the codebase, dependencies, approach options |
| Edge cases | Inputs or conditions that may break the feature |
| Out of scope | Related ideas explicitly excluded from this issue |
| Testing strategy | What should be tested - unit, integration, manual, screen reader |

### Sample Output

```markdown
## Acceptance Criteria
- [ ] Login form submits exactly once per tap on mobile
- [ ] Behavior is consistent on iOS Safari, Chrome, Firefox for Android
- [ ] No duplicate network requests visible in DevTools

## Technical Considerations
- The form submit handler is in `src/components/LoginForm.tsx:88`
- Possible cause: `onSubmit` + `onClick` both firing due to implicit form nesting
- Consider `e.preventDefault()` audit

## Edge Cases
- Slow network - does the button disable between tap and response?
- Double-tap: is this a triggered animation issue?

## Out of Scope
- Desktop browser behavior (tracked in #44)
- Password autofill - separate issue

## Testing Strategy
- Manual: iOS Safari on iPhone 13+
- Automated: add test for duplicate submit prevention in LoginForm.test.tsx
```

### Community Context Integration

If the issue has discussion comments, the agent extracts:

- Workarounds contributors suggested
- Reproduction conditions identified by commenters
- Design decisions already agreed upon in the thread

## Example Variations

```text
/refine-issue owner/repo#89                 # Full refinement
/refine-issue #89 just acceptance criteria  # Only add AC
/refine-issue #89 just testing strategy     # Only add testing notes
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [create-issue](create-issue.md) - start a new issue from scratch
- [manage-issue](manage-issue.md) - update labels and assign after refining
- [triage](triage.md) - prioritize issues in bulk
