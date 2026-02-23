# powerpoint-accessibility — Microsoft PowerPoint (PPTX) Accessibility

> Scans Microsoft PowerPoint presentations for accessibility issues. Uses the `scan_office_document` MCP tool to parse PPTX files and check for slide titles, reading order, alt text on images, table structure, audio/video descriptions, and use of speaker notes.

## When to Use It

- Reviewing presentations before sharing or presenting
- Checking slide templates for accessibility compliance
- Auditing PPTX files for procurement or public distribution
- Preparing presentations that will be available as shared documents

## What It Catches

<details>
<summary>Expand — 11 PowerPoint accessibility rules (PPTX-E001 – PPTX-W005)</summary>

| Rule | Severity | Description |
|------|----------|--------------|
| PPTX-E001 | Error | Slides without titles |
| PPTX-E002 | Error | Images without alt text |
| PPTX-E003 | Error | Missing reading order definitions |
| PPTX-E004 | Error | Tables without header rows |
| PPTX-E005 | Error | Audio/video without descriptions |
| PPTX-E006 | Error | Missing presentation language |
| PPTX-W001 | Warning | Multiple slides with identical titles |
| PPTX-W002 | Warning | Small font sizes below 18pt for slides |
| PPTX-W003 | Warning | Excessive text on single slides |
| PPTX-W004 | Warning | Missing speaker notes |
| PPTX-W005 | Warning | Slide transitions without user control |

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

```
/powerpoint-accessibility scan presentation.pptx for accessibility
@powerpoint-accessibility review the company deck template
@powerpoint-accessibility check all slide decks in assets/
```

</details>

## How to Launch It

**In Claude Code (terminal):**
```
/powerpoint-accessibility scan company-overview.pptx
/powerpoint-accessibility review the training materials deck
/powerpoint-accessibility check all .pptx files in /presentations
```

**In GitHub Copilot Chat:**
```
@powerpoint-accessibility scan company-overview.pptx
@powerpoint-accessibility audit the onboarding slide deck
```

**Via the prompt picker:** Select `audit-single-document` and enter the `.pptx` file path.

**Via document-accessibility-wizard:** For batch auditing entire presentation libraries, use the wizard with the folder scan mode.

## Step-by-Step: What a Scan Session Looks Like

**You say:**
```
/powerpoint-accessibility scan annual-review.pptx
```

**What the agent does:**

1. **Parses the PPTX file** using the `scan_office_document` MCP tool. PPTX files are ZIP archives containing one XML file per slide plus slide layouts, masters, and media relationships. The agent processes every slide.

2. **Runs all 11 accessibility rules across every slide.** For example:
   - Checks each `<p:sp>` title placeholder on every slide (PPTX-E001)
   - Inspects every `<p:pic>` element for `<p:nvPicPr><p:nvPr><a:ph>` alt text (PPTX-E002)
   - Reads the slide reading order from `<p:spTree>` element ordering (PPTX-E003)
   - Checks every `<a:tbl>` for `<a:tr>` header row attributes (PPTX-E004)

3. **Computes the score** using the weighted formula.

4. **Returns findings with exact slide numbers.** Here is a real example:

```
PPTX-E001 [Error] — High Confidence
Slide without a title
Location: Slide 7 ("Our Team" section divider)
Remediation: Add a title text box to the slide and style it with the Title placeholder
from the slide layout. If the slide is intentionally a section divider with only a visual
heading, use the built-in Title placeholder — screen readers use it to announce the
slide when navigating by slide list.
```

5. **Presents the score, grade, and remediation priority list.**

## Understanding Your Results

### Score Interpretation

| Score | Grade | What it means |
|-------|-------|---------------|
| 90–100 | A | Excellent — safe to share or publish |
| 75–89 | B | Good — some warnings before external distribution |
| 50–74 | C | Needs work — multiple errors blocking AT users |
| 25–49 | D | Poor — significant navigation and content barriers |
| 0–24 | F | Failing — largely inaccessible with screen readers |

### What to Fix First

1. **PPTX-E001** (Slides without titles) — Screen reader users navigate presentations by slide title. An untitled slide is a navigation dead end.
2. **PPTX-E002** (Images without alt text) — Slides are often image-heavy. Every undescribed image is a content gap for blind and low-vision attendees.
3. **PPTX-E003** (Missing reading order) — PowerPoint's reading order is separate from visual layout. When not explicitly set, the reading order defaults to creation order, which is often wrong.
4. **PPTX-E006** (Missing language) — Screen reader pronunciation depends on the language setting. Without it, text-to-speech may mispronounce content.
5. **PPTX-W002** (Font size below 18pt) — Presentations require larger text than documents because viewers typically see them at a distance. Sub-18pt body text is a real barrier for low-vision users.

### Reading Order: The PowerPoint-Specific Challenge

Reading order (PPTX-E003) is the most common PowerPoint accessibility issue and the hardest to diagnose visually. The order in which elements appear on a slide does not determine the order screen readers read them. That order is set in the Selection Pane (Home → Arrange → Selection Pane). The agent detects when this order appears to be the default creation order rather than a logical content order, flagging slides where automated tooling cannot confirm the order is correct.

## Connections

| Connect to | When |
|------------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | For batch audits of entire presentation libraries with cross-deck analysis and scoring |
| [office-scan-config](office-scan-config.md) | To adjust rule thresholds, e.g., raising the minimum font size threshold or disabling PPTX-W004 speaker notes for internal-only decks |
| [word-accessibility](word-accessibility.md) | When auditing mixed Office document sets that include both documents and presentations |
| [pdf-accessibility](pdf-accessibility.md) | Presentations exported as PDF need a separate PDF/UA audit |
