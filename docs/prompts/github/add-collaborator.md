# add-collaborator

Add a collaborator to a GitHub repository with the appropriate permission level. The agent checks if they are already a collaborator and suggests the right role - with a confirmation step before any action.

## When to Use It

- Inviting a new contributor to a repo
- Granting a contractor or external contributor access
- Upgrading a collaborator's permissions
- Checking who already has access before adding someone

## How to Launch It

**In GitHub Copilot Chat:**

```text
/add-collaborator owner/repo username role
```

Examples:

```text
/add-collaborator owner/repo alice write
/add-collaborator owner/repo bob read
/add-collaborator owner/repo charlie admin
```

## What to Expect

1. **Parse request** - Extracts repo, username, and requested role
2. **Check existing access** - Verifies if the user is already a collaborator
3. **Role guidance** - Confirms the role matches the intent with the role guide table
4. **Preview** - Shows what will be sent before acting
5. **Send invitation** - After confirmation, sends the GitHub collaboration invite

### Role Guide

| Role | What they can do |
|------|----------------|
| read | View and clone; comment on issues and PRs |
| triage | Read + label, assign, close issues/PRs |
| write | Triage + push to non-protected branches, manage releases |
| maintain | Write + manage repo settings (not destructive) |
| admin | Full access including destructive settings and collaborator management |

### Existing Collaborator Check

```text
Agent: alice is already a collaborator with "triage" access.
  You are requesting to upgrade to "write".
  
  Change alice's role from triage -> write? (yes/no)
```

### Org Team Suggestion

If the repo belongs to an organization with teams configured, the agent may suggest:

```text
Note: The "@myorg/contributors" team already has write access to this repo.
  Consider adding alice to that team instead of granting individual access.
```

### Sample Flow

```text
You: /add-collaborator owner/repo bob write

Agent: Checking bob's current access to owner/repo...
  bob is not a current collaborator.

  Role: write - push to non-protected branches, manage releases

  Send invitation to bob (write)? (yes/no)

You: yes

Agent: Invitation sent to bob. They will need to accept before access is granted.
```

## Example Variations

```text
/add-collaborator owner/repo alice read
/add-collaborator owner/repo alice write
/add-collaborator owner/repo alice admin
/add-collaborator owner/repo check alice    # Check current access only
```

## Connected Agents

| Agent | Role |
|-------|------|
| repo-admin agent | Executes this prompt |

## Related Prompts

- [onboard-repo](onboard-repo.md) - check repo health before adding contributors
- [manage-branches](manage-branches.md) - set branch protections after adding collaborators
