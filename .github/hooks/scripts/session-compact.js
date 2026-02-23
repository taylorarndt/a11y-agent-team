const fs = require('fs');
const path = require('path');

// PreCompact hook — fires before VS Code compacts the conversation context.
// Extracts the most important audit findings and active config state so they
// survive the compaction and remain available to the agent afterward.

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  let cwd;
  try {
    const hookInput = JSON.parse(input);
    cwd = hookInput.cwd || process.cwd();
  } catch {
    cwd = process.cwd();
  }

  const preserved = [];

  // ─── Preserve active scan configs ──────────────────────────────────────────
  const configFiles = [
    '.a11y-web-config.json',
    '.a11y-office-config.json',
    '.a11y-pdf-config.json',
  ];
  const activeConfigs = configFiles
    .filter(f => fs.existsSync(path.join(cwd, f)))
    .map(f => {
      try {
        const cfg = JSON.parse(fs.readFileSync(path.join(cwd, f), 'utf8'));
        return `${f} (profile: ${cfg.profile || 'custom'})`;
      } catch {
        return f;
      }
    });
  if (activeConfigs.length > 0) {
    preserved.push(`Active scan configs: ${activeConfigs.join(', ')}`);
  }

  // ─── Preserve web accessibility audit scorecard ─────────────────────────────
  try {
    const webAudits = fs.readdirSync(cwd)
      .filter(f => /^WEB-ACCESSIBILITY-AUDIT.*\.md$/i.test(f));
    if (webAudits.length > 0) {
      const latest = webAudits.sort().pop();
      const content = fs.readFileSync(path.join(cwd, latest), 'utf8');
      // Grab the scorecard section
      const match = content.match(/##[^\n]*(?:Scorecard|Summary)[^\n]*\n([\s\S]{1,1200}?)(?=\n##|\n---)/i);
      if (match) {
        preserved.push(
          `Web audit "${latest}" — scorecard excerpt:\n${match[1].trim().slice(0, 800)}`
        );
      } else {
        preserved.push(`Web audit in progress: ${latest}`);
      }
    }
  } catch { /* ignore */ }

  // ─── Preserve document accessibility audit scorecard ───────────────────────
  try {
    const docAudits = fs.readdirSync(cwd)
      .filter(f => /^DOCUMENT-ACCESSIBILITY-AUDIT.*\.md$/i.test(f));
    if (docAudits.length > 0) {
      const latest = docAudits.sort().pop();
      const content = fs.readFileSync(path.join(cwd, latest), 'utf8');
      const match = content.match(/##[^\n]*(?:Scorecard|Summary)[^\n]*\n([\s\S]{1,1200}?)(?=\n##|\n---)/i);
      if (match) {
        preserved.push(
          `Document audit "${latest}" — scorecard excerpt:\n${match[1].trim().slice(0, 800)}`
        );
      } else {
        preserved.push(`Document audit in progress: ${latest}`);
      }
    }
  } catch { /* ignore */ }

  if (preserved.length === 0) {
    process.stdout.write(JSON.stringify({
      continue: true,
      hookSpecificOutput: { hookEventName: 'PreCompact' },
    }));
    process.exit(0);
  }

  process.stdout.write(JSON.stringify({
    continue: true,
    hookSpecificOutput: {
      hookEventName: 'PreCompact',
      additionalContext: [
        '[COMPACTION GUARD — key audit context preserved across context window reset]',
        ...preserved,
      ].join('\n\n'),
    },
  }));
  process.exit(0);
});
