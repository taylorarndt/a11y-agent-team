#!/usr/bin/env node
/**
 * Accessibility lint script for CI.
 * Uses Node.js built-ins only — no external dependencies.
 * Scans HTML/JSX/TSX/Vue/Svelte files for common accessibility issues.
 */

import { readFileSync, readdirSync, lstatSync } from "node:fs";
import { join, relative, extname } from "node:path";

const EXTENSIONS = new Set([".html", ".htm", ".jsx", ".tsx", ".vue", ".svelte"]);
const CSS_EXTENSIONS = new Set([".css", ".scss"]);
const IGNORED_DIRS = new Set([
  "node_modules",
  ".git",
  "dist",
  "build",
  ".next",
  ".nuxt",
  "coverage",
  "vendor",
]);

// ── File discovery ──────────────────────────────────────────────

function walkDir(dir, extensions) {
  const results = [];
  let entries;
  try {
    entries = readdirSync(dir);
  } catch { // Directory unreadable — skip silently
    return results;
  }
  for (const entry of entries) {
    if (IGNORED_DIRS.has(entry)) continue;
    const full = join(dir, entry);
    let stat;
    try {
      stat = lstatSync(full);
    } catch { // Stat failed (permissions, broken link) — skip
      continue;
    }
    if (stat.isSymbolicLink()) continue;
    if (stat.isDirectory()) {
      results.push(...walkDir(full, extensions));
    } else if (extensions.has(extname(entry).toLowerCase())) {
      results.push(full);
    }
  }
  return results;
}

// ── Issue tracking ──────────────────────────────────────────────

const issues = [];

function addIssue(file, line, rule, message, severity = "warning") {
  issues.push({ file, line, rule, message, severity });
}

// ── HTML checks ─────────────────────────────────────────────────

function checkFile(filePath, root) {
  let content;
  try {
    content = readFileSync(filePath, "utf-8");
  } catch { // File unreadable — skip silently
    return;
  }

  const rel = relative(root, filePath);
  const lines = content.split("\n");

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNum = i + 1;

    // 1. Images without alt
    // NOTE: This regex only matches <img> tags on a single line.
    // Multi-line HTML tags (e.g., <img\n  src="...">) are not detected.
    const imgMatches = [...line.matchAll(/<img\b[^>]*>/gi)];
    for (const m of imgMatches) {
      const tag = m[0];
      if (!/\balt\s*=/i.test(tag)) {
        addIssue(rel, lineNum, "img-alt", "<img> missing alt attribute", "error");
      }
    }

    // 2. Positive tabindex
    const tabMatches = [...line.matchAll(/tabindex\s*=\s*["']?(\d+)["']?/gi)];
    for (const m of tabMatches) {
      const val = parseInt(m[1], 10);
      if (val > 0) {
        addIssue(
          rel,
          lineNum,
          "tabindex-positive",
          `tabindex="${val}" disrupts natural tab order — use 0 or -1`,
          "error"
        );
      }
    }

    // 3. Div/span with role="button" (should be <button>)
    if (/(<div|<span)[^>]*role\s*=\s*["']button["']/i.test(line)) {
      addIssue(
        rel,
        lineNum,
        "no-div-button",
        'Use <button> instead of <div role="button"> or <span role="button">',
        "warning"
      );
    }

    // 4. onClick on non-interactive elements without role and keyboard handler
    if (/(<div|<span)[^>]*onClick/i.test(line)) {
      if (!/role\s*=\s*["']button["']/i.test(line)) {
        addIssue(
          rel,
          lineNum,
          "click-events-have-key-events",
          "onClick on <div>/<span> without role — use <button> or add role and keyboard handler",
          "warning"
        );
      }
    }

    // 5. Heading structure: empty headings
    const headingMatches = [...line.matchAll(/<h([1-6])\b[^>]*>\s*<\/h\1>/gi)];
    for (const _m of headingMatches) {
      addIssue(rel, lineNum, "heading-has-content", "Empty heading element", "error");
    }

    // 6. Ambiguous link text
    const linkMatches = [
      ...line.matchAll(/<a\b[^>]*>([\s\S]*?)<\/a>/gi),
    ];
    for (const m of linkMatches) {
      const text = m[1].replace(/<[^>]*>/g, "").trim().toLowerCase();
      const ambiguous = [
        "click here",
        "here",
        "read more",
        "more",
        "learn more",
        "link",
        "this link",
        "details",
        "more details",
        "info",
        "more info",
        "go",
        "continue",
      ];
      if (ambiguous.includes(text)) {
        addIssue(
          rel,
          lineNum,
          "link-text-ambiguous",
          `Ambiguous link text "${m[1].trim()}" — use descriptive text`,
          "warning"
        );
      }
    }

    // 7. Form inputs without labels — basic check
    const inputMatches = [
      ...line.matchAll(/<(input|select|textarea)\b([^>]*)>/gi),
    ];
    for (const m of inputMatches) {
      const attrs = m[2];
      // Skip hidden, submit, button, reset, image types
      if (/type\s*=\s*["'](hidden|submit|button|reset|image)["']/i.test(attrs)) {
        continue;
      }
      // Acceptable if has aria-label, aria-labelledby, or id (assumes label for=id elsewhere)
      if (
        /aria-label\s*=/i.test(attrs) ||
        /aria-labelledby\s*=/i.test(attrs) ||
        /\bid\s*=/i.test(attrs) ||
        /title\s*=/i.test(attrs)
      ) {
        continue;
      }
      addIssue(
        rel,
        lineNum,
        "input-has-label",
        `<${m[1]}> may be missing an associated label (no id, aria-label, or aria-labelledby)`,
        "warning"
      );
    }

    // 8. Autocomplete missing on identity fields
    const identityTypes = ["email", "tel", "password", "text"];
    for (const im of inputMatches) {
      const attrs = im[2];
      const typeMatch = attrs.match(/type\s*=\s*["'](\w+)["']/i);
      const type = typeMatch ? typeMatch[1].toLowerCase() : "text";
      if (!identityTypes.includes(type)) continue;
      const nameMatch = attrs.match(/name\s*=\s*["']([^"']+)["']/i);
      if (!nameMatch) continue;
      const name = nameMatch[1].toLowerCase();
      const identityNames = [
        "email",
        "phone",
        "tel",
        "name",
        "fname",
        "lname",
        "first-name",
        "last-name",
        "given-name",
        "family-name",
        "username",
        "address",
        "street",
        "city",
        "state",
        "zip",
        "postal",
        "country",
        "cc-number",
        "cc-name",
        "cc-exp",
      ];
      if (identityNames.some((n) => name.includes(n))) {
        if (!/autocomplete\s*=/i.test(attrs)) {
          addIssue(
            rel,
            lineNum,
            "autocomplete-identity",
            `Input "${nameMatch[1]}" looks like an identity field — add autocomplete attribute (WCAG 1.3.5)`,
            "warning"
          );
        }
      }
    }
  }
}

// ── CSS checks ──────────────────────────────────────────────────

function checkCSSFile(filePath, root) {
  let content;
  try {
    content = readFileSync(filePath, "utf-8");
  } catch { // File unreadable — skip silently
    return;
  }

  const rel = relative(root, filePath);
  const lines = content.split("\n");

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNum = i + 1;

    // Outline removal without :focus-visible alternative
    if (/outline\s*:\s*(none|0)\b/i.test(line)) {
      // Check surrounding context for :focus-visible
      const context = lines
        .slice(Math.max(0, i - 5), Math.min(lines.length, i + 5))
        .join("\n");
      if (!/:focus-visible/i.test(context)) {
        addIssue(
          rel,
          lineNum,
          "no-outline-removal",
          "outline: none/0 without :focus-visible alternative — focus indicator removed",
          "error"
        );
      }
    }
  }
}

// ── Main ────────────────────────────────────────────────────────

const root = process.argv[2] || process.cwd();
const htmlFiles = walkDir(root, EXTENSIONS);
const cssFiles = walkDir(root, CSS_EXTENSIONS);

console.log(
  `Scanning ${htmlFiles.length} markup files and ${cssFiles.length} stylesheet files...\n`
);

// NOTE: walkDir is intentionally duplicated in markdown-a11y-lint.mjs.
// Each linter is designed to be zero-dependency and standalone for CI use.
for (const f of htmlFiles) checkFile(f, root);
for (const f of cssFiles) checkCSSFile(f, root);

// ── Output ──────────────────────────────────────────────────────

if (issues.length === 0) {
  console.log("✅ No accessibility issues found.");
  process.exit(0);
}

// Group by rule
const byRule = {};
for (const issue of issues) {
  if (!byRule[issue.rule]) byRule[issue.rule] = [];
  byRule[issue.rule].push(issue);
}

const errors = issues.filter((i) => i.severity === "error").length;
const warnings = issues.filter((i) => i.severity === "warning").length;

console.log(`Found ${issues.length} issue(s): ${errors} error(s), ${warnings} warning(s)\n`);

for (const [rule, ruleIssues] of Object.entries(byRule)) {
  console.log(`── ${rule} (${ruleIssues.length}) ──`);
  for (const issue of ruleIssues.slice(0, 20)) {
    const prefix = issue.severity === "error" ? "❌" : "⚠️";
    console.log(`  ${prefix} ${issue.file}:${issue.line} — ${issue.message}`);
  }
  if (ruleIssues.length > 20) {
    console.log(`  ... and ${ruleIssues.length - 20} more`);
  }
  console.log();
}

// GitHub Actions annotations
if (process.env.GITHUB_ACTIONS) {
  for (const issue of issues) {
    const level = issue.severity === "error" ? "error" : "warning";
    console.log(
      `::${level} file=${issue.file},line=${issue.line}::${issue.rule}: ${issue.message}`
    );
  }
}

// Exit with error code if any errors found
if (errors > 0) {
  console.log(`\n❌ ${errors} error(s) found. Fix these before merging.`);
  process.exit(1);
}

console.log(`\n⚠️ ${warnings} warning(s) found. Consider fixing these.`);
process.exit(0);
