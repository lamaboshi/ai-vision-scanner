# AI Vision Scanner

AI Vision Scanner is a Flutter Android application that demonstrates practical on-device machine learning with Google ML Kit. Users can capture or select an image, extract Latin-script text, copy OCR results, and view image labels with confidence scores without a backend, API key, or paid cloud service.

This project is designed as a concise portfolio app: small enough to review quickly, but complete enough to show Android permissions, local ML inference, state handling, responsive Material UI, release builds, and test coverage.

## Features

- Camera capture and Android gallery image selection.
- Image preview before and during analysis.
- Latin-script OCR with Google ML Kit Text Recognition.
- Selectable OCR output with copy-to-clipboard support.
- Image labeling with confidence percentages sorted by confidence.
- Loading, empty, cancelled-selection, permission, and error states.
- Duplicate-tap protection while picking or analyzing images.
- Material 3 interface with light and dark theme support.
- No backend, accounts, API keys, or paid services.

## Technology Stack

- Flutter / Dart
- Android only
- Material 3
- `image_picker`
- `google_mlkit_text_recognition`
- `google_mlkit_image_labeling`

## On-Device ML Architecture

The UI layer stays in `lib/src/screens/scanner_screen.dart` and owns simple local interaction state. ML Kit integration is isolated in `lib/src/services/vision_analyzer.dart`, which creates and disposes the text recognizer and image labeler. Result data is represented by small model classes in `lib/src/models/vision_analysis_result.dart`.

Images are analyzed locally through Google ML Kit. The app does not upload selected photos to a custom server and does not call generative AI or cloud AI APIs.

## Project Structure

```text
lib/
  main.dart
  src/
    models/
    screens/
    services/
    theme/
    widgets/
android/
  app/
    src/main/
screenshots/
  README.md
```

## Android Requirements

- Android 7.0 / API 24 or newer.
- Camera permission is requested only when using camera capture.
- Application ID: `com.lamaboshi.aivisionscanner`.
- Current release APKs are debug-signed for portfolio testing only.

## Setup

```bash
flutter pub get
flutter run
```

Use a real Android device or emulator. Real ML Kit behavior should be validated on Android hardware before publishing a demo video or release artifact.

## Testing

```bash
dart format .
flutter analyze
flutter test
```

Current local validation status:

- `flutter analyze`: passes.
- `flutter test`: passes with 4 automated tests.
- `flutter build apk --release`: passes.
- `flutter build apk --release --split-per-abi`: passes.

## Build

Universal release APK:

```bash
flutter build apk --release
```

Architecture-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

Generated APKs are written to:

```text
build/app/outputs/flutter-apk/
```

The `build/` directory is intentionally ignored by Git.

## Screenshots

Real screenshots should be added before publishing the repository. Suggested files:

- `screenshots/home-light.png`
- `screenshots/home-dark.png`
- `screenshots/image-preview.png`
- `screenshots/text-result.png`
- `screenshots/labels-result.png`

See `screenshots/README.md` for capture instructions.

## Privacy And Offline Behavior

Images are processed on device through Google ML Kit. No image is uploaded by this app to a backend owned by the project.

Google ML Kit may download required on-device models on first use depending on device state and Play Services availability. Offline analysis should only be claimed after testing the target device with the required models already available.

## Known Limitations

- OCR is configured for Latin script only.
- Arabic OCR is not claimed or enabled.
- Accuracy depends on lighting, focus, image quality, and ML Kit model behavior.
- Manual Android validation is still required for camera, gallery, OCR, labeling, clipboard, permissions, and offline behavior.
- Release builds currently use debug signing; production distribution requires a private signing key that must not be committed.
- Real screenshots are not included yet.

## Release Checklist

See `RELEASE_CHECKLIST.md` for the manual checks required before publishing or attaching APKs to a release.