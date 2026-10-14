# Screenshots

Add real Android screenshots here before publishing the GitHub repository. Do not use mockups or generated images unless they are clearly labeled as mockups.

Recommended files:

- `home-light.png`
- `home-dark.png`
- `image-preview.png`
- `text-result.png`
- `labels-result.png`

## Capture Instructions

1. Install and run the app on a real Android device or emulator.
2. Capture screenshots with Android Studio Device Manager, `adb shell screencap`, or the device screenshot shortcut.
3. Review each screenshot for personal data before committing it.
4. Keep images reasonably compressed for GitHub.

Example using ADB:

```bash
adb shell screencap -p /sdcard/ai-vision-scanner.png
adb pull /sdcard/ai-vision-scanner.png screenshots/home-light.png
```