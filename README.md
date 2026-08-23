# Fitness AI

Personalized home fitness app built with Flutter.

## Current status

V0.1 foundation:
- Flutter app shell
- Simple onboarding flow
- Goal selection: arms, chest, abs, legs, back, full body
- Fitness Engine foundation
- Initial exercise catalog
- Unit tests
- GitHub Actions CI with Android APK build

## Development

Open the repository in Android Studio with the Flutter and Dart plugins installed.

If the Android platform folder is not present yet, run:

```bash
flutter create --platforms=android .
```

Then:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Architecture

The project keeps the UI separate from the fitness domain so the workout engine remains deterministic and testable. Gemini will be integrated later as an adaptive coach, not as an unrestricted workout generator.

## License

Private project / all rights reserved for now.
