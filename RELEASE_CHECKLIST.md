# AI Vision Scanner Release Checklist

Use this checklist before publishing the project publicly or sharing the APK as a portfolio artifact.

## Automated Verification

- [x] `flutter analyze`
- [x] `flutter test`
- [x] `flutter build apk --release`
- [x] Confirm `build/app/outputs/flutter-apk/app-release.apk` exists
- [x] `flutter build apk --release --split-per-abi`

## Manual Android Verification Required

- [ ] Install the release APK on a real Android device.
- [ ] Launch the release app from the Android launcher.
- [ ] Select an image from the gallery.
- [ ] Capture an image with the camera.
- [ ] Confirm camera permission denial and retry behavior.
- [ ] Confirm cancelled camera/gallery selection does not crash.
- [ ] Recognize clear English / Latin-script text.
- [ ] Confirm a no-text image shows the empty text state.
- [ ] Confirm image labels appear with confidence percentages.
- [ ] Confirm copy recognized text places the expected text on the clipboard.
- [ ] Tap camera/gallery rapidly and confirm duplicate analysis or crashes do not occur.
- [ ] Test light and dark system modes.
- [ ] Test at least one small phone viewport and one larger Android viewport.
- [ ] Confirm first-run ML Kit model behavior on Wi-Fi.
- [ ] Confirm offline analysis after required ML Kit models are available.

## Release Readiness Before Public Publishing

- [x] Use stable application ID: `com.lamaboshi.aivisionscanner`.
- [ ] Configure a production signing key instead of debug signing.
- [ ] Add real screenshots to the README.
- [ ] Review generated APK size and decide whether split APKs are needed.
- [ ] Confirm no personal data, secrets, or generated build outputs are committed.
