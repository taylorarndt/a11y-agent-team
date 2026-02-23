# explain-code

Explain specific lines, functions, or files from a pull request with line-number references and synchronized before/after views for changed code.

## When to Use It

- A reviewer does not understand what a block of code does
- Explaining a complex algorithm or pattern to a junior contributor
- Understanding a change in context before approving
- Documenting rationale for code that isn't self-explanatory

## How to Launch It

**In GitHub Copilot Chat:**

```text
/explain-code owner/repo#123 src/auth.ts:40-60
```

Or with natural language:

```text
/explain-code owner/repo#123 "the JWT validation block"
```

Or for a whole file:

```text
/explain-code owner/repo#123 src/auth.ts
```

## What to Expect

1. **Locate the target** - Finds the specified lines, function, or file in the PR diff
2. **Read context** - Pulls in surrounding lines, imports, and related functions for context
3. **Produce explanation** - Plain-language walkthrough of what the code does, why, and any risks
4. **Show line-numbered code** - All code references include exact L-number format for traceability
5. **Before/after comparison** - For changed code, shows what the original code did and what changed

### Explanation Format

```markdown
## src/auth.ts:40-60 - JWT Token Validation

**What it does:**
This block extracts the Bearer token from the Authorization header,
decodes the JWT payload, and verifies the signature against the
server's secret key using the `jsonwebtoken` library.

**Line by line:**
- L42: Splits the Authorization header on " " to get the raw token
- L45: Calls `jwt.verify()` - this throws if invalid or expired
- L52: Attaches decoded payload to `req.user` for downstream handlers

**Important:**
- L47: `process.env.JWT_SECRET` is read here - if undefined, `jwt.verify()`
  accepts any token. Should throw at startup if secret is missing.
```

### Before/After View

For changed code:

```text
Before (main):                     After (this PR):
     
const token = req.headers          const token = req.headers
  .authorization                     .authorization?.split(' ')[1]
const decoded = jwt.verify         const decoded = jwt.verify(
  (token, process.env.SECRET)        token,
                                     process.env.SECRET ?? throwMissing()
                                   )
```

## Example Variations

```text
/explain-code owner/repo#123 src/auth.ts:40-60
/explain-code #123 "the role check middleware"
/explain-code #123 src/utils.ts               # Explain whole file
/explain-code #123 L88                        # Single line
```

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [review-pr](review-pr.md) - full review with all findings
- [pr-comment](pr-comment.md) - leave a specific comment on the code
- [pr-report](pr-report.md) - generate a written review document
