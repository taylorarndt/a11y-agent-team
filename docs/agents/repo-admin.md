# repo-admin - Repository Access and Configuration Manager

> Add and remove collaborators, configure branch protection, audit who has access to what, sync labels across repos, and manage milestones - all without leaving VS Code. Every action is previewed before execution with an explicit confirmation step.

---

## What This Agent Is For

The repo-admin agent handles the administrative layer of a GitHub repository: who can do what, what rules protect important branches, and what the repository's shared vocabulary (labels, milestones) looks like.

This is the agent for when you need to:

- Onboard a new contractor or collaborator and give them exactly the right permission level - no more, no less
- Remove someone who has left the project from all repo access
- Set up branch protection so `main` cannot be force-pushed or merged without a passing CI check
- Audit all current collaborators across multiple repos (often eye-opening)
- Synchronize your label taxonomy so every repo uses the same set of labels
- Create or close milestones as a release cadence changes

**Every destructive or access-changing operation is previewed as a diff-style summary before the agent acts.** You always have the final say.

---

## How to Launch It

### GitHub Copilot (VS Code)

```text
@repo-admin add @alice to taylorarndt/a11y-agent-team as maintainer
@repo-admin audit access on all my repos
@repo-admin configure branch protection for main
@repo-admin sync labels from my template repo
```

### Claude Code (Terminal)

```bash
/repo-admin audit access
/repo-admin add collaborator
/repo-admin branch protection setup
```

### Via GitHub Hub

```text
@github-hub manage repo admin
@github-hub audit repository access
@github-hub add @alice as maintainer
```

---

## Permission Levels Explained

<details>
<summary>Expand permission level reference</summary>

Before using this agent, understand the five GitHub permission levels:

| Level | Can push code | Can manage PRs | Can manage releases | Can manage settings | Can add admins |
|-------|:---:|:---:|:---:|:---:|:---:|
| Read | - | - | - | - | - |
| Triage | - |  label/assign | - | - | - |
| Write |  |  |  | - | - |
| Maintain |  |  |  | Limited | - |
| Admin |  |  |  |  full |  |

**Principle of least privilege:** always start with the minimum level needed. Use `Read` for external reviewers, `Triage` for community moderators, `Write` for active contributors, `Maintain` for lead developers, `Admin` only for repo owners.

</details>

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| `add @alice as contributor` / `write access` | Grant Write permission |
| `add @bob as reviewer` | Grant Triage permission |
| `add @carol as maintainer` | Grant Maintain permission |
| `add @dave as admin` | Grant Admin (will require double confirmation) |
| `remove @alice from this repo` | Revoke all access |
| `audit access` | List every collaborator and their level |
| `audit all my repos` | Cross-repo access audit |
| `protect main` | Configure branch protection for `main` |
| `require PR reviews before merge` | Adds required-reviewers rule |
| `require status checks` | CI gate before merge |
| `sync labels` / `copy labels from template` | Label taxonomy sync |
| `create milestone v2.0` | Create a milestone with a due date |
| `close milestone v1.5` | Mark milestone closed |

</details>

---

## What to Expect - Step by Step

### Adding a Collaborator

1. You say: `@repo-admin add @alice to this repo as maintainer`

2. The agent identifies the repo (from workspace context or asks):

   ```text
    Looking up @alice on GitHub...
    Found user: alice (Alice Johnson)
    Target repo: taylorarndt/a11y-agent-team
   ```

3. Checks for existing access:

   ```text
   Current access: @alice has no access to this repo.
   ```

4. Previews the change:

   ```text
   Proposed change:
   + @alice -> Maintain (was: no access)
   
   This will allow @alice to push, manage PRs, releases, and limited settings.
   Confirm? (yes / no / change permission level)
   ```

5. Sends the invitation. GitHub sends @alice an email.

### Access Audit

1. You say: `@repo-admin audit access on all my repos`

2. Collects collaborators across all your repos:

   ```text
    Auditing 4 repositories...
    Loaded collaborators for taylorarndt/a11y-agent-team (6 collaborators)
    Loaded collaborators for taylorarndt/my-app (3 collaborators)
   ```

3. Generates an access matrix:

   | User | a11y-agent-team | my-app | Notes |
   |------|:---:|:---:|------|
   | @alice | Maintain | Write | Active contributor |
   | @bob | Read | - | Not in my-app |
   | @carol | Admin | Admin | Owner on both |
   | @dave | Write | - | Only in a11y-agent-team |

4. Flags anomalies:
   >  @dave has Write access to `a11y-agent-team` but is not in your team roster (preferences.md). Was this intentional?

### Branch Protection Setup

1. You say: `@repo-admin protect the main branch - require 2 PR reviews and CI to pass`

2. Shows current state:

   ```text
   Current branch protection for main: none
   ```

3. Previews the ruleset:

   ```text
   Proposed branch protection rules for main:
   + Require pull request before merging: YES
   + Required approvals: 2
   + Dismiss stale reviews on new commits: YES
   + Require status checks to pass: YES
   + Require branches to be up to date before merging: YES
   + Restrict who can push directly: (none - open to anyone with Write+)
   + Enforce above rules for administrators: NO (recommended: YES - add if you want)
   
   Confirm? (yes / no / adjust)
   ```

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Collaborator Management

```text
@repo-admin add @alice to this repo with write access
@repo-admin add @bob as a read-only reviewer
@repo-admin remove @dave from this repo
@repo-admin list all collaborators and their permission levels
@repo-admin audit access across all my repos - flag anything unusual
```

### Branch Protection

```text
@repo-admin protect main - require at least 1 PR review before merge
@repo-admin require CI to pass before any merge to main
@repo-admin block direct pushes to main for everyone including admins
@repo-admin show me the current branch protection rules
```

### Label Management

```text
@repo-admin sync labels from taylorarndt/label-template to all my repos
@repo-admin add label "a11y" with color #0e9f6e to this repo
@repo-admin delete the "wip" label from all repos
@repo-admin show me which labels are missing from my-app compared to a11y-agent-team
```

### Milestones

```text
@repo-admin create milestone v2.0 due December 31
@repo-admin list open milestones
@repo-admin close milestone v1.5
```

</details>

---

## Output Files

<details>
<summary>Expand output file details</summary>

| File | Location | Contents |
|------|----------|----------|
| `REPO-ACCESS-AUDIT-{date}.md` | workspace root | Full collaborator matrix |
| `REPO-ACCESS-AUDIT-{date}.html` | workspace root | Accessible HTML version |

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Manage org teams | After granting repo access, assign to a team | [team-manager](team-manager.md) |
| Add to daily briefing | Include access changes in morning digest | [daily-briefing](daily-briefing.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- **Every access change is previewed before execution** - never acts silently on access or settings
- Adding `Admin` permission requires a second explicit confirmation ("are you sure you want to grant full admin access?")
- Removing yourself from a repo is blocked - preventing accidental lockout
- Label sync is always shown as a diff before applying
- The agent never removes protection rules without showing what impact that has ("removing CI requirement means anyone can merge without a green build")

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"It says I don't have permission to set branch protection."**
Branch protection requires Admin access on the repo. Confirm you are an admin there. If the repo belongs to an org, you may need organization admin access for some settings.

**"The invitation was sent but @alice says they never got an email."**
Check the email address associated with their GitHub account. If the invite is pending, you can re-send: "show pending invitations for a11y-agent-team."

**"Label sync deleted labels I wanted to keep."**
Label sync is additive by default - it adds missing labels but does not delete. To delete, you must explicitly ask: "remove all labels not in the template."

</details>
