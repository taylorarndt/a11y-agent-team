---
name: address-comments
description: "Systematically address PR review comments -- track, resolve, and respond to all feedback with release awareness"
agent: pr-review
tools:
  - github/*
  - readFile
  - codebase
  - editFiles
  - ask_questions
---

Help me systematically address all review comments on a pull request.

${input:pr:PR reference -- e.g. owner/repo#123 or a GitHub PR URL}

## Steps

1. Parse the PR reference and fetch all review comments with #tool:mcp_github_github_pull_request_read (method: `get_review_comments`).
2. Also fetch general PR comments with #tool:mcp_github_github_pull_request_read (method: `get_comments`).
3. Also fetch formal reviews with #tool:mcp_github_github_pull_request_read (method: `get_reviews`).
4. Check release context -- is this PR release-bound? If so, note the deadline.
5. Check reactions on individual review comments -- highly-reacted comments may represent consensus.
6. Organize all feedback into a trackable list:

   ```markdown
   ## PR #{number} -- Review Comments to Address

   **Release context:** {e.g., "Targets v2.0 milestone -- release Feb 20" or "No release pressure"}

   ### From @{reviewer} -- {review verdict}

   | Number | File | Line | Priority | Reactions | Status | Comment Summary |
   |--------|------|------|----------|-----------|--------|----------------|
   | 1 | `path/file.ts` | L42 | CRITICAL | +1: 3 | Todo | "Consider null check here" |
   | 2 | `path/file.ts` | L78 | SUGGESTION | -- | Todo | "This could be a utility function" |
   | 3 | General | -- | IMPORTANT | +1: 2 | Todo | "Add tests for edge case X" |
   ```

7. For each comment, classify the required action:
   - **Code change needed** -- reviewer identified a bug, missing check, or improvement
   - **Clarification needed** -- reviewer asked a question about intent
   - **Discussion** -- reviewer suggests an alternative approach
   - **Already addressed** -- comment was already fixed in a subsequent commit
   - **Won't fix** -- valid feedback but intentionally not changing (explain why)

8. Use #tool:ask_questions to present the comments and ask which ones the user wants to address first. Options:
   - **Address all sequentially** (recommended)
   - **Blocking issues first** -- prioritize CRITICAL and IMPORTANT for release
   - **Pick specific comments**
   - **Show me the code context first**

9. For each comment being addressed:
   a. Show the original review comment with the **line-numbered code context** from the annotated diff (including surrounding lines, dual line numbers, and intent annotations if available).
   b. If the user has the code locally, suggest the fix using workspace file context from #tool:readFile.
   c. Draft a reply to the reviewer explaining what was done, referencing specific L-numbers (e.g., "Fixed the null check at L42").
   d. Mark as addressed in the tracking list.

10. After all comments are addressed, offer:
    - **Reply to all** -- post responses to each comment thread
    - **Push changes first** -- remind the user to commit and push, then come back to reply
    - **Generate summary** -- create a comment summarizing all changes made

11. Optionally, draft a summary comment for the PR:
    ```markdown
    Thanks for the review, @{reviewer}! Here's what I addressed:

    Done -- Fixed null check in `file.ts:42`
    Done -- Extracted utility function for X
    Done -- Added tests for edge case Y
    Discussed -- Responded to question about Z -- keeping current approach because {reason}

    Ready for re-review when you have a moment!
    ```

**Release awareness:** If the PR is release-bound, surface blocking comments first and suggest deferring SUGGESTION/NIT items to a follow-up PR after the release.

**Goal:** Turn the review-response cycle from a chaotic back-and-forth into a systematic, trackable workflow -- with release deadlines front and center.
