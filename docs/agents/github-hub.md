# github-hub - The GitHub Workflow Orchestrator

> Your intelligent front door to every GitHub agent. Describe what you want in plain English - however vague - and GitHub Hub discovers your repositories, understands your intent, and hands you off to exactly the right specialist with context already loaded. You never need to know which agent to call.

---

## What This Agent Is For

GitHub Hub is the entry point for all GitHub workflow operations. Its job is not to do GitHub work itself; its job is to understand *what you want*, help you *identify where to do it*, and then seamlessly route you to the right specialist so you land in context with zero friction.

Think of it as a brilliant colleague who has memorized every repo in your org, knows every team member, and whose only job is to make GitHub feel effortless. You say "help me deal with the PR backlog" and it already knows your repos, already knows who is waiting on you, and drops you into the `pr-review` agent with a pre-populated queue.

Use GitHub Hub when:

- You are not sure which agent you need
- You want to start a GitHub task without thinking about routing
- You want to discover your repos and orgs before diving in
- You want to do multiple things in one session (it holds context across the whole conversation)
- You are new to the GitHub Workflow team and want a guided experience

---

## How to Launch It

### GitHub Copilot (VS Code)

1. Open Copilot Chat: `Ctrl+Shift+I` (Windows/Linux) or `Cmd+Shift+I` (macOS)
2. Type `@github-hub` followed by your request, or just `@github-hub` alone
3. The agent greets you, discovers your repos, and gets to work

### Claude Code (Terminal)

```bash
/github-hub what needs my attention today?
/github-hub
# Or just: hello
```

You can also trigger it with a slash command from any conversation by typing `/github-hub`.

---

## Language That Works

GitHub Hub is built to understand plain English at every level of specificity. You do not need exact commands. Here are the kinds of phrases it understands perfectly:

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| "what should I work on?" | Pulls your personal queue: PR reviews, assigned issues, mentions |
| "morning standup" | Routes to daily-briefing for a full status report |
| "help me add someone to my team" | Routes to team-manager with org context loaded |
| "show me my repos" | Lists all your repos with status indicators |
| "review that PR from this morning" | Finds the most likely PR, asks you to confirm, routes to pr-review |
| "onboard a new developer" | Routes to team-manager with onboarding flow |
| "what's happening with auth?" | Searches across issues, PRs, and discussions for the auth topic |
| "I want to clean up stale branches" | Routes to repo-admin with a branch cleanup suggestion |
| "help me set up a new repo" | Routes to repo-manager with scaffolding wizard |
| "accessibility changes this week" | Routes to insiders-a11y-tracker |
| "who's overloaded on the team?" | Routes to analytics with load analysis |

</details>

---

## What to Expect - Step by Step

### First Invocation

When you first invoke `@github-hub` (with or without a message), this is what happens:

**Step 1 - Greeting and discovery.**
GitHub Hub checks if session context has been injected automatically by the SessionStart hook. If it has, it uses that context (your repo, branch, org, username) and skips API discovery. If not, it calls the GitHub API to detect your authenticated user and find your current workspace repo.

**Step 2 - Show your world.**
It presents a quick summary: your GitHub username, your org (if detected), and a list of repos you own or have access to. It shows which repos are active (recent pushes or issues).

**Step 3 - Ask what you want.**
If you sent a question with your invocation (e.g., `@github-hub what PRs need my review?`), it immediately starts working on the answer. If you just typed `@github-hub hello`, it presents a menu of common starting points with clickable options:

- Morning Briefing
- Review PRs
- Triage Issues
- Team Management
- Analytics & Insights
- Repository Setup

**Step 4 - Context lock.**
Once you pick a repo or org, the agent locks that context for the entire session. You can say "now look at the issues" without ever repeating which repo - it already knows.

**Step 5 - Handoff.**
When routing to a specialist, GitHub Hub passes the full context (repo, org, user, what you said, what it found) so the specialist agent starts with everything it needs.

### Returning Invocations

If you have already established context in the session, GitHub Hub resumes without re-discovery. It acts more like a quick menu: "What do you want to do next with `community-access/accessibility-agents`?"

---

## Core Capabilities

**Repository and Organization Discovery**
Shows all repos you own, have access to, or have recently interacted with. Can filter to a specific org, show starred repos, or scope to just the workspace repo. Detects org context from the opened project automatically.

**Plain English Intent Parsing**
Interprets any natural language request - vague, partial, or exploratory - and maps it to the right agent and action. If the intent is ambiguous, it asks one clarifying question (not five) with suggested clickable answers.

**Intelligent Context Memory**
Once you say "let's work on `my-project`," it remembers that for the entire conversation. You can switch tasks ("now let's look at the issues") without re-specifying the repo.

**Smart Handoffs**
When routing to a specialist, GitHub Hub populates the handoff with context so the receiving agent starts with everything it needs - no re-authentication, no re-discovery, no repeated questions.

**Cross-Agent Navigation**
After completing work in one agent, GitHub Hub can bring you back and route you somewhere new. "Done with PRs, now walk me through the issue backlog" - it routes smoothly.

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Starting Fresh

```text
@github-hub
@github-hub hi
@github-hub what needs my attention today?
@github-hub show me my repositories
@github-hub what's going on with my projects?
```

### Specific Routing

```text
@github-hub review the PR I got assigned this morning
@github-hub triage issues in community-access/accessibility-agents
@github-hub get me the team velocity for this month
@github-hub add alice to the frontend team
@github-hub set up branch protection on main
@github-hub I want to build an accessibility bug template
@github-hub check community health on my open source project
@github-hub scaffold a new repository for my API service
```

### Exploratory Queries

```text
@github-hub what should I work on first?
@github-hub what's behind on the team?
@github-hub anything security-related I should know about?
@github-hub who needs to review something from me?
@github-hub summarize what happened this week
```

</details>

---

## Connections to Other Agents

GitHub Hub connects to every specialist in the GitHub Workflow team:

<details>
<summary>Expand agent routing table</summary>

| Specialist | Triggered When |
|-----------|----------------|
| [daily-briefing](daily-briefing.md) | You want a full status overview |
| [pr-review](pr-review.md) | You want to review code or manage PRs |
| [issue-tracker](issue-tracker.md) | You want to find, triage, or respond to issues |
| [analytics](analytics.md) | You want velocity, health scores, or bottleneck data |
| [repo-admin](repo-admin.md) | You want to manage access, protection, or settings |
| [team-manager](team-manager.md) | You want to onboard, offboard, or manage org teams |
| [contributions-hub](contributions-hub.md) | You want to manage discussions or contributor health |
| [insiders-a11y-tracker](insiders-a11y-tracker.md) | You want accessibility change tracking |
| [template-builder](template-builder.md) | You want to create issue/PR/discussion templates |
| [repo-manager](repo-manager.md) | You want to scaffold or set up a repository |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Never re-asks for information that was already established in the session
- Never routes without first confirming the target repo when multiple repos are plausible
- Always shows the repo list before asking "which repo?" - never asks cold
- Asks one smart question at a time, never a list of questions
- Does not expose agent names or architecture details to the user ("I'll now use the repo-admin agent" - it won't say that)
- Trusts SessionStart hook-injected context and uses it without redundant API calls

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"I invoked `@github-hub` but it does not seem to know my repo."**
The SessionStart hook injects context automatically when you open VS Code in a project directory. If that did not fire, GitHub Hub will discover context by calling the GitHub API. If your repo is not detected, make sure you are authenticated (`gh auth status`) and the workspace folder is a git repository.

**"It routed me to the wrong agent."**
Tell it: "Actually I want to [X]." It will re-route immediately with no friction.

**"It keeps asking what repo I want."**
Once you name a repo, it locks context. If it keeps asking, that usually means the workspace repo is ambiguous (e.g., you have multiple `.git` remotes). Say "use `owner/repo`" once to lock it.

</details>
