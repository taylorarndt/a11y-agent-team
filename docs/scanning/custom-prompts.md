# Custom Prompts

Pre-built prompt files in `.github/prompts/` provide one-click workflows for common tasks. Select them from the prompt picker in Copilot Chat.

There are 45 prompts across three categories: document accessibility (9), web accessibility (5), and GitHub workflow (31).

## How to Use

In Copilot Chat, open the prompt picker (click the prompt icon or type `/`) and select a prompt. The prompt provides structured instructions that guide the agent through the workflow.

In Claude Code, type `/` to browse agents directly. Equivalent workflows are available through the corresponding agent.

---

## Document Accessibility Prompts

These prompts invoke the `document-accessibility-wizard` agent. They work with `.docx`, `.xlsx`, `.pptx`, and `.pdf` files.

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `audit-single-document` | Scan a single document with severity scoring and metadata dashboard | [audit-single-document guide](../prompts/documents/audit-single-document.md) |
| `audit-document-folder` | Recursively scan an entire folder with cross-document analysis | [audit-document-folder guide](../prompts/documents/audit-document-folder.md) |
| `audit-changed-documents` | Delta scan - only audit documents changed since last commit | [audit-changed-documents guide](../prompts/documents/audit-changed-documents.md) |
| `quick-document-check` | Fast triage - errors only, high confidence, pass/fail verdict | [quick-document-check guide](../prompts/documents/quick-document-check.md) |
| `generate-vpat` | Generate a VPAT 2.5 / ACR compliance report from existing audit results | [generate-vpat guide](../prompts/documents/generate-vpat.md) |
| `generate-remediation-scripts` | Create PowerShell/Bash scripts to batch-fix common document issues | [generate-remediation-scripts guide](../prompts/documents/generate-remediation-scripts.md) |
| `compare-audits` | Compare two audit reports side-by-side to track remediation progress | [compare-audits guide](../prompts/documents/compare-audits.md) |
| `setup-document-cicd` | Set up CI/CD pipelines for automated document scanning | [setup-document-cicd guide](../prompts/documents/setup-document-cicd.md) |
| `create-accessible-template` | Guidance for creating accessible Word, Excel, or PowerPoint templates | [create-accessible-template guide](../prompts/documents/create-accessible-template.md) |

---

## Web Accessibility Prompts

These prompts invoke the `accessibility-lead` and specialist agents. They work with live URLs and web codebases.

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `audit-web-page` | Full single-page audit: axe-core scan + manual code review + scored report | [audit-web-page guide](../prompts/web/audit-web-page.md) |
| `quick-web-check` | Fast axe-core-only triage with pass/fail verdict | [quick-web-check guide](../prompts/web/quick-web-check.md) |
| `audit-web-multi-page` | Multi-page comparison audit with cross-page pattern detection | [audit-web-multi-page guide](../prompts/web/audit-web-multi-page.md) |
| `compare-web-audits` | Compare two web audit reports to track remediation progress | [compare-web-audits guide](../prompts/web/compare-web-audits.md) |
| `fix-web-issues` | Interactive fix mode - apply fixes from an audit report | [fix-web-issues guide](../prompts/web/fix-web-issues.md) |

---

## GitHub Workflow Prompts

These prompts invoke the GitHub workflow agents (`pr-review`, `issue-tracker`, `daily-briefing`, `analytics`, `insiders-a11y-tracker`, `repo-admin`, `template-builder`).

### Pull Request Workflows

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `review-pr` | Full code review saved as markdown and HTML to `.github/reviews/prs/` | [review-pr guide](../prompts/github/review-pr.md) |
| `pr-report` | Generate a review document without posting inline GitHub comments | [pr-report guide](../prompts/github/pr-report.md) |
| `my-prs` | Dashboard of your open PRs and pending review requests | [my-prs guide](../prompts/github/my-prs.md) |
| `pr-author-checklist` | Pre-submit 15-point readiness checklist for PR authors | [pr-author-checklist guide](../prompts/github/pr-author-checklist.md) |
| `pr-comment` | Add a targeted comment to a specific line or file in a PR | [pr-comment guide](../prompts/github/pr-comment.md) |
| `address-comments` | Track and resolve all review comments systematically | [address-comments guide](../prompts/github/address-comments.md) |
| `manage-branches` | List, compare, find stale, protect, or delete branches | [manage-branches guide](../prompts/github/manage-branches.md) |
| `merge-pr` | Verify readiness and merge a PR with strategy selection | [merge-pr guide](../prompts/github/merge-pr.md) |
| `explain-code` | Explain specific lines or files from a PR with before/after views | [explain-code guide](../prompts/github/explain-code.md) |

### Issue Workflows

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `my-issues` | Prioritized dashboard of issues assigned to or @mentioning you | [my-issues guide](../prompts/github/my-issues.md) |
| `create-issue` | Create an issue guided by type detection and template pre-fill | [create-issue guide](../prompts/github/create-issue.md) |
| `triage` | Score and prioritize all open issues; saved triage report | [triage guide](../prompts/github/triage.md) |
| `issue-reply` | Draft a context-aware reply to an issue thread (preview + confirm) | [issue-reply guide](../prompts/github/issue-reply.md) |
| `manage-issue` | Edit, label, assign, close, lock, or transfer issues | [manage-issue guide](../prompts/github/manage-issue.md) |
| `refine-issue` | Add acceptance criteria, edge cases, and testing strategy to an issue | [refine-issue guide](../prompts/github/refine-issue.md) |
| `project-status` | Snapshot of a project board with stale and blocked item detection | [project-status guide](../prompts/github/project-status.md) |
| `react` | Add emoji reactions to issues, PRs, or specific comments | [react guide](../prompts/github/react.md) |

### Briefing, CI, and Monitoring

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `daily-briefing` | Comprehensive daily GitHub briefing across all repos | [daily-briefing guide](../prompts/github/daily-briefing.md) |
| `ci-status` | CI/CD health table with failing, slow, and flaky workflow detection | [ci-status guide](../prompts/github/ci-status.md) |
| `notifications` | View and manage GitHub notifications with bulk-action support | [notifications guide](../prompts/github/notifications.md) |
| `security-dashboard` | Dependabot and Renovate alert summary by severity | [security-dashboard guide](../prompts/github/security-dashboard.md) |
| `onboard-repo` | First-time repo health check with saved onboarding report | [onboard-repo guide](../prompts/github/onboard-repo.md) |

### Releases

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `draft-release` | Generate categorized release notes from merged PRs | [draft-release guide](../prompts/github/draft-release.md) |
| `release-prep` | Guided 8-step release readiness workflow with sign-off checklist | [release-prep guide](../prompts/github/release-prep.md) |

### Analytics

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `my-stats` | Personal contribution analytics with period-over-period comparison | [my-stats guide](../prompts/github/my-stats.md) |
| `team-dashboard` | Team contributions dashboard with bottleneck detection | [team-dashboard guide](../prompts/github/team-dashboard.md) |
| `sprint-review` | End-of-sprint analytics with velocity metrics and retrospective prompts | [sprint-review guide](../prompts/github/sprint-review.md) |

### Community and Tooling

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `a11y-update` | Latest accessibility issues grouped by access need with WCAG mapping | [a11y-update guide](../prompts/github/a11y-update.md) |
| `add-collaborator` | Add a collaborator with role guidance and confirmation | [add-collaborator guide](../prompts/github/add-collaborator.md) |
| `build-template` | Interactive GitHub issue template builder | [build-template guide](../prompts/github/build-template.md) |
| `build-a11y-template` | Generate a pre-built accessibility bug report issue template | [build-a11y-template guide](../prompts/github/build-a11y-template.md) |
