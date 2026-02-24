---
description: Set up CI/CD pipeline for automated document accessibility scanning on every push or PR that modifies documents.
mode: agent
tools:
  - askQuestions
---

# Set Up Document Accessibility CI/CD Pipeline

Configure automated document accessibility scanning for your repository.

## Instructions

Use the **document-accessibility-wizard** agent to:

1. Ask which CI/CD platform to target:
   - GitHub Actions
   - Azure DevOps Pipelines
   - Generic CI (shell script)
2. Ask which scan profile to use:
   - Strict (all rules - recommended for public/government documents)
   - Moderate (errors + warnings - good default)
   - Minimal (errors only - for initial adoption)
3. Ask about notification preferences:
   - Comment on the PR with a summary
   - Upload the full report as a build artifact
   - Fail the build if errors are found
   - Send a Slack/Teams notification
4. Generate the pipeline configuration:
   - Trigger on document file changes (.docx, .xlsx, .pptx, .pdf)
   - Delta scan (only changed files) on PRs
   - Full scan on a weekly schedule
   - Upload the audit report as an artifact
5. Generate starter scan configuration files:
   - `.a11y-office-config.json` with the selected profile
   - `.a11y-pdf-config.json` with the selected profile
6. Provide setup instructions for the team

## Handoff Transparency

Announce CI/CD setup progress:
- **Start:** "Setting up document accessibility CI/CD pipeline..."
- **Per step:** Announce which config file or workflow is being generated
- **Completion:** "CI/CD setup complete: [N] files generated. See setup instructions above."
- **On failure:** "Setup failed at [step]: [reason]."
