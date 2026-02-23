# Mobile Accessibility Skill

This skill provides mobile accessibility reference data for React Native, Expo, iOS, and Android auditing. Used by `mobile-accessibility.agent.md`.

---

## React Native Accessibility Props - Full Reference

| Prop | Type | Values / Notes | WCAG SC | Required |
|------|------|---------------|---------|---------|
| `accessible` | boolean | `true` marks the view as an accessibility node | 4.1.2 | Conditional |
| `accessibilityLabel` | string | Human-readable name - overrides all child text | 1.1.1, 4.1.2 | Yes (all interactive + image elements) |
| `accessibilityLabelledBy` | string / string[] | References ID(s) of labelling element | 1.3.1 | For form inputs |
| `accessibilityRole` | string (see roles table) | Communicates element type to AT | 4.1.2 | Yes (all interactive elements) |
| `accessibilityHint` | string | Additional context spoken after label + role | 1.3.3 | When action isn't obvious |
| `accessibilityState` | object | `{checked, disabled, expanded, selected, busy}` | 4.1.2 | State-bearing elements |
| `accessibilityValue` | object | `{min, max, now, text}` | 1.3.1 | Sliders, steppers, progress bars |
| `accessibilityActions` | array | `[{name, label}]` - defines custom actions | 4.1.3 | Context menus, long-press alternatives |
| `onAccessibilityAction` | function | Handles custom action triggers | 4.1.3 | Paired with `accessibilityActions` |
| `accessibilityLiveRegion` | string | `'none'` / `'polite'` / `'assertive'` | 4.1.3 | Dynamic content updates |
| `accessibilityViewIsModal` | boolean | `true` traps VoiceOver focus inside modal | 1.3.4 | Modals, drawers, sheets |
| `accessibilityElementsHidden` | boolean | iOS - hides element and children from VoiceOver | 1.1.1 | Decorative elements |
| `importantForAccessibility` | string | Android - `'auto'` / `'yes'` / `'no'` / `'no-hide-descendants'` | 1.1.1 | Decorative / grouped elements |
| `accessibilityIgnoresInvertColors` | boolean | iOS - preserves colors in Inverted Colors mode | - | Images, video |
| `aria-label` | string | RN 0.73+ alias for `accessibilityLabel` | 1.1.1, 4.1.2 | Preferred in new code |
| `aria-labelledby` | string | RN 0.73+ alias for `accessibilityLabelledBy` | 1.3.1 | Form inputs |
| `aria-describedby` | string | RN 0.73+ alias for `accessibilityHint` | 1.3.3 | Additional description |
| `aria-role` | string | RN 0.73+ alias for `accessibilityRole` | 4.1.2 | All interactive elements |
| `aria-checked` | boolean / 'mixed' | RN 0.73+ alias for `accessibilityState.checked` | 4.1.2 | Checkboxes |
| `aria-disabled` | boolean | RN 0.73+ alias for `accessibilityState.disabled` | 4.1.2 | Disabled elements |
| `aria-expanded` | boolean | RN 0.73+ alias for `accessibilityState.expanded` | 4.1.2 | Accordions, dropdowns |
| `aria-selected` | boolean | RN 0.73+ alias for `accessibilityState.selected` | 4.1.2 | Tabs, list items |
| `aria-busy` | boolean | RN 0.73+ alias for `accessibilityState.busy` | 4.1.3 | Loading elements |
| `aria-hidden` | boolean | RN 0.73+ - maps to `importantForAccessibility` / `accessibilityElementsHidden` | 1.1.1 | Decorative content |
| `aria-live` | string | RN 0.73+ alias for `accessibilityLiveRegion` | 4.1.3 | Dynamic content |
| `aria-modal` | boolean | RN 0.73+ alias for `accessibilityViewIsModal` | 1.3.4 | Modals |

### Accessibility Role Values

| Role | Maps to (iOS) | Maps to (Android) | Use For |
|------|-------------|-----------------|--------|
| `'button'` | UIAccessibilityTraitButton | AccessibilityNodeInfo.ROLE_BUTTON | Buttons, submission triggers |
| `'link'` | UIAccessibilityTraitLink | AccessibilityNodeInfo.ROLE_LINK | Navigation links, external URLs |
| `'search'` | - | ROLE_SEARCH | Search bars |
| `'image'` | UIAccessibilityTraitImage | ROLE_IMAGE | Images (when accessible=true) |
| `'imagebutton'` | UIAccessibilityTraitImage+Button | ROLE_BUTTON | Icon buttons |
| `'header'` | UIAccessibilityTraitHeader | ROLE_HEADING | Headings |
| `'text'` | UIAccessibilityTraitStaticText | ROLE_LABEL | Static text |
| `'adjustable'` | UIAccessibilityTraitAdjustable | ROLE_SCROLL_VIEW | Sliders |
| `'checkbox'` | - | ROLE_CHECKBOX | Checkboxes |
| `'combobox'` | - | ROLE_DROP_DOWN_LIST | Dropdowns |
| `'menu'` | - | ROLE_MENU | Menus |
| `'menuitem'` | - | ROLE_MENU_ITEM | Menu items |
| `'menubar'` | - | ROLE_MENU_BAR | Menu bars |
| `'progressbar'` | UIAccessibilityTraitUpdatesFrequently | ROLE_PROGRESS_BAR | Progress indicators |
| `'radio'` | - | ROLE_RADIO_BUTTON | Radio buttons |
| `'radiogroup'` | - | - | Radio button groups |
| `'scrollbar'` | - | ROLE_SCROLL_BAR | Scrollbars |
| `'spinbutton'` | - | ROLE_SCROLL_VIEW | Steppers, number inputs |
| `'switch'` | - | ROLE_SWITCH | Toggle switches |
| `'tab'` | - | ROLE_TAB | Tab elements |
| `'tablist'` | - | ROLE_TAB_LIST | Tab containers |
| `'timer'` | UIAccessibilityTraitUpdatesFrequently | - | Countdown timers |
| `'toolbar'` | - | ROLE_TOOL_BAR | Toolbars |
| `'grid'` | - | ROLE_GRID | Data grids |
| `'list'` | - | ROLE_LIST | Lists |
| `'listitem'` | - | ROLE_LIST_ITEM | List items |
| `'summary'` | UIAccessibilityTraitSummaryElement | - | Summary/status views |
| `'alert'` | UIAccessibilityTraitCausesPageTurn | ROLE_ALERT | Alert dialogs |
| `'none'` | UIAccessibilityTraitNone | ROLE_NONE | Suppress role |

---

## Touch Target Size Requirements

| Platform | Minimum Size | Recommended | Standard |
|----------|-------------|-------------|---------|
| iOS | 44 x 44 pt | 44 x 44 pt | HIG |
| Android | 48 x 48 dp | 48 x 48 dp | Material Design |
| Web mobile | 44 x 44 CSS px (AAA) | 44 x 44 CSS px | WCAG 2.5.5 |
| Web mobile (AA, 2.2) | 24 x 24 CSS px with spacing | 44 x 44 CSS px | WCAG 2.5.8 |

### Detection Pattern (React Native)

```tsx
// Violation: TouchableOpacity below minimum
const styles = StyleSheet.create({
  closeBtn: { width: 24, height: 24 },          // FAIL - below 44pt
  iconBtn: { width: 32, height: 32 },            // FAIL - below 44pt
  navBtn: { padding: 4 },                        // CONDITIONAL - depends on content size
  compliant: { width: 44, height: 44 },          // PASS
  compliantWithPadding: { padding: 12 },         // PASS if content >= 20pt
});
```

---

## iOS UIAccessibility - Quick Reference

### SwiftUI Modifiers

| Modifier | Purpose |
|----------|---------|
| `.accessibilityLabel("...")` | Overrides spoken name |
| `.accessibilityHint("...")` | Spoken usage hint (after pause) |
| `.accessibilityValue("...")` | Spoken current value |
| `.accessibilityHidden(true)` | Removes from VoiceOver tree |
| `.accessibilityElement(children: .combine)` | Merges child elements into one node |
| `.accessibilityElement(children: .contain)` | Groups children as sub-elements |
| `.accessibilityElement(children: .ignore)` | Container becomes accessible, children hidden |
| `.accessibilityAddTraits(.isButton)` | Adds role trait |
| `.accessibilityRemoveTraits(.isImage)` | Removes wrong role trait |
| `.accessibilityInputLabels(["..."])` | Voice Control activation labels |
| `.accessibilitySortPriority(n)` | Overrides VoiceOver reading order (higher = earlier) |
| `.accessibilityAction(named: "...", {})` | Custom action in the Actions rotor |
| `.accessibilityActivationPoint(CGPoint)` | Override activation tap point |
| `.accessibilityCustomContent("label", "value")` | Extra info in Accessibility Inspector |

### SwiftUI Trait Values

`isButton`, `isHeader`, `isLink`, `isImage`, `isStaticText`, `isSelected`, `isKeyboardKey`, `isSearchField`, `playsSound`, `isModal`, `updatesFrequently`, `startsMediaSession`, `allowsDirectInteraction`, `causesPageTurn`, `isTabBar`, `isSummaryElement`

### UIKit Properties

| Property | Type | Notes |
|----------|------|-------|
| `isAccessibilityElement` | Bool | Set `true` on custom views |
| `accessibilityLabel` | String? | Overrides spoken name |
| `accessibilityHint` | String? | Spoken after pause |
| `accessibilityValue` | String? | Current value (sliders, progress) |
| `accessibilityTraits` | UIAccessibilityTraits | Bitfield of traits (`.button`, `.header`, etc.) |
| `accessibilityFrame` | CGRect | Determines VoiceOver focus rect |
| `accessibilityActivate()` | func | Override activation behavior |
| `accessibilityElements` | [Any]? | Set container's VoiceOver child order |
| `shouldGroupAccessibilityChildren` | Bool | Groups all children into single node |
| `accessibilityViewIsModal` | Bool | `true` = VoiceOver trapped inside |
| `accessibilityElementsHidden` | Bool | Hides all children from VoiceOver |

---

## Android Jetpack Compose Semantics - Quick Reference

| Modifier / Property | Purpose |
|--------------------|---------|
| `semantics { contentDescription = "..." }` | Accessible name |
| `semantics { role = Role.Button }` | Element role |
| `semantics { stateDescription = "..." }` | Current state text |
| `semantics { heading() }` | Marks as heading |
| `semantics { selected = true/false }` | Selected state |
| `semantics { toggleableState = ToggleableState.On }` | Toggle state |
| `semantics { onClick(label = "...", action = {...}) }` | Click action with label |
| `semantics { disabled() }` | Disabled state |
| `semantics { focused = true }` | Force focus |
| `semantics { liveRegion = LiveRegion.Polite }` | Live region announcements |
| `semantics { invisibleToUser() }` | Hide from TalkBack |
| `semantics { mergeDescendants = true }` | Merge child semantics into one node |
| `clearAndSetSemantics { ... }` | Replace all descendant semantics |
| `Modifier.semantics(mergeDescendants = true) { }` | Short merge pattern |

### Role Values

`Role.Button`, `Role.Checkbox`, `Role.DropdownList`, `Role.Image`, `Role.RadioButton`, `Role.Switch`, `Role.Tab`

---

## Common Violation Patterns and Fixes

### RN-001: Missing accessibilityLabel on icon button

```tsx
// VIOLATION
<TouchableOpacity onPress={close}>
  <Icon name="x" size={20} />
</TouchableOpacity>

// FIX
<TouchableOpacity
  onPress={close}
  accessibilityRole="button"
  accessibilityLabel="Close"
>
  <Icon name="x" size={20} aria-hidden />
</TouchableOpacity>
```

### RN-002: Image missing label

```tsx
// VIOLATION
<Image source={productImage} style={styles.product} />

// FIX - informational image
<Image
  source={productImage}
  style={styles.product}
  accessibilityLabel="Blue suede shoes, size 10"
/>

// FIX - decorative image
<Image
  source={decorativeBackground}
  style={styles.bg}
  accessible={false}
  importantForAccessibility="no"
/>
```

### RN-003: TextInput missing label

```tsx
// VIOLATION - placeholder is not a label
<TextInput placeholder="Email" value={email} onChangeText={setEmail} />

// FIX
<View>
  <Text nativeID="emailLabel">Email address</Text>
  <TextInput
    value={email}
    onChangeText={setEmail}
    accessibilityLabelledBy="emailLabel"
    accessibilityHint="Enter your email address"
    keyboardType="email-address"
    autoComplete="email"
  />
</View>
```

### RN-004: Checkbox missing state

```tsx
// VIOLATION
<TouchableOpacity onPress={toggle}>
  <Image source={checked ? checkedIcon : uncheckedIcon} />
  <Text>Accept terms</Text>
</TouchableOpacity>

// FIX
<TouchableOpacity
  onPress={toggle}
  accessibilityRole="checkbox"
  accessibilityState={{ checked }}
  accessibilityLabel="Accept terms and conditions"
>
  <Image source={checked ? checkedIcon : uncheckedIcon} accessible={false} />
  <Text>Accept terms</Text>
</TouchableOpacity>
```

### RN-005: Modal not trapping focus

```tsx
// VIOLATION - custom modal without VoiceOver trap
<View style={styles.modal}>
  <Text>Are you sure?</Text>
  <Button title="Confirm" onPress={confirm} />
</View>

// FIX - use Modal component (traps focus automatically) or set accessibilityViewIsModal
<Modal
  visible={visible}
  transparent
  accessibilityViewIsModal={true}  // traps VoiceOver
  onRequestClose={close}           // Android back button
>
  <View style={styles.overlay}>
    <Text>Are you sure?</Text>
    <Button title="Confirm" onPress={confirm} />
    <Button title="Cancel" onPress={close} />
  </View>
</Modal>
```

### AND-001: Compose image missing content description

```kotlin
// VIOLATION
Image(
    painter = painterResource(id = R.drawable.product),
    contentDescription = null  // null = decorative, but wrong for informational image
)

// FIX - informational
Image(
    painter = painterResource(id = R.drawable.product),
    contentDescription = stringResource(R.string.product_image_description)
)

// FIX - truly decorative
Image(
    painter = painterResource(id = R.drawable.divider),
    contentDescription = null,
    modifier = Modifier.semantics { invisibleToUser() }
)
```

---

## Testing Tool Commands

### iOS Accessibility Inspector (Xcode)

```text
Xcode -> Xcode menu -> Open Developer Tool -> Accessibility Inspector
- Run audit: Click "Audit" tab -> "Run Audit" button
- Inspect: "Inspection" tab -> hover over elements in Simulator
- Keyboard: Use +F7 to toggle VoiceOver in Simulator
```

### Android Accessibility Scanner

```bash
# Install (Play Store or adb)
adb install com.google.android.apps.accessibility.auditor

# Enable TalkBack via ADB (for CI)
adb shell settings put secure enabled_accessibility_services \
  com.google.android.marvin.talkback/.TalkBackService

# Check accessibility node tree
adb shell uiautomator dump /sdcard/ui_dump.xml
adb pull /sdcard/ui_dump.xml
```

### React Native Testing Library

```bash
npm install --save-dev @testing-library/react-native
```

```tsx
import { render, screen, fireEvent } from '@testing-library/react-native';

test('button has accessible name and role', () => {
  render(<SubmitButton onPress={jest.fn()} />);
  const btn = screen.getByRole('button', { name: /submit/i });
  expect(btn).toBeTruthy();
});

test('checkbox updates state', () => {
  render(<TermsCheckbox />);
  const checkbox = screen.getByRole('checkbox', { name: /accept terms/i });
  expect(checkbox).toHaveAccessibilityState({ checked: false });
  fireEvent.press(checkbox);
  expect(checkbox).toHaveAccessibilityState({ checked: true });
});
```

### Maestro (E2E)

```yaml
# .maestro/accessibility-checks.yaml
appId: com.example.myapp
---
- launchApp
- assertVisible:
    label: "Submit form"
- tapOn:
    label: "Close"
- assertNotVisible:
    label: "Are you sure?"
```
