---
name: explain-code
description: "Understand specific lines, functions, or blocks of code in a PR diff -- plain language explanations with context"
agent: pr-review
tools:
  - github/*
  - fetch
  - readFile
  - codebase
  - ask_questions
---

Explain specific code in a pull request -- what it does, why it's there, and what changed.

${input:target:What to explain -- e.g. 'lines 40-60 in auth.ts on PR #15', 'the handleAuth function in PR owner/repo#15', 'what changed in utils.ts'}

## Steps

1. Parse the target to extract: PR reference, file path (if specified), and line numbers or function name. Accept L-number format (e.g., "L42", "L40-L60") from annotated diff output.
2. Fetch the PR metadata and changed files list.
3. **If lines are specified** (e.g., "L40-L60 in auth.ts" or "lines 40-60 in auth.ts"):
   - Fetch the full file from the PR's head branch using #tool:mcp_github_github_get_file_contents.
   - Also fetch the base branch version to show what changed.
   - Display the target lines with **line numbers on every line** and ~10 lines of surrounding context:
     ```
     32 |   const config = loadConfig();
     ...
     40 |   function handleAuth(req: Request): AuthResult {
     41 |     const token = req.headers.authorization;   <-- start
     42 |     if (!token) {
     43 |       throw new AuthError('Missing header');    <-- end
     44 |     }
     ...
     ```
   - If lines were modified, show synchronized before/after with line numbers:
     ```
     BEFORE (main, L41-L43):           AFTER (feature branch, L41-L44):
     41 | if (!token) return null;       41 | if (!token) {
     42 | const decoded = validate(t);    42 |   throw new AuthError('Missing');
     43 | return decoded;                 43 | }
                                        44 | const decoded = validate(token);
     ```
   - Explain:
     - **What this code does** -- line-by-line plain language breakdown
     - **Why it's here** -- purpose inferred from PR description, commit messages, and surrounding code
     - **What changed** -- before vs. after with specific L-number references ("L42 changed from a silent return to a thrown error")
     - **Side effects** -- downstream impacts, state mutations, API calls, error paths
     - **Potential concerns** -- edge cases, missing error handling, performance implications

4. **If a function/class is specified** (e.g., "the handleAuth function"):
   - Search the PR diff for the function definition.
   - Show the full function with **line numbers on every line**.
   - Explain at a higher level: purpose, parameters, return values, error handling, and how it fits the broader change.
   - If modified, show the annotated diff for changed sections within the function.

5. **If a file is specified without lines** (e.g., "what changed in utils.ts"):
   - Show the annotated diff with dual line numbers (old/new) for that file.
   - Include the Change Map (hunk summary table with line ranges and intent).
   - Explain each change hunk: what was added/removed/modified and why.

6. After explaining, offer using L-number format:
   _"Want me to comment on L42, suggest a fix for L41-L44, or see the full Change Map?"_
