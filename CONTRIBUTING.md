# Contributing to Accessibility Agents

Thank you for considering a contribution. This is a community-driven project, and every improvement to these agents helps developers ship more inclusive software for blind and low vision users - and everyone else who depends on accessible design.

A sincere thanks goes out to [Taylor Arndt](https://github.com/taylorarndt) and [Jeff Bishop](https://github.com/jeffreybishop) for leading the charge in building this project. Now we want more contributors to help us make more magic. Whether you are a developer, accessibility specialist, screen reader user, or someone who just cares about inclusive software - your contributions are welcome here.

## Ways to Contribute

### Report agent gaps

The most valuable contributions are **agent gap reports** - cases where an agent missed something, gave wrong advice, or suggested unnecessary ARIA. These reports directly improve agent instructions. Use the [Agent Gap](https://github.com/Community-Access/accessibility-agents/issues/new?template=agent_gap.yml) issue template.

### Improve agent instructions

Each agent is a Markdown file with a system prompt. If you know a pattern an agent should catch, or a rule it enforces incorrectly, open a PR with the fix. Agent files live in:

- `.claude/agents/` - Claude Code agents
- `.github/agents/` - GitHub Copilot agents

When updating an agent, update both the Claude Code and Copilot versions to keep them in sync.

### Add framework-specific patterns

The agents are framework-agnostic by default. If you work with React, Vue, Svelte, Angular, or another framework and know accessibility pitfalls specific to it, those patterns are welcome additions to the relevant agent instructions.

### Fix installer or update scripts

The install, update, and uninstall scripts support macOS, Linux, and Windows. Bug fixes and improvements are welcome, especially for edge cases on systems we have not tested.

### Improve documentation

Clearer docs, better examples, typo fixes - all welcome.

## How to Submit a PR

1. Fork the repo
2. Create a branch from `main` (`git checkout -b my-fix`)
3. Make your changes
4. Test on your system (run the installer, verify agents load)
5. Open a PR with a clear description of what changed and why

## Guidelines

- **Keep agent instructions focused.** Each agent owns one domain. Do not add ARIA rules to the contrast agent or focus management to the forms agent.
- **Match the existing style.** Read the agent you are modifying before making changes. Follow the same structure and tone.
- **Update both platforms.** If you change a Claude Code agent, update the matching Copilot agent too (and vice versa).
- **Test your changes.** Install the agents and verify they work. If you changed an agent, try invoking it with a prompt that exercises the change.
- **One concern per PR.** A PR that fixes one agent gap is easier to review than one that changes five agents and the installer.

## Code of Conduct

This project follows a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it. Be kind, be respectful, and remember that accessibility is about including everyone.

## Questions?

Open a [discussion](https://github.com/Community-Access/accessibility-agents/discussions) or file an issue. No question is too basic. We especially welcome questions and feedback from blind and low vision users, screen reader users, and others with direct experience of accessibility barriers - your perspective makes these agents more effective for the people who need them most.
