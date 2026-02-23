# Setup Guide for GitHub Copilot Agents

This guide will help you set up and configure the GitHub Copilot agents in your workspace.

## Quick Start

1. **Clone or copy this repository structure** to your workspace
2. **Configure your preferences** in `.github/agents/preferences.md`
3. **Start using agents** with GitHub Copilot

## Directory Structure

Ensure your workspace has this structure:

```text
your-workspace/
 .github/
    agents/
       preferences.md         # Your configuration
       shared-instructions.md  # Core agent behavior
       *.agent.md              # Individual agents
    prompts/
        *.prompt.md             # Prompt templates
 your-project-files...
```

## Configuration

### 1. Repository Discovery & Scope (Most Important)

By default, agents search **all repos you have access to** -- public, private, and org repos. You can customize this behavior:

```yaml
repos:
  # How agents discover repos. Options: all | starred | owned | configured | workspace
  discovery: all                 # 'all' means every repo you can access (default)

  # Always include these repos in every search (pinned repos)
  include:
    - my-org/core-api
    - my-org/frontend

  # Never include these repos
  exclude:
    - my-org/archived-legacy

  # Per-repo overrides -- control what each agent tracks per repo
  overrides:
    "my-org/core-api":
      track:
        issues: true
        pull_requests: true
        discussions: true
        releases: true
        security: true
        ci: true
      labels:
        include: []              # empty = all labels
        exclude: ["wontfix"]
      paths: ["src/**"]          # only alert on changes in these paths

    "my-org/docs":
      track:
        issues: true
        pull_requests: true
        discussions: false       # skip discussions for this repo
        releases: false
        security: false
        ci: false

  # Default tracking for repos not listed in overrides
  defaults:
    track:
      issues: true
      pull_requests: true
      discussions: true
      releases: true
      security: true
      ci: true
```

See `preferences.example.md` for the complete reference with all available options.

### 2. Accessibility Tracking

Track accessibility improvements across VS Code (default) and any other repos:

```yaml
accessibility_tracking:
  enabled: true
  repos:
    - repo: microsoft/vscode       # tracked by default
      labels:
        accessibility: "accessibility"
        insiders: "insiders-released"
      channels:
        insiders: true
        stable: true
      use_milestones: true

    - repo: my-org/my-web-app      # add your own repos
      labels:
        accessibility: "a11y"      # your repo's label name
        insiders: ""
      channels:
        insiders: false
        stable: true
      use_milestones: false         # use date-based filtering

  wcag_references: true
  aria_patterns: true
  briefing_limit: 10
```

### 3. Customize Preferences

Edit `.github/agents/preferences.md` to match your workflow:

```yaml
# Example: Set your merge strategy
merge:
  default_strategy: squash
  delete_branch_after: true
  require_ci_pass: true

# Example: Configure team members
team:
  - name: Your Name
    github: your-username
    expertise:
      - backend
      - frontend
    timezone: America/New_York
```

### 4. Update Team Roster

Add your team members to enable smart reviewer suggestions:

```yaml
team:
  - name: Alice Smith
    github: alice
    expertise: ["security", "backend"]
    timezone: America/New_York
  - name: Bob Chen  
    github: bob
    expertise: ["frontend", "React"]
    timezone: America/Los_Angeles
```

### 5. Configure Default Reviewers

Set up path-based reviewer suggestions:

```yaml
reviewers:
  default:
    - alice
  by_path:
    "src/security/**":
      - alice
    "src/ui/**":
      - bob
```

### 6. Set Up Response Templates

Customize response templates for common scenarios:

```yaml
templates:
  needs-info: |
    Thanks for reporting! Could you provide:
    1. Steps to reproduce
    2. Expected vs actual behavior
    3. Environment details
```

### 7. Search & Discovery

Control how agents search and discover content:

```yaml
search:
  default_window: 30d            # default time window (7d | 14d | 30d | 60d | 90d)
  auto_broaden: true             # expand search when 0 results
  auto_narrow: true              # narrow search when 50+ results
  follow_references: true        # follow cross-repo references
  org_search: true               # search across your orgs

briefing:
  sections:
    action_needed: true
    releases: true
    discussions: true
    ci_cd: true
    security: true
    projects: true
    accessibility: true
    completed: true
    guidance: true
  cross_repo_related: true       # surface related items across repos
  formats:
    markdown: true
    html: true
```

## Agent Usage

### Daily Briefing Agent

```text
@daily-briefing generate morning briefing
@daily-briefing afternoon update
@daily-briefing weekly summary
@daily-briefing just PRs across all repos
@daily-briefing briefing for my-org/core-api only
```

### PR Review Agent

```text
@pr-review analyze #123
@pr-review show all PRs waiting for my review
@pr-review my open PRs across all repos
@pr-review detailed review focusing on security
```

### Issue Tracker Agent

```text
@issue-tracker triage new issues
@issue-tracker my issues across all repos
@issue-tracker show critical bugs in my-org
@issue-tracker search accessibility issues
```

### Accessibility Tracker

```text
@insiders-a11y-tracker what a11y changes shipped this week
@insiders-a11y-tracker track my-org/my-app
@insiders-a11y-tracker full report with WCAG analysis
@insiders-a11y-tracker screen reader improvements across all repos
```

### Analytics & Insights Agent

```text
@analytics team dashboard across all repos
@analytics my stats this month
@analytics review turnaround times
@analytics bottlenecks in my-org
```

## AI Model Integration

### GitHub Copilot

- Agents work natively with GitHub Copilot
- Use `@agent-name` syntax to invoke agents
- Agents automatically read preferences and adapt behavior

### Claude Integration

For Claude users:

1. Copy the agent content as context
2. Reference the shared-instructions.md for behavior guidelines
3. Use the prompt templates as structured inputs

### Other AI Models

The agents and prompts can be adapted for:

- OpenAI ChatGPT (copy as custom instructions)
- Anthropic Claude (use as conversation context)
- Local models (adapt prompt formatting as needed)

## Troubleshooting

### Agent Not Responding

1. Check that `.github/agents/` directory exists in your workspace
2. Verify agent files have `.agent.md` extension
3. Ensure preferences.md is properly formatted YAML

### Permissions Issues

1. Verify GitHub authentication in VS Code
2. Check repository access permissions
3. Ensure GitHub Copilot has required scopes

### Unexpected Behavior

1. Check preferences.md configuration
2. Review shared-instructions.md for behavior rules
3. Verify agent-specific instructions in the .agent.md file

## Advanced Configuration

### Custom Searches

Create saved searches for quick access:

```yaml
searches:
  my-critical: "is:open label:P0 assignee:@me"
  stale-prs: "is:open is:pr updated:<7-days-ago"
  security-alerts: "is:open label:security"
  a11y-open: "is:open label:accessibility"
  cross-repo-bugs: "is:open label:bug org:my-org"
```

### Notification Preferences

Control which updates appear in briefings:

```yaml
notifications:
  priority_repos:
    - my-org/critical-service
  priority_labels:
    - P0
    - security
    - accessibility
  muted_labels:
    - duplicate
  priority_events:
    - review_requested
    - mentioned
    - assigned
    - ci_failed
```

### CI/CD Monitoring

```yaml
ci:
  monitored_workflows:
    - "Build and Test"
    - "Deploy Production"
  flaky_test_threshold: 3
  long_running_threshold: 30
  monitored_repos: []            # empty = all repos
```

## Need Help?

- **Documentation**: See the `Documentation/` folder
- **Examples**: Check `preferences.example.md` for the complete configuration reference
- **Issues**: Create an issue if something isn't working
- **Discussions**: Use GitHub Discussions for questions

