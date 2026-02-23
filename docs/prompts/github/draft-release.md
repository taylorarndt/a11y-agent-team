# draft-release

Generate release notes from merged PRs since the last release. The agent auto-categorizes changes, writes a readable summary, and saves the notes as markdown and HTML.

## When to Use It

- Preparing a GitHub release and writing the description
- After a sprint when you need to document what shipped
- Before tagging a version to build the release notes document first
- Sharing a changelog with stakeholders before a release goes live

## How to Launch It

**In GitHub Copilot Chat:**

```text
/draft-release owner/repo
```

With an explicit version or base:

```text
/draft-release owner/repo v2.1.0
/draft-release owner/repo since v2.0.0
/draft-release owner/repo since 2026-02-01
```

## What to Expect

1. **Find previous release** - Determines the last published release or tag to use as the baseline
2. **Collect merged PRs** - Fetches all PRs merged since that baseline with titles, authors, and labels
3. **Auto-categorize** - Sorts PRs into 7 categories based on labels and title patterns
4. **Write summary** - Produces a human-readable release description
5. **Save** - Written to `.github/reviews/releases/release-notes-{version}-{date}.md` and `.html`

### Auto-Category Rules

| Category | Label or title signals |
|----------|----------------------|
| Breaking changes | `breaking`, `breaking-change`, title contains "BREAKING:" |
| New features | `enhancement`, `feature`, title contains "feat:" |
| Bug fixes | `bug`, `fix`, title contains "fix:" |
| Performance | `performance`, `perf`, title contains "perf:" |
| Security | `security`, `vulnerability`, Dependabot PRs |
| Documentation | `documentation`, `docs`, title contains "docs:" |
| Chores | `chore`, `refactor`, `ci`, `dependencies` |

### Sample Output

```markdown
# Release v2.1.0

## What's New

### New Features
- Add dark mode support (#112) - @alice
- CSV export for data tables (#98) - @bob

### Bug Fixes
- Fix login form double-submit on mobile (#108) - @charlie
- Correct broken pagination on page 2+ (#95) - @alice

### Security
- Bump lodash from 4.17.20 to 4.17.21 (#103) - Dependabot

### Documentation
- Update accessibility guide with WCAG 2.2 changes (#101) - @alice

**Full changelog:** v2.0.0...v2.1.0
```

### Readiness Checklist

The agent also produces a pre-publish checklist:

```text
Release readiness:
   14 PRs included since v2.0.0
   No critical Dependabot alerts unpatched
    2 PRs labeled "needs-test" - verify coverage
   CHANGELOG.md updated
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/releases/release-notes-{version}-{date}.md` | Release notes draft |
| `.github/reviews/releases/release-notes-{version}-{date}.html` | Accessible HTML version |

## Example Variations

```text
/draft-release owner/repo                    # Auto-detect version
/draft-release owner/repo v2.1.0             # Specify version
/draft-release owner/repo since v2.0.0       # Explicit base tag
```

## Connected Agents

| Agent | Role |
|-------|------|
| daily-briefing agent | Executes this prompt |

## Related Prompts

- [release-prep](release-prep.md) - guided 8-step release readiness workflow
- [my-prs](my-prs.md) - verify which PRs are included
