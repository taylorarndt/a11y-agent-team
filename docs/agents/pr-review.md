# pr-review - Code Review Command Center

> Pulls the complete picture of any pull request - full diff with dual line numbers, before/after file snapshots, developer comments, CI status, linked issues, reactions - and generates comprehensive review documents saved to your workspace. Fully operates from inside the editor: comment, suggest, approve, merge.

---

## What This Agent Is For

The pr-review agent replaces the browser-based PR review workflow entirely. Instead of navigating GitHub.com, switching between the diff view and the files view, copying line numbers into comments, and tracking review threads in your head, this agent pulls everything into your editor, lets you interact with it conversationally, and saves a structured review document you can annotate and reference later.

What sets it apart from a basic "show me the diff" request:

- **Dual line numbers** - every diff line shows both old and new line numbers so you can reference `L42` precisely
- **Before/after snapshots** - full side-by-side file comparison for significantly changed files
- **Confidence levels** - findings marked High / Medium / Low confidence so you know what to fix vs. investigate
- **Delta tracking** - run the same review after changes and immediately see what was Fixed, what is New, and what Persists
- **Intent annotations** - the agent reads commit messages and comments to explain *why* the developer made changes, not just what changed

Use pr-review when:

- You want a thorough code review without leaving VS Code
- You want to leave inline comments, range comments, or code suggestions on a PR
- You want to approve, request changes on, or merge a PR
- You want to see CI status, linked issues, and release context alongside the diff
- You want a saved review document to track findings across review rounds

---

## How to Launch It

### GitHub Copilot (VS Code)

```text
@pr-review owner/repo#42
@pr-review show PRs waiting for my review
@pr-review review the PR I need to merge today
```

### Claude Code (Terminal)

```bash
/pr-review owner/repo#42
/pr-review show my PR queue
/pr-review what PRs do I have open?
```

### Via GitHub Hub

```text
@github-hub review PRs
@github-hub what PRs are waiting on me?
```

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| `review PR #42` | Full review + saved document |
| `show PRs waiting for my review` | Your personal review queue |
| `my open PRs` | Status of PRs you authored |
| `diff of PR #42` | Show just the diff in chat |
| `comment on line 42 in auth.ts` | Add a line-specific inline comment |
| `comment on lines 10-20 in utils.ts` | Multi-line range comment |
| `suggest a fix for line 42` | Code suggestion block (GitHub-native suggestion format) |
| `explain line 42` | What does this code do and why? |
| `approve PR #42` | Submit an approving review |
| `request changes - missing null check on line 87` | Submit a changes-requested review with feedback |
| `merge PR #42` | Merge the pull request |
| `list CI checks for PR #42` | Show all check runs and pass/fail status |
| `react with  to PR #42` | Add a rocket/heart/thumbs-up reaction |

</details>

---

## What to Expect - Step by Step

### Full Review Mode

1. **Asset collection.** The agent pulls: PR metadata, complete diff, file list, commit history, all existing review comments and threads, linked issues, CI check runs, milestone/release context, and reactions. This is announced as it progresses.

2. **Diff display.** Every file in the diff is shown with dual line numbers (old | new), hunk headers, and intent annotations for significant changes.

3. **Risk flags.** The agent highlights files that touch security-sensitive areas (auth, crypto, permissions, tokens), dependency changes, configuration updates, and test coverage gaps.

4. **Findings report.** Issues found are presented with severity (Critical / Major / Minor), confidence level (High / Medium / Low), the specific location (file + line), a description, and a suggested fix.

5. **Document saved.** A `PR-REVIEW-{repo}-{number}.md` and `.html` file are written to your workspace with the full review package.

6. **Interactive options.** The agent offers next steps: leave comments, submit the review formally, view linked issues, check CI details.

### Queue Mode

For "show my PR queue," you get:

- A table of all PRs assigned for your review, sorted by urgency (oldest first, then by labels like `urgent`)
- Draft PRs you own and their review status
- PRs where you are awaiting a re-review after requesting changes
- Stale PRs (open >7 days) flagged separately

---

## Viewing and Navigating Diffs

Every diff the agent displays shows dual line numbers:

```text
  L42 | L38 |   function authenticate(user, password) {
  L43 | L39 |     const hash = sha256(password)   // intent: migrate from md5
  L44 |     | -   return hash === user.passwordHash
      | L40 | +   return timingSafeEqual(hash, user.passwordHash)
  L45 | L41 |   }
```

You can reference any line by number in follow-up messages:

- `"explain line 40"` - describes the change and its purpose
- `"comment on line 40 - this should use bcrypt instead"` - adds the comment to GitHub
- `"suggest a fix at line 40"` - generates a GitHub-native code suggestion block

---

## Confidence Levels

Every finding in a review document is tagged with a confidence level:

<details>
<summary>Expand confidence level reference</summary>

| Level | Meaning |
|-------|---------|
| **High** | Definite issue - fix before merging |
| **Medium** | Likely issue - investigate and confirm |
| **Low** | Possible concern - review at discretion |

Confidence drops when: the issue depends on runtime behavior the agent cannot see, the pattern could be intentional, or there is insufficient context in the diff.

</details>

---

## Delta Tracking

Run the same review command after the developer pushes updates to see:

<details>
<summary>Expand delta tracking example</summary>

```text
## Changes Since Last Review

 Fixed (2): Null check on line 87, missing error boundary
 Persistent (1): No test coverage for the new auth path
 New (1): Unused import added in utils.ts
```

Delta tracking compares the current scan against the previous review document saved in your workspace.

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Review Flows

```text
@pr-review review community-access/accessibility-agents#143
@pr-review show me the diff for PR #143
@pr-review full review with action items for PR #143
@pr-review what has changed since my last review of PR #143
```

### Comment and Suggest

```text
@pr-review comment on line 42 in auth.ts - add input validation here
@pr-review comment on lines 15-22 in utils.ts - this logic duplicates what's in helpers.ts
@pr-review suggest a fix for the null check on line 87
@pr-review reply to the comment about the missing error handling
```

### Review Submission

```text
@pr-review approve PR #143
@pr-review request changes on PR #143 - missing unit tests for the auth module
@pr-review submit my pending review on PR #143
@pr-review merge PR #143 with squash
```

### Queue and Discovery

```text
@pr-review show PRs waiting for my review
@pr-review my open PRs
@pr-review PRs I need to update based on feedback
@pr-review PRs older than 5 days that are still open
```

</details>

---

## Output Files

<details>
<summary>Expand output file details</summary>

| File | Location | Contents |
|------|----------|----------|
| `PR-REVIEW-{repo}-{number}.md` | workspace root | Full review: diff summary, findings, action items, CI status |
| `PR-REVIEW-{repo}-{number}.html` | workspace root | Same content, screen reader optimized |

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Check related issues | Find issues linked to or related to this PR | [issue-tracker](issue-tracker.md) |
| Add to daily briefing | Include PR review results in tomorrow's briefing | [daily-briefing](daily-briefing.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Never posts a review comment to GitHub without showing you a preview first
- Never merges without an explicit "merge PR #X" command - will not infer merge intent from "looks good"
- Dual line numbers are always present in diffs - never omits them
- Confidence levels are always present on findings - never omits them
- HTML output meets WCAG AA: proper heading structure, table headers, skip navigation, landmark regions
- Will not approve a PR with unresolved High-confidence findings without explicitly flagging the conflict

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"The agent cannot find the PR."**
Provide `owner/repo#number` explicitly. If you are in the workspace repo, just `#number` works. Check that you are authenticated to the org with `gh auth status`.

**"Diff shows no line numbers."**
This can happen when the diff is very large. Ask for a specific file: `"show me the diff for auth.ts in PR #42"`.

**"My comment was posted but I wanted to preview it first."**
The agent always previews before posting. If the comment went directly, check if you sent a message that included explicit post language ("post this comment"). Use "draft comment on..." to ensure preview mode.

</details>
