---
name: refine-issue
description: "Refine an issue with acceptance criteria, technical considerations, edge cases, and community context"
agent: issue-tracker
tools:
  - github/*
  - ask_questions
---

Help refine a GitHub issue to make it actionable and well-defined.

${input:issue:Issue reference -- e.g. owner/repo#123 or a GitHub issue URL}

## Steps

1. Parse the issue reference and fetch full details with #tool:mcp_github_github_issue_read -- title, body, labels, comments, assignees, reactions.
2. Check for related GitHub Discussions that provide additional context or requirements.
3. Check release context -- is this issue in a milestone with a deadline?
4. Analyze the current issue description and identify:
   - **What's clear:** Parts well-defined with specific requirements.
   - **What's missing:** Gaps in context, requirements, or scope.
   - **What's ambiguous:** Parts that could be interpreted multiple ways.
   - **Community interest:** Reaction count and sentiment -- helps prioritize refinement depth.
5. Draft a refined issue body that adds:

   ### Acceptance Criteria
   - [ ] {Specific, testable criterion derived from the description}
   - [ ] {Edge case handling criterion}
   - [ ] {Performance/UX criterion if applicable}
   - [ ] {Accessibility criterion if applicable -- reference WCAG}

   ### Technical Considerations
   - **Affected components:** {Where in the codebase this touches}
   - **Dependencies:** {Other issues, PRs, or external services}
   - **Breaking changes:** {Yes/No -- explain if yes}
   - **Migration needed:** {Yes/No -- explain if yes}
   - **Release target:** {milestone or "None specified"}

   ### Edge Cases to Handle
   - {Edge case 1 -- and expected behavior}
   - {Edge case 2 -- and expected behavior}

   ### Out of Scope
   - {What this issue explicitly does NOT cover}

   ### Testing Strategy
   - {How to verify the implementation}
   - {Accessibility testing if applicable}

   ### Community Context
   - {Reactions summary -- Popular/Controversial/Quiet}
   - {Key points from related discussions}

6. Preview the refined description in a quoted block.
7. Use #tool:ask_questions: **Post as comment** (recommended), **Update issue body** (replaces current body), **Edit** (refine further), **Cancel**.
8. If posting, use #tool:mcp_github_github_add_issue_comment to add the refined description as a comment.
9. Confirm with link.

**Goal:** Transform vague issues into specific, actionable work items that any engineer can pick up -- enriched with community context and release awareness.
