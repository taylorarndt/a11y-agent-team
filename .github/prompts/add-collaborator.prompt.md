---
name: add-collaborator
description: "Add a user to a repository as a collaborator with a specified role (read, triage, write, maintain, or admin)"
agent: repo-admin
tools:
  - github/*
  - ask_questions
---

Add a GitHub user as a collaborator to a repository.

${input:target:Who and where -- e.g. '@alice to owner/my-repo as write', 'add bob to this repo as maintainer', or just a username to be prompted for the rest}

## Steps

1. Parse the username, repo, and desired role from the input.
   - If username is missing: ask for it.
   - If repo is missing: use the workspace repo as the default and confirm.
   - If role is missing: show the role options and ask (read / triage / write / maintain / admin).

2. Check whether the user is already a collaborator:
   - If yes: show their current role and ask if they want to change it.
   - If no: proceed.

3. Preview the action:
   ```text
   About to add @{username} to {owner}/{repo} as {role}.
   This will send them an invitation email.
   They'll need to accept before gaining access.
   ```

4. Confirm with the user before proceeding.

5. Add the collaborator and confirm:
   > Invitation sent to @{username} for {owner}/{repo} ({role}).

6. If the user is in an org and a team would be a better fit than direct collaborator access, suggest:
   > Note: If {owner} is an organization, consider adding @{username} to a team instead -- use `@team-manager` for that.

**Role guide (show if the user is unsure):**
| Role | Can push? | Can manage issues? | Can change settings? |
|------|-----------|--------------------|---------------------|
| Read | No | No | No |
| Triage | No | Yes | No |
| Write | Yes | Yes | No |
| Maintain | Yes | Yes | Partial |
| Admin | Yes | Yes | Full  |
