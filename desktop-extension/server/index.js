import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { execFile } from "node:child_process";
import { readFile as fsReadFile, writeFile as fsWriteFile, unlink, stat } from "node:fs/promises";
import { tmpdir, homedir } from "node:os";
import { join, dirname, extname, basename, resolve, sep } from "node:path";
import { randomUUID } from "node:crypto";
import { promisify } from "node:util";
import { inflateRawSync } from "node:zlib";

const execFileAsync = promisify(execFile);

/**
 * Resolve an output path and verify it stays within the user's home directory
 * or the current working directory. Prevents writing to arbitrary system paths.
 */
function validateOutputPath(inputPath) {
  const resolved = resolve(inputPath);
  const home = homedir();
  const cwd = process.cwd();
  const underHome = resolved === home || resolved.startsWith(home + sep);
  const underCwd  = resolved === cwd  || resolved.startsWith(cwd  + sep);
  if (!underHome && !underCwd) {
    throw new Error(
      `Output path must be within your home directory or current working directory. ` +
      `Resolved: ${resolved}`
    );
  }
  return resolved;
}

const server = new McpServer({
  name: "a11y-agent-team",
  version: "1.0.0",
});

// --- Contrast Calculation ---

function srgbToLinear(c) {
  c = c / 255;
  return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

function relativeLuminance(hex) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return 0.2126 * srgbToLinear(r) + 0.7152 * srgbToLinear(g) + 0.0722 * srgbToLinear(b);
}

function contrastRatio(hex1, hex2) {
  const l1 = relativeLuminance(hex1);
  const l2 = relativeLuminance(hex2);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// --- Tools ---

server.registerTool(
  "check_contrast",
  {
    title: "Check Contrast Ratio",
    description:
      "Calculate WCAG contrast ratio between two colors. Returns the ratio and whether it passes AA for normal text (4.5:1), large text (3:1), and UI components (3:1).",
    inputSchema: z.object({
      foreground: z
        .string()
        .describe('Foreground color as hex (e.g. "#1a1a1a" or "#fff")'),
      background: z
        .string()
        .describe('Background color as hex (e.g. "#ffffff" or "#000")'),
    }),
  },
  async ({ foreground, background }) => {
    // Normalize short hex
    const expand = (h) => {
      h = h.replace("#", "");
      if (h.length === 3) h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
      return "#" + h.toLowerCase();
    };

    try {
      const fg = expand(foreground);
      const bg = expand(background);
      const ratio = contrastRatio(fg, bg);
      const rounded = Math.round(ratio * 100) / 100;

      const normalText = ratio >= 4.5 ? "PASS" : "FAIL";
      const largeText = ratio >= 3.0 ? "PASS" : "FAIL";
      const uiComponent = ratio >= 3.0 ? "PASS" : "FAIL";

      const lines = [
        `Contrast Ratio: ${rounded}:1`,
        ``,
        `WCAG AA Results:`,
        `  Normal text (4.5:1 required): ${normalText}`,
        `  Large text (3:1 required):    ${largeText}`,
        `  UI components (3:1 required): ${uiComponent}`,
        ``,
        `Colors: ${fg} on ${bg}`,
      ];

      if (normalText === "FAIL") {
        const needed = 4.5;
        lines.push(``);
        lines.push(
          `To pass normal text AA, you need a ratio of at least 4.5:1.`
        );
        lines.push(`Current ratio ${rounded}:1 is ${ratio >= 3.0 ? "only sufficient for large text and UI components" : "insufficient for all WCAG AA levels"}.`);
      }

      return { content: [{ type: "text", text: lines.join("\n") }] };
    } catch (e) {
      return {
        content: [
          {
            type: "text",
            text: `Error: Could not parse colors. Use hex format like "#1a1a1a" or "#fff".`,
          },
        ],
      };
    }
  }
);

// --- Guidelines Data ---

const GUIDELINES = {
  modal: `# Modal and Dialog Accessibility Guidelines

## Required Structure
Always use the native <dialog> element. Never build modals from <div> elements.

<button id="trigger" aria-haspopup="dialog">Open Settings</button>
<dialog role="dialog" aria-modal="true" aria-labelledby="modal-title">
  <button aria-label="Close">Close</button>
  <h2 id="modal-title">Settings</h2>
  <!-- content -->
</dialog>

## Non-Negotiable Rules

### Focus Landing
- Focus MUST land on the Close button when the modal opens
- Close button MUST be the first interactive element
- No Tab key should be needed to reach the first element
- Use closeBtn.focus() after modal.showModal()

### Focus Trapping
- <dialog> with showModal() handles focus trapping natively
- Tab and Shift+Tab cycle only through elements inside the modal
- Nothing behind the modal should be reachable

### Focus Return
- When modal closes, focus MUST return to the trigger element
- Store a reference to the trigger button before opening
- Call triggerButton.focus() after modal.close()

### Escape Key
- Escape MUST close the modal
- After Escape, focus returns to trigger

### Heading Structure
- Modal heading starts at H2 (H1 is the page title)
- Never use H1 inside a modal

### Alert Dialogs
- Use role="alertdialog" for confirmations
- Focus lands on the least destructive action (Cancel, not Delete)
- aria-describedby links to explanation text

## Common Mistakes
- Modal built from <div> without focus trapping
- Focus landing on heading instead of Close button
- Missing focus return on close
- Backdrop click closes without returning focus
- Scrollable content not keyboard reachable`,

  tabs: `# Tabs Accessibility Guidelines

## Required Structure
<div role="tablist" aria-label="Section tabs">
  <button role="tab" aria-selected="true" aria-controls="panel-1">Tab 1</button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" tabindex="-1">Tab 2</button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1">Content</div>

## Requirements
- Container has role="tablist" with aria-label
- Each tab is a <button> with role="tab" and aria-selected
- Unselected tabs have tabindex="-1"
- Panels have role="tabpanel" and aria-labelledby
- Left/Right arrow keys move between tabs
- Tab key moves focus OUT of the tablist to next component
- Home/End jump to first/last tab`,

  accordion: `# Accordion Accessibility Guidelines

## Required Structure
<h2>
  <button aria-expanded="false" aria-controls="panel-1">Question</button>
</h2>
<div id="panel-1" role="region" aria-labelledby="accordion-btn-1" hidden>Answer</div>

## Requirements
- Toggle button inside a heading element
- aria-expanded reflects open/closed state
- aria-controls links to panel ID
- Panel has role="region" and aria-labelledby`,

  combobox: `# Combobox / Autocomplete Accessibility Guidelines

## Required Structure
<input role="combobox" aria-expanded="false" aria-controls="results" aria-autocomplete="list" autocomplete="off">
<div aria-live="polite" class="visually-hidden" id="status"></div>
<ul id="results" role="listbox" hidden>
  <li role="option" id="result-0">Item</li>
</ul>

## Requirements
- Input has role="combobox", aria-expanded, aria-controls, aria-autocomplete="list"
- Results list has role="listbox", items have role="option"
- Arrow keys navigate options
- aria-activedescendant tracks the current option
- Live region announces result count ("3 results available")
- Escape closes the list`,

  carousel: `# Carousel Accessibility Guidelines

## Required Structure
<div role="group" aria-roledescription="slide" aria-label="Slide 1 of 3">
  <img src="photo.jpg" alt="Descriptive text">
</div>

## Requirements
- Each slide is role="group" with aria-roledescription="slide"
- aria-label includes position ("Slide 1 of 3")
- No auto-rotation (or provide a stop button before the carousel)
- Previous/Next buttons placed before the slides
- Dot navigation uses buttons with labels ("Go to slide 1")
- Current dot has aria-current="true"
- All images have descriptive alt text`,

  form: `# Form Accessibility Guidelines

## Requirements
- Every input needs a <label> with matching for attribute
- Group related inputs with <fieldset> and <legend>
- Associate errors with aria-describedby
- On submit with errors: focus moves to first error field
- Never rely on color alone to indicate errors
- Required fields use the required attribute
- Error messages use text and/or icons, not just color

## Error Pattern
<label for="email">Email</label>
<input id="email" type="email" aria-describedby="email-error" aria-invalid="true">
<p id="email-error" role="alert">Please enter a valid email address</p>`,

  "live-region": `# Live Region Accessibility Guidelines

## Politeness Levels

### aria-live="polite" (use for almost everything)
Waits until screen reader finishes current announcement. Use for:
- Search result counts ("5 results available")
- Filter updates ("Showing 12 of 48 items")
- Form success ("Changes saved")
- Sort changes, pagination, non-critical status

### aria-live="assertive" (use rarely)
Interrupts current reading. ONLY for:
- Session expiring, connection lost, critical errors

## Implementation Rules
1. Live region element MUST exist in DOM BEFORE content changes
2. Update textContent, do NOT replace elements
3. Keep announcements short
4. Debounce rapid updates (500ms minimum)
5. Never use display:none or visibility:hidden on live regions

## React Warning
// GOOD: Region always in DOM
const [status, setStatus] = useState('');
return <div aria-live="polite">{status}</div>;

// BAD: Conditionally rendering the region
{status && <div aria-live="polite">{status}</div>}`,

  navigation: `# Navigation Accessibility Guidelines

## Skip Links (required)
<body>
  <a href="#main-content" class="skip-link">Skip to main content</a>
  <header><nav>...</nav></header>
  <main id="main-content" tabindex="-1">...</main>
</body>

## Tab Order
- DOM order determines tab order
- Never use tabindex values greater than 0
- Tab order must match visual layout

## SPA Route Changes
- Focus must move to new page content on route change
- Recommended: focus the H1 or main content area
- H1 should have tabindex="-1" for programmatic focus
- Screen reader must announce the new page

## Focus After Deletion
- Focus moves to next item in list
- If last item deleted, focus moves to previous
- If list empty, focus moves to relevant element
- Never let focus disappear

## Common Mistakes
- Click handlers on <div> without keyboard equivalent
- Hover-only interactions
- outline:none without alternative focus style
- Focus left on removed DOM element`,

  general: `# General Web Accessibility Guidelines (WCAG 2.1 AA)

## Semantic HTML First
- Native HTML elements before ARIA. Always.
- <button> not <div role="button">
- <dialog> not <div role="dialog">
- <nav>, <main>, <header>, <footer> for landmarks

## Heading Structure
- One H1 per page
- Never skip levels (H1 > H2 > H3, not H1 > H3)
- Never choose heading level for visual appearance

## Buttons vs Links
- <button> for actions (submit, toggle, open modal)
- <a href> for navigation (go to page, go to section)
- Never nest one inside the other

## Icons
- aria-hidden="true" on icons when visible text present
- Icon-only buttons must have aria-label

## Images
- Descriptive alt for meaningful images
- Empty alt="" and aria-hidden="true" for decorative images

## Page Setup
- <html lang="..."> always set
- Descriptive <title> in format "Page Title - App Name"
- Proper viewport meta for zoom support
- Skip link to main content

## Color and Contrast
- Normal text: 4.5:1 minimum
- Large text (18px+ or 14px+ bold): 3:1 minimum
- UI components: 3:1 minimum
- Focus indicators: 3:1 against adjacent colors
- No information by color alone
- Support prefers-reduced-motion

## Common Tailwind Failures
- text-gray-400 on white: 2.85:1 FAILS
- text-gray-500 on white: 4.64:1 passes
- text-gray-500 on bg-gray-900: 3.41:1 FAILS normal text
- text-gray-400 on bg-gray-900: 5.51:1 passes`,
};

server.registerTool(
  "get_accessibility_guidelines",
  {
    title: "Get Accessibility Guidelines",
    description:
      "Get detailed WCAG AA accessibility guidelines for a specific component type. Returns requirements, code examples, and common mistakes.",
    inputSchema: z.object({
      component: z
        .enum([
          "modal",
          "tabs",
          "accordion",
          "combobox",
          "carousel",
          "form",
          "live-region",
          "navigation",
          "general",
        ])
        .describe("The type of component to get guidelines for"),
    }),
  },
  async ({ component }) => {
    const guidelines = GUIDELINES[component];
    if (!guidelines) {
      return {
        content: [
          {
            type: "text",
            text: `No guidelines found for "${component}". Available: modal, tabs, accordion, combobox, carousel, form, live-region, navigation, general`,
          },
        ],
      };
    }
    return { content: [{ type: "text", text: guidelines }] };
  }
);

// --- Static Analysis Tools ---

/**
 * Parse HTML and extract heading elements with their levels.
 */
function extractHeadings(html) {
  const headingRe = /<(h[1-6])\b[^>]*>([\s\S]*?)<\/\1>/gi;
  const issues = [];
  const headings = [];
  let match;
  let h1Count = 0;

  while ((match = headingRe.exec(html)) !== null) {
    const tag = match[1].toLowerCase();
    const level = parseInt(tag[1], 10);
    // Strip inner HTML tags to get text content
    const text = match[2].replace(/<[^>]*>/g, "").trim();
    headings.push({ tag, level, text, index: match.index });
    if (level === 1) h1Count++;
  }

  if (headings.length === 0) {
    issues.push({
      severity: "serious",
      issue: "No heading elements found",
      detail: "Pages should have at least one heading (H1) for document structure.",
      wcag: "1.3.1 Info and Relationships (Level A), 2.4.6 Headings and Labels (Level AA)",
    });
    return { headings, issues };
  }

  if (h1Count === 0) {
    issues.push({
      severity: "serious",
      issue: "No H1 heading found",
      detail: "Every page should have exactly one H1 that describes the page content.",
      wcag: "1.3.1 Info and Relationships (Level A)",
    });
  } else if (h1Count > 1) {
    issues.push({
      severity: "moderate",
      issue: `Multiple H1 headings found (${h1Count})`,
      detail: "Each page should have exactly one H1. Use H2-H6 for subsections.",
      wcag: "1.3.1 Info and Relationships (Level A)",
    });
  }

  // Check for skipped levels
  for (let i = 1; i < headings.length; i++) {
    const prev = headings[i - 1].level;
    const curr = headings[i].level;
    if (curr > prev + 1) {
      issues.push({
        severity: "moderate",
        issue: `Skipped heading level: H${prev} to H${curr}`,
        detail: `"${headings[i].text || "(empty)"}" is an H${curr} but the previous heading was H${prev}. Expected H${prev + 1}.`,
        wcag: "1.3.1 Info and Relationships (Level A)",
      });
    }
  }

  // Check for empty headings
  for (const h of headings) {
    if (!h.text) {
      issues.push({
        severity: "moderate",
        issue: `Empty ${h.tag.toUpperCase()} heading`,
        detail: "Heading elements must have text content. Screen readers announce empty headings, confusing users.",
        wcag: "1.3.1 Info and Relationships (Level A), 2.4.6 Headings and Labels (Level AA)",
      });
    }
  }

  return { headings, issues };
}

server.registerTool(
  "check_heading_structure",
  {
    title: "Check Heading Structure",
    description:
      "Analyze HTML for heading hierarchy issues. Checks for single H1, skipped heading levels, and empty headings. Pass an HTML string to analyze.",
    inputSchema: z.object({
      html: z
        .string()
        .describe("The HTML content to analyze for heading structure"),
    }),
  },
  async ({ html }) => {
    const { headings, issues } = extractHeadings(html);

    const lines = [];

    if (headings.length > 0) {
      lines.push("Heading outline:");
      lines.push("");
      for (const h of headings) {
        const indent = "  ".repeat(h.level - 1);
        lines.push(`${indent}${h.tag.toUpperCase()}: ${h.text || "(empty)"}`);
      }
      lines.push("");
    }

    if (issues.length === 0) {
      lines.push("No heading structure issues found. Heading hierarchy is correct.");
    } else {
      lines.push(`Found ${issues.length} issue${issues.length > 1 ? "s" : ""}:`);
      lines.push("");
      for (const issue of issues) {
        lines.push(`[${issue.severity.toUpperCase()}] ${issue.issue}`);
        lines.push(`  ${issue.detail}`);
        lines.push(`  WCAG: ${issue.wcag}`);
        lines.push("");
      }
    }

    return { content: [{ type: "text", text: lines.join("\n") }] };
  }
);

/**
 * Extract links from HTML and check for ambiguous link text patterns.
 */
server.registerTool(
  "check_link_text",
  {
    title: "Check Link Text Accessibility",
    description:
      "Scan HTML for ambiguous, generic, or problematic link text. Detects 'click here', 'read more', 'learn more', URLs as text, repeated identical text, missing new-tab warnings, and links to non-HTML resources without file type indication.",
    inputSchema: z.object({
      html: z
        .string()
        .describe("The HTML content to scan for link text issues"),
    }),
  },
  async ({ html }) => {
    const linkRe = /<a\b([^>]*)>([\s\S]*?)<\/a>/gi;
    const issues = [];
    const linkTexts = [];
    let match;

    const AMBIGUOUS = [
      "click here", "here", "read more", "learn more", "more",
      "more info", "link", "details", "info", "go", "see more",
      "continue", "start", "submit", "download", "view", "open",
    ];

    while ((match = linkRe.exec(html)) !== null) {
      const attrs = match[1];
      const rawText = match[2].replace(/<[^>]*>/g, "").trim();
      const text = rawText.toLowerCase();
      const href = (attrs.match(/href\s*=\s*["']([^"']*)["']/i) || [])[1] || "";
      const target = (attrs.match(/target\s*=\s*["']([^"']*)["']/i) || [])[1] || "";
      const ariaLabel = (attrs.match(/aria-label\s*=\s*["']([^"']*)["']/i) || [])[1] || "";

      linkTexts.push({ text: rawText, href });

      // Check ambiguous exact match
      if (AMBIGUOUS.includes(text)) {
        issues.push({
          severity: "serious",
          issue: `Ambiguous link text: "${rawText}"`,
          detail: `Link text "${rawText}" does not describe the destination. Rewrite to describe where the link goes (e.g., "View pricing plans" instead of "${rawText}").`,
          wcag: "2.4.4 Link Purpose in Context (Level A)",
          element: match[0].slice(0, 200),
        });
      }
      // Check starts with ambiguous prefix
      else if (AMBIGUOUS.some((a) => text.startsWith(a + " ")) && text.split(" ").length <= 4) {
        issues.push({
          severity: "moderate",
          issue: `Link text starts with generic prefix: "${rawText}"`,
          detail: `Consider starting with the purpose. "Download the annual report" is clearer than "Click here to download the annual report".`,
          wcag: "2.4.4 Link Purpose in Context (Level A)",
          element: match[0].slice(0, 200),
        });
      }

      // URL as link text
      if (/^https?:\/\//i.test(rawText)) {
        issues.push({
          severity: "moderate",
          issue: `URL used as link text: "${rawText.slice(0, 80)}"`,
          detail: "Screen readers will spell out the entire URL. Use descriptive text instead.",
          wcag: "2.4.4 Link Purpose in Context (Level A)",
          element: match[0].slice(0, 200),
        });
      }

      // Missing new-tab warning
      if (target === "_blank" && !ariaLabel.toLowerCase().includes("new tab") && !rawText.toLowerCase().includes("new tab") && !rawText.toLowerCase().includes("opens in")) {
        issues.push({
          severity: "moderate",
          issue: `Link opens in new tab without warning: "${rawText.slice(0, 60)}"`,
          detail: 'Add "(opens in new tab)" to the link text or aria-label so users know the behavior will change.',
          wcag: "3.2.5 Change on Request (Level AAA, recommended)",
          element: match[0].slice(0, 200),
        });
      }

      // Non-HTML resource without file type
      const fileMatch = href.match(/\.(pdf|doc|docx|xls|xlsx|ppt|pptx|zip|csv)$/i);
      if (fileMatch && !rawText.toLowerCase().includes(fileMatch[1].toLowerCase())) {
        issues.push({
          severity: "moderate",
          issue: `Link to ${fileMatch[1].toUpperCase()} file without type indication: "${rawText.slice(0, 60)}"`,
          detail: `Add the file type and size to the link text (e.g., "Annual report (PDF, 2.4 MB)").`,
          wcag: "2.4.4 Link Purpose in Context (Level A)",
          element: match[0].slice(0, 200),
        });
      }
    }

    // Check repeated identical link text
    const textCounts = {};
    for (const lt of linkTexts) {
      const key = lt.text.toLowerCase();
      if (!key) continue;
      if (!textCounts[key]) textCounts[key] = [];
      textCounts[key].push(lt.href);
    }
    for (const [text, hrefs] of Object.entries(textCounts)) {
      const uniqueHrefs = [...new Set(hrefs)];
      if (uniqueHrefs.length > 1) {
        issues.push({
          severity: "serious",
          issue: `Repeated identical link text "${text}" points to ${uniqueHrefs.length} different destinations`,
          detail: `${hrefs.length} links all say "${text}" but go to different places. Differentiate the link text so screen reader users can distinguish them.`,
          wcag: "2.4.4 Link Purpose in Context (Level A)",
        });
      }
    }

    const lines = [`Links found: ${linkTexts.length}`, ""];

    if (issues.length === 0) {
      lines.push("No link text issues found. All links have descriptive, distinguishable text.");
    } else {
      lines.push(`Found ${issues.length} issue${issues.length > 1 ? "s" : ""}:`);
      lines.push("");
      for (const issue of issues) {
        lines.push(`[${issue.severity.toUpperCase()}] ${issue.issue}`);
        lines.push(`  ${issue.detail}`);
        lines.push(`  WCAG: ${issue.wcag}`);
        if (issue.element) {
          lines.push(`  Element: ${issue.element}`);
        }
        lines.push("");
      }
    }

    return { content: [{ type: "text", text: lines.join("\n") }] };
  }
);

/**
 * Check form inputs for label association and accessible patterns.
 */
server.registerTool(
  "check_form_labels",
  {
    title: "Check Form Label Accessibility",
    description:
      "Analyze HTML for form input accessibility. Checks that every input, select, and textarea has a programmatically associated label (via <label for>, aria-label, or aria-labelledby). Also checks for missing required attributes, fieldset/legend grouping, and autocomplete on identity fields.",
    inputSchema: z.object({
      html: z
        .string()
        .describe("The HTML content to analyze for form label issues"),
    }),
  },
  async ({ html }) => {
    const issues = [];

    // Find all label for= associations
    const labelForRe = /<label\b[^>]*\bfor\s*=\s*["']([^"']*)["'][^>]*>/gi;
    const labelFors = new Set();
    let m;
    while ((m = labelForRe.exec(html)) !== null) {
      labelFors.add(m[1]);
    }

    // Find all IDs in the document for cross-referencing
    const idRe = /\bid\s*=\s*["']([^"']*)["']/gi;
    const allIds = new Set();
    while ((m = idRe.exec(html)) !== null) {
      allIds.add(m[1]);
    }

    // Check inputs, selects, textareas
    const inputRe = /<(input|select|textarea)\b([^>]*)>/gi;
    let inputCount = 0;
    let unlabeledCount = 0;

    while ((m = inputRe.exec(html)) !== null) {
      const tag = m[1].toLowerCase();
      const attrs = m[2];

      // Skip hidden, submit, button, reset, image types
      const typeMatch = attrs.match(/\btype\s*=\s*["']([^"']*)["']/i);
      const type = typeMatch ? typeMatch[1].toLowerCase() : (tag === "input" ? "text" : "");
      if (["hidden", "submit", "button", "reset", "image"].includes(type)) continue;

      inputCount++;

      const id = (attrs.match(/\bid\s*=\s*["']([^"']*)["']/i) || [])[1] || "";
      const ariaLabel = attrs.match(/\baria-label\s*=\s*["']/i);
      const ariaLabelledby = (attrs.match(/\baria-labelledby\s*=\s*["']([^"']*)["']/i) || [])[1] || "";
      const title = attrs.match(/\btitle\s*=\s*["']/i);

      const hasLabel = (id && labelFors.has(id)) || ariaLabel || ariaLabelledby || title;

      if (!hasLabel) {
        unlabeledCount++;
        issues.push({
          severity: "critical",
          issue: `${tag} (type="${type}") has no associated label`,
          detail: `Add a <label for="id"> or aria-label attribute. Screen readers will announce this as "edit text" with no context.`,
          wcag: "1.3.1 Info and Relationships (Level A), 4.1.2 Name, Role, Value (Level A)",
          element: m[0].slice(0, 200),
        });
      }

      // Check aria-labelledby references valid IDs
      if (ariaLabelledby) {
        const refIds = ariaLabelledby.split(/\s+/);
        for (const refId of refIds) {
          if (refId && !allIds.has(refId)) {
            issues.push({
              severity: "serious",
              issue: `aria-labelledby references non-existent ID: "${refId}"`,
              detail: `The element with id="${refId}" does not exist in the provided HTML.`,
              wcag: "4.1.2 Name, Role, Value (Level A)",
              element: m[0].slice(0, 200),
            });
          }
        }
      }

      // Check autocomplete on identity fields
      const identityTypes = ["email", "tel", "password", "url"];
      const needsAutocomplete = identityTypes.includes(type) || /name|address|city|state|zip|postal|country|phone|cc-/i.test(id);
      if (needsAutocomplete && !attrs.match(/\bautocomplete\s*=/i)) {
        issues.push({
          severity: "moderate",
          issue: `Input may need autocomplete attribute: type="${type}"${id ? ` id="${id}"` : ""}`,
          detail: "Identity and contact fields should have autocomplete for accessibility (WCAG 1.3.5) and user convenience.",
          wcag: "1.3.5 Identify Input Purpose (Level AA)",
          element: m[0].slice(0, 200),
        });
      }
    }

    // Check for radio/checkbox groups without fieldset
    const radioCheckRe = /<input\b[^>]*\btype\s*=\s*["'](radio|checkbox)["'][^>]*>/gi;
    const groupNames = {};
    while ((m = radioCheckRe.exec(html)) !== null) {
      const nameMatch = m[0].match(/\bname\s*=\s*["']([^"']*)["']/i);
      if (nameMatch) {
        if (!groupNames[nameMatch[1]]) groupNames[nameMatch[1]] = { type: m[1], count: 0 };
        groupNames[nameMatch[1]].count++;
      }
    }
    const hasFieldset = /<fieldset\b/i.test(html);
    for (const [name, info] of Object.entries(groupNames)) {
      if (info.count > 1 && !hasFieldset) {
        issues.push({
          severity: "moderate",
          issue: `${info.type} group "${name}" (${info.count} inputs) may need <fieldset> and <legend>`,
          detail: "Groups of related radio buttons or checkboxes should be wrapped in <fieldset> with a <legend> to provide group context.",
          wcag: "1.3.1 Info and Relationships (Level A)",
        });
      }
    }

    const lines = [`Form inputs found: ${inputCount}`, ""];

    if (issues.length === 0) {
      lines.push("No form label issues found. All inputs have associated labels.");
    } else {
      const critical = issues.filter((i) => i.severity === "critical").length;
      const serious = issues.filter((i) => i.severity === "serious").length;
      const moderate = issues.filter((i) => i.severity === "moderate").length;

      lines.push(`Found ${issues.length} issue${issues.length > 1 ? "s" : ""}: ${critical} critical, ${serious} serious, ${moderate} moderate`);
      if (unlabeledCount > 0) {
        lines.push(`${unlabeledCount} of ${inputCount} inputs have no associated label`);
      }
      lines.push("");
      for (const issue of issues) {
        lines.push(`[${issue.severity.toUpperCase()}] ${issue.issue}`);
        lines.push(`  ${issue.detail}`);
        lines.push(`  WCAG: ${issue.wcag}`);
        if (issue.element) {
          lines.push(`  Element: ${issue.element}`);
        }
        lines.push("");
      }
    }

    return { content: [{ type: "text", text: lines.join("\n") }] };
  }
);

/**
 * Generate a VPAT/ACR template from audit findings.
 */
server.registerTool(
  "generate_vpat",
  {
    title: "Generate VPAT/ACR Template",
    description:
      "Generate a Voluntary Product Accessibility Template (VPAT 2.5) / Accessibility Conformance Report (ACR) in markdown format. Provide a product name and a JSON array of findings from an audit. Each finding should have: criterion (e.g. '1.1.1'), level ('A'|'AA'), conformance ('Supports'|'Partially Supports'|'Does Not Support'|'Not Applicable'), and remarks.",
    inputSchema: z.object({
      productName: z
        .string()
        .describe("The name of the product being assessed"),
      productVersion: z
        .string()
        .optional()
        .describe("The version of the product"),
      evaluationDate: z
        .string()
        .optional()
        .describe("Date of evaluation (YYYY-MM-DD). Defaults to today."),
      findings: z
        .array(
          z.object({
            criterion: z.string().describe('WCAG criterion number (e.g., "1.1.1")'),
            name: z.string().optional().describe('Criterion name (e.g., "Non-text Content")'),
            level: z.enum(["A", "AA"]).describe("Conformance level"),
            conformance: z
              .enum([
                "Supports",
                "Partially Supports",
                "Does Not Support",
                "Not Applicable",
                "Not Evaluated",
              ])
              .describe("Conformance status"),
            remarks: z.string().optional().describe("Explanation of conformance status"),
          })
        )
        .describe("Array of findings, one per WCAG criterion evaluated"),
      reportPath: z
        .string()
        .optional()
        .describe('File path to write the VPAT report to (e.g., "VPAT.md")'),
    }),
  },
  async ({ productName, productVersion, evaluationDate, findings, reportPath }) => {
    const date = evaluationDate || new Date().toISOString().split("T")[0];
    const version = productVersion || "1.0";

    // Standard WCAG 2.1 AA criteria
    const WCAG_CRITERIA = {
      "1.1.1": "Non-text Content",
      "1.2.1": "Audio-only and Video-only (Prerecorded)",
      "1.2.2": "Captions (Prerecorded)",
      "1.2.3": "Audio Description or Media Alternative (Prerecorded)",
      "1.2.4": "Captions (Live)",
      "1.2.5": "Audio Description (Prerecorded)",
      "1.3.1": "Info and Relationships",
      "1.3.2": "Meaningful Sequence",
      "1.3.3": "Sensory Characteristics",
      "1.3.4": "Orientation",
      "1.3.5": "Identify Input Purpose",
      "1.4.1": "Use of Color",
      "1.4.2": "Audio Control",
      "1.4.3": "Contrast (Minimum)",
      "1.4.4": "Resize Text",
      "1.4.5": "Images of Text",
      "1.4.10": "Reflow",
      "1.4.11": "Non-text Contrast",
      "1.4.12": "Text Spacing",
      "1.4.13": "Content on Hover or Focus",
      "2.1.1": "Keyboard",
      "2.1.2": "No Keyboard Trap",
      "2.1.4": "Character Key Shortcuts",
      "2.2.1": "Timing Adjustable",
      "2.2.2": "Pause, Stop, Hide",
      "2.3.1": "Three Flashes or Below Threshold",
      "2.4.1": "Bypass Blocks",
      "2.4.2": "Page Titled",
      "2.4.3": "Focus Order",
      "2.4.4": "Link Purpose (In Context)",
      "2.4.5": "Multiple Ways",
      "2.4.6": "Headings and Labels",
      "2.4.7": "Focus Visible",
      "2.4.11": "Focus Not Obscured (Minimum)",
      "2.5.1": "Pointer Gestures",
      "2.5.2": "Pointer Cancellation",
      "2.5.3": "Label in Name",
      "2.5.4": "Motion Actuation",
      "2.5.7": "Dragging Movements",
      "2.5.8": "Target Size (Minimum)",
      "3.1.1": "Language of Page",
      "3.1.2": "Language of Parts",
      "3.2.1": "On Focus",
      "3.2.2": "On Input",
      "3.2.6": "Consistent Help",
      "3.3.1": "Error Identification",
      "3.3.2": "Labels or Instructions",
      "3.3.3": "Error Suggestion",
      "3.3.4": "Error Prevention (Legal, Financial, Data)",
      "3.3.7": "Redundant Entry",
      "3.3.8": "Accessible Authentication (Minimum)",
      "4.1.2": "Name, Role, Value",
      "4.1.3": "Status Messages",
    };

    // Build lookup from findings
    const findingMap = {};
    for (const f of findings) {
      findingMap[f.criterion] = f;
    }

    const lines = [
      `# VPAT 2.5 - Accessibility Conformance Report`,
      ``,
      `## Product Information`,
      ``,
      `| Field | Value |`,
      `|-------|-------|`,
      `| Product Name | ${productName} |`,
      `| Product Version | ${version} |`,
      `| Report Date | ${date} |`,
      `| WCAG Version | WCAG 2.2 |`,
      `| Conformance Target | Level AA |`,
      `| Evaluation Method | A11y Agent Team automated and agent-driven review |`,
      ``,
      `## Terms`,
      ``,
      `| Term | Definition |`,
      `|------|-----------|`,
      `| Supports | The functionality of the product has at least one method that meets the criterion without known defects or meets with equivalent facilitation. |`,
      `| Partially Supports | Some functionality of the product does not meet the criterion. |`,
      `| Does Not Support | The majority of product functionality does not meet the criterion. |`,
      `| Not Applicable | The criterion is not relevant to the product. |`,
      `| Not Evaluated | The criterion has not been evaluated. |`,
      ``,
      `## WCAG 2.2 AA Conformance`,
      ``,
      `### Table 1: Level A`,
      ``,
      `| Criteria | Conformance Level | Remarks and Explanations |`,
      `|----------|------------------|--------------------------|`,
    ];

    // Level A criteria
    for (const [num, name] of Object.entries(WCAG_CRITERIA)) {
      const f = findingMap[num];
      // Determine level of this criterion
      const isAA = ["1.2.4", "1.2.5", "1.3.4", "1.3.5", "1.4.3", "1.4.4", "1.4.5", "1.4.10", "1.4.11", "1.4.12", "1.4.13", "2.4.5", "2.4.6", "2.4.7", "2.4.11", "2.5.7", "2.5.8", "3.1.2", "3.2.6", "3.3.3", "3.3.4", "3.3.7", "3.3.8"].includes(num);
      if (isAA) continue; // Skip AA for this table

      if (f) {
        lines.push(`| ${num} ${f.name || name} | ${f.conformance} | ${f.remarks || ""} |`);
      } else {
        lines.push(`| ${num} ${name} | Not Evaluated | |`);
      }
    }

    lines.push(``);
    lines.push(`### Table 2: Level AA`);
    lines.push(``);
    lines.push(`| Criteria | Conformance Level | Remarks and Explanations |`);
    lines.push(`|----------|------------------|--------------------------|`);

    const aaCriteria = ["1.2.4", "1.2.5", "1.3.4", "1.3.5", "1.4.3", "1.4.4", "1.4.5", "1.4.10", "1.4.11", "1.4.12", "1.4.13", "2.4.5", "2.4.6", "2.4.7", "2.4.11", "2.5.7", "2.5.8", "3.1.2", "3.2.6", "3.3.3", "3.3.4", "3.3.7", "3.3.8"];
    for (const num of aaCriteria) {
      const name = WCAG_CRITERIA[num];
      if (!name) continue;
      const f = findingMap[num];
      if (f) {
        lines.push(`| ${num} ${f.name || name} | ${f.conformance} | ${f.remarks || ""} |`);
      } else {
        lines.push(`| ${num} ${name} | Not Evaluated | |`);
      }
    }

    // Summary statistics
    const supports = findings.filter((f) => f.conformance === "Supports").length;
    const partial = findings.filter((f) => f.conformance === "Partially Supports").length;
    const doesNot = findings.filter((f) => f.conformance === "Does Not Support").length;
    const na = findings.filter((f) => f.conformance === "Not Applicable").length;
    const total = Object.keys(WCAG_CRITERIA).length;
    const evaluated = findings.length;

    lines.push(``);
    lines.push(`## Summary`);
    lines.push(``);
    lines.push(`| Status | Count |`);
    lines.push(`|--------|-------|`);
    lines.push(`| Supports | ${supports} |`);
    lines.push(`| Partially Supports | ${partial} |`);
    lines.push(`| Does Not Support | ${doesNot} |`);
    lines.push(`| Not Applicable | ${na} |`);
    lines.push(`| Not Evaluated | ${total - evaluated} |`);
    lines.push(``);
    lines.push(`---`);
    lines.push(``);
    lines.push(`*This report was generated by the A11y Agent Team. For the full report format, see the [ITI VPAT 2.5 template](https://www.itic.org/policy/accessibility/vpat).*`);

    const report = lines.join("\n");

    let reportNote = "";
    if (reportPath) {
      try {
        const safeReportPath = validateOutputPath(reportPath);
        await fsWriteFile(safeReportPath, report, "utf-8");
        reportNote = `\nReport written to: ${safeReportPath}`;
      } catch (writeErr) {
        reportNote = `\nFailed to write report to ${reportPath}: ${writeErr.message}`;
      }
    }

    return {
      content: [{ type: "text", text: report + reportNote }],
    };
  }
);

// --- axe-core Integration ---

/**
 * Build a structured markdown accessibility report from axe-core results.
 */
function buildMarkdownReport(url, violations, passes, incomplete, selector) {
  const now = new Date();
  const date = now.toISOString().split("T")[0];
  const time = now.toTimeString().split(" ")[0];

  const groups = { critical: [], serious: [], moderate: [], minor: [] };
  for (const v of violations) {
    const bucket = groups[v.impact] || groups.moderate;
    bucket.push(v);
  }

  const lines = [
    `# Accessibility Scan Report`,
    ``,
    `## Scan Details`,
    ``,
    `| Field | Value |`,
    `|-------|-------|`,
    `| URL | ${url} |`,
    selector ? `| Scope | \`${selector}\` |` : null,
    `| Date | ${date} at ${time} |`,
    `| Standard | WCAG 2.1 AA |`,
    `| Scanner | axe-core |`,
    `| Violations | ${violations.length} |`,
    `| Rules passed | ${passes.length} |`,
    `| Needs manual review | ${incomplete.length} |`,
    ``,
    `## Summary`,
    ``,
  ].filter(Boolean);

  if (violations.length === 0) {
    lines.push(
      `No automated violations found. ${passes.length} rules passed.`,
      ``,
      `> Automated scanning catches approximately 30% of accessibility issues.`,
      `> Manual testing with a screen reader and keyboard is still required.`
    );
  } else {
    lines.push(
      `| Severity | Count |`,
      `|----------|-------|`,
      `| Critical | ${groups.critical.length} |`,
      `| Serious | ${groups.serious.length} |`,
      `| Moderate | ${groups.moderate.length} |`,
      `| Minor | ${groups.minor.length} |`,
      ``
    );

    for (const [label, items] of [
      ["Critical", groups.critical],
      ["Serious", groups.serious],
      ["Moderate", groups.moderate],
      ["Minor", groups.minor],
    ]) {
      if (items.length === 0) continue;

      lines.push(`## ${label} Issues`);
      lines.push(``);

      for (const v of items) {
        const wcagTags = v.tags
          .filter((t) => t.startsWith("wcag"))
          .join(", ");

        lines.push(`### ${v.id}: ${v.help}`);
        lines.push(``);
        lines.push(`- **Impact:** ${v.impact}`);
        lines.push(`- **WCAG:** ${wcagTags}`);
        lines.push(
          `- **Help:** [${v.id} documentation](${v.helpUrl})`
        );
        lines.push(
          `- **Instances:** ${v.nodes.length}`
        );
        lines.push(``);

        if (v.description) {
          lines.push(v.description);
          lines.push(``);
        }

        lines.push(`**Affected elements:**`);
        lines.push(``);

        for (const [i, node] of v.nodes.entries()) {
          lines.push(`${i + 1}. \`${node.target ? node.target.join(" > ") : "unknown"}\``);
          lines.push(`   \`\`\`html`);
          lines.push(`   ${node.html.slice(0, 300)}`);
          lines.push(`   \`\`\``);
          if (node.failureSummary) {
            // Clean up the failure summary
            const fix = node.failureSummary
              .replace(/^Fix any of the following:\n?/i, "")
              .replace(/^Fix all of the following:\n?/i, "")
              .trim();
            lines.push(`   **Fix:** ${fix}`);
          }
          lines.push(``);
        }
      }
    }

    lines.push(`## Next Steps`);
    lines.push(``);
    lines.push(`1. Fix critical and serious issues first — these block access for assistive technology users`);
    lines.push(`2. Address moderate issues — these degrade the experience`);
    lines.push(`3. Consider minor issues — these are improvements, not blockers`);
    lines.push(`4. Run manual testing with a screen reader (NVDA + Firefox, VoiceOver + Safari)`);
    lines.push(`5. Re-scan after fixes to verify resolution`);
    lines.push(``);
    lines.push(`> This report was generated by axe-core automated scanning.`);
    lines.push(`> Automated tools catch approximately 30% of accessibility issues.`);
    lines.push(`> Manual testing with assistive technology is required for a complete assessment.`);
  }

  return lines.join("\n");
}

server.registerTool(
  "run_axe_scan",
  {
    title: "Run axe-core Accessibility Scan",
    description:
      "Run an automated axe-core accessibility scan against a live URL (e.g., a local dev server). Returns WCAG 2.1 AA violations grouped by severity with affected elements and fix suggestions. Optionally writes a structured markdown report file. Requires @axe-core/cli to be installed (globally or in the project) and the target URL to be reachable.",
    inputSchema: z.object({
      url: z
        .string()
        .describe('The URL to scan (e.g., "http://localhost:3000")'),
      selector: z
        .string()
        .optional()
        .describe(
          'CSS selector to limit the scan to a specific element (e.g., "#main", ".modal")'
        ),
      reportPath: z
        .string()
        .optional()
        .describe(
          'File path to write a markdown report to (e.g., "ACCESSIBILITY-SCAN.md"). If omitted, returns results as text only without writing a file.'
        ),
    }),
  },
  async ({ url, selector, reportPath }) => {
    // Validate URL
    let parsedUrl;
    try {
      parsedUrl = new URL(url);
    } catch {
      return {
        content: [
          {
            type: "text",
            text: 'Invalid URL. Provide a valid URL like http://localhost:3000',
          },
        ],
      };
    }
    if (!["http:", "https:"].includes(parsedUrl.protocol)) {
      return {
        content: [
          { type: "text", text: "URL must use http: or https: protocol." },
        ],
      };
    }
    const validatedUrl = parsedUrl.href;

    // Temp file for axe JSON output
    const tmpFile = join(tmpdir(), `axe-${randomUUID()}.json`);
    const tags = "wcag2a,wcag2aa,wcag21a,wcag21aa";

    // Build args — execFile passes these as separate arguments, not through a shell
    const cliArgs = [
      "@axe-core/cli",
      validatedUrl,
      "--save",
      tmpFile,
      "--tags",
      tags,
    ];
    if (selector) {
      // Allowlist CSS selector characters to prevent injection on Windows
      if (/[;&|`$<>']/.test(selector)) {
        return { content: [{ type: "text", text: "Invalid selector: contains disallowed characters." }] };
      }
      cliArgs.push("--include", selector);
    }

    try {
      // Use npx.cmd on Windows to avoid running through cmd.exe shell
      const npxCmd = process.platform === "win32" ? "npx.cmd" : "npx";
      await execFileAsync(npxCmd, cliArgs, {
        timeout: 60000,
        shell: false,
      });

      const raw = await fsReadFile(tmpFile, "utf-8");
      const results = JSON.parse(raw);
      await unlink(tmpFile).catch(() => {});

      const page = Array.isArray(results) ? results[0] : results;
      const violations = page.violations || [];
      const passes = page.passes || [];
      const incomplete = page.incomplete || [];

      // Build markdown report
      const report = buildMarkdownReport(validatedUrl, violations, passes, incomplete, selector);

      // Write report file if requested
      let reportNote = "";
      if (reportPath) {
        try {
          const safeReportPath = validateOutputPath(reportPath);
          await fsWriteFile(safeReportPath, report, "utf-8");
          reportNote = `\nReport written to: ${safeReportPath}`;
        } catch (writeErr) {
          reportNote = `\nFailed to write report to ${reportPath}: ${writeErr.message}`;
        }
      }

      if (violations.length === 0) {
        return {
          content: [
            {
              type: "text",
              text: [
                `axe-core scan complete: ${validatedUrl}`,
                ``,
                `No WCAG 2.1 AA violations found.`,
                `${passes.length} rules passed. ${incomplete.length} rules need manual review.`,
                ``,
                `Automated scanning catches ~30% of accessibility issues.`,
                `Manual testing with a screen reader and keyboard is still required.`,
                reportNote,
              ].filter(Boolean).join("\n"),
            },
          ],
        };
      }

      // Group by impact severity
      const groups = { critical: [], serious: [], moderate: [], minor: [] };
      for (const v of violations) {
        const bucket = groups[v.impact] || groups.moderate;
        bucket.push(v);
      }

      const formatViolation = (v) => {
        const examples = v.nodes
          .slice(0, 3)
          .map(
            (n) =>
              `    ${n.html.slice(0, 200)}\n    Fix: ${n.failureSummary}`
          )
          .join("\n\n");
        const more =
          v.nodes.length > 3
            ? `\n    ... and ${v.nodes.length - 3} more instances`
            : "";
        const wcagTags = v.tags
          .filter((t) => t.startsWith("wcag"))
          .join(", ");
        return [
          `  ${v.id}: ${v.help}`,
          `  Impact: ${v.impact} | WCAG: ${wcagTags}`,
          `  Help: ${v.helpUrl}`,
          `  Affected elements (${v.nodes.length}):`,
          examples + more,
        ].join("\n");
      };

      const lines = [
        `axe-core scan complete: ${validatedUrl}`,
        `Total: ${violations.length} violations | ${passes.length} passed | ${incomplete.length} need review`,
        ``,
      ];

      for (const [label, items] of [
        ["CRITICAL", groups.critical],
        ["SERIOUS", groups.serious],
        ["MODERATE", groups.moderate],
        ["MINOR", groups.minor],
      ]) {
        if (items.length > 0) {
          lines.push(`${label} (${items.length}):`);
          lines.push(items.map(formatViolation).join("\n\n"));
          lines.push("");
        }
      }

      lines.push(
        "Fix critical and serious issues first. Use the appropriate specialist agent for targeted fix guidance."
      );
      if (reportNote) {
        lines.push(reportNote);
      }

      return { content: [{ type: "text", text: lines.join("\n") }] };
    } catch (err) {
      await unlink(tmpFile).catch(() => {});

      const msg = err.message || String(err);

      if (
        msg.includes("ENOENT") ||
        msg.includes("not found") ||
        msg.includes("is not recognized")
      ) {
        return {
          content: [
            {
              type: "text",
              text: [
                "axe-core CLI is not installed or not found on PATH.",
                "",
                "Install it globally:",
                "  npm install -g @axe-core/cli",
                "",
                "Or in your project:",
                "  npm install --save-dev @axe-core/cli",
                "",
                "axe-core CLI uses Chromium to render the page and run accessibility checks.",
              ].join("\n"),
            },
          ],
        };
      }

      if (msg.includes("ETIMEDOUT") || msg.includes("timeout")) {
        return {
          content: [
            {
              type: "text",
              text: [
                `Scan timed out for ${validatedUrl}.`,
                "",
                "Make sure:",
                "1. Your dev server is running and accessible",
                "2. The URL responds within 60 seconds",
                "3. Try scanning a simpler page first",
              ].join("\n"),
            },
          ],
        };
      }

      return {
        content: [
          {
            type: "text",
            text: [
              `axe-core scan failed: ${msg}`,
              "",
              "Common causes:",
              `1. Dev server not running at ${validatedUrl}`,
              "2. @axe-core/cli not installed (npm install -g @axe-core/cli)",
              "3. Chrome/Chromium not available on this system",
            ].join("\n"),
          },
        ],
      };
    }
  }
);

// --- Office Document Scanning ---

/**
 * Minimal ZIP reader using only Node.js built-ins.
 * Parses the Central Directory to extract named entries.
 */
function readZipEntries(buf) {
  // Find End of Central Directory record (search last 65KB)
  const searchStart = Math.max(0, buf.length - 65557);
  let eocdOff = -1;
  for (let i = buf.length - 22; i >= searchStart; i--) {
    if (buf.readUInt32LE(i) === 0x06054b50) { eocdOff = i; break; }
  }
  if (eocdOff === -1) throw new Error("Not a valid ZIP file");
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

function extractZipEntry(buf, entry) {
  const localOff = entry.localOff;
  if (buf.readUInt32LE(localOff) !== 0x04034b50) throw new Error("Invalid local header");
  const nameLen = buf.readUInt16LE(localOff + 26);
  const extraLen = buf.readUInt16LE(localOff + 28);
  const dataStart = localOff + 30 + nameLen + extraLen;
  const raw = buf.subarray(dataStart, dataStart + entry.cSize);
  if (entry.method === 0) return raw.toString("utf8");
  if (entry.method === 8) return inflateRawSync(raw).toString("utf8");
  throw new Error(`Unsupported compression method: ${entry.method}`);
}

function getZipXml(buf, entries, path) {
  const entry = entries.get(path);
  if (!entry) return "";
  try { return extractZipEntry(buf, entry); } catch { return ""; }
}

/** Load .a11y-office-config.json searching from filePath upward */
async function loadOfficeConfig(filePath) {
  const defaultConfig = {
    docx: { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] },
    xlsx: { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] },
    pptx: { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] },
  };
  let dir = dirname(filePath);
  for (let i = 0; i < 20; i++) {
    const configPath = join(dir, ".a11y-office-config.json");
    try {
      const raw = await fsReadFile(configPath, "utf-8");
      const parsed = JSON.parse(raw);
      return { ...defaultConfig, ...parsed };
    } catch { /* not found, keep searching */ }
    const parent = dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return defaultConfig;
}

// Simple XML text extractor (no dependency)
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
function xmlHas(xml, tag) {
  return new RegExp(`<${tag}[\\s/>]`, "i").test(xml);
}
function xmlCount(xml, tag) {
  const re = new RegExp(`<${tag}[\\s/>]`, "gi");
  let c = 0, m;
  while ((m = re.exec(xml)) !== null) c++;
  return c;
}

function scanDocx(buf, entries, config) {
  const findings = [];
  const disabled = new Set(config.disabledRules || []);
  const sevFilter = new Set(config.severityFilter || ["error", "warning", "tip"]);

  const doc = getZipXml(buf, entries, "word/document.xml");
  const core = getZipXml(buf, entries, "docProps/core.xml");
  const rels = getZipXml(buf, entries, "word/_rels/document.xml.rels");

  function add(id, sev, msg, location) {
    if (disabled.has(id)) return;
    if (!sevFilter.has(sev)) return;
    findings.push({ ruleId: id, severity: sev, message: msg, location: location || "document" });
  }

  // E004: missing document title
  const titles = xmlText(core, "dc:title");
  if (!titles.length || !titles[0]) add("DOCX-E004", "error", "Document title is not set in properties. Screen readers announce this when opening.", "docProps/core.xml");

  // T001: missing document language
  if (!xmlHas(doc, "w:lang") && !xmlHas(core, "dc:language")) add("DOCX-T001", "tip", "Document language is not set. Screen readers use this to select the correct voice.", "word/settings.xml");

  // E007: no heading structure
  const headingStyles = doc.match(/<w:pStyle\s+w:val="Heading\d"/gi) || [];
  if (headingStyles.length === 0) add("DOCX-E007", "error", "Document has zero headings. Screen reader users cannot navigate by section.", "word/document.xml");

  // E003: skipped heading levels
  if (headingStyles.length > 0) {
    const levels = headingStyles.map(h => parseInt(h.match(/Heading(\d)/i)[1])).filter(n => !isNaN(n));
    const seen = new Set();
    for (const lvl of levels) {
      seen.add(lvl);
      if (lvl > 1 && !seen.has(lvl - 1)) {
        add("DOCX-E003", "error", `Heading level ${lvl} used without Heading ${lvl - 1} before it. Heading levels must not skip.`, "word/document.xml");
        break;
      }
    }
  }

  // E001: missing alt text on images
  const drawings = doc.match(/<w:drawing>[\s\S]*?<\/w:drawing>/gi) || [];
  let imgNoAlt = 0;
  for (const d of drawings) {
    const descrs = xmlAttr(d, "wp:docPr", "descr");
    const descrs2 = xmlAttr(d, "pic:cNvPr", "descr");
    const allDescr = [...descrs, ...descrs2];
    if (allDescr.length === 0 || allDescr.every(v => !v.trim())) imgNoAlt++;
  }
  if (imgNoAlt > 0) add("DOCX-E001", "error", `${imgNoAlt} image(s) missing alt text. Blind users cannot understand these images.`, "word/document.xml");

  // W002: long alt text
  for (const d of drawings) {
    const descrs = [...xmlAttr(d, "wp:docPr", "descr"), ...xmlAttr(d, "pic:cNvPr", "descr")];
    for (const desc of descrs) {
      if (desc.length > 150) add("DOCX-W002", "warning", `Alt text exceeds 150 characters (${desc.length} chars). Consider shortening.`, "word/document.xml");
    }
  }

  // E002: tables without header rows
  const tables = doc.match(/<w:tbl>[\s\S]*?<\/w:tbl>/gi) || [];
  let tblNoHeader = 0;
  for (const t of tables) {
    if (!xmlHas(t, "w:tblHeader")) tblNoHeader++;
  }
  if (tblNoHeader > 0) add("DOCX-E002", "error", `${tblNoHeader} table(s) without designated header rows. Screen readers cannot identify column headers.`, "word/document.xml");

  // E005: merged cells
  let mergedCells = xmlCount(doc, "w:gridSpan") + xmlCount(doc, "w:vMerge");
  if (mergedCells > 0) add("DOCX-E005", "error", `${mergedCells} merged/split cell(s) found. Merged cells break screen reader table navigation.`, "word/document.xml");

  // W001: nested tables
  for (const t of tables) {
    const innerTables = (t.match(/<w:tbl>/gi) || []).length - 1;
    if (innerTables > 0) { add("DOCX-W001", "warning", "Nested table found. Nested tables are nearly impossible to navigate with a screen reader.", "word/document.xml"); break; }
  }

  // E006: ambiguous link text
  const hyperlinks = doc.match(/<w:hyperlink[\s\S]*?<\/w:hyperlink>/gi) || [];
  const badLinkPatterns = /^(click here|here|link|read more|learn more|more info|more|download)$/i;
  let badLinks = 0;
  for (const h of hyperlinks) {
    const texts = xmlText(h, "w:t");
    const linkText = texts.join("").trim();
    if (badLinkPatterns.test(linkText) || /^https?:\/\//i.test(linkText)) badLinks++;
  }
  if (badLinks > 0) add("DOCX-E006", "error", `${badLinks} hyperlink(s) with ambiguous text (e.g., "click here" or raw URLs). Link text must describe the destination.`, "word/document.xml");

  // W003: manual lists
  const paragraphs = xmlText(doc, "w:t");
  let manualLists = 0;
  for (const p of paragraphs) {
    if (/^[\u2022\u2023\u25E6\-\*\>]\s/.test(p) || /^\d+[\.\)]\s/.test(p)) manualLists++;
  }
  if (manualLists > 3) add("DOCX-W003", "warning", `${manualLists} paragraphs appear to use manual bullet/number characters instead of Word list styles.`, "word/document.xml");

  // W005: long headings
  for (const hs of headingStyles) {
    // Extract heading text from surrounding paragraph
  }

  // W006: watermark
  const headerFooter = [...Array.from(entries.keys())].filter(k => k.startsWith("word/header") || k.startsWith("word/footer"));
  for (const hf of headerFooter) {
    const xml = getZipXml(buf, entries, hf);
    if (/watermark/i.test(xml) || xmlHas(xml, "v:textpath")) {
      add("DOCX-W006", "warning", "Document may contain a watermark. Watermarks are visual-only and not announced by screen readers.", hf);
      break;
    }
  }

  // T003: repeated blank characters
  const docText = paragraphs.join(" ");
  if (/   /.test(docText) || /\t\t/.test(docText)) add("DOCX-T003", "tip", "Document contains repeated blank characters (spaces/tabs) used for formatting. Use Word styles instead.", "word/document.xml");

  return findings;
}

function scanXlsx(buf, entries, config) {
  const findings = [];
  const disabled = new Set(config.disabledRules || []);
  const sevFilter = new Set(config.severityFilter || ["error", "warning", "tip"]);

  const workbook = getZipXml(buf, entries, "xl/workbook.xml");
  const core = getZipXml(buf, entries, "docProps/core.xml");

  function add(id, sev, msg, location) {
    if (disabled.has(id)) return;
    if (!sevFilter.has(sev)) return;
    findings.push({ ruleId: id, severity: sev, message: msg, location: location || "workbook" });
  }

  // E006: missing workbook title
  const titles = xmlText(core, "dc:title");
  if (!titles.length || !titles[0]) add("XLSX-E006", "error", "Workbook title is not set in properties.", "docProps/core.xml");

  // T003: missing language
  if (!xmlHas(core, "dc:language")) add("XLSX-T003", "tip", "Workbook language is not set.", "docProps/core.xml");

  // E003: default sheet names
  const sheetNames = xmlAttr(workbook, "sheet", "name");
  const defaultNames = sheetNames.filter(n => /^Sheet\d+$/i.test(n));
  if (defaultNames.length > 0) add("XLSX-E003", "error", `${defaultNames.length} sheet(s) using default names (${defaultNames.join(", ")}). Rename to describe content.`, "xl/workbook.xml");

  // Scan individual sheets
  const sheetFiles = [...entries.keys()].filter(k => /^xl\/worksheets\/sheet\d+\.xml$/.test(k));
  let totalMerged = 0;
  let emptySheets = 0;
  let sheetsWithHyperlinks = 0;
  let badHyperlinks = 0;

  for (const sf of sheetFiles) {
    const sheetXml = getZipXml(buf, entries, sf);

    // E004: merged cells
    const merges = xmlCount(sheetXml, "mergeCell");
    totalMerged += merges;

    // W004: empty sheets
    if (!xmlHas(sheetXml, "c ") && !xmlHas(sheetXml, "c>")) emptySheets++;

    // E005: ambiguous hyperlinks
    const hyperlinks = sheetXml.match(/<hyperlink[^>]*>/gi) || [];
    for (const h of hyperlinks) {
      sheetsWithHyperlinks++;
      const display = h.match(/display="([^"]*)"/i);
      if (display) {
        const text = display[1];
        if (/^(click here|here|link|read more)$/i.test(text) || /^https?:\/\//i.test(text)) badHyperlinks++;
      }
    }

    // W002: conditional formatting (color-only indicator)
    if (xmlHas(sheetXml, "conditionalFormatting")) {
      add("XLSX-W002", "warning", "Conditional formatting found. Ensure color is not the only way to convey meaning.", sf);
    }
  }

  if (totalMerged > 0) add("XLSX-E004", "error", `${totalMerged} merged cell region(s) found. Merged cells break screen reader navigation.`, "worksheets");
  if (emptySheets > 0) add("XLSX-W004", "warning", `${emptySheets} empty sheet(s) found. Remove empty sheets to reduce confusion.`, "xl/workbook.xml");
  if (badHyperlinks > 0) add("XLSX-E005", "error", `${badHyperlinks} hyperlink(s) with ambiguous display text.`, "worksheets");

  // E001/E002: charts and tables
  const tableFiles = [...entries.keys()].filter(k => /^xl\/tables\//.test(k));
  for (const tf of tableFiles) {
    const tXml = getZipXml(buf, entries, tf);
    if (/headerRowCount="0"/i.test(tXml)) {
      add("XLSX-E002", "error", "Table found with headerRowCount='0'. Tables must have header rows.", tf);
    }
  }

  const drawingFiles = [...entries.keys()].filter(k => /^xl\/drawings\//.test(k));
  let chartNoAlt = 0;
  for (const df of drawingFiles) {
    const dXml = getZipXml(buf, entries, df);
    const cNvPrs = dXml.match(/<xdr:cNvPr[^>]*>/gi) || [];
    for (const el of cNvPrs) {
      const descr = el.match(/descr="([^"]*)"/i);
      if (!descr || !descr[1].trim()) chartNoAlt++;
    }
  }
  if (chartNoAlt > 0) add("XLSX-E001", "error", `${chartNoAlt} chart/image(s) missing alt text.`, "xl/drawings");

  return findings;
}

function scanPptx(buf, entries, config) {
  const findings = [];
  const disabled = new Set(config.disabledRules || []);
  const sevFilter = new Set(config.severityFilter || ["error", "warning", "tip"]);

  const core = getZipXml(buf, entries, "docProps/core.xml");
  const presentation = getZipXml(buf, entries, "ppt/presentation.xml");

  function add(id, sev, msg, location) {
    if (disabled.has(id)) return;
    if (!sevFilter.has(sev)) return;
    findings.push({ ruleId: id, severity: sev, message: msg, location: location || "presentation" });
  }

  // W001: missing presentation title
  const titles = xmlText(core, "dc:title");
  if (!titles.length || !titles[0]) add("PPTX-W001", "warning", "Presentation title is not set in properties.", "docProps/core.xml");

  // T004: missing language
  if (!xmlHas(core, "dc:language")) add("PPTX-T004", "tip", "Presentation language is not set.", "docProps/core.xml");

  // Scan slides
  const slideFiles = [...entries.keys()].filter(k => /^ppt\/slides\/slide\d+\.xml$/.test(k)).sort();
  const slideTitles = [];
  let noAltCount = 0;

  for (let si = 0; si < slideFiles.length; si++) {
    const sf = slideFiles[si];
    const slideNum = si + 1;
    const slideXml = getZipXml(buf, entries, sf);

    // E002: missing slide title
    const hasTitlePh = /ph\s+type="(title|ctrTitle)"/i.test(slideXml);
    let titleText = "";
    if (hasTitlePh) {
      // Find all text in the title shape — simplified extraction
      const titleMatch = slideXml.match(/<p:sp>[\s\S]*?ph\s+type="(title|ctrTitle)"[\s\S]*?<\/p:sp>/i);
      if (titleMatch) {
        const tTexts = xmlText(titleMatch[0], "a:t");
        titleText = tTexts.join(" ").trim();
      }
    }
    if (!hasTitlePh || !titleText) {
      add("PPTX-E002", "error", `Slide ${slideNum} has no title. Screen reader users cannot navigate to this slide.`, sf);
    } else {
      slideTitles.push({ slideNum, title: titleText });
    }

    // E001: missing alt text
    const cNvPrs = slideXml.match(/<p:cNvPr[^>]*>/gi) || [];
    for (const el of cNvPrs) {
      if (/ph\s+type=/i.test(slideXml.substring(slideXml.indexOf(el)))) continue; // skip placeholders
      const descr = el.match(/descr="([^"]*)"/i);
      if (!descr || !descr[1].trim()) noAltCount++;
    }

    // E004: tables without headers
    if (xmlHas(slideXml, "a:tbl")) {
      const tblProps = slideXml.match(/<a:tblPr[^>]*>/gi) || [];
      for (const tp of tblProps) {
        if (!/firstRow="1"/i.test(tp)) {
          add("PPTX-E004", "error", `Table on slide ${slideNum} does not have header row designated.`, sf);
        }
      }
      // W003: merged cells
      if (/gridSpan="|rowSpan="/i.test(slideXml)) {
        add("PPTX-W003", "warning", `Table on slide ${slideNum} has merged cells.`, sf);
      }
    }

    // E005: ambiguous links
    const hlinkClicks = slideXml.match(/<a:hlinkClick[^>]*>/gi) || [];
    // Links with no descriptive text are caught by the alt-text check above

    // W004: media without captions
    if (xmlHas(slideXml, "p:vid") || xmlHas(slideXml, "a:audioFile")) {
      add("PPTX-W004", "warning", `Slide ${slideNum} contains audio/video. Ensure captions or transcript are provided.`, sf);
    }
  }

  if (noAltCount > 0) add("PPTX-E001", "error", `${noAltCount} image/shape(s) missing alt text across all slides.`, "ppt/slides");

  // E003: duplicate titles
  const titleMap = new Map();
  for (const { slideNum, title } of slideTitles) {
    const key = title.toLowerCase();
    if (titleMap.has(key)) {
      add("PPTX-E003", "error", `Duplicate slide title "${title}" on slides ${titleMap.get(key)} and ${slideNum}.`, "ppt/slides");
    } else {
      titleMap.set(key, slideNum);
    }
  }

  // T001: sections
  if (slideFiles.length > 10 && !xmlHas(presentation, "p:sectionLst")) {
    add("PPTX-T001", "tip", "Presentation has more than 10 slides but no sections. Add sections for easier navigation.", "ppt/presentation.xml");
  }

  return findings;
}

function buildOfficeSarif(filePath, findings, fileType) {
  const rules = findings.map(f => ({
    id: f.ruleId,
    shortDescription: { text: f.message.split(".")[0] },
    fullDescription: { text: f.message },
    defaultConfiguration: {
      level: f.severity === "error" ? "error" : f.severity === "warning" ? "warning" : "note",
    },
  }));
  // Deduplicate rules by ID
  const uniqueRules = [...new Map(rules.map(r => [r.id, r])).values()];

  return {
    $schema: "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/main/sarif-2.1/schema/sarif-schema-2.1.0.json",
    version: "2.1.0",
    runs: [{
      tool: {
        driver: {
          name: "a11y-office-scanner",
          version: "1.0.0",
          informationUri: "https://github.com/taylorarndt/a11y-agent-team",
          rules: uniqueRules,
        },
      },
      results: findings.map(f => ({
        ruleId: f.ruleId,
        level: f.severity === "error" ? "error" : f.severity === "warning" ? "warning" : "note",
        message: { text: f.message },
        locations: [{
          physicalLocation: {
            artifactLocation: { uri: filePath },
          },
        }],
        properties: { internalLocation: f.location, fileType },
      })),
    }],
  };
}

function buildOfficeMarkdownReport(filePath, findings, fileType) {
  const now = new Date();
  const errors = findings.filter(f => f.severity === "error");
  const warnings = findings.filter(f => f.severity === "warning");
  const tips = findings.filter(f => f.severity === "tip");

  const lines = [
    `# Office Document Accessibility Report`,
    ``,
    `## Scan Details`,
    ``,
    `| Field | Value |`,
    `|-------|-------|`,
    `| File | ${basename(filePath)} |`,
    `| Type | ${fileType.toUpperCase()} |`,
    `| Date | ${now.toISOString().split("T")[0]} |`,
    `| Errors | ${errors.length} |`,
    `| Warnings | ${warnings.length} |`,
    `| Tips | ${tips.length} |`,
    ``,
  ];

  if (findings.length === 0) {
    lines.push(`No accessibility issues found.`, ``);
    lines.push(`> Note: Automated scanning catches common issues but cannot verify all accessibility requirements.`);
    lines.push(`> Manual review with the Microsoft Accessibility Checker is recommended.`);
  } else {
    for (const [label, items] of [["Errors", errors], ["Warnings", warnings], ["Tips", tips]]) {
      if (items.length === 0) continue;
      lines.push(`## ${label}`, ``);
      for (const f of items) {
        lines.push(`### ${f.ruleId}: ${f.message.split(".")[0]}`);
        lines.push(``);
        lines.push(f.message);
        lines.push(``);
        lines.push(`- **Location:** ${f.location}`);
        lines.push(``);
      }
    }
    lines.push(`## Next Steps`, ``);
    lines.push(`1. Fix errors first — these block access for assistive technology users`);
    lines.push(`2. Address warnings — these degrade the experience`);
    lines.push(`3. Consider tips — these are best practices`);
    lines.push(`4. Run Microsoft Accessibility Checker in the Office application for additional checks`);
  }

  return lines.join("\n");
}

server.registerTool(
  "scan_office_document",
  {
    title: "Scan Office Document for Accessibility",
    description:
      "Scan a .docx, .xlsx, or .pptx file for accessibility issues using Microsoft Accessibility Checker rule sets. Returns findings grouped by severity. Supports configurable rule sets via .a11y-office-config.json. Optionally writes markdown report and/or SARIF output.",
    inputSchema: z.object({
      filePath: z
        .string()
        .describe("Absolute path to the Office document (.docx, .xlsx, or .pptx)"),
      reportPath: z
        .string()
        .optional()
        .describe("File path to write a markdown accessibility report"),
      sarifPath: z
        .string()
        .optional()
        .describe("File path to write SARIF 2.1.0 output for CI integration"),
      configPath: z
        .string()
        .optional()
        .describe("Path to .a11y-office-config.json. If omitted, searches from file directory upward."),
      disabledRules: z
        .array(z.string())
        .optional()
        .describe("Rule IDs to disable for this scan (overrides config file)"),
      severityFilter: z
        .array(z.enum(["error", "warning", "tip"]))
        .optional()
        .describe('Severity levels to include (overrides config file). Default: ["error","warning","tip"]'),
    }),
  },
  async ({ filePath, reportPath, sarifPath, configPath, disabledRules, severityFilter }) => {
    const ext = extname(filePath).toLowerCase();
    const validExts = [".docx", ".xlsx", ".pptx"];
    if (!validExts.includes(ext)) {
      return { content: [{ type: "text", text: `Unsupported file type: ${ext}. Supported: .docx, .xlsx, .pptx` }] };
    }
    const fileType = ext.slice(1); // "docx", "xlsx", "pptx"

    let buf;
    try {
      buf = await fsReadFile(filePath);
    } catch (err) {
      return { content: [{ type: "text", text: `Cannot read file: ${err.message}` }] };
    }

    let entries;
    try {
      entries = readZipEntries(buf);
    } catch (err) {
      return { content: [{ type: "text", text: `Cannot parse as ZIP/Office file: ${err.message}` }] };
    }

    // Load config
    let config;
    if (configPath) {
      try {
        if (!configPath.toLowerCase().endsWith(".json")) {
          return { content: [{ type: "text", text: "configPath must be a .json file." }] };
        }
        const safeConfigPath = validateOutputPath(configPath);
        const raw = await fsReadFile(safeConfigPath, "utf-8");
        config = JSON.parse(raw);
      } catch {
        config = {};
      }
    } else {
      config = await loadOfficeConfig(filePath);
    }

    const typeConfig = { ...(config[fileType] || { enabled: true, disabledRules: [], severityFilter: ["error", "warning", "tip"] }) };
    if (!typeConfig.enabled) {
      return { content: [{ type: "text", text: `Scanning disabled for ${fileType} in configuration.` }] };
    }
    // CLI overrides
    if (disabledRules) typeConfig.disabledRules = [...(typeConfig.disabledRules || []), ...disabledRules];
    if (severityFilter) typeConfig.severityFilter = severityFilter;

    let findings;
    if (fileType === "docx") findings = scanDocx(buf, entries, typeConfig);
    else if (fileType === "xlsx") findings = scanXlsx(buf, entries, typeConfig);
    else findings = scanPptx(buf, entries, typeConfig);

    // Write reports
    let reportNote = "";
    if (reportPath) {
      try {
        const safeReportPath = validateOutputPath(reportPath);
        const md = buildOfficeMarkdownReport(filePath, findings, fileType);
        await fsWriteFile(safeReportPath, md, "utf-8");
        reportNote += `\nReport written to: ${safeReportPath}`;
      } catch (err) {
        reportNote += `\nFailed to write report: ${err.message}`;
      }
    }
    if (sarifPath) {
      try {
        const safeSarifPath = validateOutputPath(sarifPath);
        const sarif = buildOfficeSarif(filePath, findings, fileType);
        await fsWriteFile(safeSarifPath, JSON.stringify(sarif, null, 2), "utf-8");
        reportNote += `\nSARIF written to: ${safeSarifPath}`;
      } catch (err) {
        reportNote += `\nFailed to write SARIF: ${err.message}`;
      }
    }

    const errors = findings.filter(f => f.severity === "error");
    const warnings = findings.filter(f => f.severity === "warning");
    const tips = findings.filter(f => f.severity === "tip");

    if (findings.length === 0) {
      return {
        content: [{ type: "text", text: `Office document scan complete: ${basename(filePath)}\n\nNo accessibility issues found.\n\nAutomated scanning catches common issues. Manual review with Microsoft Accessibility Checker is recommended.${reportNote}` }],
      };
    }

    const lines = [
      `Office document scan complete: ${basename(filePath)} (${fileType.toUpperCase()})`,
      `Total: ${errors.length} errors | ${warnings.length} warnings | ${tips.length} tips`,
      ``,
    ];

    for (const [label, items] of [["ERRORS", errors], ["WARNINGS", warnings], ["TIPS", tips]]) {
      if (items.length > 0) {
        lines.push(`${label} (${items.length}):`);
        for (const f of items) {
          lines.push(`  ${f.ruleId}: ${f.message}`);
        }
        lines.push("");
      }
    }

    lines.push("Fix errors first. Use the appropriate document specialist agent (word-accessibility, excel-accessibility, powerpoint-accessibility) for remediation guidance.");
    if (reportNote) lines.push(reportNote);

    return { content: [{ type: "text", text: lines.join("\n") }] };
  }
);

// --- PDF Document Scanning ---

/**
 * Lightweight PDF parser for accessibility checks.
 * Reads PDF structure without full rendering — checks metadata, tags, structure.
 */
function parsePdfBasics(buf) {
  const text = buf.toString("latin1");
  const info = {
    hasText: false,
    isTagged: false,
    hasTitle: false,
    title: "",
    hasLang: false,
    lang: "",
    hasStructureTree: false,
    hasBookmarks: false,
    hasForms: false,
    pageCount: 0,
    hasLinks: false,
    hasFigures: false,
    hasAltOnFigures: null, // null = no figures to check
    hasTables: false,
    hasLists: false,
    hasRoleMap: false,
    hasEmbeddedFonts: false,
    hasUnicodeMap: false,
    isEncrypted: false,
  };

  // Check encryption
  if (/\/Encrypt\s/.test(text)) info.isEncrypted = true;

  // Page count
  const pageCountMatch = text.match(/\/Type\s*\/Pages[\s\S]*?\/Count\s+(\d+)/);
  if (pageCountMatch) info.pageCount = parseInt(pageCountMatch[1]);

  // Check if tagged
  if (/\/MarkInfo\s*<<[\s\S]*?\/Marked\s+true/i.test(text)) info.isTagged = true;
  if (/\/StructTreeRoot\s/.test(text)) info.hasStructureTree = true;

  // Check for text content (vs scanned-only)
  if (/\/Type\s*\/Page[\s\S]*?stream[\s\S]*?BT[\s\S]*?ET/i.test(text)) info.hasText = true;
  // Also check for text via TJ/Tj operators
  if (/\(.*?\)\s*Tj|<[0-9a-fA-F]+>\s*Tj|\[.*?\]\s*TJ/i.test(text)) info.hasText = true;

  // Title in Info dictionary
  const titleMatch = text.match(/\/Title\s*\(([^)]*)\)/);
  if (titleMatch && titleMatch[1].trim()) {
    info.hasTitle = true;
    info.title = titleMatch[1].trim();
  }
  // Title in hex
  const titleHex = text.match(/\/Title\s*<([0-9a-fA-F]+)>/);
  if (titleHex && titleHex[1].length > 0) info.hasTitle = true;

  // Language
  const langMatch = text.match(/\/Lang\s*\(([^)]*)\)/);
  if (langMatch && langMatch[1].trim()) {
    info.hasLang = true;
    info.lang = langMatch[1].trim();
  }

  // Bookmarks / Outlines
  if (/\/Type\s*\/Outlines/.test(text) || /\/Outlines\s+\d+\s+\d+\s+R/.test(text)) info.hasBookmarks = true;

  // Forms
  if (/\/AcroForm\s/.test(text)) info.hasForms = true;

  // Links
  if (/\/Subtype\s*\/Link/.test(text)) info.hasLinks = true;

  // Structure elements
  if (/\/S\s*\/Figure/.test(text)) info.hasFigures = true;
  if (/\/S\s*\/Table/.test(text)) info.hasTables = true;
  if (/\/S\s*\/L\b/.test(text)) info.hasLists = true;
  if (/\/RoleMap\s*<</.test(text)) info.hasRoleMap = true;

  // Alt text on figures
  if (info.hasFigures) {
    const figureBlocks = text.match(/\/S\s*\/Figure[\s\S]*?(?:>>|endobj)/gi) || [];
    let withAlt = 0;
    for (const fb of figureBlocks) {
      if (/\/Alt\s/.test(fb)) withAlt++;
    }
    info.hasAltOnFigures = withAlt > 0;
  }

  // Fonts
  if (/\/Type\s*\/Font\b/.test(text)) {
    if (/\/FontFile|\/FontFile2|\/FontFile3/.test(text)) info.hasEmbeddedFonts = true;
    if (/\/ToUnicode\s/.test(text)) info.hasUnicodeMap = true;
  }

  return info;
}

function scanPdf(buf, config) {
  const findings = [];
  const disabled = new Set(config.disabledRules || []);
  const sevFilter = new Set(config.severityFilter || ["error", "warning", "tip"]);
  const info = parsePdfBasics(buf);

  function add(id, sev, msg, loc, confidence, humanReview) {
    if (disabled.has(id)) return;
    if (!sevFilter.has(sev === "blocker" ? "error" : sev)) return;
    findings.push({
      ruleId: id,
      severity: sev === "blocker" ? "error" : sev,
      message: msg,
      location: loc || "document",
      confidence: confidence || "high",
      requiresHumanReview: humanReview || false,
    });
  }

  // --- Layer 1: PDF/UA conformance (Matterhorn-derived, machine-checkable) ---

  // Checkpoint 01: Structure tree
  if (!info.hasStructureTree) {
    add("PDFUA.01.001", "error", "PDF has no structure tree. The document is not tagged and is inaccessible to screen readers. This is the most fundamental PDF/UA requirement.", "document catalog");
  }

  if (!info.isTagged) {
    add("PDFUA.01.002", "error", "PDF is not marked as tagged (MarkInfo/Marked is not true). Even if some structure exists, the document is not identified as a tagged PDF.", "MarkInfo");
  }

  // Checkpoint 06: Language
  if (!info.hasLang) {
    add("PDFUA.06.001", "error", "Document language (/Lang) is not set. Screen readers cannot determine which language to use for speech synthesis.", "document catalog");
  }

  // Checkpoint 07: Role mapping
  if (info.hasStructureTree && !info.hasRoleMap) {
    // Not necessarily a failure — only needed if custom tags are used
    // But we flag it as a tip for awareness
  }

  // Checkpoint 13: Figures
  if (info.hasFigures && info.hasAltOnFigures === false) {
    add("PDFUA.13.001", "error", "Figure elements exist without /Alt text. All non-decorative figures must have alternative text describing their content.", "structure tree");
  }

  // Checkpoint 19: Tables
  if (info.hasTables) {
    add("PDFUA.19.001", "warning", "Tables detected in structure tree. Verify TH (header) and TD (data) cells are correctly designated. Automated checking of header/scope relationships requires deeper parsing.", "structure tree", "medium", true);
  }

  // Checkpoint 21: Lists
  if (info.hasLists) {
    // Lists are tagged — good. This is primarily a check-present rule.
  }

  // Checkpoint 26: Forms
  if (info.hasForms) {
    add("PDFUA.26.001", "warning", "Form fields detected. Verify all form fields have tooltips and correct tab order. Full form accessibility requires manual testing.", "AcroForm", "medium", true);
  }

  // Checkpoint 28: Annotations (Links)
  if (info.hasLinks) {
    add("PDFUA.28.001", "warning", "Link annotations detected. Verify links are represented in the structure tree and have meaningful text. Manual verification recommended.", "annotations", "medium", true);
  }

  // --- Layer 2: Best-practice rules ---

  // PDFBP.META
  if (!info.hasTitle) {
    add("PDFBP.META.TITLE_PRESENT", "error", "Document title metadata is missing. Screen readers announce the title when opening the file. Without it, users hear the filename.", "Info dictionary");
  }

  if (!info.hasLang) {
    // Already covered by PDFUA.06.001. Only add best practice if UA rule disabled.
    if (disabled.has("PDFUA.06.001")) {
      add("PDFBP.META.LANG_PRESENT", "error", "Document language is not set.", "document catalog");
    }
  }

  if (!info.isTagged) {
    if (disabled.has("PDFUA.01.002")) {
      add("PDFBP.META.TAGGED_MARKER", "error", "PDF is not marked as tagged.", "MarkInfo");
    }
  }

  // PDFBP.TEXT
  if (!info.hasText) {
    add("PDFBP.TEXT.EXTRACTABLE", "error", "No extractable text found. This PDF may be a scanned image. Screen readers cannot read image-only PDFs. OCR or a tagged source document is required.", "page content streams");
  }

  if (info.hasText && !info.hasUnicodeMap) {
    add("PDFBP.TEXT.UNICODE_MAP", "warning", "No ToUnicode maps found for fonts. Text may not be correctly extracted by assistive technology, especially for non-Latin scripts.", "font resources");
  }

  if (info.hasText && !info.hasEmbeddedFonts) {
    add("PDFBP.TEXT.EMBEDDED_FONTS", "warning", "No embedded fonts detected. Non-embedded fonts may render differently or fail entirely on systems missing the font, impacting accessibility.", "font resources");
  }

  // PDFBP.STRUCT
  if (!info.hasStructureTree) {
    if (disabled.has("PDFUA.01.001")) {
      add("PDFBP.STRUCT.STRUCTURE_TREE_PRESENT", "error", "No structure tree. Document is unstructured.", "document catalog");
    }
  }

  // PDFBP.IMG
  if (info.hasFigures) {
    if (info.hasAltOnFigures === false && disabled.has("PDFUA.13.001")) {
      add("PDFBP.IMG.ALT_PRESENT", "error", "Figures without /Alt text.", "structure tree");
    }
  }

  // PDFBP.NAV
  if (info.pageCount > 10 && !info.hasBookmarks) {
    add("PDFBP.NAV.BOOKMARKS_FOR_LONG_DOCS", "warning", `Document has ${info.pageCount} pages but no bookmarks/outlines. Long documents should have bookmarks for navigation.`, "document outlines");
  }

  // PDFBP.FORMS
  if (info.hasForms) {
    add("PDFBP.FORMS.TAB_ORDER", "warning", "Form fields present. Verify tab order is set to 'Use Document Structure' (not 'Unordered'). Wrong tab order makes forms unusable for keyboard-only users.", "AcroForm", "medium", true);
  }

  // --- Layer 3: Quality/pipeline rules ---

  if (!info.hasText) {
    add("PDFQ.REPO.NO_SCANNED_ONLY", "error", "PDF appears to be image-only (scanned). Image-only PDFs are completely inaccessible. Provide a tagged source or apply OCR.", "page content");
  }

  if (info.isEncrypted) {
    add("PDFQ.REPO.ENCRYPTED", "warning", "PDF is encrypted. Encryption may prevent assistive technology from accessing content. Ensure accessibility permissions are not restricted.", "encryption dictionary");
  }

  return { findings, info };
}

function buildPdfSarif(filePath, findings) {
  const rules = findings.map(f => ({
    id: f.ruleId,
    shortDescription: { text: f.message.split(".")[0] },
    fullDescription: { text: f.message },
    defaultConfiguration: {
      level: f.severity === "error" ? "error" : f.severity === "warning" ? "warning" : "note",
    },
    properties: {
      confidence: f.confidence || "high",
      requiresHumanReview: f.requiresHumanReview || false,
    },
  }));
  const uniqueRules = [...new Map(rules.map(r => [r.id, r])).values()];

  return {
    $schema: "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/main/sarif-2.1/schema/sarif-schema-2.1.0.json",
    version: "2.1.0",
    runs: [{
      tool: {
        driver: {
          name: "a11y-pdf-scanner",
          version: "1.0.0",
          informationUri: "https://github.com/taylorarndt/a11y-agent-team",
          rules: uniqueRules,
        },
      },
      results: findings.map(f => ({
        ruleId: f.ruleId,
        level: f.severity === "error" ? "error" : f.severity === "warning" ? "warning" : "note",
        message: { text: f.message },
        locations: [{
          physicalLocation: {
            artifactLocation: { uri: filePath },
          },
        }],
        properties: {
          internalLocation: f.location,
          confidence: f.confidence,
          requiresHumanReview: f.requiresHumanReview,
        },
      })),
    }],
  };
}

function buildPdfMarkdownReport(filePath, findings, info) {
  const now = new Date();
  const errors = findings.filter(f => f.severity === "error");
  const warnings = findings.filter(f => f.severity === "warning");
  const tips = findings.filter(f => f.severity === "tip");
  const humanReview = findings.filter(f => f.requiresHumanReview);

  const lines = [
    `# PDF Accessibility Report`,
    ``,
    `## Scan Details`,
    ``,
    `| Field | Value |`,
    `|-------|-------|`,
    `| File | ${basename(filePath)} |`,
    `| Date | ${now.toISOString().split("T")[0]} |`,
    `| Pages | ${info.pageCount || "unknown"} |`,
    `| Tagged | ${info.isTagged ? "Yes" : "No"} |`,
    `| Language | ${info.lang || "Not set"} |`,
    `| Title | ${info.title || "Not set"} |`,
    `| Has text | ${info.hasText ? "Yes" : "No (may be scanned image)"} |`,
    `| Errors | ${errors.length} |`,
    `| Warnings | ${warnings.length} |`,
    `| Tips | ${tips.length} |`,
    `| Requires human review | ${humanReview.length} |`,
    ``,
  ];

  if (findings.length === 0) {
    lines.push(`No automated accessibility issues found.`, ``);
    lines.push(`> Automated PDF scanning checks structure and metadata.`);
    lines.push(`> Manual review for reading order, alt text quality, and complex semantics is still required.`);
  } else {
    for (const [label, items] of [["Errors", errors], ["Warnings", warnings], ["Tips", tips]]) {
      if (items.length === 0) continue;
      lines.push(`## ${label}`, ``);
      for (const f of items) {
        lines.push(`### ${f.ruleId}`);
        lines.push(``);
        lines.push(f.message);
        lines.push(``);
        lines.push(`- **Location:** ${f.location}`);
        lines.push(`- **Confidence:** ${f.confidence}`);
        if (f.requiresHumanReview) lines.push(`- **Requires human review:** Yes`);
        lines.push(``);
      }
    }

    if (humanReview.length > 0) {
      lines.push(`## Human Review Checklist`, ``);
      lines.push(`The following items were flagged but require human verification:`, ``);
      for (const f of humanReview) {
        lines.push(`- [ ] ${f.ruleId}: ${f.message.split(".")[0]}`);
      }
      lines.push(``);
    }

    lines.push(`## Next Steps`, ``);
    lines.push(`1. Fix errors first — untagged/image-only PDFs are completely inaccessible`);
    lines.push(`2. Address warnings — these impact navigability and correct interpretation`);
    lines.push(`3. Complete human review items — automated tools cannot verify these`);
    lines.push(`4. For advanced PDF/UA validation, run veraPDF locally: \`verapdf --flavour ua1 file.pdf\``);
    lines.push(`5. For interactive testing, use PAC (PDF Accessibility Checker)`);
  }

  return lines.join("\n");
}

/** Load PDF scan config searching from filePath upward */
async function loadPdfConfig(filePath) {
  const defaultConfig = {
    enabled: true,
    disabledRules: [],
    severityFilter: ["error", "warning", "tip"],
    maxFileSize: 100 * 1024 * 1024, // 100MB
  };
  let dir = dirname(filePath);
  for (let i = 0; i < 20; i++) {
    const configPath = join(dir, ".a11y-pdf-config.json");
    try {
      const raw = await fsReadFile(configPath, "utf-8");
      const parsed = JSON.parse(raw);
      return { ...defaultConfig, ...parsed };
    } catch { /* not found */ }
    const parent = dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return defaultConfig;
}

server.registerTool(
  "scan_pdf_document",
  {
    title: "Scan PDF Document for Accessibility",
    description:
      "Scan a PDF file for accessibility issues using PDF/UA (Matterhorn Protocol) conformance checks and best-practice rules. Checks tagging, structure tree, language, alt text, bookmarks, forms, and more. Supports configurable rule sets via .a11y-pdf-config.json. Optionally writes markdown report and/or SARIF output.",
    inputSchema: z.object({
      filePath: z
        .string()
        .describe("Absolute path to the PDF file"),
      reportPath: z
        .string()
        .optional()
        .describe("File path to write a markdown accessibility report"),
      sarifPath: z
        .string()
        .optional()
        .describe("File path to write SARIF 2.1.0 output for CI integration"),
      configPath: z
        .string()
        .optional()
        .describe("Path to .a11y-pdf-config.json. If omitted, searches from file directory upward."),
      disabledRules: z
        .array(z.string())
        .optional()
        .describe("Rule IDs to disable for this scan (overrides config file)"),
      severityFilter: z
        .array(z.enum(["error", "warning", "tip"]))
        .optional()
        .describe('Severity levels to include. Default: ["error","warning","tip"]'),
    }),
  },
  async ({ filePath, reportPath, sarifPath, configPath, disabledRules, severityFilter }) => {
    if (!filePath.toLowerCase().endsWith(".pdf")) {
      return { content: [{ type: "text", text: "File must be a .pdf file." }] };
    }

    let buf;
    try {
      buf = await fsReadFile(filePath);
    } catch (err) {
      return { content: [{ type: "text", text: `Cannot read file: ${err.message}` }] };
    }

    // Basic PDF validation
    const header = buf.toString("latin1", 0, 8);
    if (!header.startsWith("%PDF-")) {
      return { content: [{ type: "text", text: "File does not appear to be a valid PDF (missing %PDF- header)." }] };
    }

    // Load config
    let config;
    if (configPath) {
      try {
        if (!configPath.toLowerCase().endsWith(".json")) {
          return { content: [{ type: "text", text: "configPath must be a .json file." }] };
        }
        const safeConfigPath = validateOutputPath(configPath);
        const raw = await fsReadFile(safeConfigPath, "utf-8");
        config = JSON.parse(raw);
      } catch { config = {}; }
    } else {
      config = await loadPdfConfig(filePath);
    }

    if (config.enabled === false) {
      return { content: [{ type: "text", text: "PDF scanning is disabled in configuration." }] };
    }
    if (disabledRules) config.disabledRules = [...(config.disabledRules || []), ...disabledRules];
    if (severityFilter) config.severityFilter = severityFilter;

    const { findings, info } = scanPdf(buf, config);

    // Write reports
    let reportNote = "";
    if (reportPath) {
      try {
        const safeReportPath = validateOutputPath(reportPath);
        const md = buildPdfMarkdownReport(filePath, findings, info);
        await fsWriteFile(safeReportPath, md, "utf-8");
        reportNote += `\nReport written to: ${safeReportPath}`;
      } catch (err) {
        reportNote += `\nFailed to write report: ${err.message}`;
      }
    }
    if (sarifPath) {
      try {
        const safeSarifPath = validateOutputPath(sarifPath);
        const sarif = buildPdfSarif(filePath, findings);
        await fsWriteFile(safeSarifPath, JSON.stringify(sarif, null, 2), "utf-8");
        reportNote += `\nSARIF written to: ${safeSarifPath}`;
      } catch (err) {
        reportNote += `\nFailed to write SARIF: ${err.message}`;
      }
    }

    const errors = findings.filter(f => f.severity === "error");
    const warnings = findings.filter(f => f.severity === "warning");
    const tips = findings.filter(f => f.severity === "tip");
    const humanReview = findings.filter(f => f.requiresHumanReview);

    if (findings.length === 0) {
      return {
        content: [{ type: "text", text: `PDF scan complete: ${basename(filePath)}\n\nNo automated accessibility issues found.\nPages: ${info.pageCount} | Tagged: ${info.isTagged ? "Yes" : "No"} | Language: ${info.lang || "Not set"}\n\nFor comprehensive PDF/UA validation, run veraPDF: verapdf --flavour ua1 "${basename(filePath)}"${reportNote}` }],
      };
    }

    const lines = [
      `PDF scan complete: ${basename(filePath)}`,
      `Pages: ${info.pageCount} | Tagged: ${info.isTagged ? "Yes" : "No"} | Language: ${info.lang || "Not set"}`,
      `Total: ${errors.length} errors | ${warnings.length} warnings | ${tips.length} tips | ${humanReview.length} need human review`,
      ``,
    ];

    for (const [label, items] of [["ERRORS", errors], ["WARNINGS", warnings], ["TIPS", tips]]) {
      if (items.length > 0) {
        lines.push(`${label} (${items.length}):`);
        for (const f of items) {
          lines.push(`  ${f.ruleId}: ${f.message}`);
        }
        lines.push("");
      }
    }

    if (humanReview.length > 0) {
      lines.push(`HUMAN REVIEW REQUIRED (${humanReview.length}):`);
      for (const f of humanReview) {
        lines.push(`  ${f.ruleId}: ${f.message.split(".")[0]}`);
      }
      lines.push("");
    }

    lines.push("Use the pdf-accessibility agent for detailed remediation guidance.");
    lines.push("For comprehensive PDF/UA validation, run veraPDF locally.");
    if (reportNote) lines.push(reportNote);

    return { content: [{ type: "text", text: lines.join("\n") }] };
  }
);

// --- Document Metadata Extraction ---

server.registerTool(
  "extract_document_metadata",
  {
    title: "Extract Document Metadata",
    description:
      "Extract accessibility-relevant metadata from an Office document (.docx, .xlsx, .pptx) or PDF. Returns title, author, language, creation date, modification date, template info, page/slide/sheet count, and accessibility property health. Useful for building metadata dashboards and identifying systemic metadata gaps across document libraries.",
    inputSchema: z.object({
      filePath: z
        .string()
        .describe("Absolute path to the document file (.docx, .xlsx, .pptx, or .pdf)"),
    }),
  },
  async ({ filePath }) => {
    const ext = extname(filePath).toLowerCase();
    const validExts = [".docx", ".xlsx", ".pptx", ".pdf"];
    if (!validExts.includes(ext)) {
      return { content: [{ type: "text", text: `Unsupported file type: ${ext}. Supported: .docx, .xlsx, .pptx, .pdf` }] };
    }

    let buf;
    try {
      buf = await fsReadFile(filePath);
    } catch (err) {
      return { content: [{ type: "text", text: `Cannot read file: ${err.message}` }] };
    }

    const fileStat = await stat(filePath).catch(() => null);
    const fileSize = fileStat ? fileStat.size : buf.length;

    if (ext === ".pdf") {
      const info = parsePdfBasics(buf);
      const meta = {
        file: basename(filePath),
        type: "pdf",
        fileSize,
        title: info.title || null,
        titleSet: info.hasTitle,
        language: info.lang || null,
        languageSet: info.hasLang,
        tagged: info.isTagged,
        hasStructureTree: info.hasStructureTree,
        hasBookmarks: info.hasBookmarks,
        hasForms: info.hasForms,
        hasText: info.hasText,
        pageCount: info.pageCount,
        encrypted: info.isEncrypted,
        hasEmbeddedFonts: info.hasEmbeddedFonts,
        hasUnicodeMap: info.hasUnicodeMap,
      };

      const lines = [
        `Document Metadata: ${meta.file}`,
        `Type: PDF`,
        `File Size: ${(fileSize / 1024).toFixed(1)} KB`,
        `Pages: ${meta.pageCount}`,
        `Title: ${meta.title || "NOT SET"}`,
        `Language: ${meta.language || "NOT SET"}`,
        `Tagged: ${meta.tagged ? "Yes" : "No"}`,
        `Structure Tree: ${meta.hasStructureTree ? "Yes" : "No"}`,
        `Bookmarks: ${meta.hasBookmarks ? "Yes" : "No"}`,
        `Has Text: ${meta.hasText ? "Yes" : "No (may be scanned image)"}`,
        `Encrypted: ${meta.encrypted ? "Yes" : "No"}`,
        `Embedded Fonts: ${meta.hasEmbeddedFonts ? "Yes" : "No"}`,
        ``,
        `Accessibility Property Health:`,
        `  Title: ${meta.titleSet ? "PASS" : "FAIL"}`,
        `  Language: ${meta.languageSet ? "PASS" : "FAIL"}`,
        `  Tagged: ${meta.tagged ? "PASS" : "FAIL"}`,
        `  Structure: ${meta.hasStructureTree ? "PASS" : "FAIL"}`,
        `  Text extractable: ${meta.hasText ? "PASS" : "FAIL"}`,
      ];

      return { content: [{ type: "text", text: lines.join("\n") }] };
    }

    // Office documents (ZIP-based)
    let entries;
    try {
      entries = readZipEntries(buf);
    } catch (err) {
      return { content: [{ type: "text", text: `Cannot parse as ZIP/Office file: ${err.message}` }] };
    }

    const core = getZipXml(buf, entries, "docProps/core.xml");
    const app = getZipXml(buf, entries, "docProps/app.xml");

    const title = (xmlText(core, "dc:title")[0] || "").trim();
    const creator = (xmlText(core, "dc:creator")[0] || "").trim();
    const lastModifiedBy = (xmlText(core, "cp:lastModifiedBy")[0] || "").trim();
    const created = (xmlText(core, "dcterms:created")[0] || "").trim();
    const modified = (xmlText(core, "dcterms:modified")[0] || "").trim();
    const subject = (xmlText(core, "dc:subject")[0] || "").trim();
    const keywords = (xmlText(core, "cp:keywords")[0] || "").trim();
    const language = (xmlText(core, "dc:language")[0] || "").trim();
    const description = (xmlText(core, "dc:description")[0] || "").trim();
    const template = (xmlText(app, "Template")[0] || "").trim();
    const appName = (xmlText(app, "Application")[0] || "").trim();
    const pages = (xmlText(app, "Pages")[0] || "").trim();
    const slides = (xmlText(app, "Slides")[0] || "").trim();

    let itemCount = "";
    if (ext === ".docx") {
      itemCount = pages ? `Pages: ${pages}` : "Pages: unknown";
    } else if (ext === ".pptx") {
      const slideFiles = [...entries.keys()].filter(k => /^ppt\/slides\/slide\d+\.xml$/.test(k));
      itemCount = `Slides: ${slides || slideFiles.length}`;
    } else if (ext === ".xlsx") {
      const workbook = getZipXml(buf, entries, "xl/workbook.xml");
      const sheetNames = xmlAttr(workbook, "sheet", "name");
      itemCount = `Sheets: ${sheetNames.length} (${sheetNames.join(", ")})`;
    }

    const lines = [
      `Document Metadata: ${basename(filePath)}`,
      `Type: ${ext.slice(1).toUpperCase()}`,
      `File Size: ${(fileSize / 1024).toFixed(1)} KB`,
      itemCount,
      `Title: ${title || "NOT SET"}`,
      `Author: ${creator || "NOT SET"}`,
      `Last Modified By: ${lastModifiedBy || "unknown"}`,
      `Created: ${created || "unknown"}`,
      `Modified: ${modified || "unknown"}`,
      `Language: ${language || "NOT SET"}`,
      `Subject: ${subject || "NOT SET"}`,
      `Keywords: ${keywords || "NOT SET"}`,
      `Template: ${template || "none detected"}`,
      `Application: ${appName || "unknown"}`,
      ``,
      `Accessibility Property Health:`,
      `  Title: ${title ? "PASS" : "FAIL"}`,
      `  Author: ${creator ? "PASS" : "FAIL"}`,
      `  Language: ${language ? "FAIL — not set" : (() => { const doc = ext === ".docx" ? getZipXml(buf, entries, "word/document.xml") : ""; return xmlHas(doc, "w:lang") ? "PASS" : "FAIL — not set"; })()}`,
      `  Subject: ${subject ? "PASS" : "MISSING"}`,
      `  Keywords: ${keywords ? "PASS" : "MISSING"}`,
    ];

    return { content: [{ type: "text", text: lines.join("\n") }] };
  }
);

server.registerTool(
  "batch_scan_documents",
  {
    title: "Batch Scan Documents for Accessibility",
    description:
      "Scan multiple Office documents (.docx, .xlsx, .pptx) and/or PDFs for accessibility issues in a single call. Returns an aggregated summary with per-file results, cross-document patterns, and an overall accessibility scorecard. More efficient than scanning files individually.",
    inputSchema: z.object({
      filePaths: z
        .array(z.string())
        .describe("Array of absolute file paths to scan"),
      reportPath: z
        .string()
        .optional()
        .describe("File path to write an aggregated markdown report"),
      severityFilter: z
        .array(z.enum(["error", "warning", "tip"]))
        .optional()
        .describe('Severity levels to include. Default: ["error","warning","tip"]'),
    }),
  },
  async ({ filePaths, reportPath, severityFilter }) => {
    const results = [];
    const errors = [];

    for (const fp of filePaths) {
      const ext = extname(fp).toLowerCase();
      const validExts = [".docx", ".xlsx", ".pptx", ".pdf"];
      if (!validExts.includes(ext)) {
        errors.push(`${basename(fp)}: unsupported type ${ext}`);
        continue;
      }

      let buf;
      try {
        buf = await fsReadFile(fp);
      } catch (err) {
        errors.push(`${basename(fp)}: ${err.message}`);
        continue;
      }

      const defaultSev = severityFilter || ["error", "warning", "tip"];
      let findings = [];

      if (ext === ".pdf") {
        const header = buf.toString("latin1", 0, 8);
        if (!header.startsWith("%PDF-")) {
          errors.push(`${basename(fp)}: not a valid PDF`);
          continue;
        }
        const config = await loadPdfConfig(fp);
        if (severityFilter) config.severityFilter = severityFilter;
        const result = scanPdf(buf, config);
        findings = result.findings;
      } else {
        let entries;
        try {
          entries = readZipEntries(buf);
        } catch {
          errors.push(`${basename(fp)}: not a valid Office file`);
          continue;
        }
        const config = await loadOfficeConfig(fp);
        const fileType = ext.slice(1);
        const typeConfig = { ...(config[fileType] || { enabled: true, disabledRules: [], severityFilter: defaultSev }) };
        if (severityFilter) typeConfig.severityFilter = severityFilter;
        if (!typeConfig.enabled) {
          errors.push(`${basename(fp)}: scanning disabled in config`);
          continue;
        }
        if (fileType === "docx") findings = scanDocx(buf, entries, typeConfig);
        else if (fileType === "xlsx") findings = scanXlsx(buf, entries, typeConfig);
        else findings = scanPptx(buf, entries, typeConfig);
      }

      const errs = findings.filter(f => f.severity === "error").length;
      const warns = findings.filter(f => f.severity === "warning").length;
      const tips = findings.filter(f => f.severity === "tip").length;

      // Compute score
      let score = 100;
      for (const f of findings) {
        const conf = f.confidence || "high";
        if (f.severity === "error") {
          score -= conf === "high" ? 10 : conf === "medium" ? 7 : 3;
        } else if (f.severity === "warning") {
          score -= conf === "high" ? 3 : conf === "medium" ? 2 : 1;
        }
      }
      score = Math.max(0, score);
      const grade = score >= 90 ? "A" : score >= 75 ? "B" : score >= 50 ? "C" : score >= 25 ? "D" : "F";

      results.push({
        file: basename(fp),
        path: fp,
        type: ext.slice(1),
        errors: errs,
        warnings: warns,
        tips: tips,
        score,
        grade,
        findings,
      });
    }

    // Cross-document patterns
    const ruleCounts = {};
    for (const r of results) {
      const seenRules = new Set();
      for (const f of r.findings) {
        if (!seenRules.has(f.ruleId)) {
          ruleCounts[f.ruleId] = (ruleCounts[f.ruleId] || 0) + 1;
          seenRules.add(f.ruleId);
        }
      }
    }
    const commonIssues = Object.entries(ruleCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5);

    const totalErrors = results.reduce((s, r) => s + r.errors, 0);
    const totalWarnings = results.reduce((s, r) => s + r.warnings, 0);
    const totalTips = results.reduce((s, r) => s + r.tips, 0);
    const avgScore = results.length > 0 ? Math.round(results.reduce((s, r) => s + r.score, 0) / results.length) : 0;
    const avgGrade = avgScore >= 90 ? "A" : avgScore >= 75 ? "B" : avgScore >= 50 ? "C" : avgScore >= 25 ? "D" : "F";

    const lines = [
      `Batch Scan Complete: ${results.length} documents scanned`,
      errors.length > 0 ? `Skipped: ${errors.length} files (${errors.join("; ")})` : "",
      ``,
      `Overall: ${totalErrors} errors | ${totalWarnings} warnings | ${totalTips} tips`,
      `Average Score: ${avgScore}/100 (${avgGrade})`,
      ``,
      `Scorecard:`,
    ];

    for (const r of results.sort((a, b) => a.score - b.score)) {
      lines.push(`  ${r.file.padEnd(40)} ${r.score}/100 (${r.grade})  ${r.errors}E ${r.warnings}W ${r.tips}T`);
    }

    if (commonIssues.length > 0) {
      lines.push(``);
      lines.push(`Most Common Issues:`);
      for (const [rule, count] of commonIssues) {
        lines.push(`  ${rule} — found in ${count}/${results.length} documents`);
      }
    }

    // Write report if requested
    let reportNote = "";
    if (reportPath) {
      const now = new Date();
      const reportLines = [
        `# Batch Document Accessibility Report`,
        ``,
        `| Field | Value |`,
        `|-------|-------|`,
        `| Date | ${now.toISOString().split("T")[0]} |`,
        `| Documents Scanned | ${results.length} |`,
        `| Documents Skipped | ${errors.length} |`,
        `| Total Errors | ${totalErrors} |`,
        `| Total Warnings | ${totalWarnings} |`,
        `| Average Score | ${avgScore}/100 (${avgGrade}) |`,
        ``,
        `## Scorecard`,
        ``,
        `| Document | Type | Score | Grade | Errors | Warnings | Tips |`,
        `|----------|------|-------|-------|--------|----------|------|`,
      ];
      for (const r of results.sort((a, b) => a.score - b.score)) {
        reportLines.push(`| ${r.file} | ${r.type.toUpperCase()} | ${r.score} | ${r.grade} | ${r.errors} | ${r.warnings} | ${r.tips} |`);
      }
      reportLines.push(``);
      if (commonIssues.length > 0) {
        reportLines.push(`## Cross-Document Patterns`);
        reportLines.push(``);
        reportLines.push(`| Rule | Files Affected | Percentage |`);
        reportLines.push(`|------|---------------|------------|`);
        for (const [rule, count] of commonIssues) {
          reportLines.push(`| ${rule} | ${count}/${results.length} | ${Math.round(count / results.length * 100)}% |`);
        }
        reportLines.push(``);
      }
      if (errors.length > 0) {
        reportLines.push(`## Skipped Files`);
        reportLines.push(``);
        for (const e of errors) reportLines.push(`- ${e}`);
        reportLines.push(``);
      }
      reportLines.push(`## Per-File Details`);
      reportLines.push(``);
      for (const r of results) {
        reportLines.push(`### ${r.file}`);
        reportLines.push(``);
        reportLines.push(`**Score:** ${r.score}/100 (${r.grade}) | **Errors:** ${r.errors} | **Warnings:** ${r.warnings} | **Tips:** ${r.tips}`);
        reportLines.push(``);
        if (r.findings.length > 0) {
          for (const f of r.findings) {
            reportLines.push(`- **${f.ruleId}** (${f.severity}): ${f.message}`);
          }
        } else {
          reportLines.push(`No issues found.`);
        }
        reportLines.push(``);
      }
      try {
        const safeReportPath = validateOutputPath(reportPath);
        await fsWriteFile(safeReportPath, reportLines.join("\n"), "utf-8");
        reportNote = `\nReport written to: ${safeReportPath}`;
      } catch (err) {
        reportNote = `\nFailed to write report: ${err.message}`;
      }
    }

    if (reportNote) lines.push(reportNote);

    return { content: [{ type: "text", text: lines.filter(Boolean).join("\n") }] };
  }
);

// --- Prompts ---

const AUDIT_PREAMBLE = `You are an accessibility specialist conducting a WCAG 2.1 AA compliance review. Be thorough and specific. For each issue found, report:
- Severity (Critical/Major/Minor)
- File location and what is wrong
- Impact on screen reader and keyboard users
- How to fix it with corrected code

`;

server.registerPrompt(
  "accessibility-audit",
  {
    title: "Full Accessibility Audit",
    description:
      "Run a comprehensive accessibility audit checking structure, ARIA, keyboard navigation, contrast, focus management, and live regions.",
    argsSchema: {
      code: z.string().describe("The code to audit"),
    },
  },
  ({ code }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `${AUDIT_PREAMBLE}Review this code against ALL of the following checklists:

STRUCTURE:
- Single H1, logical heading hierarchy
- Correct landmark elements (header, nav, main, footer)
- Skip link present and functional
- Page title set and descriptive
- Lang attribute on html element

INTERACTION:
- Every interactive element reachable by keyboard
- Tab order matches visual layout
- No positive tabindex values
- Focus managed on route changes, dynamic content, deletions
- Modals trap focus and return focus on close
- Escape closes overlays

ARIA:
- No redundant ARIA on semantic elements
- ARIA states update dynamically with interactions
- All ID references in aria-controls, aria-labelledby, aria-describedby are valid
- Live regions present for dynamic content updates

VISUAL:
- Text contrast 4.5:1 normal, 3:1 large
- UI component contrast 3:1
- Focus indicators visible with 3:1 contrast
- No information by color alone
- prefers-reduced-motion supported

FORMS:
- Every input has a label
- Errors associated with aria-describedby
- Focus moves to first error on submit
- Required fields marked with required attribute

CONTENT:
- Images have appropriate alt text
- Icons hidden from screen readers
- Links have descriptive text

Code to audit:

${code}`,
        },
      },
    ],
  })
);

server.registerPrompt(
  "aria-review",
  {
    title: "ARIA Review",
    description:
      "Review ARIA roles, states, and properties. Enforces the first rule of ARIA: do not use it if native HTML works.",
    argsSchema: {
      code: z.string().describe("The code to review"),
    },
  },
  ({ code }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `${AUDIT_PREAMBLE}You are an ARIA specialist. Review this code for ARIA correctness.

NEVER ADD REDUNDANT ARIA:
- <header> already has banner role
- <nav> already has navigation role
- <main> already has main role
- <button> never needs role="button"
- <a href> never needs role="link"

CHECK:
1. Does every interactive element have an accessible name?
2. Are ARIA roles used only where native HTML cannot express the semantics?
3. Are ARIA states (aria-expanded, aria-selected, aria-checked) updated dynamically?
4. Do aria-controls and aria-labelledby point to valid, existing IDs?
5. Are live regions present and using correct politeness level?
6. Is focus managed correctly?
7. Are decorative elements hidden from assistive technology?
8. Will a screen reader announce each component in a way that makes sense?

Code to review:

${code}`,
        },
      },
    ],
  })
);

server.registerPrompt(
  "modal-review",
  {
    title: "Modal/Dialog Review",
    description:
      "Review a modal, dialog, drawer, or overlay for focus trapping, focus return, escape behavior, and heading structure.",
    argsSchema: {
      code: z.string().describe("The modal/dialog code to review"),
    },
  },
  ({ code }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `${AUDIT_PREAMBLE}You are a modal and dialog specialist. Review this overlay code.

CHECK ALL OF THE FOLLOWING:
1. Does it use <dialog> with showModal()?
2. Does focus land on Close button without needing Tab?
3. Is focus trapped inside?
4. Does Escape close it?
5. Does focus return to the trigger on close?
6. Is there a heading at H2 or lower (never H1 in a modal)?
7. Does aria-labelledby point to a valid heading ID?
8. Does the trigger have aria-haspopup="dialog"?
9. Are icons hidden with aria-hidden="true"?
10. For alert dialogs: does focus land on least destructive action?

Code to review:

${code}`,
        },
      },
    ],
  })
);

server.registerPrompt(
  "contrast-review",
  {
    title: "Color Contrast Review",
    description:
      "Review color choices and CSS for WCAG AA contrast compliance.",
    argsSchema: {
      code: z.string().describe("The CSS/styled code to review"),
    },
  },
  ({ code }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `${AUDIT_PREAMBLE}You are a color contrast and visual accessibility specialist. Review this code.

WCAG AA REQUIREMENTS:
- Normal text (under 18px): 4.5:1 against background
- Large text (18px+ or 14px+ bold): 3:1 against background
- UI components (buttons, inputs, borders): 3:1 against adjacent colors
- Focus indicators: 3:1 against both component and background

ALSO CHECK:
- No information conveyed by color alone (errors need text/icons too)
- Links distinguishable from surrounding text without color
- prefers-reduced-motion handled
- Dark mode colors re-checked (not just inverted)
- Placeholder text meets contrast requirements
- Focus indicators visible on all backgrounds

COMMON TAILWIND FAILURES:
- text-gray-400 on white: 2.85:1 FAILS
- text-gray-300 on white: 1.74:1 FAILS
- text-gray-500 on bg-gray-900: 3.41:1 FAILS normal text

For each color combination, calculate the contrast ratio and state PASS or FAIL.

Code to review:

${code}`,
        },
      },
    ],
  })
);

server.registerPrompt(
  "keyboard-review",
  {
    title: "Keyboard Navigation Review",
    description:
      "Review code for keyboard accessibility: tab order, focus management, skip links, and keyboard traps.",
    argsSchema: {
      code: z.string().describe("The code to review"),
    },
  },
  ({ code }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `${AUDIT_PREAMBLE}You are a keyboard navigation and focus management specialist. Review this code.

CHECK ALL OF THE FOLLOWING:
1. Can every interactive element be reached by Tab?
2. Can every interactive element be activated by Enter or Space?
3. Does tab order match visual layout?
4. No positive tabindex values?
5. Focus managed on route changes?
6. Focus managed when content is added or removed?
7. No keyboard traps (except intentional modal traps)?
8. Skip link present and working?
9. Arrow keys work in tabs, menus, comboboxes?
10. Escape closes overlays and returns focus?
11. Focus indicators visible on every interactive element?

COMMON MISTAKES TO CATCH:
- Click handlers on <div> without keyboard equivalent
- Hover-only interactions with no keyboard trigger
- Drag-and-drop without keyboard alternative
- outline:none without alternative focus style
- Focus left on removed DOM element
- mousedown/mouseup without keydown/keyup

Code to review:

${code}`,
        },
      },
    ],
  })
);

server.registerPrompt(
  "live-region-review",
  {
    title: "Live Region Review",
    description:
      "Review dynamic content for screen reader announcements: live regions, toasts, loading states, and form feedback.",
    argsSchema: {
      code: z.string().describe("The code to review"),
    },
  },
  ({ code }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `${AUDIT_PREAMBLE}You are a live region and dynamic content specialist. Review this code.

CHECK ALL OF THE FOLLOWING:
1. Does every dynamic content update have a live region or focus management?
2. Are live regions in the DOM BEFORE their content changes?
3. Is aria-live="assertive" used ONLY for genuine critical alerts?
4. Are rapid updates debounced (500ms minimum)?
5. Are loading states announced for operations over 2 seconds?
6. Are announcements short and meaningful?
7. Are live regions NOT hidden with display:none or visibility:hidden?
8. Is textContent used to update (not innerHTML or element replacement)?
9. For React: are live regions unconditionally rendered (not behind &&)?
10. Are toasts announced without stealing focus?

COMMON MISTAKES TO CATCH:
- No live region for search results or filter changes
- aria-live on container that gets replaced instead of updated
- aria-live="assertive" on routine updates like search counts
- Live region created dynamically at same time as content
- Using display:none on a live region

Code to review:

${code}`,
        },
      },
    ],
  })
);

// --- Start Server ---

const transport = new StdioServerTransport();
await server.connect(transport);
