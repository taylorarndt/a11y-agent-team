---
applyTo: "**"
---

## PowerShell Terminal Operations on Windows

### Multi-Line Git Commits

**NEVER use PowerShell here-strings (`@"..."@`) in terminal commands.** The closing `"@` must appear at column 0 on its own line, but the `run_in_terminal` tool serialises the entire command as a single string - the `"@` terminator is never recognised and the terminal locks permanently in `>>` continuation mode, requiring a manual terminal kill.

**NEVER use `create_file` to write a commit message then commit in a second call.** The file write and the `git commit -F` are separate tool invocations; timing/ordering can cause the commit to run before the file is flushed.

**NEVER use `git commit -m "line1\nline2"`.** PowerShell does not interpret `\n` inside double-quoted strings as newlines.

#### The ONLY reliable pattern for multi-line commits

Use `[IO.File]::WriteAllText()` with PowerShell backtick-n (`` `n ``) for newlines. Do everything - write, commit, cleanup - in a **single `run_in_terminal` call** with **`isBackground: true`**:

```powershell
[IO.File]::WriteAllText('msg.txt', "fix: short summary`n`n- detail line 1`n- detail line 2`n")
git commit -F msg.txt
Remove-Item msg.txt
git log --oneline -2
```

Key points:
- `` `n `` is the PowerShell newline escape inside a double-quoted string
- No BOM issues (unlike `Set-Content -Encoding utf8` on older PowerShell)
- `isBackground: true` spawns a fresh shell, avoiding any inherited stuck state
- Always append a trailing `` `n `` so the file ends with a newline (git prefers this)
- Include `git log --oneline -2` at the end to confirm success in the same output

#### Single-line commits

Simple one-line messages are fine with `-m`:

```powershell
git commit -m "fix: short single-line message"
```

---

### General PowerShell Terminal Rules

- **Avoid chaining commands that include here-strings.** `@"..."@` and `@'...'@` are both unsafe in tool-issued terminal strings.
- **One `run_in_terminal` call per logical operation.** Do not split write-then-execute across two calls when the second depends on the first having flushed.
- **Use `isBackground: true` for all git commit/push operations** to avoid inheriting stuck terminal state from previous calls.
- **Verify success** by including `git log --oneline -2` or `git status --short` at the end of the same call.
