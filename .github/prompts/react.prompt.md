---
name: react
description: "Add emoji reactions to issues, PRs, and comments -- thumbs up, heart, rocket, and more"
agent: issue-tracker
tools:
  - github/*
  - ask_questions
---

Add an emoji reaction to an issue, PR, or specific comment.

${input:target:What to react to -- e.g. 'thumbs up owner/repo#42', 'heart the latest comment on #42', 'rocket PR owner/repo#15'}

## Behavior

Parse the target to determine:

1. **What to react to:**
   - An **issue** --> "like #42", "thumbs up issue #42"
   - A **PR** --> "rocket PR #15", "thumbs up PR owner/repo#15"
   - A **specific comment** --> "heart Alice's comment on #42", "like comment 3 on #42"
   - The **latest comment** --> "thumbs up the last comment on #42"

2. **Which reaction:**
   - Map natural language to GitHub reaction types:
     - "like", "agree", "thumbs up", "+1" --> `+1`
     - "disagree", "thumbs down", "-1" --> `-1`
     - "love", "heart" --> `heart`
     - "celebrate", "hooray", "tada" --> `hooray`
     - "ship it", "rocket", "launch" --> `rocket`
     - "looking", "eyes", "watching" --> `eyes`
     - "funny", "laugh", "lol" --> `laugh`
     - "confused", "huh", "what" --> `confused`

## Steps

1. Parse the target reference to extract owner, repo, number, and optionally comment identifier.
2. If targeting an **issue or PR body**:
   - Fetch current reactions to show what's already there.
   - Add the reaction.
   - Confirm: _"Added thumbs-up to {repo}#{number}. Current reactions: +1: 6, heart: 2"_
3. If targeting a **specific comment**:
   - Fetch all comments and display a numbered list if the user didn't specify which one.
   - Add the reaction to the identified comment.
   - Confirm: _"Added heart to @alice's comment on {repo}#{number}."_
4. If the user says "react to #42" without specifying which reaction, show the available reactions and ask.

**Never modify issue/PR state -- reactions only.**
