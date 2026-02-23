# merge-pr

Merge a pull request after verifying it is ready. The agent checks approvals, CI status, and conflicts, suggests a merge strategy, and requires explicit confirmation before merging.

## When to Use It

- Merging a PR that has been approved and is CI-green
- Choosing the right merge strategy (squash vs. merge commit vs. rebase)
- Cleaning up the source branch after merge
- Triggering a planned merge at end of review

## How to Launch It

**In GitHub Copilot Chat:**
```
/merge-pr owner/repo#123
```

Or for the current branch PR:
```
/merge-pr
```

## What to Expect

1. **Readiness check** — Verifies approvals, CI status, and merge conflict state
2. **Strategy recommendation** — Suggests squash, merge commit, or rebase based on PR size and history
3. **Confirmation prompt** — Shows the proposed merge and asks for your explicit `yes` before proceeding
4. **Execute merge** — Merges the PR via the GitHub API
5. **Post-merge cleanup** — Optionally deletes the source branch

### Readiness Criteria

| Criterion | Required |
|-----------|---------|
| At least one approval | Yes (for protected branches) |
| All required CI checks passing | Yes |
| No unresolved merge conflicts | Yes |
| PR not in draft state | Yes |
| All requested reviews completed | Preferred (warning if any outstanding) |

If any required criterion fails, the agent explains the blocker and does **not** merge.

### Merge Strategy Selection

| Strategy | When recommended |
|----------|-----------------|
| Squash and merge | Feature branches with noisy commit history |
| Merge commit | Release branches, significant multi-commit PRs |
| Rebase and merge | Clean linear commits, author wrote good messages |

### Sample Flow

```
Merge readiness — owner/repo#123 "Add authentication":

  ✅ Approved by: alice (2 days ago)
  ✅ CI: all 3 checks passing
  ✅ No merge conflicts
  ✅ Not a draft

  Suggested strategy: Squash and merge
  (14 commits → 1 clean commit)

  Proceed with squash merge? (yes/no/change-strategy)
```

### Post-merge Cleanup

After a successful merge, the agent offers:
- Delete the source branch
- Close any linked issues with the merge
- Update the linked project board column

## Example Variations

```
/merge-pr                              # Detect from current branch
/merge-pr owner/repo#123              # Specific PR
/merge-pr owner/repo#123 squash       # Force squash strategy
/merge-pr owner/repo#123 no-delete    # Keep source branch after merge
```

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [review-pr](review-pr.md) — do a final review before merging
- [address-comments](address-comments.md) — resolve blocking comments first
- [manage-branches](manage-branches.md) — clean up branches after merge
- [pr-author-checklist](pr-author-checklist.md) — check readiness before requesting merge
