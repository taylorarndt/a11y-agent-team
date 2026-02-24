#!/usr/bin/env node
/**
 * PDF accessibility scan script for CI.
 * Uses Node.js built-ins only — no external dependencies.
 * Scans PDF files for structure, metadata, and tagging issues.
 * Outputs SARIF for GitHub Code Scanning integration.
 */

import { readFileSync, readdirSync, lstatSync, writeFileSync } from "node:fs";
import { join, relative, extname } from "node:path";

const IGNORED_DIRS = new Set([
  "node_modules", ".git", "dist", "build", ".next", ".nuxt",
  "coverage", "vendor", "__pycache__",
]);

// ── Config loading ──────────────────────────────────────────────

function loadConfig(root) {
  const defaultConfig = {
    enabled: true,
    disabledRules: [],
    severityFilter: ["error", "warning", "tip"],
    maxFileSize: 100 * 1024 * 1024,
  };
  try {
    const raw = readFileSync(join(root, ".a11y-pdf-config.json"), "utf-8");
    return { ...defaultConfig, ...JSON.parse(raw) };
  } catch { return defaultConfig; }
}

// ── PDF parser ──────────────────────────────────────────────────

function parsePdfBasics(buf) {
  const text = buf.toString("latin1");
  const info = {
    hasText: false, isTagged: false, hasTitle: false, title: "",
    hasLang: false, lang: "", hasStructureTree: false, hasBookmarks: false,
    hasForms: false, pageCount: 0, hasLinks: false, hasFigures: false,
    hasAltOnFigures: null, hasTables: false, hasLists: false,
    hasRoleMap: false, hasEmbeddedFonts: false, hasUnicodeMap: false,
    isEncrypted: false,
  };
  if (/\/Encrypt\s/.test(text)) info.isEncrypted = true;
  const pageCountMatch = text.match(/\/Type\s*\/Pages[^>]{0,200}\/Count\s+(\d+)/);
  if (pageCountMatch) info.pageCount = parseInt(pageCountMatch[1]);
  if (/\/MarkInfo\s*<<[^>]{0,200}\/Marked\s+true/i.test(text)) info.isTagged = true;
  if (/\/StructTreeRoot\s/.test(text)) info.hasStructureTree = true;
  if (/\(.*?\)\s*Tj|<[0-9a-fA-F]+>\s*Tj|\[.*?\]\s*TJ/i.test(text)) info.hasText = true;
  const titleMatch = text.match(/\/Title\s*\(([^)\\]*(?:\\.[^)\\]*)*)\)/);
  if (titleMatch && titleMatch[1].trim()) { info.hasTitle = true; info.title = titleMatch[1].replace(/\\(.)/g, '$1').trim(); }
  const titleHex = text.match(/\/Title\s*<([0-9a-fA-F]+)>/);
  if (titleHex && titleHex[1].length > 0) info.hasTitle = true;
  const langMatch = text.match(/\/Lang\s*\(([^)]*)\)/);
  if (langMatch && langMatch[1].trim()) { info.hasLang = true; info.lang = langMatch[1].trim(); }
  if (/\/Type\s*\/Outlines/.test(text) || /\/Outlines\s+\d+\s+\d+\s+R/.test(text)) info.hasBookmarks = true;
  if (/\/AcroForm\s/.test(text)) info.hasForms = true;
  if (/\/Subtype\s*\/Link/.test(text)) info.hasLinks = true;
  if (/\/S\s*\/Figure/.test(text)) info.hasFigures = true;
  if (/\/S\s*\/Table/.test(text)) info.hasTables = true;
  if (/\/S\s*\/L\b/.test(text)) info.hasLists = true;
  if (/\/RoleMap\s*<</.test(text)) info.hasRoleMap = true;
  if (/\/FontFile|\/FontFile2|\/FontFile3/.test(text)) info.hasEmbeddedFonts = true;
  if (/\/ToUnicode\s/.test(text)) info.hasUnicodeMap = true;
  if (info.hasFigures) {
    const figureBlocks = text.match(/\/S\s*\/Figure[\s\S]*?(?:>>|endobj)/gi) || [];
    let withAlt = 0;
    for (const fb of figureBlocks) { if (/\/Alt\s/.test(fb)) withAlt++; }
    info.hasAltOnFigures = withAlt > 0;
  }
  return info;
}

function scanPdf(buf, config) {
  const findings = [];
  const disabled = new Set(config.disabledRules || []);
  const sevFilter = new Set(config.severityFilter || ["error", "warning", "tip"]);
  const info = parsePdfBasics(buf);

  function add(id, sev, msg, loc) {
    if (disabled.has(id) || !sevFilter.has(sev)) return;
    findings.push({ ruleId: id, severity: sev, message: msg, location: loc || "document" });
  }

  if (!info.hasStructureTree) add("PDFUA.01.001", "error", "No structure tree — document is not tagged", "document catalog");
  if (!info.isTagged) add("PDFUA.01.002", "error", "PDF is not marked as tagged", "MarkInfo");
  if (!info.hasLang) add("PDFUA.06.001", "error", "Document language not set", "document catalog");
  if (info.hasFigures && info.hasAltOnFigures === false) add("PDFUA.13.001", "error", "Figure elements without alt text", "structure tree");
  if (info.hasTables) add("PDFUA.19.001", "warning", "Tables detected — verify header cells are designated", "structure tree");
  if (info.hasForms) add("PDFUA.26.001", "warning", "Form fields detected — verify tooltips and tab order", "AcroForm");
  if (!info.hasTitle) add("PDFBP.META.TITLE_PRESENT", "error", "Document title missing", "Info dictionary");
  if (!info.hasText) add("PDFBP.TEXT.EXTRACTABLE", "error", "No extractable text — likely image-only PDF", "page content");
  if (info.hasText && !info.hasUnicodeMap) add("PDFBP.TEXT.UNICODE_MAP", "warning", "No ToUnicode maps for fonts", "font resources");
  if (info.pageCount > 10 && !info.hasBookmarks) add("PDFBP.NAV.BOOKMARKS_FOR_LONG_DOCS", "warning", `${info.pageCount} pages without bookmarks`, "document outlines");
  if (!info.hasText && !disabled.has("PDFBP.TEXT.EXTRACTABLE")) {
    add("PDFQ.REPO.NO_SCANNED_ONLY", "error", "Image-only PDF in repository", "page content");
  }
  if (info.isEncrypted) add("PDFQ.REPO.ENCRYPTED", "warning", "PDF is encrypted — may block AT access", "encryption dictionary");

  return { findings, info };
}

// ── File discovery ──────────────────────────────────────────────

function walkDir(dir) {
  const results = [];
  let entries;
  try { entries = readdirSync(dir); } catch { return results; }
  for (const entry of entries) {
    if (IGNORED_DIRS.has(entry)) continue;
    const full = join(dir, entry);
    let s;
    try { s = lstatSync(full); } catch { continue; }
    if (s.isSymbolicLink()) continue;
    if (s.isDirectory()) results.push(...walkDir(full));
    else if (extname(entry).toLowerCase() === ".pdf") results.push(full);
  }
  return results;
}

// ── SARIF builder ───────────────────────────────────────────────

function buildSarif(allFindings) {
  const ruleMap = new Map();
  const results = [];
  for (const { filePath, findings } of allFindings) {
    for (const f of findings) {
      if (!ruleMap.has(f.ruleId)) {
        ruleMap.set(f.ruleId, {
          id: f.ruleId,
          shortDescription: { text: f.message.split(".")[0] },
          defaultConfiguration: { level: f.severity === "error" ? "error" : f.severity === "warning" ? "warning" : "note" },
        });
      }
      results.push({
        ruleId: f.ruleId,
        level: f.severity === "error" ? "error" : f.severity === "warning" ? "warning" : "note",
        message: { text: f.message },
        locations: [{ physicalLocation: { artifactLocation: { uri: filePath } } }],
      });
    }
  }
  return {
    $schema: "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/main/sarif-2.1/schema/sarif-schema-2.1.0.json",
    version: "2.1.0",
    runs: [{ tool: { driver: { name: "a11y-pdf-scanner", version: "1.0.0", rules: [...ruleMap.values()] } }, results }],
  };
}

// ── Main ────────────────────────────────────────────────────────

const root = process.argv[2] || process.cwd();
const sarifOut = process.argv[3] || "";
const config = loadConfig(root);

if (!config.enabled) {
  console.log("PDF scanning disabled in config.");
  process.exit(0);
}

const files = walkDir(root);
console.log(`Scanning ${files.length} PDF file(s)...\n`);

const allFindings = [];
let totalErrors = 0;
let totalWarnings = 0;

for (const filePath of files) {
  let buf;
  try { buf = readFileSync(filePath); } catch { continue; }

  if (config.maxFileSize && buf.length > config.maxFileSize) {
    console.log(`Skipping ${relative(root, filePath)} (${Math.round(buf.length / 1048576)}MB exceeds limit)`);
    continue;
  }

  const header = buf.toString("latin1", 0, 8);
  if (!header.startsWith("%PDF-")) continue;

  const { findings } = scanPdf(buf, config);
  const rel = relative(root, filePath);
  const errors = findings.filter(f => f.severity === "error").length;
  const warnings = findings.filter(f => f.severity === "warning").length;
  totalErrors += errors;
  totalWarnings += warnings;

  if (findings.length > 0) {
    console.log(`${rel}: ${errors} error(s), ${warnings} warning(s)`);
    for (const f of findings) {
      const prefix = f.severity === "error" ? "  ❌" : "  ⚠️";
      console.log(`${prefix} ${f.ruleId}: ${f.message}`);
    }
    allFindings.push({ filePath: rel, findings });

    if (process.env.GITHUB_ACTIONS) {
      for (const f of findings) {
        const level = f.severity === "error" ? "error" : "warning";
        console.log(`::${level} file=${rel}::${f.ruleId}: ${f.message}`);
      }
    }
  }
}

if (sarifOut && allFindings.length > 0) {
  writeFileSync(sarifOut, JSON.stringify(buildSarif(allFindings), null, 2));
  console.log(`\nSARIF written to: ${sarifOut}`);
}

const total = totalErrors + totalWarnings;
if (total === 0) {
  console.log("\n✅ No PDF accessibility issues found.");
  process.exit(0);
} else {
  console.log(`\nTotal: ${totalErrors} error(s), ${totalWarnings} warning(s) across ${allFindings.length} file(s)`);
  if (totalErrors > 0) {
    console.log(`\n❌ ${totalErrors} error(s) found. Fix these before merging.`);
    process.exit(1);
  }
  console.log(`\n⚠️ ${totalWarnings} warning(s) found. Consider fixing these.`);
  process.exit(0);
}
