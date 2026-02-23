# issue-tracker — GitHub Issue Command Center

> Find, triage, review, and respond to GitHub issues without leaving VS Code. Generates prioritized dashboards and full issue reports saved to your workspace. Handles the complete issue lifecycle: create, comment, label, assign, close, and file with reactions.

---

## What This Agent Is For

The issue-tracker agent is your full-service GitHub issues workplace. It replaces the GitHub.com issues tab with something smarter: it does not just list your issues, it *thinks* about them — deduplicates, cross-references linked PRs and discussions, scores priority, and tells you which ones are silently blocking other work.

Beyond reading issues, it handles the complete lifecycle:
- Create issues from scratch or templates
- Comment, reply to specific comments, and batch-reply across multiple issues
- Manage labels, assignees, milestones, and state
- Add reactions to build community engagement
- Generate VPAT-ready reports documenting your issue history

Use issue-tracker when:
- You want to triage a backlog and get a priority-sorted action list
- You want to deep-dive into a specific issue's full thread history
- You want to reply to issues or comments without leaving the editor
- You need to create a batch of issues from a list, an audit report, or a meeting
- You want to generate a report of your issue status for a stakeholder

---

## How to Launch It

### GitHub Copilot (VS Code)

```
@issue-tracker show my open issues
@issue-tracker triage my backlog
@issue-tracker deep dive into taylorarndt/a11y-agent-team#42
```

### Claude Code (Terminal)

```bash
/issue-tracker triage
/issue-tracker show what's assigned to me
/issue-tracker create issue from this bug report
```

### Via GitHub Hub

```
@github-hub triage issues
@github-hub show me my issue backlog
```

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| `my issues` / `what's open` | Search and display your issues |
| `triage` / `what needs attention` | Priority dashboard + document |
| `show me #42` | Full thread with every comment |
| `reply to #42 — I'll look at this Thursday` | Post a comment |
| `reply to @alice's comment on #42` | Reply to a specific existing comment |
| `create issue — users cannot tab into the date picker` | Create a new issue |
| `thumbs up #42` / `react to #42` | Add a reaction |
| `add label "bug" to #42` | Manage labels |
| `assign @alice to #42` | Assign the issue |
| `close #42 as resolved` | Close the issue |
| `weekly report of issues` | Generate a status document |
| `search critical-bugs` | Load a named saved search from preferences |

</details>

---

## What to Expect — Step by Step

### Triage Mode

1. **Scope detection.** The agent reads `preferences.md` to determine which repos to search and which label filters to apply. Defaults to all your repos for the last 30 days.

2. **Progress collection.**
   ```
   ⚙️ Searching issues across your repos…
   ✅ Found 38 open issues: 6 assigned to you, 12 @mentions, 20 to monitor
   ```

3. **Priority scoring.** Each issue is ranked using:
   - Days open (older = higher priority)
   - Label signals (`critical`, `blocker`, `regression` score up; `nice-to-have` scores down)
   - Reaction count (a11y community signal)
   - Comment velocity (active discussion = higher priority)
   - PR linkage (a linked open PR elevates the issue)

4. **Dashboard output.** A triage table is shown in chat and saved as a workspace document:

   | Priority | Issue | Age | Labels | Linked PRs |
   |----------|-------|-----|--------|-----------|
   | 🔴 Critical | #87 Focus lost after delete | 14d | `a11y`, `regression` | — |
   | 🟠 High | #64 Contrast fails on dark mode | 8d | `a11y`, `needs-fix` | #88 |

5. **Action prompts.** After the dashboard, the agent offers: "Reply to the top issue?" "Create tasks from this list?" "Add to tomorrow's briefing?"

### Deep Dive Mode

1. Pulls the complete issue thread: title, body, all comments, timeline events, linked PRs, linked discussions
2. Shows a structured summary: what the issue reports, what has been tried, what the current status is, who is waiting on whom
3. Drafts a response if you ask for one
4. Shows reaction summary so you can gauge community interest

### Create Mode

The agent guides you through creating a high-quality issue:
1. Asks for the repository (defaults to workspace repo)
2. Checks existing issues for duplicates before creating
3. Suggests labels based on the content
4. Recommends assignees based on the area of code
5. Previews the issue before posting

---

## Priority Scoring Explained

<details>
<summary>Expand priority scoring signals</summary>

The issue-tracker scores each issue on a 0–100 scale based on multiple signals:

| Signal | Weight | Notes |
|--------|--------|-------|
| Days open | High | Issues >30d flagged as stale |
| Critical/blocker label | High | Instant top-of-queue |
| Assigned to you | High | Always in your personal queue |
| @mentions | Medium | Your name in comments or body |
| Reaction count | Medium | Community weight indicator |
| Comment velocity (last 3d) | Medium | Fresh activity = likely needs response |
| Linked open PR | Medium | Elevates — someone is working on it |
| Milestone due date | High if <7d | Deadline pressure |
| `wontfix` / `duplicate` label | Negative | Demoted in triage |

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Discovery and Triage

```
@issue-tracker show my open issues from the last 2 weeks
@issue-tracker triage everything assigned to me
@issue-tracker what issues are blocking the next release?
@issue-tracker find all WCAG regression issues
@issue-tracker show issues with no response in 7+ days
```

### Deep Dives

```
@issue-tracker deep dive into #42
@issue-tracker show the full thread on the focus management issue
@issue-tracker what's the status of the contrast bug?
@issue-tracker summarize the discussion on #87
```

### Create and Manage

```
@issue-tracker create a bug: tabbing into the modal does not trap focus
@issue-tracker create 3 issues from this accessibility audit report
@issue-tracker close #42 as resolved — fixed in PR #88
@issue-tracker add label "needs-repro" to #64
@issue-tracker assign @alice to all unassigned critical issues
```

### Report Generation

```
@issue-tracker weekly report for the team meeting
@issue-tracker generate a status document for all open a11y issues
@issue-tracker show me a summary of issues closed this month
```

</details>

---

## Output Files

<details>
<summary>Expand output file details</summary>

| File | Location | Contents |
|------|----------|----------|
| `ISSUE-TRIAGE-{date}.md` | workspace root | Priority dashboard with all scored issues |
| `ISSUE-TRIAGE-{date}.html` | workspace root | Screen reader optimized version |
| `ISSUE-{repo}-{number}.md` | workspace root | Deep-dive report for a single issue |

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Review related PR | A PR is linked to the issue | [pr-review](pr-review.md) |
| Add to daily briefing | Include issue status in tomorrow's briefing | [daily-briefing](daily-briefing.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Never posts a comment without showing a preview first
- Always checks for duplicates before creating a new issue
- Label operations always show current labels before and after changes
- Close operations always confirm: "Close #42 as [reason]?" before acting
- Priority scores are always shown with the signals that drove the score — never a mystery number
- Searching "my issues" searches across all configured repos, not just the workspace repo

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"It only found issues in my current repo."**
Add a `preferences.md` with `repos.discovery: all` to search all your repos. Or say: "search all my repos for issues assigned to me."

**"It created a duplicate issue."**
The agent checks for duplicates before creating. If a duplicate passed through, it means the existing issue had different wording. Try: "search for existing issues about [topic] first, then create one if none exist."

**"I want to use a saved search filter."**
Define named searches in `preferences.md` under `search.saved_searches`. Then say: `search a11y-critical` and it will expand the filter automatically.

</details>
