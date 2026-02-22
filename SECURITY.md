# Security Policy

## Scope

A11y Agent Team consists of Markdown agent instructions, shell scripts (bash and PowerShell), and a Claude Desktop MCP extension (Node.js). The agents themselves do not execute code, access networks, or store credentials. The installer scripts copy files and optionally create scheduled tasks for auto-updates.

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest release | Yes |
| Older releases | No |

We recommend always using the latest version. If you have auto-updates enabled, you are already on the latest.

## Reporting a Vulnerability

If you discover a security issue, please report it responsibly.

**Do not open a public issue.**

Instead, email the maintainer directly or use [GitHub's private vulnerability reporting](https://github.com/taylorarndt/a11y-agent-team/security/advisories/new).

We will acknowledge receipt within 48 hours and provide a fix or mitigation as quickly as possible.

## What to Report

- Installer scripts executing unintended commands
- Auto-update mechanism pulling from unauthorized sources
- MCP extension (desktop-extension) exposing data it should not
- Any file operation that could overwrite or delete user data unexpectedly

## What Is Not in Scope

- The content of agent instructions (these are prompts, not executable code)
- Accessibility advice accuracy (use the Agent Gap issue template for that)
