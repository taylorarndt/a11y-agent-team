# insiders-a11y-tracker - VS Code Accessibility Progress Tracker

> Track accessibility improvements shipping to VS Code Insiders and Stable by monitoring the microsoft/vscode repo for issues tagged with `accessibility` + `insiders-released`. Cross-references each fix against WCAG 2.2 success criteria and ARIA patterns, then saves a delta report to your workspace.

---

## What This Agent Is For

VS Code ships accessibility improvements on a two-stage cadence: Insiders first, then Stable. These fixes are tagged with `insiders-released` when they land in the Insiders channel. The insiders-a11y-tracker watches for these tags across any repo you configure, organizes them by WCAG category and ARIA impact area, and produces a structured report.

This agent is for:

- **Accessibility engineers and advocates** who want to know what improved in VS Code and whether it affects workflows they care about
- **Extension developers** who need to know when VS Code behavior changes around focus, keyboard nav, or ARIA roles
- **Team leads** who want a regular digest of accessibility progress as a signal for their own roadmap
- **Open source contributors** who monitor the a11y backlog to find good-first issues and contribute fixes

It does not just list issues. It maps each fix to the WCAG success criterion it addresses, identifies the ARIA pattern involved, and tracks whether the same issue has appeared before (delta tracking). If a pattern persists for 3+ consecutive scans, the agent flags it for escalation and can file a new issue on your behalf.

---

## How to Launch It

### GitHub Copilot (VS Code)

```text
@insiders-a11y-tracker latest accessibility updates
@insiders-a11y-tracker what shipped to Insiders this week?
@insiders-a11y-tracker WCAG failures in VS Code this month
@insiders-a11y-tracker compare last month to this month
```

### Claude Code (Terminal)

```bash
/insiders-a11y-tracker latest updates
/insiders-a11y-tracker delta report
/insiders-a11y-tracker track microsoft/vscode
```

### Via GitHub Hub

```text
@github-hub accessibility tracker
@github-hub what's new in VS Code a11y?
```

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| `latest updates` / `what's new` | Full inventory of recent `insiders-released` a11y issues |
| `Insiders channel` | Filter to Insiders-only; exclude Stable |
| `Stable channel` | Filter to items that have also reached Stable |
| `delta report` / `compare to last scan` | Show Fixed, New, Persistent, Regressed since previous run |
| `WCAG 1.3 issues` / `WCAG 2.4 items` | Filter by WCAG principle |
| `keyboard navigation fixes` | Filter by ARIA/keyboard pattern |
| `focus management issues` | Filter by pattern area |
| `persistent issues` | Items present in 3+ consecutive scans |
| `track owner/repo` | Add a different GitHub repo to the watch list |

</details>

---

## What to Expect - Step by Step

### Standard Scan

1. **Channel determination.** The agent distinguishes Insiders vs. Stable by checking which `insiders-released` issues have also been labeled `stable-released`.

2. **Issue collection.** Searches the default repo (`microsoft/vscode`) for issues tagged with both `accessibility` and `insiders-released`, filtering by the configured time window (default: last 30 days).

   ```text
    Scanning microsoft/vscode for accessibility updates...
    Found 23 items: 18 Insiders-only, 5 reaching Stable
   ```

3. **WCAG cross-reference.** Each issue title and body is analyzed to determine which WCAG success criterion is most relevant:
   - Keyboard navigation issues -> WCAG 2.1.1, 2.1.2
   - Focus management -> WCAG 2.4.3
   - Screen reader labels -> WCAG 4.1.2
   - Color contrast -> WCAG 1.4.3, 1.4.11

4. **ARIA pattern mapping.** Where possible, each issue is categorized by ARIA design pattern involved (e.g., Dialog, Tree, Grid, Combobox, Live Region).

5. **Structured report:**

   ```text
   ## VS Code Accessibility - Insiders Report
   Period: Nov 1 - Nov 30

   ### Fixed (18 items reaching Insiders this period)
   
    #12847  Focus lost after closing notifications panel
    Channel: Insiders  |  WCAG: 2.4.3  |  Pattern: Live Region / Modal
    Status: Fixed
   
    #12801  Screen reader not announcing tree item expand state
    Channel: Insiders  |  WCAG: 4.1.2  |  Pattern: Tree
    Status: Fixed
   
   ```

6. **Delta tracking.** Compares against the previous scan to show:
   - **Fixed** - present before, resolved now
   - **New** - appeared this scan for the first time
   - **Persistent** - present for 2 consecutive scans
   - **Persistent (3+)** -  escalation flag
   - **Regressed** - was fixed, has reopened

7. **Escalation flag:**
   >  Persistent Issue Detected (3+ scans): Focus trap not working in Settings editor (#11200). This issue has appeared in 3 consecutive monthly scans without resolution. Recommended action: comment on the issue to signal continued impact, or file a priority escalation issue.

---

## Delta Tracking Explained

Each time the agent runs, it writes a scan result. The next run compares against the previous:

| Delta Status | Meaning | Visual indicator |
|-------------|---------|-----------------|
| Fixed | Resolved since last scan |  |
| New | First appearance |  |
| Persistent | Seen across 2 scans |  |
| Persistent (3+) | Flagged for escalation |  |
| Regressed | Closed then reopened |  |

**Confidence levels** on WCAG mappings:

| Confidence | Meaning |
|-----------|---------|
| High | Issue title/body contains explicit WCAG criterion |
| Medium | Clear keyword match (e.g., "focus", "contrast", "label") |
| Low | Inferred from issue area and component type |

---

## Tracking Additional Repos

<details>
<summary>Expand multi-repo configuration</summary>

By default only `microsoft/vscode` is tracked. To track additional repos:

**Via preferences.md:**

```yaml
accessibility_tracking:
  repos:
    - microsoft/vscode
    - your-org/your-repo
  labels:
    - accessibility
  channels:
    - insiders
    - stable
```

**Via prompt:**

```text
@insiders-a11y-tracker track your-org/your-repo for accessibility issues
@insiders-a11y-tracker add microsoft/vscode-jupyter to the watch list
```

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Routine Monitoring

```text
@insiders-a11y-tracker what accessibility issues shipped to Insiders this week?
@insiders-a11y-tracker show me everything that reached Stable this month
@insiders-a11y-tracker give me the delta since my last scan
```

### Filtered Views

```text
@insiders-a11y-tracker focus management issues only
@insiders-a11y-tracker WCAG 2.1 keyboard issues
@insiders-a11y-tracker screen reader related fixes
@insiders-a11y-tracker issues that regressed this month
```

### Multi-Repo

```text
@insiders-a11y-tracker scan all my tracked repos
@insiders-a11y-tracker compare vscode and vscode-jupyter accessibility status
```

</details>

---

## Output Files

<details>
<summary>Expand output file details</summary>

| File | Location | Contents |
|------|----------|----------|
| `A11Y-TRACKER-{date}.md` | workspace root | Full WCAG-mapped report |
| `A11Y-TRACKER-{date}.html` | workspace root | Accessible HTML version |

Previous scan results are kept to enable delta comparison on the next run.

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Add to daily briefing | Include tracker summary in morning digest | [daily-briefing](daily-briefing.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Default repo is `microsoft/vscode` - always shown in progress output so you know what is being scanned
- WCAG mappings always include a confidence level - never presented as definitive without textual evidence
- Escalation (auto-file issue) only happens if explicitly requested - the agent asks first
- Delta comparison is only shown if a previous scan file exists in the workspace
- If no `insiders-released` issues are found, the agent reports "no new accessibility items in this window" rather than a confusing empty result

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"I don't see a delta report."**
Delta reports require a previous scan file in the workspace. Run the agent once to generate a baseline, then run it again the following week or month to see the delta.

**"WCAG mappings seem off."**
WCAG mappings are inferred from issue text. Low-confidence mappings are labeled as such. You can correct them: "re-map issue #12847 to WCAG 2.4.7 (Focus Visible)."

**"I want to track a private repo."**
Private repos require proper authentication scope. Make sure your GitHub token has `repo` scope (not just `public_repo`). Then add the private repo to `preferences.md` under `accessibility_tracking.repos`.

</details>
