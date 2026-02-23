# Mobile Accessibility Agent

The `mobile-accessibility` agent audits React Native, Expo, iOS (SwiftUI/UIKit), and Android (Jetpack Compose/Views) code for accessibility compliance. It covers screen reader compatibility (VoiceOver, TalkBack), touch target sizes, accessible naming, focus management, and platform-specific semantics.

## When to Use

- Reviewing React Native or Expo components for accessibility props
- Auditing iOS SwiftUI or UIKit code for VoiceOver compatibility
- Auditing Android Jetpack Compose semantics or View XML accessibility attributes
- Checking touch target sizes against iOS (44 x 44pt) and Android (48 x 48dp) requirements
- Verifying screen reader compatibility before release
- Setting up automated accessibility testing (React Native Testing Library, Detox, Maestro)

## Trigger Phrases

- "Audit my React Native component for accessibility"
- "Check this component for VoiceOver compatibility"
- "Are my touch targets big enough?"
- "Review the Android screen for TalkBack"
- "Does this pass mobile accessibility?"
- "Set up mobile accessibility testing"

## What it Audits

### React Native / Expo Props

| Category | Props Checked |
|----------|--------------|
| Naming | `accessibilityLabel`, `accessibilityHint`, `aria-label`, `aria-describedby` |
| Role | `accessibilityRole`, `aria-role` |
| State | `accessibilityState` (checked/disabled/expanded/selected/busy), `aria-*` state equivalents |
| Value | `accessibilityValue` (min/max/now/text) |
| Visibility | `accessibilityElementsHidden` (iOS), `importantForAccessibility` (Android), `aria-hidden` |
| Focus | `accessibilityViewIsModal`, `aria-modal`, `AccessibilityInfo.setAccessibilityFocus()` |
| Actions | `accessibilityActions`, `onAccessibilityAction` |
| Live regions | `accessibilityLiveRegion`, `aria-live` |

### iOS (SwiftUI and UIKit)

- `.accessibilityLabel`, `.accessibilityHint`, `.accessibilityValue`
- `.accessibilityAddTraits` / `.accessibilityRemoveTraits` (15+ trait values)
- `.accessibilityElement(children:)` - combine, contain, ignore
- `.accessibilityHidden`, `.accessibilitySortPriority`
- `.accessibilityAction(named:)` for custom rotor actions
- `UIAccessibilityTraits`, `accessibilityElements` ordering, `accessibilityViewIsModal`

### Android (Compose and Views)

- `semantics { contentDescription, role, stateDescription }` (Compose)
- `semantics { mergeDescendants = true }`, `clearAndSetSemantics {}`
- `semantics { liveRegion = LiveRegion.Polite }` for dynamic content
- `android:contentDescription`, `android:importantForAccessibility` (Views)
- `android:focusable` for Switch Access compatibility

### Touch Target Sizes

| Platform | Minimum | Recommended |
|----------|---------|-------------|
| iOS | 44 x 44 pt | 44 x 44 pt (HIG) |
| Android | 48 x 48 dp | 48 x 48 dp (Material Design) |
| Web (WCAG 2.5.8, AA, 2.2) | 24 x 24 CSS px with spacing | 44 x 44 CSS px (WCAG 2.5.5 AAA) |

All `TouchableOpacity`, `TouchableHighlight`, `Pressable`, and `accessible={true}` `View` elements are checked against these minimums.

## Phase Structure

1. **Identify platform** - React Native / Expo / iOS SwiftUI or UIKit / Android Compose or Views
2. **Core accessibility props** - Every interactive and informational element is checked
3. **Touch targets** - All interactive elements measured against platform minimums
4. **Screen reader compatibility** - Focus order, modal trapping, live regions, state announcements
5. **Testing** - Automated and manual testing guidance
6. **Report** - Issue list with platform-specific IDs, WCAG SC, impact, and fix code

## Handoffs

- Web companion audit -> `accessibility-lead`
- Token-level contrast / spacing issues -> `design-system-auditor`
- WCAG criterion explanations -> `wcag-guide`
- Testing setup -> `testing-coach`

## Skill Reference

This agent uses the `mobile-accessibility` skill in `.github/skills/mobile-accessibility/SKILL.md`, which contains:

- Full React Native accessibility props reference table (30+ props with types, values, WCAG mapping, and required/optional status)
- Accessibility role values reference table (28 roles mapped to iOS traits and Android roles)
- Touch target detection patterns and auto-fix code examples
- iOS UIAccessibility / SwiftUI modifier quick reference tables
- Android Jetpack Compose semantics quick reference table
- Common violation patterns with before/after fix code: missing labels, missing state, modal focus trapping, decorative image handling, FlatList patterns
- Testing tool commands: Xcode Accessibility Inspector, Android Accessibility Scanner, ADB TalkBack enablement, React Native Testing Library examples, Detox examples, Maestro YAML examples

## Testing Tools Covered

| Tool | Platform | Type |
|------|---------|------|
| Accessibility Inspector (Xcode) | iOS | Manual + automated audit |
| Android Accessibility Scanner | Android | Manual audit |
| ADB shell | Android | CLI TalkBack toggle |
| React Native Testing Library | React Native | Unit testing |
| Detox | React Native | E2E testing |
| Maestro | React Native / iOS / Android | E2E testing, CI |

## Example Output

```markdown
## Mobile Accessibility Audit - ProductCard Component
**Platform:** React Native (Expo SDK 51)
**Date:** 2025-01-15

### Summary
| Severity | Count |
|----------|-------|
| Error | 2 |
| Warning | 1 |
| Tip | 1 |

#### RN-001: Icon button missing accessibilityLabel - ERROR
- **File:** components/ProductCard.tsx (line 34)
- **WCAG:** 1.1.1 Non-text Content, 4.1.2 Name, Role, Value
- **Impact:** VoiceOver reads "button" with no context. Screen reader users cannot determine the button's purpose.
- **Current code:** `<TouchableOpacity onPress={addToCart}><Icon name="cart" /></TouchableOpacity>`
- **Fix:** `<TouchableOpacity onPress={addToCart} accessibilityRole="button" accessibilityLabel="Add to cart">`

#### RN-002: Touch target too small - ERROR
- **File:** components/ProductCard.tsx (line 34)
- **WCAG:** 2.5.5 Target Size (AAA), 2.5.8 Target Size Minimum (AA)
- **Impact:** 24 x 24 icon button falls below the 44 x 44pt iOS minimum. Users with motor impairments may be unable to activate it reliably.
- **Fix:** `style={{ width: 44, height: 44, alignItems: 'center', justifyContent: 'center' }}`
```
