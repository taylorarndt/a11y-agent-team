const fs = require('fs');
const path = require('path');

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  let cwd, payload;
  try {
    payload = JSON.parse(input);
    cwd = payload.cwd || process.cwd();
  } catch {
    payload = {};
    cwd = process.cwd();
  }

  // Guard against infinite loop — stop hooks can re-trigger the Stop event.
  if (payload.stop_hook_active === true) {
    process.stdout.write(JSON.stringify({ continue: true, hookSpecificOutput: { hookEventName: 'Stop' } }));
    process.exit(0);
  }

  const incomplete = {};

  // ─── Validate document accessibility audit report ──────────────────────────
  try {
    const docAudits = fs.readdirSync(cwd)
      .filter(f => /^DOCUMENT-ACCESSIBILITY-AUDIT.*\.md$/i.test(f));
    if (docAudits.length > 0) {
      const latest = docAudits.sort().pop();
      const content = fs.readFileSync(path.join(cwd, latest), 'utf8');
      const required = [
        'Audit Information',
        'Executive Summary',
        'Accessibility Scorecard',
        'Confidence Summary',
      ];
      const missing = required.filter(s => !content.includes(s));
      if (missing.length > 0) incomplete[`Document audit "${latest}"`] = missing;
    }
  } catch { /* no access — skip */ }

  // ─── Validate web accessibility audit report ───────────────────────────────
  try {
    const webAudits = fs.readdirSync(cwd)
      .filter(f => /^WEB-ACCESSIBILITY-AUDIT.*\.md$/i.test(f));
    if (webAudits.length > 0) {
      const latest = webAudits.sort().pop();
      const content = fs.readFileSync(path.join(cwd, latest), 'utf8');
      const required = [
        'Audit Information',
        'Executive Summary',
        'Accessibility Scorecard',
      ];
      const missing = required.filter(s => !content.includes(s));
      if (missing.length > 0) incomplete[`Web audit "${latest}"`] = missing;
    }
  } catch { /* no access — skip */ }

  if (Object.keys(incomplete).length === 0) {
    process.stdout.write(JSON.stringify({ continue: true, hookSpecificOutput: { hookEventName: 'Stop' } }));
    process.exit(0);
  }

  // One or more reports are incomplete — inject guidance for the agent to act on.
  const lines = ['[A11y Quality Gate] Audit report(s) are missing required sections:'];
  for (const [report, sections] of Object.entries(incomplete)) {
    lines.push(`${report}:`);
    sections.forEach(s => lines.push(`  - ${s}`));
  }
  lines.push('Please complete these sections before finishing the session.');

  process.stdout.write(JSON.stringify({
    continue: true,
    hookSpecificOutput: {
      hookEventName: 'Stop',
      additionalContext: lines.join('\n'),
    },
  }));
  process.exit(0);
});
