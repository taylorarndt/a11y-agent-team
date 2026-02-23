# team-manager — Organization Team and Membership Manager

> Create and configure GitHub org teams, add and remove members, sync access across repositories, and run complete onboarding and offboarding checklists — all with a principle of least privilege and confirmation before every change.

---

## What This Agent Is For

The team-manager agent handles the organizational layer above individual repo access: GitHub Teams within an organization. A GitHub Team is a named group (e.g., `frontend`, `accessibility-reviewers`, `release-managers`) that can be granted consistent access across multiple repos at once. Managing this through the GitHub UI requires many separate steps. This agent does it in one conversation.

Key operations:

- **Onboard a new team member** — add them to the right teams, grant correct repo access, welcome them in
- **Offboard a departing member** — remove them from all teams, revoke repo access, document what was removed
- **Create a new team** — describe the team's purpose and it scaffolds the GitHub team with the right repos
- **Sync access** — when a new repo is added, quickly grant all the right teams the right level of access
- **Generate a team report** — see which teams exist, who is in them, what repos they can access

This agent is for org admins and team leads who manage GitHub organization structure. For individual repo collaboration (adding a single person to a single repo), use [repo-admin](repo-admin.md) instead.

---

## How to Launch It

### GitHub Copilot (VS Code)

```
@team-manager add @alice to the frontend team
@team-manager onboard @newdev — they are joining backend
@team-manager offboard @alice — she is leaving the team
@team-manager create team "accessibility-reviewers"
@team-manager show all teams and members
```

### Claude Code (Terminal)

```bash
/team-manager onboard @newdev
/team-manager offboard @alice
/team-manager create team
```

### Via GitHub Hub

```
@github-hub team management
@github-hub onboard @newdev
@github-hub who is in the backend team?
```

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| `add @alice to backend team` | Add member to named team |
| `remove @alice from frontend team` | Remove from one team only |
| `onboard @newdev` | Full onboarding checklist |
| `offboard @alice` | Full offboarding checklist |
| `create team "reviewers"` | Scaffold a new GitHub team |
| `list all teams` | Show org teams with members |
| `list teams for @alice` | Show every team a user belongs to |
| `generate team report` | Full team health document |
| `sync access for new-repo` | Grant all relevant teams access to a new repo |
| `what can @alice access?` | Cross-repo permission summary for one user |

</details>

---

## What to Expect — Step by Step

### Full Onboarding

1. You say: `@team-manager onboard @newdev — joining the accessibility team with write access to a11y-agent-team`

2. The agent builds an onboarding checklist and previews it:

   ```
   Onboarding checklist for @newdev:
   
   [ ] Add to GitHub org (invitation)
   [ ] Add to team: accessibility-reviewers
   [ ] Grant Write access to: taylorarndt/a11y-agent-team
   [ ] Verify org membership is accepted
   [ ] Post welcome message in team discussion
   
   Confirm? (yes / adjust)
   ```

3. Executes each step in order, reporting status:
   ```
   ✅ Org invitation sent to @newdev
   ✅ Added to team: accessibility-reviewers
   ✅ Granted Write access to: taylorarndt/a11y-agent-team
   ⏳ Org membership pending acceptance (they must accept the email invitation)
   ```

4. Saves an onboarding record to your workspace with a checklist of what was done and what is pending.

### Full Offboarding

1. You say: `@team-manager offboard @alice — she is leaving the project`

2. The agent discovers all access first:
   ```
   ⚙️ Auditing @alice's access…
   ✅ Teams: accessibility-reviewers, frontend
   ✅ Direct repo collaborator: taylorarndt/my-other-repo (Maintain)
   ✅ Org membership: active
   ```

3. Builds and previews the offboarding checklist:

   ```
   Offboarding checklist for @alice:
   
   [ ] Remove from team: accessibility-reviewers
   [ ] Remove from team: frontend
   [ ] Remove direct collaborator access: taylorarndt/my-other-repo
   [ ] Revoke org membership
   
   ⚠️ After offboarding, @alice will have no access to any org resources.
   Are any items above incorrect? Confirm to proceed.
   ```

4. Executes each step and saves an offboarding record.

### Create a New Team

1. You say: `@team-manager create a team called "a11y-reviewers" with access to a11y-agent-team`

2. Asks for team visibility (visible to all org members / secret):
   ```
   Team visibility:
   (a) Visible — all org members can see this team
   (b) Secret — only team members and org owners can see it
   ```

3. Creates the team and grants it access to the specified repo:
   ```
   ✅ Team created: a11y-reviewers (visible)
   ✅ Granted Write access to: taylorarndt/a11y-agent-team
   ```

4. Asks: "Add any initial members?"

---

## Principle of Least Privilege — Built In

<details>
<summary>Expand least privilege defaults</summary>

The team-manager agent applies least-privilege defaults in every operation:

| Situation | Default permission | Why |
|-----------|-------------------|-|
| New contributor to a team | Write | Can push and manage PRs; cannot change settings |
| External reviewer | Read | Can read and comment; cannot push |
| Community moderator | Triage | Can label/assign; cannot push code |
| Release manager | Maintain | Can manage releases; limited settings |
| Org admin only | Admin | Only when explicitly required |

If you ask for a higher permission level, the agent notes the impact: "Granting Admin means @alice can manage repo settings, webhooks, and manage all collaborators. Is this required?"

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Basic Member Operations

```
@team-manager add @alice to the frontend team
@team-manager add @bob to all teams @alice is in
@team-manager remove @carol from the release-managers team
@team-manager what teams is @alice on?
@team-manager who is in the accessibility-reviewers team?
```

### Onboarding and Offboarding

```
@team-manager onboard @newdev — frontend team, write access to main repo
@team-manager offboard @alice completely — she is leaving today
@team-manager generate an onboarding record for @newdev
```

### Team Structure

```
@team-manager create team "qa-reviewers" with read access to all repos
@team-manager list all teams in the org
@team-manager generate a full team report
@team-manager sync access — grant qa-reviewers access to my new repo
```

</details>

---

## Output Files

<details>
<summary>Expand output file details</summary>

| File | Location | Contents |
|------|----------|----------|
| `ONBOARDING-{user}-{date}.md` | workspace root | Onboarding checklist and status |
| `OFFBOARDING-{user}-{date}.md` | workspace root | Offboarding record for audit trail |
| `TEAM-REPORT-{date}.md` | workspace root | Full org team structure |
| `TEAM-REPORT-{date}.html` | workspace root | Accessible HTML version |

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Repo-level access | Team access alone insufficient; direct repo collab needed | [repo-admin](repo-admin.md) |
| Add to daily briefing | Include onboarding status in morning digest | [daily-briefing](daily-briefing.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- **Offboarding always shows a full audit first** — the agent never removes access without first showing you everything it found
- **Org membership removal is the last step**, not the first, to prevent locking someone out of pending work items
- The agent cannot modify individual repo permission levels if they were granted through a GitHub Team — you must adjust the team's permission level instead
- If you are the only admin in the org, the agent will not remove you or demote your access — doing so would orphan the organization

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"I get an error when adding to a team."**
You must be an organization owner or team maintainer to add members. Confirm your org role: "what is my role in the org?"

**"@alice says she still has access after offboarding."**
Check if she is a Direct Collaborator (granted on a specific repo, outside of teams). The agent audits both teams and direct collaborators. After offboarding, run "audit access for @alice" to confirm everything is removed.

**"I want to manage a team I do not own."**
You can view any visible team. To modify, you need team Maintainer or org ownership. Ask the team owner to grant you team-maintainer status.

</details>
