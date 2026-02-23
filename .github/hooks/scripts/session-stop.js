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

  // Look for audit reports written during this session
  let auditFiles;
  try {
    auditFiles = fs.readdirSync(cwd).filter(f =>
      /^DOCUMENT-ACCESSIBILITY-AUDIT.*\.md$/i.test(f)
    );
  } catch {
    // No access to cwd — skip validation
    process.stdout.write(JSON.stringify({ continue: true }));
    process.exit(0);
  }

  // If no audit report exists, nothing to validate — pass through silently
  if (auditFiles.length === 0) {
    process.stdout.write(JSON.stringify({ continue: true }));
    process.exit(0);
  }

  const latest = auditFiles.sort().pop();
  const reportPath = path.join(cwd, latest);
  let content;
  try {
    content = fs.readFileSync(reportPath, 'utf8');
  } catch {
    process.stdout.write(JSON.stringify({ continue: true }));
    process.exit(0);
  }

  // Validate required sections
  const requiredSections = [
    'Audit Information',
    'Executive Summary',
    'Accessibility Scorecard',
    'Confidence Summary'
  ];

  const missing = requiredSections.filter(section =>
    !content.includes(section)
  );

  if (missing.length === 0) {
    // All required sections present — report is complete
    process.stdout.write(JSON.stringify({ continue: true }));
    process.exit(0);
  }

  // Report incomplete — inject guidance to complete it
  const guidance = [
    `[Document A11y Quality Gate] Audit report "${latest}" is missing required sections:`,
    ...missing.map(s => `  - ${s}`),
    'Please complete these sections before finishing the audit.'
  ].join('\n');

  process.stdout.write(JSON.stringify({
    continue: true,
    hookSpecificOutput: {
      hookEventName: 'SessionEnd',
      additionalContext: guidance
    }
  }));
  process.exit(0);
});
