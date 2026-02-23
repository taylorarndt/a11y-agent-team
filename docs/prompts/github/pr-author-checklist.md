# pr-author-checklist

Run a pre-submit readiness checklist against any pull request. The agent scores the PR on 15 dimensions - description quality, CI status, diff size, test coverage, reviewer readiness, and more - before you request review.

## When to Use It

- Before clicking "Request review" on a PR you authored
- Teaching junior contributors what a good PR looks like
- Catching missing test coverage, vague descriptions, or CI failures before reviewers notice
- Getting an objective readiness score to decide if the PR is ready

## How to Launch It

**In GitHub Copilot Chat:**

```text
/pr-author-checklist owner/repo#123
```

Or for the current branch:

```text
/pr-author-checklist
```

## What to Expect

1. **Fetch PR** - Reads description, diff, CI status, linked issues, and existing comments
2. **Score 15 dimensions** - Each area is graded pass / warning / fail
3. **Compute overall score** - 0-100 with an A-F grade
4. **Highlight blockers** - Any fails that should be resolved before requesting review
5. **Provide specific fixes** - For failing dimensions, the agent explains what to add or change

### Checklist Dimensions

| Dimension | What is checked |
|-----------|----------------|
| PR description | Has a purpose statement and explains the "why" |
| Linked issue | References at least one issue with `Closes #N` or `Fixes #N` |
| CI passing | All required checks are green |
| Diff size | Under 400 lines (warning at 300, fail above 600) |
| Test coverage | New code has corresponding test files |
| No debug code | No console.log, TODO, or debugging artifacts |
| No secret leaks | No hard-coded credentials or API keys |
| File scope | Changes stay within described scope |
| Breaking changes | Noted and migration path documented if any |
| Reviewer assignment | At least one reviewer assigned |
| Screenshots/demo | UI changes have screenshots |
| Changelog entry | If project uses changelog files |
| Commit message quality | Descriptive, follows project conventions |
| Self-review | Evidence of author's own review (comments, resolved todos) |
| Draft status | Not marked as draft if genuinely ready |

### Sample Output

```text
PR Readiness: owner/repo#123 - 78/100 (C+)

 Description - Clear purpose and context
 Linked issue - Closes #89
 CI - 1 check failing: unit-tests
  Diff size - 320 lines (approaching limit)
 No debug code
 Reviewer assigned

Action needed before requesting review:
  1. Fix unit-test failure in src/auth.test.ts:line 44
```

## Example Variations

```text
/pr-author-checklist                     # Current branch PR
/pr-author-checklist owner/repo#123     # Specific PR
/pr-author-checklist strict             # Treat warnings as failures
```

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [review-pr](review-pr.md) - full reviewer-perspective review
- [pr-comment](pr-comment.md) - add a specific comment to the PR
- [manage-pr](merge-pr.md) - merge when everything is ready
