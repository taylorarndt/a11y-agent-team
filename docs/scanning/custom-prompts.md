# Custom Prompts

Pre-built prompt files in `.github/prompts/` provide one-click workflows for common tasks. Select them from the prompt picker in Copilot Chat.

## Document Accessibility Prompts

| Prompt | What It Does |
|--------|-------------|
| `audit-single-document` | Scan a single .docx, .xlsx, .pptx, or .pdf with severity scoring and metadata dashboard |
| `audit-document-folder` | Recursively scan an entire folder of documents with cross-document analysis |
| `audit-changed-documents` | Delta scan — only audit documents changed since last commit |
| `generate-vpat` | Generate a VPAT 2.5 / ACR compliance report from existing audit results |
| `generate-remediation-scripts` | Create PowerShell/Bash scripts to batch-fix common document issues |
| `compare-audits` | Compare two audit reports side-by-side to track remediation progress |
| `setup-document-cicd` | Set up CI/CD pipelines (GitHub Actions / Azure DevOps) for automated document scanning |
| `quick-document-check` | Fast triage — errors only, high confidence, pass/fail verdict |
| `create-accessible-template` | Guidance for creating accessible Word, Excel, or PowerPoint templates from scratch |

## How to Use

In Copilot Chat, open the prompt picker (click the prompt icon or type `/`) and select a prompt. The prompt provides structured instructions that guide the agent through the workflow.

In Claude Code, the prompt files are not directly invokable but agents reference them. Use the `document-accessibility-wizard` agent for equivalent workflows.
