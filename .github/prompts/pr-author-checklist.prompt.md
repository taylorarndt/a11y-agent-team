---
name: pr-author-checklist
description: "PR self-review checklist for authors -- CI status, reviewer suggestions, description quality check, and pre-submit verification"
agent: pr-review
tools:
  - github/*
  - readFile
  - textSearch
  - codebase
  - ask_questions
---

Run a pre-submit self-review checklist for a PR you authored. Checks CI, description quality, reviewers, and common issues before requesting review.

${input:pr:Required: PR number or owner/repo#number}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Fetch the PR metadata, diff, and check run status.
3. Run the self-review checklist:

### Description Quality
- [ ] PR title is clear and descriptive (not "fix bug" or "update")
- [ ] Description explains **what** changed and **why**
- [ ] Linked issues are referenced (`Fixes #N` or `Closes #N`)
- [ ] Breaking changes are called out
- [ ] Screenshots included for UI changes (if applicable)

### CI Status
- [ ] All check runs passing
- [ ] No merge conflicts with the base branch
- [ ] Branch is up to date with base (or rebased recently)

### Code Quality
- [ ] No TODO/FIXME/HACK comments left in the diff
- [ ] No console.log/print/debug statements left
- [ ] No commented-out code
- [ ] No hardcoded secrets, tokens, or credentials
- [ ] Test coverage for new code

### Reviewer Readiness
- [ ] Reviewers assigned (suggest from preferences if not)
- [ ] PR is not in draft mode (unless intentional)
- [ ] Labels are set appropriately
- [ ] Milestone set (if release-bound)

4. For each failing check, provide specific guidance on what to fix.
5. Suggest reviewers based on:
   - Changed file paths matched against preferences reviewer config
   - Who reviewed similar PRs recently
   - Team member expertise areas from preferences
6. Summarize: _"Your PR scores {N}/15 on the self-review checklist. {action items}. Ready to request review?"_
