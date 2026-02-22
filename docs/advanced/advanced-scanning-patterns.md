# Advanced Scanning Patterns

Patterns for background execution and isolated scanning contexts when working with large document libraries.

## Background Scanning

### When to Use Background Scanning

- Document libraries with 50+ files where scanning takes several minutes
- Scheduled nightly or weekly audit runs
- CI/CD pipeline integration where scanning runs asynchronously

### Claude Code: Background Task Pattern

Claude Code supports the `Task` tool for spawning parallel sub-agents. For background-style scanning:

```
Scan these 4 document types in parallel:
1. Task 1: Scan all .docx files in /docs/ → return findings summary
2. Task 2: Scan all .xlsx files in /docs/ → return findings summary
3. Task 3: Scan all .pptx files in /docs/ → return findings summary
4. Task 4: Scan all .pdf files in /docs/ → return findings summary

Wait for all tasks to complete, then merge results.
```

Each task runs in its own context window, scanning independently. The orchestrator collects results and merges them.

**Limitations:**
- Tasks share the same filesystem — no isolation between tasks
- Each task has its own context window but sees the same working directory
- Progress reporting happens only when tasks complete

### GitHub Copilot: Sub-Agent Pattern

Copilot agents use the `agents` frontmatter to reference sub-agents:

```yaml
agents: ['word-accessibility', 'excel-accessibility', 'powerpoint-accessibility', 'pdf-accessibility', 'document-inventory', 'cross-document-analyzer']
```

The orchestrator (document-accessibility-wizard) delegates to sub-agents sequentially or by type group. True background execution is not yet supported — sub-agents run within the main conversation context.

**Practical pattern for large scans:**
1. Use `document-inventory` to build the file list
2. Group files by type
3. Process each type group as a batch
4. Report progress after each group completes

### CI/CD Background Pattern

For true background execution, use CI/CD pipelines:

```yaml
# GitHub Actions — runs asynchronously on push
name: Document Accessibility Audit
on:
  push:
    paths: ['**/*.docx', '**/*.xlsx', '**/*.pptx', '**/*.pdf']
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: node .github/scripts/office-a11y-scan.mjs
      - run: node .github/scripts/pdf-a11y-scan.mjs
      - uses: actions/upload-artifact@v4
        with:
          name: audit-report
          path: DOCUMENT-ACCESSIBILITY-AUDIT.md
```

This runs the scan in the background. Results are available as build artifacts.

## Worktree Isolation

### When to Use Isolated Scanning

- Scanning documents in a branch without switching your working directory
- Running audits against a specific git tag or release
- Comparing documents across branches

### Git Worktree Pattern

Use `git worktree` to create isolated copies for scanning without affecting your main working directory:

```bash
# Create a worktree for the target branch
git worktree add ../audit-workspace release/v2.0

# Run scan against the worktree
cd ../audit-workspace
# (run scanning tools here)

# Clean up after scanning
cd ..
git worktree remove audit-workspace
```

### Temp Directory Pattern

For non-git scenarios or when you need a clean scanning environment:

```powershell
# PowerShell: Copy documents to temp for isolated scanning
$ScanDir = Join-Path $env:TEMP "a11y-scan-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $ScanDir
Copy-Item -Path "docs\*.docx","docs\*.xlsx","docs\*.pptx","docs\*.pdf" -Destination $ScanDir

# Run scan in isolated directory
# (scan commands targeting $ScanDir)

# Clean up
Remove-Item -Recurse -Force $ScanDir
```

```bash
# Bash: Copy documents to temp for isolated scanning
SCAN_DIR=$(mktemp -d)
cp docs/*.docx docs/*.xlsx docs/*.pptx docs/*.pdf "$SCAN_DIR/"

# Run scan in isolated directory
# (scan commands targeting $SCAN_DIR)

# Clean up
rm -rf "$SCAN_DIR"
```

### Branch Comparison Pattern

Compare document accessibility across branches:

```bash
# Scan current branch
node .github/scripts/office-a11y-scan.mjs --output AUDIT-current.md

# Create worktree for comparison branch
git worktree add ../compare-branch main

# Scan comparison branch
cd ../compare-branch
node .github/scripts/office-a11y-scan.mjs --output ../AUDIT-main.md

# Compare results
cd ..
# Use compare-audits prompt or diff the reports
git worktree remove compare-branch
```

## Large Library Strategies

### Tiered Scanning

For very large document libraries (500+ documents):

**Tier 1 — Triage (minimal profile):**
Scan all documents with `errors only` to identify the worst offenders.

**Tier 2 — Priority (moderate profile):**
Re-scan the worst 20% with errors and warnings.

**Tier 3 — Comprehensive (strict profile):**
Full scan of high-priority or public-facing documents.

### Incremental Scanning

Rather than scanning the entire library each time:

1. Run a full baseline scan once
2. On subsequent runs, use delta scanning (changed files only)
3. Compare each delta scan against the baseline
4. Run a full re-scan quarterly to catch configuration drift

### Sampling Strategy

For initial assessment of a large library:

1. Select a proportional sample across document types and folders
2. Scan 10-20 representative files
3. Extrapolate issue rates to estimate total remediation effort
4. Use the sample results to prioritize which folders to scan first
