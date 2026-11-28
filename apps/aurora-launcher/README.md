# Aurora launcher (starter app)

The home screen for the Aurora glasses, in its first form. It is the first of the launch apps in the [build package](../../docs/glasses-build-package.md#the-apps) and the place to start app work today, before any glasses hardware arrives.

What it does now:

- A home row of cards for the launch apps (Assistant, Camera, Captions, Navigate, Messages, Notes, Music, Apps), with a clock.
- Everything works with five inputs: left, right, up, down and select, plus back. The temple touchpad is mapped to these keys on the glasses; on a computer the arrow keys and Enter do the same; touch works too.
- Black background with bright text, because black is see-through on the lenses.
- The display fades after 8 seconds without input, to save battery, and wakes on any input.
- The Apps card lists every installed Android app and opens it (tier 2 apps in the [software plan](../../docs/glasses-software-platform.md#how-apps-get-onto-the-glasses)).
- It registers as a home app, so on the glasses it can replace the default launcher.

The other cards open placeholder screens; each becomes its own app in the order listed in the build package.

## Run it

1. Install [Android Studio](https://developer.android.com/studio) and open this folder (`apps/aurora-launcher`).
2. Let it download the Android SDK 34 platform and Gradle when it asks.
3. **Emulator:** Device Manager → New device → New hardware profile, 640 × 480 pixels, about 160 dpi, landscape. Run the app on it and use the arrow keys and Enter.
4. **Phone + display glasses (route A):** plug USB-C display glasses into a phone that outputs DisplayPort. With developer options on, run `adb shell dumpsys display | grep mDisplayId` to find the glasses' display id, then `adb shell am start --display <id> -n com.aurora.launcher/.MainActivity`.
5. **ODM board (route B):** `adb install app-debug.apk`, then choose Aurora Launcher as the home app (or set it as the default home in the system image).

Built with Kotlin 2.0, Jetpack Compose (BOM 2024.09) and Android Gradle Plugin 8.5; minimum Android 10, target Android 14. It was written without an Android SDK on hand, so the first Android Studio sync is its first build: if Studio suggests a plugin or library version bump, accept it.
