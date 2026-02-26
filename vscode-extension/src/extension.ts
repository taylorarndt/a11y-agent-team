import * as vscode from "vscode";
import * as path from "path";
import * as fs from "fs/promises";

/** Maps slash-command names to the .agent.md filename stem(s) they route to. */
const COMMAND_AGENT_MAP: Record<string, string[]> = {
  aria: ["aria-specialist"],
  contrast: ["contrast-master"],
  keyboard: ["keyboard-navigator"],
  forms: ["forms-specialist"],
  "alt-text": ["alt-text-headings"],
  tables: ["tables-data-specialist"],
  links: ["link-checker"],
  modal: ["modal-specialist"],
  "live-region": ["live-region-controller"],
  audit: ["web-accessibility-wizard"],
  document: ["document-accessibility-wizard"],
  markdown: ["markdown-a11y-assistant"],
  test: ["testing-coach"],
  wcag: ["wcag-guide"],
  cognitive: ["cognitive-accessibility"],
  mobile: ["mobile-accessibility"],
  "design-system": ["design-system-auditor"],
};

/** The default agent used when no slash command is given. */
const DEFAULT_AGENT = "accessibility-lead";

/**
 * Try to locate the `.github/agents/` folder by walking up from likely roots.
 * Returns the first path that exists, or undefined.
 */
async function findAgentsDir(): Promise<string | undefined> {
  const folders = vscode.workspace.workspaceFolders;
  if (!folders) {
    return undefined;
  }

  for (const folder of folders) {
    const candidate = path.join(folder.uri.fsPath, ".github", "agents");
    try {
      const info = await fs.stat(candidate);
      if (info.isDirectory()) {
        return candidate;
      }
    } catch {
      // not found in this folder, try next
    }
  }
  return undefined;
}

/**
 * Read the body of an agent file (everything after the YAML frontmatter).
 * Returns the system-prompt text, or a fallback message.
 */
async function readAgentBody(
  agentsDir: string,
  stem: string
): Promise<string> {
  const filePath = path.join(agentsDir, `${stem}.agent.md`);
  try {
    const raw = await fs.readFile(filePath, "utf-8");

    // Strip YAML frontmatter (--- ... ---)
    const fmMatch = raw.match(/^---\r?\n[\s\S]*?\r?\n---\r?\n?/);
    if (fmMatch) {
      return raw.slice(fmMatch[0].length).trim();
    }
    return raw.trim();
  } catch {
    return `(Could not load agent instructions from ${stem}.agent.md)`;
  }
}

/**
 * Build the full system prompt for the participant turn by loading the
 * relevant agent file(s).
 */
async function buildSystemPrompt(
  agentsDir: string,
  stems: string[]
): Promise<string> {
  const parts: string[] = [];
  for (const stem of stems) {
    const body = await readAgentBody(agentsDir, stem);
    parts.push(body);
  }
  return parts.join("\n\n---\n\n");
}

export function activate(context: vscode.ExtensionContext) {
  const participant = vscode.chat.createChatParticipant(
    "a11y-agent-team.a11y",
    handler
  );

  participant.iconPath = vscode.Uri.joinPath(
    context.extensionUri,
    "icon.png"
  );

  context.subscriptions.push(participant);
}

const handler: vscode.ChatRequestHandler = async (
  request,
  _context,
  stream,
  token
) => {
  // Determine which agent file(s) to load based on slash command
  const command = request.command;
  let stems: string[];

  if (command && command in COMMAND_AGENT_MAP) {
    stems = COMMAND_AGENT_MAP[command];
  } else if (command) {
    stream.markdown(
      `> Unknown command \`/${command}\`. Routing to the Accessibility Lead.\n\n`
    );
    stems = [DEFAULT_AGENT];
  } else {
    stems = [DEFAULT_AGENT];
  }

  // Locate agent definitions in the workspace
  const agentsDir = await findAgentsDir();
  if (!agentsDir) {
    stream.markdown(
      "I could not find the `.github/agents/` directory in your workspace. " +
        "Please open the **accessibility-agents** repository so I can load " +
        "the specialist instructions.\n\n" +
        "I will do my best with built-in knowledge.\n\n"
    );
  }

  // Build system prompt from agent files
  let systemPrompt = "";
  if (agentsDir) {
    systemPrompt = await buildSystemPrompt(agentsDir, stems);
  }

  if (token.isCancellationRequested) {
    return;
  }

  // Assemble messages — system context + user prompt
  const messages: vscode.LanguageModelChatMessage[] = [];

  if (systemPrompt) {
    messages.push(
      vscode.LanguageModelChatMessage.User(
        `You are an accessibility specialist. Apply these instructions:\n\n${systemPrompt}`
      )
    );
  }

  messages.push(
    vscode.LanguageModelChatMessage.User(request.prompt)
  );

  // Use the model the user already selected in the chat view
  const chatResponse = await request.model.sendRequest(messages, {}, token);

  for await (const fragment of chatResponse.text) {
    if (token.isCancellationRequested) {
      return;
    }
    stream.markdown(fragment);
  }
};

export function deactivate() {
  // nothing to clean up
}
