#!/usr/bin/env node
/**
 * Markdown accessibility lint script for CI.
 * Uses Node.js built-ins only — no external dependencies.
 * Scans .md files for common accessibility issues:
 *   - Missing image alt text
 *   - Ambiguous link text ("click here", "here", etc.)
 *   - Bare URLs without descriptive text
 *   - Skipped heading levels
 *   - Multiple H1 headings
 *   - Emoji in headings
 *   - Tables without preceding description
 */

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative, extname } from "node:path";

const EXTENSIONS = new Set([".md", ".mdx"]);
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
  } catch {
    return results;
  }
  for (const entry of entries) {
    if (IGNORED_DIRS.has(entry)) continue;
    const full = join(dir, entry);
    let stat;
    try {
      stat = statSync(full);
    } catch {
      continue;
    }
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

// ── Markdown checks ─────────────────────────────────────────────

function checkFile(filePath, root) {
  let content;
  try {
    content = readFileSync(filePath, "utf-8");
  } catch {
    return;
  }

  const rel = relative(root, filePath);
  const lines = content.split("\n");
  let inCodeBlock = false;
  let inFrontMatter = false;
  let lastHeadingLevel = 0;
  let h1Count = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNum = i + 1;

    // Skip YAML front matter
    if (i === 0 && line.trim() === "---") {
      inFrontMatter = true;
      continue;
    }
    if (inFrontMatter) {
      if (line.trim() === "---") inFrontMatter = false;
      continue;
    }

    // Skip fenced code blocks
    if (/^```/.test(line.trim())) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    if (inCodeBlock) continue;

    // 1. Images without alt text: ![](url) or ![ ](url)
    const imgMatches = [...line.matchAll(/!\[([^\]]*)\]\([^)]+\)/g)];
    for (const m of imgMatches) {
      const alt = m[1].trim();
      if (alt.length === 0) {
        addIssue(rel, lineNum, "md-img-alt", "Image missing alt text", "error");
      }
    }

    // 2. HTML img tags without alt (in markdown files)
    const htmlImgMatches = [...line.matchAll(/<img\b[^>]*>/gi)];
    for (const m of htmlImgMatches) {
      if (!/\balt\s*=/i.test(m[0])) {
        addIssue(rel, lineNum, "md-img-alt", "<img> in markdown missing alt attribute", "error");
      }
    }

    // 3. Heading hierarchy
    const headingMatch = line.match(/^(#{1,6})\s+/);
    if (headingMatch) {
      const level = headingMatch[1].length;

      // Multiple H1s
      if (level === 1) {
        h1Count++;
        if (h1Count > 1) {
          addIssue(
            rel,
            lineNum,
            "md-multi-h1",
            "Multiple H1 headings — use only one H1 per document",
            "error"
          );
        }
      }

      // Skipped heading level
      if (lastHeadingLevel > 0 && level > lastHeadingLevel + 1) {
        addIssue(
          rel,
          lineNum,
          "md-heading-skip",
          `Heading level skipped: H${lastHeadingLevel} to H${level}`,
          "error"
        );
      }

      lastHeadingLevel = level;

      // Emoji in heading
      // Match common emoji Unicode ranges
      const headingText = line.slice(headingMatch[0].length);
      if (/[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/u.test(headingText)) {
        addIssue(
          rel,
          lineNum,
          "md-emoji-heading",
          "Emoji in heading — may cause screen reader issues",
          "warning"
        );
      }
    }

    // 4. Ambiguous link text
    const linkMatches = [...line.matchAll(/\[([^\]]+)\]\([^)]+\)/g)];
    for (const m of linkMatches) {
      const text = m[1].trim().toLowerCase();
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
        "this",
        "this page",
      ];
      if (ambiguous.includes(text)) {
        addIssue(
          rel,
          lineNum,
          "md-link-ambiguous",
          `Ambiguous link text "${m[1].trim()}" — use descriptive text`,
          "warning"
        );
      }
    }

    // 5. Bare URLs in prose (not inside links or code)
    // Match URLs not preceded by ( or [ or <
    const bareUrlMatches = [...line.matchAll(/(?<![(<\[])(https?:\/\/[^\s)>\]]+)/g)];
    for (const m of bareUrlMatches) {
      // Skip if the URL is inside a markdown link
      const before = line.slice(0, m.index);
      if (/\]\($/.test(before) || /\[.*$/.test(before)) continue;
      addIssue(
        rel,
        lineNum,
        "md-bare-url",
        "Bare URL in prose — wrap in descriptive link text",
        "warning"
      );
    }

    // 6. Table without preceding description
    if (/^\|/.test(line.trim()) && i > 0) {
      // Check if this is the first row of a table
      const prevLine = lines[i - 1];
      if (prevLine !== undefined && !/^\|/.test(prevLine.trim())) {
        // This is the first row of a table — check for description above
        const prevTrimmed = prevLine.trim();
        if (prevTrimmed === "" || /^#{1,6}\s/.test(prevTrimmed)) {
          addIssue(
            rel,
            lineNum,
            "md-table-desc",
            "Table without preceding description — add a one-sentence summary before the table",
            "warning"
          );
        }
      }
    }
  }
}

// ── Main ────────────────────────────────────────────────────────

const root = process.argv[2] || process.cwd();
const mdFiles = walkDir(root, EXTENSIONS);

console.log(`Scanning ${mdFiles.length} markdown files...\n`);

for (const f of mdFiles) checkFile(f, root);

// ── Output ──────────────────────────────────────────────────────

if (issues.length === 0) {
  console.log("✅ No markdown accessibility issues found.");
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
