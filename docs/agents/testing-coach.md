# testing-coach — How to Test Accessibility

> Teaches you how to test what the other agents built. Provides screen reader commands (NVDA, VoiceOver, JAWS, Narrator, TalkBack), keyboard testing workflows, automated testing setup (axe-core, Playwright, Pa11y, Lighthouse), browser DevTools accessibility features, and test plan templates.

## When to Use It

- You have built a component and need to verify it actually works in a screen reader
- Setting up automated accessibility tests in CI
- Learning screen reader commands for manual testing
- Creating an accessibility test plan for a feature
- Choosing the right testing tool combination
- Understanding what automated testing catches vs what requires manual testing

## What It Does NOT Do

- Does not write product code — it teaches testing practices
- Does not replace manual testing (automated tools catch ~30% of issues)
- Does not guarantee compliance (testing reveals issues, not their absence)

## What It Covers

<details>
<summary>Expand — full testing coverage list</summary>

- NVDA commands (Windows, free) — full command reference
- VoiceOver commands (macOS, built-in) — full command reference including Rotor
- JAWS commands (Windows, enterprise) — essential commands
- Narrator commands (Windows, built-in) — quick-check commands
- The 5-Minute Keyboard Test workflow
- axe-core integration with Playwright, Cypress, Jest, and Storybook
- Pa11y CLI and CI configuration
- Lighthouse accessibility audits
- Chrome, Firefox, and Edge DevTools accessibility features
- Test plan templates for features
- Recommended browser + screen reader testing combinations
- Bug report templates for accessibility issues

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Claude Code

```
/testing-coach how do I test this modal with NVDA?
/testing-coach set up axe-core with Playwright for CI
/testing-coach what VoiceOver commands do I need for testing tables?
/testing-coach write an accessibility test plan for the checkout flow
/testing-coach what is the minimum screen reader testing I should do?
```

### GitHub Copilot

```
@testing-coach how should I test this component with VoiceOver?
@testing-coach what automated accessibility tests should I add?
@testing-coach create a test plan for the login page
@testing-coach what are the essential NVDA commands for testing forms?
```

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Will always emphasize that automated testing catches only ~30% of issues — manual testing is required
- Recommends minimum viable testing as NVDA + Firefox and VoiceOver + Safari
- Will not write product feature code — only test code and test plans
- Provides exact key commands, not vague descriptions

</details>
