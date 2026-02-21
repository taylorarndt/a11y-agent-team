import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

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
