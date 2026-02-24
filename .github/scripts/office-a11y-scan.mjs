#!/usr/bin/env node
/**
 * Office document accessibility scan script for CI.
 * Uses Node.js built-ins only — no external dependencies.
 * Scans .docx, .xlsx, .pptx files for common accessibility issues.
 * Outputs SARIF for GitHub Code Scanning integration.
 */

import { readFileSync, readdirSync, lstatSync, writeFileSync } from "node:fs";
import { join, relative, extname } from "node:path";
import { inflateRawSync } from "node:zlib";

const EXTENSIONS = new Set([".docx", ".xlsx", ".pptx"]);
const IGNORED_DIRS = new Set([
  "node_modules", ".git", "dist", "build", ".next", ".nuxt",
  "coverage", "vendor", "__pycache__",
]);

// ── Config loading ──────────────────────────────────────────────

function loadConfig(root) {
  const defaultConfig = {
    docx: { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] },
    xlsx: { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] },
    pptx: { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] },
  };
  try {
    const raw = readFileSync(join(root, ".a11y-office-config.json"), "utf-8");
    return { ...defaultConfig, ...JSON.parse(raw) };
  } catch { return defaultConfig; }
}

// ── ZIP parsing (same as MCP server) ────────────────────────────

function readZipEntries(buf) {
  const searchStart = Math.max(0, buf.length - 65557);
  let eocdOff = -1;
  for (let i = buf.length - 22; i >= searchStart; i--) {
    if (buf.readUInt32LE(i) === 0x06054b50) { eocdOff = i; break; }
  }
  if (eocdOff === -1) throw new Error("Not a valid ZIP file");
  // Detect ZIP64 (EOCD64 locator signature)
  if (eocdOff >= 20) {
    const zip64LocatorOff = eocdOff - 20;
    if (buf.readUInt32LE(zip64LocatorOff) === 0x07064b50) {
      throw new Error("ZIP64 archives are not supported");
    }
  }
  const cdOffset = buf.readUInt32LE(eocdOff + 16);
  const cdCount = buf.readUInt16LE(eocdOff + 10);
  const entries = new Map();
  let pos = cdOffset;
  for (let i = 0; i < cdCount; i++) {
    if (buf.readUInt32LE(pos) !== 0x02014b50) break;
    const method = buf.readUInt16LE(pos + 10);
    const cSize = buf.readUInt32LE(pos + 20);
    const uSize = buf.readUInt32LE(pos + 24);
    const nameLen = buf.readUInt16LE(pos + 28);
    const extraLen = buf.readUInt16LE(pos + 30);
    const commentLen = buf.readUInt16LE(pos + 32);
    const localOff = buf.readUInt32LE(pos + 42);
    const name = buf.toString("utf8", pos + 46, pos + 46 + nameLen);
    entries.set(name, { method, cSize, uSize, localOff });
    pos += 46 + nameLen + extraLen + commentLen;
  }
  return entries;
}

const MAX_INFLATE_BYTES = 200 * 1024 * 1024;

function extractZipEntry(buf, entry) {
  const localOff = entry.localOff;
  if (buf.readUInt32LE(localOff) !== 0x04034b50) throw new Error("Invalid local header");
  const nameLen = buf.readUInt16LE(localOff + 26);
  const extraLen = buf.readUInt16LE(localOff + 28);
  const dataStart = localOff + 30 + nameLen + extraLen;
  const raw = buf.subarray(dataStart, dataStart + entry.cSize);
  if (entry.method === 0) return raw.toString("utf8");
  if (entry.method === 8) {
    if (entry.uSize > MAX_INFLATE_BYTES) {
      throw new Error(`Entry uncompressed size ${entry.uSize} exceeds ${MAX_INFLATE_BYTES} byte limit`);
    }
    return inflateRawSync(raw, { maxOutputLength: MAX_INFLATE_BYTES }).toString("utf8");
  }
  throw new Error(`Unsupported compression: ${entry.method}`);
}

function getZipXml(buf, entries, path) {
  const entry = entries.get(path);
  if (!entry) return "";
  try { return extractZipEntry(buf, entry); } catch { return ""; }
}

// ── XML helpers ─────────────────────────────────────────────────

function xmlText(xml, tag) {
  const matches = [];
  const re = new RegExp(`<${tag}[^>]*>([\\s\\S]*?)</${tag}>`, "gi");
  let m;
  while ((m = re.exec(xml)) !== null) matches.push(m[1].replace(/<[^>]+>/g, "").trim());
  return matches;
}
function xmlAttr(xml, tag, attr) {
  const matches = [];
  const re = new RegExp(`<${tag}[^>]*?\\b${attr}\\s*=\\s*"([^"]*)"`, "gi");
  let m;
  while ((m = re.exec(xml)) !== null) matches.push(m[1]);
  return matches;
}
function xmlHas(xml, tag) { return new RegExp(`<${tag}[\\s/>]`, "i").test(xml); }
function xmlCount(xml, tag) { let c = 0; const re = new RegExp(`<${tag}[\\s/>]`, "gi"); while (re.exec(xml)) c++; return c; }

// ── Scanners (mirrored from MCP server) ─────────────────────────

function scanDocx(buf, entries, config) {
  const findings = [];
  const disabled = new Set(Array.isArray(config.disabledRules) ? config.disabledRules : []);
  const sevFilter = new Set(Array.isArray(config.severityFilter) ? config.severityFilter : ["error", "warning", "tip"]);
  const doc = getZipXml(buf, entries, "word/document.xml");
  const core = getZipXml(buf, entries, "docProps/core.xml");
  function add(id, sev, msg, loc) {
    if (disabled.has(id) || !sevFilter.has(sev)) return;
    findings.push({ ruleId: id, severity: sev, message: msg, location: loc || "document" });
  }
  const titles = xmlText(core, "dc:title");
  if (!titles.length || !titles[0]) add("DOCX-E004", "error", "Document title is not set", "docProps/core.xml");
  if (!xmlHas(doc, "w:lang") && !xmlHas(core, "dc:language")) add("DOCX-T001", "tip", "Document language is not set", "word/settings.xml");
  const headingStyles = doc.match(/<w:pStyle\s+w:val="Heading\d"/gi) || [];
  if (headingStyles.length === 0) add("DOCX-E007", "error", "Document has zero headings", "word/document.xml");
  const drawings = doc.match(/<w:drawing>[\s\S]*?<\/w:drawing>/gi) || [];
  let imgNoAlt = 0;
  for (const d of drawings) {
    const descrs = [...xmlAttr(d, "wp:docPr", "descr"), ...xmlAttr(d, "pic:cNvPr", "descr")];
    if (descrs.length === 0 || descrs.every(v => !v.trim())) imgNoAlt++;
  }
  if (imgNoAlt > 0) add("DOCX-E001", "error", `${imgNoAlt} image(s) missing alt text`, "word/document.xml");
  const tables = doc.match(/<w:tbl>[\s\S]*?<\/w:tbl>/gi) || [];
  let tblNoHeader = 0;
  for (const t of tables) { if (!xmlHas(t, "w:tblHeader")) tblNoHeader++; }
  if (tblNoHeader > 0) add("DOCX-E002", "error", `${tblNoHeader} table(s) without header rows`, "word/document.xml");
  let mergedCells = xmlCount(doc, "w:gridSpan") + xmlCount(doc, "w:vMerge");
  if (mergedCells > 0) add("DOCX-E005", "error", `${mergedCells} merged cell(s) found`, "word/document.xml");
  return findings;
}

function scanXlsx(buf, entries, config) {
  const findings = [];
  const disabled = new Set(Array.isArray(config.disabledRules) ? config.disabledRules : []);
  const sevFilter = new Set(Array.isArray(config.severityFilter) ? config.severityFilter : ["error", "warning", "tip"]);
  const workbook = getZipXml(buf, entries, "xl/workbook.xml");
  const core = getZipXml(buf, entries, "docProps/core.xml");
  function add(id, sev, msg, loc) {
    if (disabled.has(id) || !sevFilter.has(sev)) return;
    findings.push({ ruleId: id, severity: sev, message: msg, location: loc || "workbook" });
  }
  const titles = xmlText(core, "dc:title");
  if (!titles.length || !titles[0]) add("XLSX-E006", "error", "Workbook title is not set", "docProps/core.xml");
  const sheetNames = xmlAttr(workbook, "sheet", "name");
  const defaultNames = sheetNames.filter(n => /^Sheet\d+$/i.test(n));
  if (defaultNames.length > 0) add("XLSX-E003", "error", `${defaultNames.length} sheet(s) using default names`, "xl/workbook.xml");
  const sheetFiles = [...entries.keys()].filter(k => /^xl\/worksheets\/sheet\d+\.xml$/.test(k));
  let totalMerged = 0;
  for (const sf of sheetFiles) { totalMerged += xmlCount(getZipXml(buf, entries, sf), "mergeCell"); }
  if (totalMerged > 0) add("XLSX-E004", "error", `${totalMerged} merged cell region(s) found`, "worksheets");
  return findings;
}

function scanPptx(buf, entries, config) {
  const findings = [];
  const disabled = new Set(Array.isArray(config.disabledRules) ? config.disabledRules : []);
  const sevFilter = new Set(Array.isArray(config.severityFilter) ? config.severityFilter : ["error", "warning", "tip"]);
  const core = getZipXml(buf, entries, "docProps/core.xml");
  function add(id, sev, msg, loc) {
    if (disabled.has(id) || !sevFilter.has(sev)) return;
    findings.push({ ruleId: id, severity: sev, message: msg, location: loc || "presentation" });
  }
  const titles = xmlText(core, "dc:title");
  if (!titles.length || !titles[0]) add("PPTX-W001", "warning", "Presentation title is not set", "docProps/core.xml");
  const slideFiles = [...entries.keys()].filter(k => /^ppt\/slides\/slide\d+\.xml$/.test(k)).sort();
  let noTitle = 0;
  for (const sf of slideFiles) {
    const xml = getZipXml(buf, entries, sf);
    if (!/ph\s+type="(title|ctrTitle)"/i.test(xml)) noTitle++;
  }
  if (noTitle > 0) add("PPTX-E002", "error", `${noTitle} slide(s) missing titles`, "ppt/slides");
  return findings;
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
    else if (EXTENSIONS.has(extname(entry).toLowerCase())) results.push(full);
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
    runs: [{ tool: { driver: { name: "a11y-office-scanner", version: "1.0.0", rules: [...ruleMap.values()] } }, results }],
  };
}

// ── Main ────────────────────────────────────────────────────────

const root = process.argv[2] || process.cwd();
const sarifOut = process.argv[3] || "";
const config = loadConfig(root);
const files = walkDir(root);

console.log(`Scanning ${files.length} Office document(s)...\n`);

const allFindings = [];
let totalErrors = 0;
let totalWarnings = 0;

for (const filePath of files) {
  const ext = extname(filePath).toLowerCase().slice(1);
  const typeConfig = config[ext] || { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] };
  if (!typeConfig.enabled) continue;

  let buf;
  try { buf = readFileSync(filePath); } catch { continue; }
  let entries;
  try { entries = readZipEntries(buf); } catch { continue; }

  let findings;
  if (ext === "docx") findings = scanDocx(buf, entries, typeConfig);
  else if (ext === "xlsx") findings = scanXlsx(buf, entries, typeConfig);
  else findings = scanPptx(buf, entries, typeConfig);

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

    // GitHub Actions annotations
    if (process.env.GITHUB_ACTIONS) {
      for (const f of findings) {
        const level = f.severity === "error" ? "error" : "warning";
        console.log(`::${level} file=${rel}::${f.ruleId}: ${f.message}`);
      }
    }
  }
}

// Write SARIF
if (sarifOut && allFindings.length > 0) {
  writeFileSync(sarifOut, JSON.stringify(buildSarif(allFindings), null, 2));
  console.log(`\nSARIF written to: ${sarifOut}`);
}

// Summary
const total = totalErrors + totalWarnings;
if (total === 0) {
  console.log("\n✅ No Office document accessibility issues found.");
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
