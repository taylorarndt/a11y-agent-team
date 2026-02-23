# repo-manager - Repository Setup and Infrastructure Specialist

> Scaffold issue templates, contributing guides, CI/CD workflows, labels, licenses, changelogs, README badges, and everything else a well-run open source repo needs - without touching a single line of application code. Every generated file is previewed before it is written.

---

## What This Agent Is For

When you create a new GitHub repository, it is just an empty shell. Making it welcoming to contributors, navigable for users, and trustworthy to maintainers takes dozens of small files: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, issue templates, PR templates, CI workflows, labels, `FUNDING.yml`, a proper README, and more.

Setting all of these up manually is an afternoon of boilerplate. The repo-manager does it in minutes with a detection-first approach: it reads your project first, understands the language and framework, checks what already exists, and generates only what is missing.

**Important boundary:** The repo-manager generates *repository infrastructure files* only - `.github/` directory contents and root configuration files. It never touches your application source code, never deploys anything, and never manages hosting.

Use repo-manager when:

- You are starting a new open source project and need to go from empty to professional quickly
- An existing repo is missing essential community health files
- You want to add GitHub Actions CI for a project that doesn't have it yet
- You need to set up a standard label taxonomy across your repos
- You want to scaffold a release workflow with automatic changelog generation
- You want the full `good first issue` pipeline set up to attract contributors

---

## How to Launch It

### GitHub Copilot (VS Code)

```text
@repo-manager set up this repo
@repo-manager add issue templates
@repo-manager scaffold a CI workflow
@repo-manager create labels for this repo
@repo-manager draft a release for v2.0
```

### Claude Code (Terminal)

```bash
/repo-manager set up repo
/repo-manager add contributing guide
/repo-manager scaffold ci
/repo-manager create release
```

### Via GitHub Hub

```text
@github-hub set up repo
@github-hub add templates
```

---

## What It Can Generate

<details>
<summary>Expand full capability reference (14 categories)</summary>

| Category | What is generated | Location |
|----------|------------------|----------|
| **Issue templates** | Bug report, feature request, custom YAML forms, template chooser config | `.github/ISSUE_TEMPLATE/` |
| **PR template** | Checklist-driven pull request template | `.github/PULL_REQUEST_TEMPLATE.md` |
| **Contributing guide** | Fork/branch/PR workflow, dev setup, code style, commit conventions | `CONTRIBUTING.md` |
| **Code of conduct** | Contributor Covenant v2.1 with contact details | `CODE_OF_CONDUCT.md` |
| **Security policy** | Supported versions table, reporting instructions, response timeline | `SECURITY.md` |
| **README scaffolding** | Badges (shields.io), table of contents, features, getting started, license, contributors | `README.md` |
| **CI/CD workflows** | Build, test, release, Dependabot - pinned versions, least-privilege, caching | `.github/workflows/` |
| **Labels** | Standard 14-label taxonomy with colors and descriptions including `accessibility` | GitHub labels via `gh` commands |
| **Releases and changelogs** | Keep a Changelog format, commit grouping, tagging guidance | `CHANGELOG.md` + tag commands |
| **Wiki structure** | Standard wiki page outline | GitHub Wiki |
| **Funding** | Sponsors/platforms config | `.github/FUNDING.yml` |
| **License** | MIT, Apache 2.0, GPL 3.0, BSD 2-Clause, MPL 2.0, or Unlicense | `LICENSE` |
| **.gitignore** | Language/framework-aware, covering build, IDE, OS, env, deps | `.gitignore` |
| **Good first issues** | Analyzes codebase for starter opportunities, creates issues with context | GitHub issues via `gh` commands |

</details>

---

## What to Expect - Step by Step

### Full Setup Flow

1. **Detection first:**

   ```text
    Detecting project language and framework…
    Checking existing repo structure for conflicts…
    Ready to scaffold - 8 files to generate. Previewing before proceeding.
   ```

2. **Reads your project.** Before generating anything, the agent reads your repository structure to detect language/framework (Node, Python, Go, etc.) so CI workflows and `.gitignore` are appropriate.

3. **Checks existing files.** Scans for existing `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, issue templates, etc. so it only tells you about gaps.

4. **Previews each file** before writing. You see the full content and confirm.

5. **Provides next steps** after generation: file paths, `gh` commands to run, how to test templates in GitHub's UI.

### Adding Issue Templates

The agent generates YAML form templates (the current GitHub standard, not legacy Markdown templates). Every template set includes a `config.yml` for the template chooser.

The default templates generated:

- **Bug Report** - description, steps to reproduce, expected vs. actual behavior, environment, logs/screenshots
- **Feature Request** - problem/motivation, proposed solution, alternatives considered, additional context

To build a custom template interactively, use [template-builder](template-builder.md).

### Scaffolding CI/CD

The agent detects your language and generates an appropriate workflow. All generated CI files:

- Use **pinned action versions** (e.g., `actions/checkout@v4`, not `@latest`)
- Include a **`permissions:` block** with least-privilege settings
- Enable **dependency caching** for faster runs
- Use **concurrency groups** to cancel redundant runs on new pushes

Example output for a Node.js project:

```yaml
name: CI

on: [push, pull_request]

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

### Setting Up Labels

The agent generates the standard label taxonomy and provides the `gh label create` commands to apply them:

```bash
gh label create "accessibility" --color "#1d76db" --description "Accessibility improvements"
gh label create "good first issue" --color "#7057ff" --description "Good for newcomers"
# ... (all 14 labels shown before running)
```

Confirm before any `gh` commands are run.

### Drafting a Release

1. The agent reads commit history since the last tag
2. Groups commits by type (feat, fix, docs, chore)
3. Generates a Keep a Changelog entry
4. Guides through `gh release create` with the generated notes

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Full Setup

```text
@repo-manager set up this repo for open source contributions
@repo-manager what health files am I missing from this repo?
@repo-manager scaffold everything - templates, CI, labels, contributing guide
```

### Individual Files

```text
@repo-manager add a CONTRIBUTING.md
@repo-manager create a CODE_OF_CONDUCT.md
@repo-manager add a security policy
@repo-manager scaffold a README with badges and table of contents
@repo-manager add a .gitignore for Node.js
@repo-manager generate a license - help me choose
```

### CI and Labels

```text
@repo-manager scaffold a CI workflow for this project
@repo-manager add Dependabot config
@repo-manager create the standard label set for this repo
@repo-manager add the accessibility label
```

### Releases and Changelogs

```text
@repo-manager draft a release for v2.0
@repo-manager generate a changelog since v1.5
@repo-manager help me create and push a release tag
```

### Contributor Pipeline

```text
@repo-manager seed good first issues from this repo's TODOs
@repo-manager add a PR template with an accessibility checklist
@repo-manager create issue templates - bug report and feature request
```

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Custom issue templates | Build additional templates with an interactive wizard | [template-builder](template-builder.md) |
| Access and branch protection | After repo infrastructure is set up, configure who can push and merge | [repo-admin](repo-admin.md) |
| Back to hub | Continue with other GitHub workflow tasks | [github-hub](github-hub.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- **Detect before generating** - always reads existing project structure before producing any file; never generates blindly
- **Preview before writing** - every generated file is shown in full before being saved to disk
- **Confirm before overwriting** - never replaces an existing file without showing a diff and getting explicit approval
- **Application source off-limits** - only generates `.github/` and root config files; never touches `src/`, `app/`, or any application code
- **YAML form format for issue templates** - never generates the legacy Markdown-style `---` header templates
- **Pinned action versions always** - generated GitHub Actions workflows never use `@latest` or `@main`
- **Least-privilege CI permissions** - every generated workflow includes a `permissions:` block scoped to minimum required access
- **`accessibility` label always present** - included in every standard label scheme generated

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"The CI workflow runs but fails on dependency installation."**
The agent detects your package manager (npm, yarn, pnpm, pip, etc.) from your lockfile. If you use a non-standard setup, say: "generate a CI workflow for pnpm with Node 20" to be explicit.

**"My issue templates are not appearing in the GitHub UI."**
Templates must be in `.github/ISSUE_TEMPLATE/` with `.yml` extensions. There must also be a `config.yml` in that folder. Ask: "check my issue template setup and generate a config.yml."

**"The label commands keep failing - labels already exist."**
Use `gh label edit` instead of `gh label create` for existing labels (or delete them first). Ask: "update my labels - keep existing ones, add any that are missing."

**"I need a CI workflow for a monorepo with multiple packages."**
Describe your structure: "generate CI for a monorepo - Node frontend in `packages/web`, Python API in `packages/api`." The agent generates a matrix workflow.

</details>
