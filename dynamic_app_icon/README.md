# dynamic_app_icon

A production-grade, highly reliable Flutter plugin to dynamically switch the application launcher icon at runtime using predefined assets bundled with the app.

<p align="center">
  <img src="doc/demo.gif" width="300" alt="Dynamic App Icon Demo">
</p>
<p align="center">
  <em>Note: Add your demonstration GIF or screenshot to <code>doc/demo.gif</code> in your project repository so it appears here on pub.dev!</em>
</p>

---

## Features

- **Runtime Icon Switching**: Change launcher icons programmatically on Android and iOS instantly or with system alerts based on OS capabilities.
- **Android Adaptive Icons**: Automatically splits 1024x1024 flat or transparent logos into foreground/background vectors, maintaining full circular safe zones.
- **iOS Opaque Backplane Blending**: Automatically overlays transparent assets onto solid backdrops to meet AppStore opaque icon requirements.
- **Validation Engine**: Scans assets, validates shape dimensions, checks duplicate casings, sanitizes filenames, and corrects size/transparency configurations automatically.
- **Developer CLI**: Automates assets scaling, `AndroidManifest.xml` alias installations, and `Info.plist` CFBundleAlternateIcons setups with one shell command.

---

## Installation

Add of `dynamic_app_icon` package under your project's `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  dynamic_app_icon: ^0.0.1  # Or specify path dependency locally
```

Ensure you run:
```bash
flutter pub get
```

---

## Setup

Create a local source directory in your project's root: `assets/app_icons/`. Place all alternate icons there as **1024x1024 PNG** files.

Example workspace structure:
```text
my_flutter_app/
  assets/
    app_icons/
      default.png       <-- Primary, default application app icon
      dark_icon.png     <-- Alternate icon variant 1
      festive_gold.png  <-- Alternate icon variant 2
```

> [!NOTE]
> `default.png` is mandatory. It represents your application's fallback standard launcher icon.

Then, register this assets directory in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/app_icons/
```

---

## CLI Automated Setup (Fastest)

Run the automated CLI generation pipeline. This utility validates files, handles sizes and transparencies, generates assets, compiles mipmaps, and configures platform manifests with zero configuration:

```bash
dart run dynamic_app_icon:generate
```

### What does the CLI automate?

#### **Android**
1. Checks for name collisions, size dimensions (converts to 1024x1024 automatically in-memory), and formats filenames to conform to Android resources standard (`[a-z0-9_]`).
2. Creates legacy, round, and adaptive icon layers:
   - **Transparent PNGs**: Treated as Foreground. The Background is generated as a solid opaque white canvas.
   - **Opaque (Flat) PNGs**: Padds the logo to 66% (safe zone) for the Foreground, and uses the raw flat canvas as the Background.
3. Generates XML wrappers under `mipmap-anydpi-v26/ic_launcher_{icon}.xml`.
4. Injects activity-alias items to `AndroidManifest.xml` inside `<!-- dynamic_app_icon:inject:start -->` comments automatically.

#### **iOS**
1. Generates 5 distinct alternate sizes: `@2x` (120x120), `@3x` (180x180), iPad `@1x` (76x76), iPad `@2x` (152x152), and iPad Pro `@2x` (167x167).
2. Automatically blends transparent images onto a solid white background (preventing alpha channel app rejection).
3. Modifies `Info.plist` injecting `CFBundleAlternateIcons` setups within XML tags.

---

## Manual Configuration (Fallback)

If you prefer manual control over manifest configurations:

### Android Configuration
In `android/app/src/main/AndroidManifest.xml`, configure an `<activity-alias>` for each variant targeting `.MainActivity`, and disable them by default:

```xml
<activity-alias
    android:name=".MainActivitydark_icon"
    android:enabled="false"
    android:exported="true"
    android:icon="@mipmap/ic_launcher_dark_icon"
    android:targetActivity=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity-alias>
```

### iOS Configuration
In `ios/Runner/Info.plist`, declare alternate icons inside the `CFBundleIcons` key:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>dark_icon</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>dark_icon-2x</string>
                <string>dark_icon-3x</string>
            </array>
            <key>UIPrerenderedIcon</key>
            <false/>
        </dict>
    </dict>
</dict>
```

---

## Dart API Usage Examples

Exposes a clean client static API representing `DynamicAppIcon`.

### 1. Check Platform Support
Alternate launcher changing requires Android 8.0+ or iOS 10.3+.

```dart
bool isSupported = await DynamicAppIcon.isSupported();
if (isSupported) {
  print("Device supports runtime launcher switching!");
}
```

### 2. Available Alternate Icons
Gets a list of all configured alternate icon suffix names (excluding `default`).

```dart
List<String> list = await DynamicAppIcon.availableIcons();
print("Configured alternates: $list"); // ['dark_icon', 'festive_gold']
```

### 3. Get Active Icon
Returns the active icon name. If default, it returns `'default'`.

```dart
String active = await DynamicAppIcon.current();
print("Current active icon: $active");
```

### 4. Change Launcher Icon
Dynamically swaps to one of the configured alternate names.

```dart
try {
  await DynamicAppIcon.change('dark_icon');
  print("Icon updated successfully");
} on DynamicAppIconException catch (e) {
  print("Failed to change icon: ${e.message}");
}
```

### 5. Revert to Default Icon
Re-enables the primary `.MainActivity` component and reverts change.

```dart
try {
  await DynamicAppIcon.reset();
  print("Reverted to base default launcher icon.");
} on DynamicAppIconException catch (e) {
  print("Reset failed: ${e.message}");
}
```

---

## Example Application 📱

The `dynamic_app_icon` package includes a fully functional Example Application to demonstrate dynamic launcher icon switching in action. It is intentionally simple so you can quickly understand how to integrate the package into your own projects.

### Bundled Icons 🎨
The example app comes pre-configured with six beautiful predefined launcher icons:
- Default (Flutter Original)
- Cat 🐱
- Dog 🐶
- Fox 🦊
- Panda 🐼
- Rocket 🚀

All launcher icons are bundled with the application and switched entirely at runtime. Under the hood, this works seamlessly by leveraging native Android `<activity-alias>` configurations and iOS `CFBundleAlternateIcons`.

### Interactive Demo 🛠️
- **Select an Icon**: Tap any icon in the grid to select it.
- **Apply Icon**: Pressing the "Apply Icon" button changes the device's launcher icon to your selection.
- **Reset to Default**: Instantly restores the original fallback application icon.
- **Random Icon**: Randomly selects and applies one of the predefined alternate icons.

> **💡 Pro Tip:** The example app is just a playground! We encourage you to replace these demo animal icons with your own gorgeous branding and custom artwork when building your app! ✨

---

## Best Practices

- **Avoid frequent switches**: Constantly switching launcher icons can trigger platform rate limits, particularly on iOS. Limit switching to actions like theme changes or achievements.
- **Run the CLI on changes**: If you add, delete, or rename files in `assets/app_icons/`, immediately rerun the CLI tool to refresh compiled output and keep files in sync.
- **File Naming**: Keep filename characters under standard lowercase style (`^[a-z0-9_]+$`). The CLI validator automatically sanitizes non-compliant names, but maintaining natural name compatibility keeps code clear.

---

## Known Limitations

- **iOS Alert Banner**: Changing alternate icons on iOS triggers a system alert dialog displaying: *"You have changed the icon for..."*. This is a hardcoded system security popup on iOS and cannot be bypassed.
- **App Drawer Recents**: When switching icons on Android, the launcher environment restarts the background services of the application. This causes the app status to briefly rebuild and current background processes to cycle, which is normal Android package manager behavior.
- **iPad alternates**: Always supply ipad alternate keys (`CFBundleIcons~ipad`) whenever compiling iOS; our automated CLI tool takes care of this by default.

---

## Troubleshooting & FAQs

### Q: Why does the app crash or restart when I change the icon on Android?
On Android, changing the enabled components via Package Manager kills the app process in background to rebuild launcher shortcuts. This is standard OS behavior. Ensure you save user preferences or app state before calling `DynamicAppIcon.change()`.

### Q: Can my launcher icon draw dynamic graphics or graphs from network APIs?
No. App alternate icons must be statically resolved and bundled into resources at compile-time. Operating systems do not permit remote asset loading of launcher icons for security reasons.

### Q: The changes are not updating on iOS!
Ensure you ran `dart run dynamic_app_icon:generate`. If assets still display old versions, perform a clean rebuild:
```bash
flutter clean && flutter run
```

---

## Migration Guide
If migrating from primitive single-purpose packages:
1. Delete any hardcoded `<activity-alias>` elements from `AndroidManifest.xml` that could clash.
2. Clean out old Xcode alternate icons configuration blocks from `Info.plist`.
3. Drop your raw logo files in `assets/app_icons/` naming them clean suffix styles.
4. Run `dart run dynamic_app_icon:generate` to finalize.