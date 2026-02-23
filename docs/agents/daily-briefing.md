# daily-briefing - Your Morning GitHub Command Center

> Generates a comprehensive, prioritized briefing of everything happening across your GitHub repos - open issues, PR queue, CI status, security alerts, accessibility updates, releases, and community activity - in both markdown and HTML formats, saved to your workspace.

---

## What This Agent Is For

The daily-briefing agent is the first thing you open each morning (or afternoon, or whenever your workday starts). Its job is to replace the 15-minute tab-switching ritual of manually checking GitHub, Slack, and email for what needs your attention. It collects from up to nine data streams simultaneously and produces a single, prioritized briefing document that tells you:

- What is on fire (issues past SLA, blocking PRs, failed CI)
- What needs your response today (review requests, @mentions, assigned issues)
- What happened while you were away (merged PRs, closed issues, new releases)
- What the community is buzzing about (reactions, active discussions)
- What accessibility changes shipped in VS Code (if you track that)

You do not just read the briefing in chat - the agent saves a `.md` and `.html` file to your workspace so you can annotate it, share it on Slack, or reference it throughout the day.

Use daily-briefing when:

- You want to start the day with a full situational awareness snapshot
- You want a weekly summary before a team meeting
- You track multiple repositories and want everything in one place
- You want to generate a shareable status report for your team
- You want to delegate to sub-agents after the briefing (deep-dive into a specific issue or PR)

---

## How to Launch It

### GitHub Copilot (VS Code)

1. Open Copilot Chat: `Ctrl+Shift+I` (Windows/Linux) or `Cmd+Shift+I` (macOS)
2. Type your request:

   ```text
   @daily-briefing morning briefing
   @daily-briefing
   @daily-briefing what happened since yesterday?
   ```

### Claude Code (Terminal)

```bash
/daily-briefing morning briefing
/daily-briefing weekly report
/daily-briefing what needs my attention today?
```

### Via GitHub Hub

```text
@github-hub morning standup
@github-hub what's going on today?
```

GitHub Hub will route you automatically.

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it generates |
|-------------|-------------------|
| `morning briefing` | Last 24 hours, all repos |
| `weekly report` | Last 7 days, all repos |
| `what happened since yesterday` | Since yesterday 9 AM |
| `just PRs and issues` | Filtered to those two streams only |
| `briefing for taylorarndt/a11y-agent-team` | Scoped to that single repo |
| `what needs my attention?` | Only action-required items, no monitoring section |
| `full briefing` | All 9 streams, full detail |
| `quick briefing` | High-priority items only, terse format |

</details>

---

## What to Expect - Step by Step

Collecting a full briefing takes 30 to 60 seconds for large multi-repo scopes. The agent announces progress throughout so you always know what is happening.

**Step 1 - Scope detection.**
The agent checks for a SessionStart-injected context (your repos, org, username). If present, it reads your `preferences.md` to understand which repos to include, which to exclude, and what tracking settings to apply per repo. If no preference file exists, it defaults to searching across all repos you have access to.

**Step 2 - Stream collection.**
Nine streams are collected (those enabled by your preferences):

```text
 Collecting your daily briefing… (all repos, last 24h)

 Checking issues and @mentions… (1/9)
 Issues: 4 need your response, 7 to monitor

 Checking pull requests… (2/9)
 PRs: 2 need your review, 1 needs your update

 Checking CI/CD status… (3/9)
 CI: 1 failing workflow needs attention

 Checking security alerts… (4/9)
 Security: 2 Dependabot alerts, 1 high severity

 Checking discussions… (5/9)
 Discussions: 3 new, 1 awaiting your reply

 Checking releases… (6/9)
 Releases: 1 shipped yesterday, 1 coming next week

 Checking reactions and community pulse… (7/9)
 Community: feature request gaining traction (14 reactions)

 Checking accessibility updates… (8/9)
 A11y: 6 issues closed in VS Code Insiders this week

 Building reflection and recommendations… (9/9)
 Done.
```

**Step 3 - Report output.**
The agent generates:

- A `DAILY-BRIEFING-{DATE}.md` file in your workspace
- A `DAILY-BRIEFING-{DATE}.html` file (screen reader optimized with landmarks, skip links, and a11y-compliant structure)

**Step 4 - Handoffs.**
After the briefing is generated, the agent offers action paths. You can deep-dive into a specific issue or PR, pull up the full accessibility report, or view team analytics - all without re-invoking anything manually.

---

## Output Structure

Every briefing document follows this structure:

<details>
<summary>Expand briefing document structure</summary>

```text
# Daily Briefing - February 22, 2026

##  Needs Immediate Action
[Items that are blocking, failing, or past SLA]

##  Needs Your Response Today
[Review requests, @mentions, assigned items]

##  Status Overview
[Summary table: open issues, open PRs, CI status per repo]

##  What Changed
[Merged PRs, closed issues, new releases since last briefing]

##  Community Pulse
[Discussions, reactions, first-time contributors]

##  Accessibility Updates
[VS Code Insiders a11y changes + custom repo tracking]

##  Upcoming
[Milestones, planned releases, team schedule notes]

##  Reflections
[Patterns noticed, bottleneck flags, suggestions]
```

</details>

---

## Preferences Configuration

Create `.github/agents/preferences.md` in your workspace to control briefing behavior. See `preferences.example.md` for the full reference. Key options:

<details>
<summary>Expand preferences.md example</summary>

```markdown
## repos

discovery: all          # search all repos you can access
include:
  - taylorarndt/a11y-agent-team
  - taylorarndt/swift-agent-team
exclude:
  - taylorarndt/archived-project

## briefing

sections:
  - issues
  - pull_requests
  - ci_status
  - security_alerts
  - discussions
  - releases
  - community_pulse
  - accessibility_tracking
```

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Daily Use

```text
@daily-briefing morning briefing
@daily-briefing good morning
@daily-briefing what's up?
@daily-briefing show me what happened overnight
```

### Scoped Briefings

```text
@daily-briefing briefing for taylorarndt/a11y-agent-team only
@daily-briefing just show me PRs waiting for my review
@daily-briefing only show items that need action
@daily-briefing weekly summary for the team meeting
```

### Follow-Up Actions

```text
@daily-briefing deep dive into issue #142
@daily-briefing show me the full PR review for PR #87
@daily-briefing pull up accessibility updates in more detail
```

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Deep dive into issue | You want full context on an issue from the briefing | [issue-tracker](issue-tracker.md) |
| Full PR review | You want the complete code review of a PR from the briefing | [pr-review](pr-review.md) |
| Accessibility detail | You want more on VS Code a11y changes | [insiders-a11y-tracker](insiders-a11y-tracker.md) |
| Team analytics | You want velocity or health metrics | [analytics](analytics.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Always saves both `.md` and `.html` versions to the workspace - never chat-only
- HTML output is fully accessible: ARIA landmarks, skip navigation, proper heading hierarchy, high-contrast by default
- Prioritizes action-required items at the top; never buries urgent items under monitoring sections
- When tracking multiple repos, rounds up data in parallel - does not scan sequentially
- Respects `preferences.md` include/exclude lists and per-repo tracking granularity

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"The briefing only shows one repo."**
The agent defaults to the workspace repo if it cannot detect your full repo scope. Add a `preferences.md` with `discovery: all` or list explicit repos in `include`.

**"I do not see accessibility updates in my briefing."**
Add an `accessibility_tracking` section to `preferences.md`. The default tracks only `microsoft/vscode` - you can add your own repos there.

**"The HTML file looks fine in my browser but copilot shows it as text."**
Open the `.html` file directly in a browser. The HTML output is for sharing or screen reader testing, not for in-editor preview.

</details>
