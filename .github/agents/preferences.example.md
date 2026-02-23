# Workspace Preferences - Example Configuration

**Copy this file to `preferences.md` and customize for your workspace.**

This file shows examples of all available configuration options. You can copy sections you need and remove the rest.

---

## Repository Discovery & Scope

Control which repos the agents scan and how broadly they search.

```yaml
repos:
  # How agents discover repos when no specific repo is mentioned.
  # Options: all | starred | owned | configured | workspace
  #   all        -- Search ALL repos the user has access to (public, private, org member).
  #                 This is the default. Agents use the GitHub Search API with
  #                 the authenticated user's token, which automatically covers
  #                 every repo they can read.
  #   starred    -- Only repos the user has starred.
  #   owned      -- Only repos the user owns (excludes org repos they're a member of).
  #   configured -- Only repos explicitly listed below in 'include'.
  #   workspace  -- Only the repo detected from the current workspace directory.
  discovery: all

  # Repos to ALWAYS include in every search, regardless of discovery mode.
  # These are your "pinned" repos -- they always show up in briefings,
  # issue sweeps, PR queues, and accessibility tracking.
  include:
    - owner/core-api
    - owner/frontend-app
    - owner/mobile-app

  # Repos to NEVER include, even if discovery would find them.
  # Great for archiving noisy forks, sandbox repos, or legacy projects.
  exclude:
    - owner/archived-legacy
    - owner/fork-of-something
    - owner/experimental-sandbox

  # Per-repo overrides -- fine-grained control over what each agent
  # tracks for specific repos. These override the global defaults.
  overrides:
    "owner/core-api":
      track:
        issues: true
        pull_requests: true
        discussions: true
        releases: true
        security: true
        ci: true
      labels:
        priority: ["P0", "P1", "critical"]
        include: []              # only show items with these labels (empty = all)
        exclude: ["wontfix"]     # hide items with these labels
      paths:                     # only trigger reviews/alerts for changes in these paths
        - "src/**"
        - "lib/**"
      assignees: []              # filter to specific assignees (empty = all)

    "owner/docs-site":
      track:
        issues: true
        pull_requests: true
        discussions: false       # no discussions for docs repo
        releases: false
        security: false
        ci: false
      labels:
        include: ["content", "bug", "typo"]
        exclude: []

    "microsoft/vscode":
      track:
        issues: true             # accessibility tracking
        pull_requests: false     # don't track PRs in vscode
        discussions: false
        releases: true           # track stable/insiders releases
        security: false
        ci: false
      labels:
        include: ["accessibility"]

  # Default tracking settings applied to all repos not listed in 'overrides'.
  defaults:
    track:
      issues: true
      pull_requests: true
      discussions: true
      releases: true
      security: true
      ci: true
    labels:
      include: []                # empty = show all labels
      exclude: ["wontfix", "duplicate"]
    paths: []                    # empty = all paths
    assignees: []                # empty = all assignees
```

---

## Accessibility Tracking

Configure which repos and labels the accessibility tracker monitors.
`microsoft/vscode` is tracked by default. Add your own repos to extend coverage.

```yaml
accessibility_tracking:
  # Enable/disable the accessibility section in daily briefings
  enabled: true

  # Repos to track for accessibility improvements.
  # Each repo can define its own labels and channels.
  repos:
    - repo: microsoft/vscode
      labels:
        accessibility: "accessibility"        # main a11y label
        insiders: "insiders-released"         # insiders channel label
      channels:
        insiders: true                        # track Insiders builds
        stable: true                          # track Stable releases
      use_milestones: true                    # use milestone-based filtering

    - repo: owner/my-web-app
      labels:
        accessibility: "a11y"                 # your repo's a11y label name
        insiders: ""                          # no insiders concept -- leave empty
      channels:
        insiders: false
        stable: true                          # just track closed a11y issues
      use_milestones: false                   # use date-based filtering instead

    - repo: owner/design-system
      labels:
        accessibility: "accessibility"
        insiders: ""
      channels:
        insiders: false
        stable: true
      use_milestones: false

  # WCAG cross-referencing in reports
  wcag_references: true                       # map fixes to WCAG criteria
  aria_patterns: true                         # map fixes to ARIA design patterns

  # How many recent items to show in daily briefing a11y section
  briefing_limit: 10
```

---

## Merge Strategy

```yaml
merge:
  default_strategy: squash    # squash | rebase | merge
  delete_branch_after: true   # auto-offer to delete source branch
  require_ci_pass: true       # block merge if CI is failing
```

---

## Default Reviewers

```yaml
reviewers:
  default:
    - teamlead
    - senior-dev
  by_path:
    "src/auth/**":
      - security-team
    "src/frontend/**":
      - frontend-team
      - ux-designer
    "docs/**":
      - technical-writer
    "*.md":
      - documentation-team
    "package.json":
      - devops-team
    "Dockerfile":
      - devops-team
      - security-team
```

---

## Labels & Priority System

```yaml
labels:
  priority:
    - P0          # critical -- drop everything
    - P1          # high -- this sprint  
    - P2          # medium -- next sprint
    - P3          # low -- backlog
  type:
    - bug
    - feature
    - enhancement
    - task
    - documentation
    - refactoring
    - performance
  status:
    - needs-triage
    - needs-info
    - in-progress
    - blocked
    - ready-for-review
  area:
    - frontend
    - backend
    - infrastructure
    - security
    - accessibility
    - testing
```

---

## Response Templates

```yaml
templates:
  needs-info: |
    Thanks for reporting! To help us investigate, could you provide:
    
    1. **Steps to reproduce** the issue
    2. **Expected behavior** vs **actual behavior**
    3. **Environment details** (OS, browser, version)
    4. **Screenshots or logs** if available
    
    This will help us resolve the issue quickly. Thank you!
    
  duplicate: |
    Thanks for reporting! This appears to be a duplicate of #{ref}.
    
    Please follow that issue for updates and add any additional context there if needed.
    
  wontfix: |
    After team discussion, we've decided not to pursue this feature because {reason}.
    
    We appreciate the suggestion! If circumstances change or you'd like to discuss further, please feel free to reopen this issue or start a discussion.
    
  welcome: |
    Welcome to the project! Thanks for your first contribution.
    
    A maintainer will review this shortly. If you have questions while you wait, feel free to ask here or in our discussions.
    
  stale-closing: |
    This issue has been inactive for 30+ days with no response to requests for information.
    
    Closing for now to keep our issue tracker manageable. Feel free to reopen if this is still relevant -- just provide the requested details.
    
  security-ack: |
    Thanks for the security report!
    
    We've received your report and will investigate promptly. For security issues, please email security@company.com instead of posting publicly.
    
  good-first-issue: |
    This looks like a great first contribution opportunity!
    
    Added the `good first issue` label. New contributors: check our [contributing guide](../CONTRIBUTING.md) to get started.
```

---

## Saved Searches

```yaml
searches:
  # Personal productivity
  my-issues: "is:open is:issue assignee:@me"
  my-prs: "is:open is:pr author:@me"
  my-reviews: "is:open is:pr review-requested:@me"
  my-mentions: "is:open mentions:@me"
  
  # Team workflow
  needs-triage: "is:open no:label no:assignee"
  needs-review: "is:open is:pr label:ready-for-review"
  in-progress: "is:open label:in-progress"
  blocked: "is:open label:blocked"
  
  # Priority and urgency
  critical: "is:open label:P0"
  high-priority: "is:open label:P0,P1"
  security: "is:open label:security"
  bugs: "is:open label:bug"
  
  # Maintenance
  stale-issues: "is:open is:issue updated:<14-days-ago"
  stale-prs: "is:open is:pr updated:<7-days-ago"
  no-response: "is:open label:needs-info updated:<7-days-ago"
  
  # Community
  first-time: "is:open author:@-member"
  help-wanted: "is:open label:help-wanted"
  good-first-issues: "is:open label:good-first-issue"
  
  # Release management
  milestone-blockers: "is:open milestone:* label:P0,P1"
  release-ready: "is:closed milestone:* closed:>2023-01-01"
```

---

## Team Roster

```yaml
team:
  - name: Alice Johnson
    github: alice
    expertise:
      - backend
      - security
      - databases
    timezone: America/New_York
    
  - name: Bob Chen
    github: bobchen
    expertise:
      - frontend
      - React
      - accessibility
    timezone: America/Los_Angeles
    
  - name: Charlie Kumar
    github: ckumar
    expertise:
      - devops
      - kubernetes
      - monitoring
    timezone: Europe/London
    
  - name: Diana Rodriguez
    github: drodriguez
    expertise:
      - design-systems
      - CSS
      - user-experience
    timezone: America/Chicago
    
  - name: Eve Park
    github: epark
    expertise:
      - documentation
      - technical-writing
      - product-management
    timezone: Asia/Seoul
```

---

## Notification Preferences

```yaml
notifications:
  priority_repos:
    - company/core-api
    - company/user-dashboard  
    - company/mobile-app
    
  muted_repos:
    - company/archived-legacy
    - company/experimental-sandbox
    
  priority_labels:
    - P0
    - P1 
    - critical
    - security
    - accessibility
    
  muted_labels:
    - wontfix
    - duplicate
    - question
    
  priority_events:
    - review_requested
    - mentioned
    - assigned
    - ci_failed
    
  muted_events:
    - subscribed      # auto-subscribed threads
    - labeled         # label changes
```

---

## Briefing Preferences

Control what appears in daily briefings and how sections are organized.

```yaml
briefing:
  # Which sections to include in the daily briefing.
  # Set to false to disable a section entirely.
  sections:
    action_needed: true          # issues/PRs waiting on you
    releases: true               # recent and upcoming releases
    discussions: true            # GitHub Discussions activity
    ci_cd: true                  # CI/CD health dashboard
    security: true               # security alerts and advisories
    projects: true               # project board status
    monitor: true                # items to keep an eye on
    accessibility: true          # accessibility tracking section
    completed: true              # recently completed work
    guidance: true               # patterns and recommendations

  # Maximum items per section (0 = no limit)
  max_items_per_section: 15

  # Include cross-repo related items in briefings.
  # When true, the briefing also surfaces related issues/PRs from
  # repos you don't directly own but have access to.
  cross_repo_related: true

  # Auto-detect related items across repos by matching:
  related_matching:
    - keywords                   # match by issue/PR title keywords
    - labels                     # match by shared label names
    - mentions                   # match by @username mentions
    - linked                     # match by explicit cross-repo links

  # Render format: which formats to auto-generate
  formats:
    markdown: true
    html: true
```

---

## Search & Discovery Preferences

Control how agents search and discover content across GitHub.

```yaml
search:
  # Default time window when no date range is specified
  default_window: 30d           # 7d | 14d | 30d | 60d | 90d

  # Maximum results to fetch per search query before paginating
  page_size: 10

  # Auto-broaden search when 0 results found
  auto_broaden: true

  # Auto-narrow search when >50 results found
  auto_narrow: true

  # Cross-repo search: also search repos that are related to
  # items found in your primary repos (e.g., dependencies, forks)
  follow_references: true

  # Organization-wide search: search across entire orgs you belong to
  org_search: true
  orgs:                          # leave empty to auto-detect from user membership
    - my-company
    - my-oss-org
```

---

## Working Hours & Timezone

```yaml
schedule:
  timezone: America/New_York
  working_hours:
    start: "09:00" 
    end: "17:00"
  working_days:
    - Monday
    - Tuesday  
    - Wednesday
    - Thursday
    - Friday
  vacation_mode: false        # set true to reduce notifications
```

---

## CI/CD Preferences

```yaml
ci:
  monitored_workflows:
    - "Build and Test"
    - "Deploy to Staging"
    - "Deploy to Production"
    - "Security Scan"
    
  flaky_test_threshold: 3       # flag tests failing N+ times in 7 days
  long_running_threshold: 30    # flag jobs running longer than N minutes
  
  monitored_repos:              # leave empty for all repos
    - company/core-api
    - company/frontend
    - company/mobile-app
```

---

## Security Preferences

```yaml
security:
  alert_severity:
    - critical
    - high
    # - medium              # uncomment to include medium
    # - low                 # uncomment to include low
    
  auto_flag_dependabot: true    # flag Dependabot PRs in briefings
  
  monitored_repos:              # leave empty for all repos
    - company/core-api
    - company/payment-service
```

---

## Project Board Preferences  

```yaml
projects:
  active:
    - project_number: 1
      org: company
      name: "Sprint Board"
    - project_number: 2  
      org: company
      name: "Roadmap 2024"
      
  show_in_briefing: true        # include project status
  show_in_issues: true          # show project column for issues
```

---

## Custom Workflow Settings

```yaml
workflow:
  auto_assign_author: true      # assign PR authors to their own PRs
  require_issue_link: false     # require PRs to reference an issue
  
  branch_protection:
    require_reviews: 2
    dismiss_stale: true
    require_codeowner: true
    
  pr_checks:
    require_description: true
    min_description_length: 50
    require_test_plan: false
```