# A11y Agent Team - Strategic Ecosystem Plan

> **Status:** Draft for review - not committed, not staged.
> **Purpose:** Internal planning document. Covers simplification, gap analysis, and a phased expansion roadmap for the agent, prompt, skill, and instruction ecosystem.
> **Scope:** Everything in `.github/agents/`, `.github/prompts/`, `.github/skills/`, and `.github/instructions/`.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Core Strategic Shift](#the-core-strategic-shift)
3. [Current Ecosystem Inventory](#current-ecosystem-inventory)
4. [What Is Working Well](#what-is-working-well)
5. [Redundancies and Simplification Opportunities](#redundancies-and-simplification-opportunities)
6. [High-Impact Gaps](#high-impact-gaps)
7. [Phase 1 - Quick Wins](#phase-1--quick-wins)
8. [Phase 2 - New Agents and Skills](#phase-2--new-agents-and-skills)
9. [Phase 3 - Ecosystem Expansion](#phase-3--ecosystem-expansion)
10. [Phase 4 - Strategic Horizon](#phase-4--strategic-horizon)
11. [Full Proposed Inventory](#full-proposed-inventory)
12. [Success Metrics](#success-metrics)

---

## Executive Summary

The a11y agent team has built a remarkably complete, deeply detailed web and document accessibility toolchain. The web wizard alone spans 12 specialist sub-agents, multi-phase parallel scanning, framework-specific intelligence, VPAT generation, remediation tracking, screenshot capture, CI/CD integration, and per-page severity scoring. The document wizard covers Word, Excel, PowerPoint, and PDF with per-format specialists and cross-document pattern detection. The GitHub workflow suite adds daily briefings, PR review, analytics, team management, and community health tooling.

The platform is strong. The strategic question is: **where do we go to make the largest possible impact?**

Three answers emerge from an honest assessment of the current state:

1. **Make it always-on.** The entire ecosystem today is opt-in: users invoke a wizard, ask for an audit, or explicitly call a prompt. Every line of code produced *without* invoking these agents carries zero accessibility guidance. A small number of `instructions.md` files - which fire automatically on every code generation or edit - can fundamentally change this. This is the single highest-leverage change available.

2. **Close the genuine capability gaps.** Mobile/native accessibility, cognitive accessibility, design-system source hinting, and CI gating are the four domains where developers need help and this toolkit offers nothing today. These are not marginal additions - they each address a major class of real-world accessibility failures.

3. **Reduce decision fatigue.** Two near-identical orchestrators (`nexus` / `github-hub`), two thin config agents (`office-scan-config` / `pdf-scan-config`), and the web wizard's CI/CD phase buried 12 phases deep all create friction. Simplification is as valuable as expansion when it increases the chance a user actually uses the tool.

---

## The Core Strategic Shift

### From Opt-In to Always-On

Today's accessibility flow:

```text
Developer writes code  ->  (forgets about a11y)  ->  Bug filed
                       OR
Developer writes code  ->  Invites web wizard   ->  Finds issues  ->  Fixes issues
```

Target accessibility flow:

```text
Developer writes code  ->  Instructions fire automatically  ->  Issues caught at write time
```

The mechanism is VS Code `instructions.md` files with `applyTo` patterns. When `applyTo: "**/*.{html,jsx,tsx,vue,svelte}"` is set, the instructions apply to **every** Copilot completion and edit in those file types - no invocation required.

This is the paradigm shift. Everything else in this plan is valuable, but this one change is transformative because it operates at the point where most accessibility debt is created: the blank-page editor.

---

## Current Ecosystem Inventory

### Agents - 36 user-facing + 4 hidden helpers

| Category | Agents |
|----------|--------|
| **Web Accessibility** | `accessibility-lead`, `aria-specialist`, `keyboard-navigator`, `modal-specialist`, `contrast-master`, `forms-specialist`, `live-region-controller`, `alt-text-headings`, `tables-data-specialist`, `link-checker`, `testing-coach`, `wcag-guide`, `web-accessibility-wizard` |
| **Hidden - Web** | `web-issue-fixer`, `cross-page-analyzer` |
| **Document Accessibility** | `document-accessibility-wizard`, `word-accessibility`, `excel-accessibility`, `powerpoint-accessibility`, `pdf-accessibility`, `office-scan-config`, `pdf-scan-config` |
| **Hidden - Document** | `document-inventory`, `cross-document-analyzer` |
| **GitHub Workflow** | `nexus`, `github-hub`, `daily-briefing`, `pr-review`, `issue-tracker`, `analytics`, `insiders-a11y-tracker`, `repo-admin`, `repo-manager`, `team-manager`, `contributions-hub`, `template-builder` |

### Prompts - 44

Web a11y: 6, Document a11y: 11, GitHub workflow: 27

### Skills - 9

`accessibility-rules`, `document-scanning`, `framework-accessibility`, `github-analytics-scoring`, `github-scanning`, `github-workflow-standards`, `report-generation`, `web-scanning`, `web-severity-scoring`

### Instructions - 1

`powershell-terminal-ops.instructions.md`

---

## What Is Working Well

### Web Accessibility Wizard - Exceptional Depth

The `web-accessibility-wizard` is genuinely best-in-class. Key strengths that should be preserved and referenced in new work:

- **Parallel specialist scanning** - Groups A/B/C run concurrently, significantly reducing audit time
- **Framework-specific intelligence** - React, Vue, Angular, Svelte, Next.js, Tailwind each get tailored scanning patterns and fix syntax
- **Remediation tracking** - Fixed / New / Persistent / Regressed classification across audit runs
- **Interactive fix mode** - Auto-fixable vs human-judgment separation is the right design
- **VPAT/ACR generation** - Supports WCAG, Section 508, EN 301 549, and International editions
- **Confidence levels** - High/medium/low confidence weighting on every finding
- **Severity scoring** - 0-100 with A-F grade per page with cross-page comparison scorecard
- **CE/CD phase** - GitHub Actions, Azure DevOps, and generic CI all covered *in the wizard*
- **Edge case handling** - SPAs, shadow DOM, iframes, auth-gated content, lazy loading

One gap: the CI/CD integration is buried 12 phases into a multi-phase wizard. Users who just want to set up CI need to navigate through discovery questions. This is addressable with a standalone prompt.

### GitHub Workflow Suite - Comprehensive and Well-Designed

The `nexus`/`github-hub` orchestrators handle intent classification and routing thoughtfully. The sub-agents (`daily-briefing`, `pr-review`, `issue-tracker`, `analytics`, `repo-admin`, `team-manager`, `contributions-hub`) each have well-defined scope. The `preferences.md` configuration system and cross-repo intelligence are solid patterns.

### Document Accessibility - Parallel Architecture Works

The team model (wizard -> inventory -> format specialists -> cross-document analyzer) mirrors the web architecture effectively. The scan configuration template system (strict/moderate/minimal) is reusable.

---

## Redundancies and Simplification Opportunities

### 1. `nexus` and `github-hub` Are Nearly Identical

Both agents are GitHub workflow orchestrators. Both route to the same 10 sub-agents. Both have identical handoff configurations, intent classification tables, and behavioral rules. The primary difference today is naming and persona text.

**Recommendation:** Designate `nexus` as the single canonical entry point. Rewrite `github-hub` to be a thin alias that immediately forwards to `nexus` with a note in its description. This preserves backward compatibility (anyone who bookmarked `@github-hub` still gets an experience) while eliminating maintenance drift.

**Alternatively:** Keep both but make `github-hub` the "confirm before routing" variant and `nexus` the "route immediately" variant - the AGENTS.md describes them as "same team, both orchestrate," so let them have genuinely different personalities.

### 2. `office-scan-config` and `pdf-scan-config` Are Thin Agents

These two agents exist to help users create `.a11y-office-config.json` and `.a11y-pdf-config.json` files. They are configuration helpers that wrap what amounts to "copy the right template file."

**Recommendation:** Fold this functionality into `document-accessibility-wizard` as a dedicated Phase 0 sub-step: "I see no scan config file. Would you like to create one? Here are the profiles: strict / moderate / minimal." Remove the standalone agents from the menu. They add to cognitive load for new users who don't know they need to discover a config agent before running an audit.

The VS Code tasks (`A11y: Init Office Scan Config` and `A11y: Init PDF Scan Config`) already cover the mechanical step; the agents add no unique value on top.

### 3. The CI/CD Integration Is Buried in the Web Wizard

Phase 12 of `web-accessibility-wizard` covers GitHub Actions, Azure DevOps, and generic CI integration - with full YAML templates. But to reach it, a user must walk through a 12-phase guided wizard. Users who just need CI setup never find this.

**Recommendation:** Extract into a standalone `setup-web-cicd.prompt.md` prompt (parallel to `setup-document-cicd.prompt.md` which already exists for documents).

### 4. Only One Instruction File - For Terminal Operations

The entire `instructions/` directory has a single `.instructions.md` file that handles PowerShell multi-line commit syntax. This is clearly a developer-experience instruction for repo contributors, not a user-facing accessibility enforcement mechanism. The gap between "1 instruction for contributors" and "0 instructions for accessibility enforcement" is the biggest missed opportunity in the whole toolkit.

### 5. No Standalone "Fix This Component" Prompt

The `fix-web-issues.prompt.md` operates on a previously-generated audit report. There's no quick-start prompt for "here's a React component, find and fix its accessibility issues without running a full wizard." The `react.prompt.md` prompt appears to fill this role but its scope is unclear from the filename.

---

## High-Impact Gaps

### Gap 1 - Always-On Instructions (Highest Priority)

**Current state:** Zero instructions files that apply accessibility expertise to code generation.

**Impact:** Every Copilot-generated button, form, image, and modal exits without any WCAG guidance applied unless the user explicitly invokes an agent.

**Proposed solution:** See Phase 1 for full specification.

---

### Gap 2 - Mobile and Native Accessibility

**Current state:** Zero coverage of React Native, Expo, iOS (UIKit/SwiftUI), or Android (Views/Jetpack Compose). All 13 web specialists assume a browser DOM.

**Impact:** Mobile is not a niche use case. As of 2024, approximately 60% of web traffic is mobile. Screen readers on iOS (VoiceOver) and Android (TalkBack) have different API surfaces, different touch interaction models, and different testing methodologies. React Native is the dominant cross-platform mobile framework, and its accessibility model - `accessibilityLabel`, `accessibilityRole`, `accessibilityHint`, `accessibilityState` - is entirely distinct from ARIA.

This gap is already on the public ROADMAP (issue #8 - "Mobile native accessibility agents"). The plan below gives it a concrete design.

---

### Gap 3 - Cognitive Accessibility

**Current state:** The web wizard mentions "Cognitive accessibility specialist" as an agent to consider recommending, but the agent does not exist.

**Impact:** WCAG 2.2 introduced new success criteria (2.4.11 Focus Not Obscured, 2.4.12 Focus Not Obscured Enhanced, 2.4.13 Focus Appearance, 3.2.6 Consistent Help, 3.3.7 Redundant Entry, 3.3.8 Accessible Authentication, 3.3.9 Accessible Authentication No Exception) and the forthcoming WCAG 3.0 puts cognitive accessibility at its center. Plain language, reading level, instructions clarity, and error recovery are accessibility issues that affect approximately 20% of adults with cognitive or learning differences. No other tool in this ecosystem covers this domain.

---

### Gap 4 - Design System and Token Validation

**Current state:** `contrast-master` checks contrast in rendered HTML. Zero coverage of the upstream source: design tokens, CSS custom properties, and component library configurations.

**Impact:** A team using Tailwind, Material UI, Chakra UI, or a custom design system will fail contrast at the token definition layer - long before any page is ever rendered. By the time `contrast-master` catches it, the token has been in production for months. Catching it at the design token level prevents the root cause.

---

### Gap 5 - Proactive PR Accessibility Gating

**Current state:** `pr-review` does general code review. `insiders-a11y-tracker` tracks accessibility changes in microsoft/vscode and user-configured repos. But there is no agent that:

- Looks at the diff of an open PR
- Identifies files that contain component/HTML changes
- Runs targeted accessibility analysis on those changed files only
- Posts findings as PR comments before merge

**Impact:** This closes the loop between "audit" and "prevent." Without this, accessibility improvements are constantly chasing regressions introduced by PRs that nobody reviewed for accessibility.

---

### Gap 6 - Screen Reader Simulation

**Current state:** `testing-coach` provides testing guidance. No agent interactively walks developers through what a screen reader would announce.

**Impact:** Most developers have never used a screen reader. Abstract guidance ("test with NVDA + Firefox") does not build intuition. An agent that can simulate "if VoiceOver reaches this button, it will say: *Group, Add to Cart, button*" - and explain why each token is present or missing - is a fundamentally more effective teaching tool. This is the difference between telling and showing.

---

### Gap 7 - PDF Remediation (Not Just Auditing)

**Current state:** `pdf-accessibility` audits PDFs against PDF/UA and WCAG rules. The public roadmap (issue #11) identifies "Document remediation tools" as a medium-priority item.

**Impact:** Audit-without-fix is only half the value. The document toolkit currently finds issues in PDFs and says "fix them in your authoring tool." An agent that can apply specific, programmatic fixes (add missing document title, set correct reading order metadata, tag untagged content, repair reading language) would complete the workflow.

---

## Phase 1 - Quick Wins

*Target: High leverage, low authoring effort, no new agent architecture required.*

---

### 1.1 - `web-accessibility-baseline.instructions.md`

**Path:** `.github/instructions/web-accessibility-baseline.instructions.md`
**applyTo:** `**/*.{html,jsx,tsx,vue,svelte,astro}`

Always-on WCAG AA enforcement for all web content. Fires on every Copilot completion and edit in HTML and component files - no agent invocation required.

**Content scope:**

- Every interactive element must be keyboard-reachable (no `onClick` without `onKeyDown`/`onKeyUp` where applicable; prefer `<button>` over `<div role="button">`)
- Every `<img>` must have `alt` - empty string for decorative images, descriptive text for content images
- Every `<input>` must have a programmatic label (`<label>`, `aria-label`, or `aria-labelledby`) - never `placeholder` alone
- Heading hierarchy must be maintained: one `<h1>` per page, no skipped levels
- Never use `outline: none` or `outline: 0` without providing an alternative visible focus indicator
- No positive `tabindex` values
- `<button>` for actions, `<a href>` for navigation - never swap them
- `aria-*` attributes only on elements that support them; no redundant ARIA on semantic HTML
- Color alone must not convey meaning; always pair color with text, pattern, or icon
- Text contrast: 4.5:1 for normal text, 3:1 for large text and UI components
- Dynamic content updates must use live regions (`aria-live`, `role="status"`, `role="alert"`)

---

### 1.2 - `semantic-html.instructions.md`

**Path:** `.github/instructions/semantic-html.instructions.md`
**applyTo:** `**/*.{html,jsx,tsx,vue,svelte,astro}`

Enforces semantic HTML-first patterns as a complement to the WCAG baseline.

**Content scope:**

- Use `<main>`, `<nav>`, `<header>`, `<footer>`, `<aside>`, `<section>`, `<article>` for landmark structure
- Use `<ul>/<ol>/<li>` for actual lists - not for menus styled as lists (use `role="menu"` / `role="menuitem"` only for true application menus)
- Use `<table>` / `<thead>` / `<tbody>` / `<th scope>` for tabular data - not for layout
- Use `<fieldset>` + `<legend>` for groups of related inputs (radio groups, checkbox groups)
- Use `<details>` + `<summary>` for disclosure widgets where supported
- Use `<dialog>` for modal dialogs (with `open` attribute management) - not `<div role="dialog">` unless polyfill constraints require it
- Forms: `<form>` elements must have `action`, required fields must use `required` attribute, error messages must use `aria-describedby`
- Skip navigation: every page template must have a skip-to-main-content link as its first focusable element

---

### 1.3 - `aria-patterns.instructions.md`

**Path:** `.github/instructions/aria-patterns.instructions.md`
**applyTo:** `**/*.{html,jsx,tsx,vue,svelte,astro}`

Role-specific ARIA requirements. Fires specifically when ARIA roles or custom interactive patterns are detected in generated code.

**Content scope:**

- **Tabs:** `role="tablist"` on container, `role="tab"` on each tab, `role="tabpanel"` on each panel; `aria-controls`, `aria-selected`, keyboard pattern (arrow keys switch tabs, Enter/Space activate)
- **Combobox:** `role="combobox"` + `aria-expanded` + `aria-autocomplete` + `aria-controls` pointing to listbox; keyboard pattern (arrow keys, Escape)
- **Dialog:** `role="dialog"` + `aria-modal="true"` + `aria-labelledby`; focus trap on open, focus return on close, Escape to dismiss
- **Accordion:** `role="button"` on triggers (or native `<button>`), `aria-expanded`, `aria-controls`, `id` on panels
- **Carousel/Slider:** `role="region"` with label, `aria-roledescription="carousel"`, live region for auto-advancing content
- **Tree:** `role="tree"` > `role="treeitem"` with `aria-expanded` on nodes with children; keyboard pattern (arrow keys, Home, End)
- **Menu button:** `role="button"` + `aria-haspopup="menu"` + `aria-expanded`; `role="menu"` on dropdown; `role="menuitem"` items; keyboard pattern (arrow keys, Escape)

---

### 1.4 - `setup-web-cicd.prompt.md`

**Path:** `.github/prompts/setup-web-cicd.prompt.md`

Standalone prompt for CI/CD accessibility setup - the content already exists in `web-accessibility-wizard` Phase 12 but is unreachable without running the full wizard. This makes it a one-click action.

Ask: URL/command to start dev server, CI platform (GitHub Actions / Azure DevOps / GitLab CI / generic), desired violation threshold, whether to generate SARIF output for code scanning.
Output: Ready-to-commit CI workflow file, threshold script, and instructions for connecting to PR status checks.

---

### 1.5 - `a11y-pr-check.prompt.md`

**Path:** `.github/prompts/a11y-pr-check.prompt.md`

Targets an open PR's diff. Finds HTML/component file changes. Runs targeted accessibility analysis on changed files. Posts results as a structured PR review comment with WCAG citations and code fix suggestions.

This closes the **"prevent in PR, not just audit post-deploy"** loop. No equivalent exists today - `pr-review` does general code review, not accessibility-specific analysis.

---

### 1.6 - Resolve `nexus` / `github-hub` Ambiguity

**Change type:** Configuration edit, not new file.

Make `nexus` and `github-hub` meaningfully distinct:

- **`nexus`:** Auto-routing mode. When intent is clear, routes immediately without repeating context. For users who know the tool.
- **`github-hub`:** Guided mode. At startup, confirms the active repo and asks "what do you want to work on?" before routing. For users who are less familiar or want to be deliberate.

Both should have descriptions that communicate this difference clearly. Eliminates the confusing situation where two agents do the same thing.

---

### 1.7 - Fold Config Agents into the Document Wizard

**Change type:** Edit `document-accessibility-wizard.agent.md`. Deprecate `office-scan-config` and `pdf-scan-config` as standalone user-invokable agents.

In Phase 0 of `document-accessibility-wizard`, add: detect whether a config file exists; if not, ask "No scan config found. Would you like to create one?" with profile options. Invoke the config generation inline as part of the wizard setup rather than as a separate agent the user must discover.

Mark `office-scan-config` and `pdf-scan-config` as `user-invokable: false` (hidden helpers for wizard-internal use only). This reduces the visible agent count by 2 without removing any functionality.

---

## Phase 2 - New Agents and Skills

*Target: Fills genuine capability gaps. Each requires a new agent file and at least one new skill.*

---

### 2.1 - `cognitive-accessibility.agent.md`

**Path:** `.github/agents/cognitive-accessibility.agent.md`
**Paired skill:** `.github/skills/cognitive-accessibility/SKILL.md`

**What it does:**
Analyzes web content for cognitive accessibility compliance. Covers:

- **Reading level analysis** - Flesch-Kincaid, Gunning Fog; target: Grade 8 or below for general-purpose content
- **Plain language audit** - Passive constructions, double negatives, technical jargon, undefined acronyms
- **Instruction clarity** - Are error messages actionable? Do form instructions appear before the input or only on error?
- **Consistent navigation** - WCAG 3.2.3 Consistent Navigation, 3.2.4 Consistent Identification
- **Accessible authentication** - WCAG 3.3.8/3.3.9: no cognitive function tests (puzzles, transcription challenges) required for login
- **Redundant entry prevention** - WCAG 3.3.7: information already entered must not need re-typing in the same session
- **Timeout warnings** - WCAG 2.2.1: sessions with time limits must warn users with sufficient notice
- **Animation and distraction** - WCAG 2.3.1: no content flashing > 3 Hz; `prefers-reduced-motion` respected

**WCAG scope:** 1.3.3, 1.4.1, 2.2.1, 2.2.2, 2.3.1, 2.4.6, 3.1.3, 3.1.4, 3.1.5, 3.2.3, 3.2.4, 3.3.2, 3.3.4, 3.3.7, 3.3.8 (WCAG 2.2 new)

**Integration:** Add as sub-agent option in `web-accessibility-wizard` Phase 3+. Available standalone via prompt.

---

### 2.2 - `mobile-accessibility.agent.md`

**Path:** `.github/agents/mobile-accessibility.agent.md`
**Paired skill:** `.github/skills/mobile-accessibility/SKILL.md`

**What it does:**
Platform-specific accessibility analysis for mobile and native applications:

**React Native / Expo:**

- All interactive components need `accessible={true}` or are naturally accessible (View, Text with onPress needs it)
- `accessibilityLabel` - non-redundant, no "button" suffix (platform adds role)
- `accessibilityRole` - correct role for element: `"button"`, `"link"`, `"header"`, `"image"`, `"checkbox"`, etc.
- `accessibilityHint` - explains the result of an action when not clear from the label
- `accessibilityState` - `disabled`, `selected`, `checked`, `busy`, `expanded`
- `accessibilityValue` - for sliders and progress indicators: `min`, `max`, `now`, `text`
- Touch target minimum: 44 x 44 dp (iOS HIG) / 48 x 48 dp (Material Design) - enforced in style checks
- `importantForAccessibility` - use `"no-hide-descendants"` for decorative containers
- `aria-*` props (React Native 0.73+) for cross-platform alignment
- Gesture alternatives: every swipe gesture must have an alternative accessible via button
- Focus order in scrollable lists - `FlatList`/`SectionList` accessibility configuration

**iOS (UIKit/SwiftUI):** Guidance on `isAccessibilityElement`, `accessibilityLabel`, `accessibilityTraits`, `accessibilityHint`, focus order.

**Android (Jetpack Compose / Views):** Guidance on `contentDescription`, `semantics { }` modifier, `clearAndSetSemantics`, `mergeDescendants`.

**Testing tooling:**

- React Native: Maestro, Detox with accessibility assertions
- iOS: Accessibility Inspector (Xcode), XCTest accessibility APIs
- Android: Accessibility Scanner (Google), espresso

---

### 2.3 - `design-system-auditor.agent.md`

**Path:** `.github/agents/design-system-auditor.agent.md`
**Paired skill:** `.github/skills/design-system/SKILL.md`

**What it does:**
Audits the source of truth for visual accessibility: design tokens, CSS custom properties, theme files, and component library configurations. Catches contrast failures before they reach rendered HTML.

**Analysis targets:**

- **CSS custom properties** - scans `:root { --color-text: ... }` declarations; validates all `--color-text-*` on `--color-bg-*` combinations meet 4.5:1 (normal) / 3:1 (large/UI)
- **Tailwind config** - analyzes `tailwind.config.js`/`.ts` `colors` extension; flags color pairs that will create contrast failures
- **Design token files** - `tokens.json`, `design-tokens.json`, Style Dictionary output files; validates all color token pairs
- **Storybook `a11y` addon config** - verifies `@storybook/addon-a11y` is installed, configured with correct axe rules, and not suppressing critical violations
- **Component library theme files** - Material UI `createTheme`, Chakra UI `extendTheme`, Radix UI CSS variable overrides; validates theme color choices
- **Focus ring tokens** - verifies `--focus-ring-color` meets 3:1 WCAG 2.4.13 requirement

**Output:**

- List of token pairs that fail contrast with exact ratio
- Suggested replacement values (nearest compliant color maintaining the design intent)
- Storybook a11y configuration report
- Remediation: direct edits to token files with compliant values

---

### 2.4 - `ci-accessibility.agent.md`

**Path:** `.github/agents/ci-accessibility.agent.md`
**Paired skill:** `.github/skills/ci-integration/SKILL.md`

**What it does:**
A focused, lightweight alternative to the web wizard's Phase 12 for users who only need CI/CD setup or management.

**Unlike `setup-web-cicd.prompt.md` (which is a one-shot generator), this agent is conversational:**

- Reviews an existing CI configuration and identifies gaps in accessibility coverage
- Configures threshold rules: "block deploys on any new critical violations," "warn but permit on serious"
- Sets up SARIF output for GitHub code scanning (security tab integration)
- Configures PR annotations - axe violations appear as inline code comments in pull request diffs
- Manages baseline files: `axe-baseline.json` stores the current violation count; CI fails only when violations *increase*
- Integrates with popular CI platforms: GitHub Actions, Azure DevOps, GitLab CI, CircleCI, Jenkins

**Key differentiator from existing tooling:** The *baseline file* pattern. Without a baseline, every legacy violation fails CI, making CI adoption impossible on real-world brownfield apps. With a baseline, CI gates only prevent *regressions* - new violations introduced in the current PR.

---

### 2.5 - `screen-reader-lab.agent.md`

**Path:** `.github/agents/screen-reader-lab.agent.md`

**What it does:**
Interactive screen reader simulation for educational use and debugging. Takes HTML, JSX, or a component file and produces a step-by-step narration of what a screen reader would announce.

**How it works:**

- Parse the HTML/DOM structure semantically (role, name, state computation following ARIA in HTML spec)
- Walk the reading order and compute the accessible name and description for each element
- Output a narration transcript: `"Heading level 2: Product Details"`, `"Link: Add to cart, opens checkout page"`, `"Button: Submit form, dimmed"`
- Highlight gaps: elements with no accessible name are annotated `[No accessible name - screen reader will skip]`
- Support mode: simulate Tab-order navigation (only focusable elements, in order)
- Support mode: simulate heading navigation (`H` key in browse mode - all headings in sequence)
- Support mode: simulate form navigation (`F` key - all form controls in sequence)

**When to use:**

- Debugging a specific component's screen reader experience
- Developer education: "I've never used a screen reader. What do my users actually hear?"
- Verifying ARIA attribute chains are correct (`aria-labelledby` -> multiple IDs -> computed name)
- Explaining why a found violation matters

**This is not a replacement for real screen reader testing.** The agent must make this explicit and recommend `testing-coach` for actual screen reader test plans.

---

## Phase 3 - Ecosystem Expansion

*Target: Fills specialist gaps and builds toward a complete platform. Each item is valuable but requires more authoring effort or depends on earlier phases.*

---

### 3.1 - `pdf-remediator.agent.md`

**Path:** `.github/agents/pdf-remediator.agent.md`

Extends the existing `pdf-accessibility` audit-only workflow with actual fix capability. Addresses ROADMAP issue #11 "Document remediation tools."

**Fixable programmatically (via `pdf-lib`, `pdfmake`, or `qpdf` CLI instructions):**

- Document title metadata (XMP `dc:title`)
- Document language (`/Lang` in PDF catalog)
- Reading order (`/Tabs` entry)
- Tag type corrections (headings incorrectly tagged as `<P>`, `<Artifact>` on decorative elements)
- Alt text on figures (`/Alt` in figure tag attributes)
- Missing PDF/UA identifier (`/PDFA` or `/PDFUA-1` metadata)

**Requires Adobe Acrobat Pro or authoring tool (guided instructions only):**

- Table structure (rows, headers, scope)
- Form field `TooltipName` and `TU` attribute
- Reading order of complex multi-column layouts
- Replacement text for abbreviations (`/ActualText` or `/E`)

**Output:** Generates a shell script of `qpdf` / `pdfmake` / `ghostscript` commands for auto-fixable issues; provides step-by-step Acrobat Pro instructions for manual fixes.

---

### 3.2 - `wcag3-preview.agent.md`

**Path:** `.github/agents/wcag3-preview.agent.md`

**What it does:**
WCAG 3.0 is in active development (current status: early draft) and will introduce significant methodology changes: outcome-based conformance, functional needs categories, visual contrast with the APCA algorithm (Advanced Perceptual Contrast Algorithm), and new cognitive / task-based criteria.

This agent helps teams understand:

- What WCAG 3.0 will require that WCAG 2.2 doesn't
- Which current WCAG 2.2 failures will become more severe under 3.0
- The APCA contrast algorithm vs the current WCAG 2.x formula - and what changes are needed
- Delta planning: "Given your current ACCESSIBILITY-AUDIT.md, what would fail under WCAG 3.0 that currently passes?"

**Scope:** Educational and forward-planning only. Should clearly communicate WCAG 3.0's draft status (not yet a standard) and discourage abandoning WCAG 2.2 compliance.

---

### 3.3 - `component-library-audit.prompt.md`

**Path:** `.github/prompts/component-library-audit.prompt.md`

Audits every component in a component library directory - not a full-page audit, but a per-component accessibility scorecard.

**Flow:**

1. Ask: path to component directory (e.g., `src/components/`, `packages/ui/src/`)
2. Discover all component files (`.jsx`, `.tsx`, `.vue`, `.svelte`)
3. For each component, run the appropriate specialists via sub-agent (aria-specialist, keyboard-navigator, forms-specialist, etc.)
4. Generate a per-component scorecard: name, score, grade, critical issues, issues list
5. Sort by score ascending - worst components first
6. Identify components that share common issues (fix the issue specification, not each instance)

**Why this matters:** Component libraries multiply: a single inaccessible `<Button>` component may appear 500+ times in a codebase. Auditing the component is orders of magnitude more efficient than auditing every page.

---

### 3.4 - `training-scenario.prompt.md`

**Path:** `.github/prompts/training-scenario.prompt.md`

Generates interactive accessibility training scenarios for developer education.

**Modes:**

- **"Show me a bad example"** - Generate a purposely inaccessible version of a common UI pattern: a form, modal, navigation bar, data table. Walk the developer through each issue, why it matters, what a screen reader user would experience, and how to fix it.
- **"Quiz me"** - Generate a component with hidden accessibility issues. Let the developer try to find them. Reveal issues with explanations.
- **"Explain this WCAG criterion"** - Pick a WCAG success criterion (or let the agent choose based on "what did I just fail?") and explain it with a code example of the failure and the fix.
- **"Before and after"** - Generate a side-by-side comparison: inaccessible version vs. accessible version with annotations explaining each difference.

**Target audience:** Developers new to accessibility who need intuition-building, not just rule lists.

---

### 3.5 - `a11y-issue-scorer.agent.md`

**Path:** `.github/agents/a11y-issue-scorer.agent.md`

Hidden helper (not user-invokable directly). Invocable by `issue-tracker` when an issue is labeled `accessibility` or when accessibility is mentioned in the issue body.

**What it does:**

- Takes the text of an accessibility bug report
- Maps it to the most likely WCAG success criterion
- Assigns a severity score (critical/serious/moderate/minor) based on WCAG conformance level and user impact
- Suggests a priority label: `p1-blocker`, `p2-high`, `p3-medium`, `p4-low`
- Estimates fix complexity: `complexity: simple` / `complexity: medium` / `complexity: complex`
- Drafts a structured comment: "This issue appears to relate to WCAG 1.4.3 Contrast (Minimum, AA). Users relying on low-vision tools with high-contrast mode settings may be unable to distinguish..."

**Integration:** `issue-tracker` currently routes all issues through WCAG-unaware generic scoring. This agent adds a11y-specific intelligence to the triage workflow.

---

### 3.6 - `audit-native-app.prompt.md`

**Path:** `.github/prompts/audit-native-app.prompt.md`

Companion to `audit-web-page.prompt.md` for React Native / Expo apps. Routes to `mobile-accessibility` agent. Mirrors the structure of the web audit prompt.

---

### 3.7 - `component-a11y-check.prompt.md`

**Path:** `.github/prompts/component-a11y-check.prompt.md`

Quick accessibility check for a single component file. Identifies the framework, runs relevant specialists (aria-specialist, keyboard-navigator, always; others based on component type), and returns a structured findings list with inline code fixes.

The current `react.prompt.md` appears to serve a similar role - this prompt generalizes it to any framework and gives it a clearer, more discoverable name.

---

## Phase 4 - Strategic Horizon

*Items that position the platform for growth beyond individual developer use.*

---

### 4.1 - Enterprise Packaging and White-Labeling

The `desktop-extension/` directory already contains a VS Code extension manifest and server stub. The install scripts (`install.ps1`, `install.sh`, `update.ps1`, `update.sh`) suggest a distribution model.

**Opportunity:** Package the agent team as a configurable enterprise bundle where organizations can:

- Specify their own WCAG conformance target (AA or AAA)
- Configure which standards they must comply with (WCAG, Section 508, EN 301 549, ADA Title III)
- Customize severity thresholds for CI gating
- Set organization-specific design token paths
- Route reports to their issue tracker (Jira, GitHub Issues, Azure Boards, Linear)
- Define their preferred component frameworks so scanning is accurate on day 1

---

### 4.2 - Anthropic Claude Desktop / MCP Distribution

Issue #9 on the public roadmap: publish to the Anthropic Connectors Directory. The `desktop-extension/` already has a manifest and server scaffold. Completing this enables automatic distribution and updates for Claude Desktop users.

This is high-impact for reach: it opens the toolkit to users outside VS Code.

---

### 4.3 - WCAG 3.0 and APCA Readiness

When WCAG 3.0 reaches Candidate Recommendation status, the `contrast-master` skill will need to be updated to support the APCA contrast algorithm. Begin preparing the `web-severity-scoring` skill with a parallel APCA calculation path so the transition is a configuration change rather than a rewrite.

---

### 4.4 - Internationalization / RTL Accessibility

A significant gap for global applications:

- `dir="rtl"` / `dir="ltr"` - correct `dir` at document and component level
- `<html lang>` with correct BCP 47 subtags (not just `en` but `en-US`, `ar`, `he`)
- `lang` attribute on inline content in a different language than the document
- Bidirectional text (`bidi`) - `<bdi>` element, `unicode-bidi` CSS, `dir="auto"`
- Mixed-direction content in forms (RTL label + LTR input value)
- Icon mirror conventions in RTL layouts

**Proposed agent:** `i18n-accessibility.agent.md` - or fold into `alt-text-headings` which already covers `lang` attributes.

---

### 4.5 - Expanded Preferences System

The `preferences.md` system is powerful but under-utilized. Expand default preferences to include:

```yaml
accessibility:
  default_wcag_level: AA          # AA or AAA
  default_framework: auto         # auto-detect or specify
  ci_fail_on: [critical, serious]  # severity levels that block CI
  report_format: by-severity      # by-page | by-issue | by-severity
  mobile:
    platforms: [react-native]
    min_touch_target_ios: 44
    min_touch_target_android: 48
  design_system:
    token_file: null              # path to design tokens
    storybook: false              # enable Storybook audit
  scanning:
    screenshot_default: false
    include_passed: true
```

---

## Full Proposed Inventory

### Agents

**To add (Phase 2):**

- `cognitive-accessibility.agent.md`
- `mobile-accessibility.agent.md`
- `design-system-auditor.agent.md`
- `ci-accessibility.agent.md`
- `screen-reader-lab.agent.md`

**To add (Phase 3):**

- `pdf-remediator.agent.md`
- `wcag3-preview.agent.md`
- `a11y-issue-scorer.agent.md` *(hidden helper)*

**To change:**

- `nexus.agent.md` - differentiate as auto-routing vs `github-hub` guided-routing
- `github-hub.agent.md` - differentiate as guided-routing variant
- `office-scan-config.agent.md` - mark `user-invokable: false` (fold into doc wizard)
- `pdf-scan-config.agent.md` - mark `user-invokable: false` (fold into doc wizard)

---

### Prompts

**To add (Phase 1):**

- `setup-web-cicd.prompt.md`
- `a11y-pr-check.prompt.md`

**To add (Phase 3):**

- `component-library-audit.prompt.md`
- `training-scenario.prompt.md`
- `component-a11y-check.prompt.md`
- `audit-native-app.prompt.md`

---

### Skills

**To add (Phase 2):**

- `cognitive-accessibility/SKILL.md` - plain language, reading level, COGA mapping, WCAG 2.2 new SC
- `mobile-accessibility/SKILL.md` - React Native props, iOS/Android APIs, touch targets, TalkBack/VoiceOver
- `design-system/SKILL.md` - design token validation, Tailwind/MUI/Chakra/Radix patterns, Storybook a11y
- `ci-integration/SKILL.md` - axe-core CI pipelines, SARIF, PR annotations, baseline file pattern

---

### Instructions

**To add (Phase 1 - highest priority of the entire plan):**

- `web-accessibility-baseline.instructions.md` (applyTo: `**/*.{html,jsx,tsx,vue,svelte,astro}`)
- `semantic-html.instructions.md` (applyTo: `**/*.{html,jsx,tsx,vue,svelte,astro}`)
- `aria-patterns.instructions.md` (applyTo: `**/*.{html,jsx,tsx,vue,svelte,astro}`)

**To add (Phase 2):**

- `mobile-accessibility-baseline.instructions.md` (applyTo: `**/*.{tsx,jsx,ts,js}` - React Native)

**To add (Phase 3, optional):**

- `document-accessibility-baseline.instructions.md` (applyTo: scripts that generate or modify Office/PDF documents)

---

## Success Metrics

How we measure whether the plan is achieving impact:

### Adoption Metrics (quantitative)

- Number of `web-accessibility-wizard` sessions per week
- Number of auto-fixable issues corrected via `web-issue-fixer` per session
- CI/CD configurations generated (tracked via `setup-web-cicd` prompt usage)
- PR accessibility check invocations per week
- Number of projects with `.a11y-web-config.json` created

### Quality Metrics (from audit data)

- Average accessibility score across all audits: target improvement over time
- Ratio of critical issues per audit: target decrease
- Fixed/New/Persistent/Regressed ratio: target >50% Fixed in follow-up audits
- Percentage of audits that use comparison mode (remediation tracking enabled)

### Coverage Metrics (ecosystem breadth)

- Agent categories covered: web, document, mobile, cognitive, design-system, CI
- Number of frameworks with explicit scanning patterns
- Number of CI platforms with generated configurations
- WCAG versions supported: currently 2.1 AA, 2.2 AA; target + 2.2 AAA, WCAG 3.0 preview

### Developer Experience Metrics

- Time from "first invoke" to "first report written" - target under 10 minutes for standard audit
- Number of wizard phases the average user completes before dropping off (shorter = better UX)
- Proportion of fixes accepted vs skipped in interactive fix mode - high acceptance = good fix quality

---

## Implementation Notes

### Priority Order

Given finite time, this is the recommended order:

1. **Instructions files** (three new `.instructions.md` files) - highest leverage per hour of work. Start here.
2. **`setup-web-cicd.prompt.md`** and **`a11y-pr-check.prompt.md`** - two prompts, fills the two biggest UX gaps.
3. **`nexus`/`github-hub` differentiation** - small config edit, eliminates the most common point of confusion.
4. **Config agent deprecation** - fold `office-scan-config` + `pdf-scan-config` into the document wizard.
5. **`cognitive-accessibility` agent + skill** - fills the most impactful content gap.
6. **`mobile-accessibility` agent + skill** - highest user demand, on the public roadmap already.
7. **`design-system-auditor` agent + skill** - shifts detection upstream, highest ROI for teams at scale.
8. **`ci-accessibility` agent** - completes the CI/CD story with baseline management.
9. **`screen-reader-lab`** - strong educational value, moderate development effort.
10. **Phase 3 items** - pdf-remediator, wcag3, component-library, training, scoring.

### Authoring Standards

New agent files should follow the established patterns in the highest-quality examples:

- `web-accessibility-wizard` as the model for multi-phase guided workflows
- `nexus` as the model for orchestrator design and context management
- `web-issue-fixer` as the model for auto-fix vs human-judgment separation

New skill files should follow the established skills - each with: purpose statement, domain reference tables, rule lists with WCAG criterion codes, and examples.

New instructions files should be declarative (what must be true) rather than procedural (what to do). They fire on every completion - brevity matters, but completeness matters more.

---

*End of plan. Awaiting review.*
