# address-comments

Track all review comments on your PR in one table, work through them systematically, and mark them resolved. The agent is release-context-aware — it flags which comments must be resolved before merging and which can be deferred.

## When to Use It

- After receiving a code review with multiple comments
- Working through reviewer feedback systematically
- Deciding which review comments are blocking vs. deferrable
- Confirming all required changes are resolved before re-requesting review

## How to Launch It

**In GitHub Copilot Chat:**
```
/address-comments owner/repo#123
```

Or for the current branch PR:
```
/address-comments
```

## What to Expect

1. **Fetch all comments** — Reads every review comment, inline comment, and review summary from the PR
2. **Build tracking table** — Each comment gets an ID, reviewer name, file/line, content snapshot, and status
3. **Classify resolution priority** — Blocking (must resolve before merge) vs. Deferrable (can address later)
4. **Walk comments sequentially** — Presents each one with suggested resolution or asks for your decision
5. **Mark resolved** — As you address each comment, the agent marks it done and updates the table

### Comment Status Tracking

| Status | Meaning |
|--------|---------|
| Open | Unaddressed |
| In progress | You have started a fix |
| Resolved | Fixed and marked done |
| Dismissed | Intentionally not addressed (with reason) |
| Deferred | Agreed to address in a follow-up PR |

### Blocking vs. Deferrable

The agent classifies each comment as:
- **Blocking** — CRITICAL or IMPORTANT priority, or reviewer explicitly said "must fix"
- **Deferrable** — SUGGESTION or NIT, or reviewer said "optional" or "nice to have"

If a linked milestone or release is near, the threshold shifts and more comments are marked blocking.

### Sample Tracking Table

```
# Review Comment Tracker — owner/repo#123

| ID | Reviewer | File | Priority | Status | Comment |
|----|----------|------|----------|--------|---------|
| 1  | alice    | src/auth.ts:47 | CRITICAL | Open | JWT secret fallback missing |
| 2  | alice    | src/routes.ts:22 | IMPORTANT | Open | Admin route needs role check |
| 3  | bob      | src/auth.ts:61 | NIT | Deferrable | Extract to constant |

Blocking: 2 | Deferrable: 1 | Resolved: 0
```

## Example Variations

```
/address-comments                         # Current branch PR
/address-comments owner/repo#123         # Specific PR
/address-comments blocking only          # Show only must-fix items
/address-comments mark 1 resolved        # Quick-resolve item by ID
```

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [review-pr](review-pr.md) — review a PR as a reviewer
- [pr-comment](pr-comment.md) — add a comment to a PR
- [merge-pr](merge-pr.md) — merge once all blocking comments are resolved
