# mobile-accessibility Skill

> Mobile accessibility reference data for React Native, Expo, iOS, and Android auditing. Covers the complete React Native accessibility props table (including RN 0.73+ ARIA aliases), `accessibilityRole` values with iOS UIAccessibility and Android TalkBack mappings, touch target size requirements, SwiftUI and UIKit property references, Jetpack Compose semantics, common violation patterns with fixes, and testing tool commands.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [mobile-accessibility](../agents/mobile-accessibility.md) | Primary consumer - full mobile accessibility audit |

## React Native Accessibility Props

| Prop | Purpose | WCAG SC |
|------|---------|---------|
| `accessibilityLabel` / `aria-label` | Human-readable name for the element | 1.1.1, 4.1.2 |
| `accessibilityRole` / `aria-role` | Communicates element type to AT | 4.1.2 |
| `accessibilityHint` / `aria-describedby` | Additional context spoken after label and role | 1.3.3 |
| `accessibilityState` | `{checked, disabled, expanded, selected, busy}` | 4.1.2 |
| `accessibilityValue` | `{min, max, now, text}` - for sliders, steppers | 1.3.1 |
| `accessibilityActions` | Custom actions (context menus, long-press alternatives) | 4.1.3 |
| `accessibilityLiveRegion` / `aria-live` | `'polite'` or `'assertive'` for dynamic updates | 4.1.3 |
| `accessibilityViewIsModal` / `aria-modal` | Traps VoiceOver/TalkBack focus inside modals | 1.3.4 |
| `accessibilityElementsHidden` / `aria-hidden` | iOS - hides decorative content from VoiceOver | 1.1.1 |
| `importantForAccessibility` | Android - `'no'` or `'no-hide-descendants'` for decorative | 1.1.1 |

> RN 0.73+ introduces ARIA-aliased props (`aria-label`, `aria-role`, etc.) - use these in new code.

## Key accessibilityRole Values

| Role | Use For |
|------|---------|
| `'button'` | Buttons, submission triggers |
| `'link'` | Navigation links, external URLs |
| `'image'` | Informational images |
| `'imagebutton'` | Icon buttons |
| `'header'` | Section headings |
| `'checkbox'` | Checkboxes |
| `'switch'` | Toggle switches |
| `'tab'` / `'tablist'` | Tab elements and containers |
| `'combobox'` | Dropdowns / selects |
| `'alert'` | Alert dialogs |
| `'progressbar'` | Progress indicators |
| `'none'` | Suppress/remove role |

## Touch Target Size Requirements

| Platform | Minimum | Standard |
|----------|---------|---------|
| iOS | 44 x 44 pt | Apple HIG |
| Android | 48 x 48 dp | Material Design |
| Web mobile (WCAG 2.5.5 AAA) | 44 x 44 CSS px | WCAG |
| Web mobile (WCAG 2.5.8 AA) | 24 x 24 CSS px with spacing | WCAG 2.2 |

## Common Violations and Fixes

### Icon button missing label

```tsx
// VIOLATION
<TouchableOpacity onPress={close}>
  <Icon name="x" size={20} />
</TouchableOpacity>

// FIX
<TouchableOpacity onPress={close} accessibilityRole="button" accessibilityLabel="Close">
  <Icon name="x" size={20} aria-hidden />
</TouchableOpacity>
```

### TextInput using placeholder as label

```tsx
// VIOLATION - placeholder is not a label
<TextInput placeholder="Email" value={email} onChangeText={setEmail} />

// FIX
<View>
  <Text nativeID="emailLabel">Email address</Text>
  <TextInput
    value={email} onChangeText={setEmail}
    accessibilityLabelledBy="emailLabel"
    keyboardType="email-address" autoComplete="email"
  />
</View>
```

### Modal not trapping focus

```tsx
// FIX - Modal component traps VoiceOver automatically
<Modal visible={visible} transparent accessibilityViewIsModal={true} onRequestClose={close}>
  <View style={styles.overlay}>
    <Text>Are you sure?</Text>
    <Button title="Confirm" onPress={confirm} />
    <Button title="Cancel" onPress={close} />
  </View>
</Modal>
```

## iOS SwiftUI - Key Accessibility Modifiers

| Modifier | Purpose |
|----------|---------|
| `.accessibilityLabel("...")` | Overrides spoken name |
| `.accessibilityHint("...")` | Spoken usage hint |
| `.accessibilityHidden(true)` | Removes from VoiceOver tree |
| `.accessibilityElement(children: .combine)` | Merges children into one node |
| `.accessibilityAddTraits(.isButton)` | Adds role trait |
| `.accessibilityAction(named: "...", {})` | Custom action in Actions rotor |

## Android Compose - Key Semantics

| Modifier | Purpose |
|----------|---------|
| `semantics { contentDescription = "..." }` | Accessible name |
| `semantics { role = Role.Button }` | Element role |
| `semantics { heading() }` | Marks as heading |
| `semantics { liveRegion = LiveRegion.Polite }` | Live announcements |
| `semantics { invisibleToUser() }` | Hides from TalkBack |
| `semantics { mergeDescendants = true }` | Merges child semantics |

## Testing Commands

```bash
# React Native Testing Library
npm install --save-dev @testing-library/react-native
```

```tsx
const btn = screen.getByRole('button', { name: /submit/i });
expect(btn).toBeTruthy();
```

```bash
# Enable TalkBack via ADB (Android CI)
adb shell settings put secure enabled_accessibility_services \
  com.google.android.marvin.talkback/.TalkBackService
```

## Skill Location

`.github/skills/mobile-accessibility/SKILL.md`
