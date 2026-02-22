# powerpoint-accessibility — Microsoft PowerPoint (PPTX) Accessibility

> Scans Microsoft PowerPoint presentations for accessibility issues. Uses the `scan_office_document` MCP tool to parse PPTX files and check for slide titles, reading order, alt text on images, table structure, audio/video descriptions, and use of speaker notes.

## When to Use It

- Reviewing presentations before sharing or presenting
- Checking slide templates for accessibility compliance
- Auditing PPTX files for procurement or public distribution
- Preparing presentations that will be available as shared documents

## What It Catches

| Rule | Severity | Description |
|------|----------|-------------|
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

## Example Prompts

```
/powerpoint-accessibility scan presentation.pptx for accessibility
@powerpoint-accessibility review the company deck template
@powerpoint-accessibility check all slide decks in assets/
```
