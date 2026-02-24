# contributions-hub - Community and Contributions Command Center

> Manage GitHub Discussions, monitor community health, track contributor activity, support first-time contributors, and generate community reports - all from VS Code. Every write action (posting, converting, closing) requires a preview and explicit confirmation.

---

## What This Agent Is For

The contributions-hub agent is your open source community operations center. It does the work that normally falls through the cracks: answering discussions before they go stale, welcoming first-time contributors warmly, spotting when your `good first issue` queue has run dry, and generating a monthly community health score you can actually act on.

This agent is for:

- **Maintainers** who want to keep discussions responsive without spending an hour in the GitHub UI
- **Team leads** who need a monthly community health report to share with stakeholders
- **Advocates** who want to make sure every first-time contributor gets a genuine welcome, not a generic bot reply
- **Community managers** who track contributor activity and want to know who is active, who is new, and who has gone quiet

The contributions-hub handles everything community-facing:

- List, create, summarize, respond to, and convert GitHub Discussions
- Score community health across repos (templates, code of conduct, label hygiene)
- Identify first-time contributors and draft personalized welcomes
- Clean up stale discussions with a human review at each step
- Generate structured community and contributor reports

**Tone principle:** Community work is relationship work. When this agent drafts replies or discussion responses, it is warm, specific, and grateful - never robotic.

---

## How to Launch It

### GitHub Copilot (VS Code)

```text
@contributions-hub show active discussions
@contributions-hub community health report
@contributions-hub who are my top contributors this month?
@contributions-hub welcome first-time contributors
```

### Claude Code (Terminal)

```bash
/contributions-hub show discussions
/contributions-hub community health check
/contributions-hub contributor insights
```

### Via GitHub Hub

```text
@github-hub community
@github-hub discussions
@github-hub community health
```

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| `show discussions` / `active discussions` | List and prioritize open GitHub Discussions |
| `create a discussion` | Guided wizard to create a new discussion with draft assist |
| `summarize discussion #N` | Condense a long thread into key points, decisions, open questions |
| `convert discussion #N to issue` | Draft an issue from the discussion thread, link back |
| `community health` / `health report` | Score repo health (files, labels, response time) |
| `contributor insights` / `top contributors` | Leaderboard with first-time contributor highlights |
| `welcome first-time contributors` | Identify new contributors and draft personal welcomes |
| `stale discussions` / `cleanup` | Find and manage discussions with no recent activity |
| `unanswered Q&As` | Find Q&A discussions with no marked answer |
| `who has been inactive?` | Contributors not seen in the configured period |

</details>

---

## What to Expect - Step by Step

### Monitoring Discussions

1. **Scope.** Reads `preferences.md` for `community.discussion_categories` and the repos to scan. Defaults to workspace repo.

2. **Collection with progress:**

   ```text
    Scanning discussions across your repos…
    Found 14 open discussions - 3 unanswered Q&As, 2 high-activity threads, 4 stale
   ```

3. **Priority-sorted display:**

   | Priority | Discussion | Category | Activity |
   |----------|-----------|----------|---------|
   |  Hot | Feature: dark mode toggle | Ideas | 14 comments, 3h ago |
   |  Unanswered | How to configure PDF strict mode? | Q&A | 5 days, no answer |
   |  Stale | Anyone using the Excel scanner? | General | 34 days, no activity |

4. **Action prompts:** "Respond to the unanswered Q&A? Summarize the thread? Convert to issue?"

### Creating a Discussion

1. The agent asks guided questions: category, title, body description.
2. For Announcements, it warns that write access is required.
3. It drafts the full post body based on your description and shows a preview:

   ```text
   Draft for review:

   Title: [A11y Feature Proposal] Add live region support to scanner output
   Category: Ideas
   Body: [full draft shown here]

   Post as-is? [Yes / Edit / Change category / Cancel]
   ```

4. Only posts after explicit confirmation.

### Summarizing a Long Thread

For discussions with 20+ replies, the agent generates:

- Core question or proposal (2 sentences)
- Key points raised (attributed by @username)
- Any consensus or decisions reached
- Open questions that remain unresolved
- Suggested next step (close, convert to issue, post summary reply)

### Converting a Discussion to an Issue

1. Fetches the discussion thread
2. Drafts an issue title and body preserving the key context
3. Suggests labels based on the content
4. Previews the issue before creating
5. After creating, posts a comment on the original discussion linking to the new issue - so the thread is not a dead end

### Community Health Check

The agent scans for the presence and recency of health files, label hygiene, and contributor accessibility signals:

```text
 Scanning community health for community-access/accessibility-agents…
 Health score: 7/10
```

The report shows each file (present/missing/outdated), `good first issue` label status, average time to first response, and prioritized recommendations.

### Contributor Insights and First-Time Welcomes

1. Builds a leaderboard: PRs merged, issues filed, reviews given, comment count - per contributor
2. Identifies first-time contributors (no prior merged PR in the repo)
3. For each first-time contributor with an open PR or issue, drafts a personalized welcome message:

   ```text
   Welcome draft for @newcontributor's PR #43:

   Thanks for your first contribution, @newcontributor! 

   This change does exactly what the issue needed. I noticed you added tests
   for the edge case - that's exactly the right instinct.

   One small thing to check before we merge:
   - The import order on line 12 should follow the project convention (see CONTRIBUTING.md)

   Don't hesitate to ask questions. Really glad to have you here.

   Post this? [Yes / Edit / Cancel]
   ```

---

## Community Health Score

<details>
<summary>Expand community health scoring reference</summary>

The community health check scores your repo out of 10 across the following categories:

| Category | What it checks |
|----------|----------------|
| Documentation | README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, SUPPORT all present and updated within 1 year |
| Issue infrastructure | YAML issue templates plus `config.yml` chooser, PR template |
| Contributor accessibility | `good first issue` labels have 3+ open items; `help wanted` label in use |
| Response time | Median time to first response on issues and discussions |
| Label hygiene | Standard labels present with descriptions and colors |

Each category scores 0-2 points. Scores below 7/10 include prioritized action items.

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Discussion Management

```text
@contributions-hub show all open discussions
@contributions-hub unanswered Q&As - what needs a response?
@contributions-hub summarize the dark mode discussion thread
@contributions-hub convert discussion #23 to an issue
@contributions-hub create a discussion announcing our v2.0 release
```

### Community Health

```text
@contributions-hub community health report for this repo
@contributions-hub what health files am I missing?
@contributions-hub do I have enough good first issues?
@contributions-hub check my label hygiene across all repos
```

### Contributor Insights and Welcome

```text
@contributions-hub who are my top contributors this month?
@contributions-hub who made their first contribution this week?
@contributions-hub draft a welcome for @newcontributor's PR
@contributions-hub who has been inactive for more than 60 days?
```

### Stale Cleanup

```text
@contributions-hub find stale discussions
@contributions-hub show discussions with no activity in 30+ days
@contributions-hub close all answered Q&As older than 2 weeks
```

</details>

---

## Output Files

<details>
<summary>Expand output file details</summary>

| File | Location | Contents |
|------|----------|----------|
| `COMMUNITY-HEALTH-{repo}-{date}.md` | workspace root | Full health report with score and recommendations |
| `COMMUNITY-HEALTH-{repo}-{date}.html` | workspace root | Accessible HTML version |
| `CONTRIBUTORS-{date}.md` | workspace root | Contributor leaderboard and first-timer highlights |
| `DISCUSSION-{number}-SUMMARY.md` | workspace root | Thread summary for a specific discussion |

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Deep-dive an issue from a discussion | A community discussion surfaces a bug or request to track formally | [issue-tracker](issue-tracker.md) |
| Team analytics context | Compare community contributor activity to internal team velocity | [analytics](analytics.md) |
| Add to daily briefing | Include community health in tomorrow's digest | [daily-briefing](daily-briefing.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- **Never posts without confirmation** - all discussion replies, issue conversions, close actions, and welcome messages require a preview and explicit "yes" before posting
- **Never closes a discussion without showing it** - always displays the full discussion content before any close action
- **Community tone review** - when drafting replies, flags if tone could be perceived as dismissive or generic
- **Only public data** - contributor activity shown is limited to public GitHub events; no private data is surfaced
- **Draft welcomes are specific** - welcome messages reference something the contributor actually did, not a generic greeting
- **Stale cleanup is interactive** - never batch-closes stale discussions; shows each one and asks per-item

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"It only found discussions in my current repo."**
Add `repos.include` to `preferences.md` with a list of repos to monitor. Or say: "scan all my repos for open discussions."

**"The first-time contributor detection seems wrong."**
The agent determines first-time status by checking whether the contributor has had a previously merged PR in the repo. If they have commits but no merged PRs, they may appear as first-time contributors. You can override: "treat @username as an existing contributor."

**"A discussion I wanted to keep got marked stale."**
Stale detection requires no activity in `community.stale_days` (default 30). Adjust the threshold in `preferences.md` under `community.stale_days`. You can also exclude categories.

**"The health score seems low even though I have everything."**
The score checks *recency* of files too - documents not updated in over a year are flagged as outdated. Bump the `CONTRIBUTING.md` date or add a small update to reset the clock.

</details>
