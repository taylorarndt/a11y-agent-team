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
| `audit-single-document` | Scan a single document with severity scoring and metadata dashboard | [Details](../prompts/documents/audit-single-document.md) |
| `audit-document-folder` | Recursively scan an entire folder with cross-document analysis | [Details](../prompts/documents/audit-document-folder.md) |
| `audit-changed-documents` | Delta scan — only audit documents changed since last commit | [Details](../prompts/documents/audit-changed-documents.md) |
| `quick-document-check` | Fast triage — errors only, high confidence, pass/fail verdict | [Details](../prompts/documents/quick-document-check.md) |
| `generate-vpat` | Generate a VPAT 2.5 / ACR compliance report from existing audit results | [Details](../prompts/documents/generate-vpat.md) |
| `generate-remediation-scripts` | Create PowerShell/Bash scripts to batch-fix common document issues | [Details](../prompts/documents/generate-remediation-scripts.md) |
| `compare-audits` | Compare two audit reports side-by-side to track remediation progress | [Details](../prompts/documents/compare-audits.md) |
| `setup-document-cicd` | Set up CI/CD pipelines for automated document scanning | [Details](../prompts/documents/setup-document-cicd.md) |
| `create-accessible-template` | Guidance for creating accessible Word, Excel, or PowerPoint templates | [Details](../prompts/documents/create-accessible-template.md) |

---

## Web Accessibility Prompts

These prompts invoke the `accessibility-lead` and specialist agents. They work with live URLs and web codebases.

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `audit-web-page` | Full single-page audit: axe-core scan + manual code review + scored report | [Details](../prompts/web/audit-web-page.md) |
| `quick-web-check` | Fast axe-core-only triage with pass/fail verdict | [Details](../prompts/web/quick-web-check.md) |
| `audit-web-multi-page` | Multi-page comparison audit with cross-page pattern detection | [Details](../prompts/web/audit-web-multi-page.md) |
| `compare-web-audits` | Compare two web audit reports to track remediation progress | [Details](../prompts/web/compare-web-audits.md) |
| `fix-web-issues` | Interactive fix mode — apply fixes from an audit report | [Details](../prompts/web/fix-web-issues.md) |

---

## GitHub Workflow Prompts

These prompts invoke the GitHub workflow agents (`pr-review`, `issue-tracker`, `daily-briefing`, `analytics`, `insiders-a11y-tracker`, `repo-admin`, `template-builder`).

### Pull Request Workflows

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `review-pr` | Full code review saved as markdown and HTML to `.github/reviews/prs/` | [Details](../prompts/github/review-pr.md) |
| `pr-report` | Generate a review document without posting inline GitHub comments | [Details](../prompts/github/pr-report.md) |
| `my-prs` | Dashboard of your open PRs and pending review requests | [Details](../prompts/github/my-prs.md) |
| `pr-author-checklist` | Pre-submit 15-point readiness checklist for PR authors | [Details](../prompts/github/pr-author-checklist.md) |
| `pr-comment` | Add a targeted comment to a specific line or file in a PR | [Details](../prompts/github/pr-comment.md) |
| `address-comments` | Track and resolve all review comments systematically | [Details](../prompts/github/address-comments.md) |
| `manage-branches` | List, compare, find stale, protect, or delete branches | [Details](../prompts/github/manage-branches.md) |
| `merge-pr` | Verify readiness and merge a PR with strategy selection | [Details](../prompts/github/merge-pr.md) |
| `explain-code` | Explain specific lines or files from a PR with before/after views | [Details](../prompts/github/explain-code.md) |

### Issue Workflows

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `my-issues` | Prioritized dashboard of issues assigned to or @mentioning you | [Details](../prompts/github/my-issues.md) |
| `create-issue` | Create an issue guided by type detection and template pre-fill | [Details](../prompts/github/create-issue.md) |
| `triage` | Score and prioritize all open issues; saved triage report | [Details](../prompts/github/triage.md) |
| `issue-reply` | Draft a context-aware reply to an issue thread (preview + confirm) | [Details](../prompts/github/issue-reply.md) |
| `manage-issue` | Edit, label, assign, close, lock, or transfer issues | [Details](../prompts/github/manage-issue.md) |
| `refine-issue` | Add acceptance criteria, edge cases, and testing strategy to an issue | [Details](../prompts/github/refine-issue.md) |
| `project-status` | Snapshot of a project board with stale and blocked item detection | [Details](../prompts/github/project-status.md) |
| `react` | Add emoji reactions to issues, PRs, or specific comments | [Details](../prompts/github/react.md) |

### Briefing, CI, and Monitoring

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `daily-briefing` | Comprehensive daily GitHub briefing across all repos | [Details](../prompts/github/daily-briefing.md) |
| `ci-status` | CI/CD health table with failing, slow, and flaky workflow detection | [Details](../prompts/github/ci-status.md) |
| `notifications` | View and manage GitHub notifications with bulk-action support | [Details](../prompts/github/notifications.md) |
| `security-dashboard` | Dependabot and Renovate alert summary by severity | [Details](../prompts/github/security-dashboard.md) |
| `onboard-repo` | First-time repo health check with saved onboarding report | [Details](../prompts/github/onboard-repo.md) |

### Releases

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `draft-release` | Generate categorized release notes from merged PRs | [Details](../prompts/github/draft-release.md) |
| `release-prep` | Guided 8-step release readiness workflow with sign-off checklist | [Details](../prompts/github/release-prep.md) |

### Analytics

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `my-stats` | Personal contribution analytics with period-over-period comparison | [Details](../prompts/github/my-stats.md) |
| `team-dashboard` | Team contributions dashboard with bottleneck detection | [Details](../prompts/github/team-dashboard.md) |
| `sprint-review` | End-of-sprint analytics with velocity metrics and retrospective prompts | [Details](../prompts/github/sprint-review.md) |

### Community and Tooling

| Prompt | What It Does | Detailed Docs |
|--------|-------------|---------------|
| `a11y-update` | Latest accessibility issues grouped by access need with WCAG mapping | [Details](../prompts/github/a11y-update.md) |
| `add-collaborator` | Add a collaborator with role guidance and confirmation | [Details](../prompts/github/add-collaborator.md) |
| `build-template` | Interactive GitHub issue template builder | [Details](../prompts/github/build-template.md) |
| `build-a11y-template` | Generate a pre-built accessibility bug report issue template | [Details](../prompts/github/build-a11y-template.md) |
