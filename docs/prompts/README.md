# Prompt Reference

This directory contains complete documentation for all 45 prompt files in this repository. Prompts are one-click workflows that launch pre-configured agent sessions - select them from the prompt picker in GitHub Copilot Chat or type `/` in Claude Code.

## Web Accessibility Prompts

| Prompt | Description |
|--------|-------------|
| [audit-web-page](web/audit-web-page.md) | Full single-page audit - axe-core + code review, scored report saved to file |
| [quick-web-check](web/quick-web-check.md) | Fast triage - axe-core only, inline pass/fail verdict |
| [audit-web-multi-page](web/audit-web-multi-page.md) | Multi-page comparison audit with systemic vs page-specific classification |
| [compare-web-audits](web/compare-web-audits.md) | Track remediation progress between two audit snapshots |
| [fix-web-issues](web/fix-web-issues.md) | Interactive fix mode with auto-fix + human-judgment workflow |

## Document Accessibility Prompts

| Prompt | Description |
|--------|-------------|
| [audit-single-document](documents/audit-single-document.md) | Audit one .docx, .xlsx, .pptx, or .pdf with strict profile |
| [audit-document-folder](documents/audit-document-folder.md) | Recursive folder scan with cross-document pattern analysis |
| [audit-changed-documents](documents/audit-changed-documents.md) | Delta scan - only documents changed since last git commit |
| [quick-document-check](documents/quick-document-check.md) | Fast triage - errors only, pass/fail verdict, no report file |
| [generate-vpat](documents/generate-vpat.md) | Generate a VPAT 2.5 / Section 508 / EN 301 549 conformance report |
| [generate-remediation-scripts](documents/generate-remediation-scripts.md) | Create PowerShell and Bash scripts for automatable fixes |
| [compare-audits](documents/compare-audits.md) | Compare two document audit reports and track progress |
| [setup-document-cicd](documents/setup-document-cicd.md) | Set up CI/CD pipeline for automated document scanning |
| [create-accessible-template](documents/create-accessible-template.md) | Create an accessible Office document template from scratch |

## GitHub Workflow Prompts

### Pull Request Workflows

| Prompt | Description |
|--------|-------------|
| [review-pr](github/review-pr.md) | Full PR review with annotated diff, saved as markdown + HTML |
| [pr-report](github/pr-report.md) | Save a PR review as workspace documents for offline review |
| [my-prs](github/my-prs.md) | Dashboard of your open PRs with review status and CI state |
| [pr-author-checklist](github/pr-author-checklist.md) | Pre-submit self-review checklist before requesting review |
| [pr-comment](github/pr-comment.md) | Add line-specific review comments to a PR |
| [address-comments](github/address-comments.md) | Systematically respond to all PR review feedback |
| [manage-branches](github/manage-branches.md) | List, compare, and clean up stale branches |
| [merge-pr](github/merge-pr.md) | Merge a PR after readiness check with strategy selection |
| [explain-code](github/explain-code.md) | Explain specific lines or functions in a PR diff |

### Issue Workflows

| Prompt | Description |
|--------|-------------|
| [my-issues](github/my-issues.md) | Smart issue dashboard across all repos with priority signals |
| [create-issue](github/create-issue.md) | Create a new issue with smart formatting and metadata |
| [triage](github/triage.md) | Prioritized triage dashboard saved as markdown + HTML |
| [issue-reply](github/issue-reply.md) | Draft and post a context-aware reply to an issue |
| [manage-issue](github/manage-issue.md) | Edit, label, assign, close, or transfer an issue |
| [refine-issue](github/refine-issue.md) | Add acceptance criteria, edge cases, and technical context |
| [project-status](github/project-status.md) | GitHub Projects board overview with per-column metrics |
| [react](github/react.md) | Add emoji reactions to issues, PRs, or comments |

### Briefing and CI Workflows

| Prompt | Description |
|--------|-------------|
| [daily-briefing](github/daily-briefing.md) | Daily GitHub briefing across all repos, saved as markdown + HTML |
| [ci-status](github/ci-status.md) | CI/CD health dashboard with failures, flaky tests, and long runs |
| [notifications](github/notifications.md) | Manage GitHub notifications with filtering and actions |
| [security-dashboard](github/security-dashboard.md) | Dependabot alerts and dependency vulnerability overview |
| [onboard-repo](github/onboard-repo.md) | First-time repo scan - health check, quick wins, saved report |

### Release Workflows

| Prompt | Description |
|--------|-------------|
| [draft-release](github/draft-release.md) | Draft release notes from merged PRs since last release |
| [release-prep](github/release-prep.md) | Complete release preparation - milestone, CI, checklist, notes |

### Analytics Workflows

| Prompt | Description |
|--------|-------------|
| [my-stats](github/my-stats.md) | Personal contribution metrics with team comparison |
| [team-dashboard](github/team-dashboard.md) | Team activity and review load with bottleneck detection |
| [sprint-review](github/sprint-review.md) | End-of-sprint summary with velocity and retrospective prompts |

### Community and Tooling

| Prompt | Description |
|--------|-------------|
| [a11y-update](github/a11y-update.md) | Latest accessibility improvements across tracked repos with WCAG mapping |
| [add-collaborator](github/add-collaborator.md) | Add a user to a repo with role selection |
| [build-template](github/build-template.md) | Interactive wizard to build a GitHub issue, PR, or discussion template |
| [build-a11y-template](github/build-a11y-template.md) | Generate a production-ready accessibility bug report template |
