const fs = require('fs');
const path = require('path');

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

  const context = [];

  // Check for Office scan configuration
  const officeConfigPath = path.join(cwd, '.a11y-office-config.json');
  if (fs.existsSync(officeConfigPath)) {
    try {
      const config = JSON.parse(fs.readFileSync(officeConfigPath, 'utf8'));
      const profile = config.profile || 'custom';
      context.push(`Office scan config: profile=${profile}`);
    } catch {
      context.push('Office scan config: present but could not parse');
    }
  }

  // Check for PDF scan configuration
  const pdfConfigPath = path.join(cwd, '.a11y-pdf-config.json');
  if (fs.existsSync(pdfConfigPath)) {
    try {
      const config = JSON.parse(fs.readFileSync(pdfConfigPath, 'utf8'));
      const profile = config.profile || 'custom';
      context.push(`PDF scan config: profile=${profile}`);
    } catch {
      context.push('PDF scan config: present but could not parse');
    }
  }

  // Check for ePub scan configuration
  const epubConfigPath = path.join(cwd, '.a11y-epub-config.json');
  if (fs.existsSync(epubConfigPath)) {
    try {
      const config = JSON.parse(fs.readFileSync(epubConfigPath, 'utf8'));
      const profile = config.profile || 'custom';
      context.push(`ePub scan config: profile=${profile}`);
    } catch {
      context.push('ePub scan config: present but could not parse');
    }
  }

  // Check for markdownlint configuration
  const markdownlintPaths = ['.markdownlint.json', '.markdownlint-cli2.jsonc', '.markdownlint.yaml'];
  for (const mlPath of markdownlintPaths) {
    if (fs.existsSync(path.join(cwd, mlPath))) {
      context.push(`Markdownlint config: ${mlPath}`);
      break;
    }
  }

  // Check for previous document audit reports
  try {
    const auditFiles = fs.readdirSync(cwd).filter(f =>
      /^DOCUMENT-ACCESSIBILITY-AUDIT.*\.md$/i.test(f)
    );
    if (auditFiles.length > 0) {
      const latest = auditFiles.sort().pop();
      const stat = fs.statSync(path.join(cwd, latest));
      context.push(`Last document audit: ${latest} (${stat.mtime.toISOString().split('T')[0]})`);
    }
  } catch { /* ignore read errors */ }

  // Check for previous web audit reports
  try {
    const webAuditFiles = fs.readdirSync(cwd).filter(f =>
      /^WEB-ACCESSIBILITY-AUDIT.*\.md$/i.test(f)
    );
    if (webAuditFiles.length > 0) {
      const latest = webAuditFiles.sort().pop();
      const stat = fs.statSync(path.join(cwd, latest));
      context.push(`Last web audit: ${latest} (${stat.mtime.toISOString().split('T')[0]})`);
    }
  } catch { /* ignore read errors */ }

  // Check for previous markdown audit reports
  try {
    const mdAuditFiles = fs.readdirSync(cwd).filter(f =>
      /^MARKDOWN-ACCESSIBILITY-AUDIT.*\.md$/i.test(f)
    );
    if (mdAuditFiles.length > 0) {
      const latest = mdAuditFiles.sort().pop();
      const stat = fs.statSync(path.join(cwd, latest));
      context.push(`Last markdown audit: ${latest} (${stat.mtime.toISOString().split('T')[0]})`);
    }
  } catch { /* ignore read errors */ }

  // Only inject context if something relevant was found
  if (context.length === 0) {
    process.stdout.write(JSON.stringify({
      hookSpecificOutput: { hookEventName: 'SessionStart' },
    }));
    process.exit(0);
  }

  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'SessionStart',
      additionalContext: `[Document A11y] ${context.join(' | ')}`,
    },
  }));
  process.exit(0);
});
