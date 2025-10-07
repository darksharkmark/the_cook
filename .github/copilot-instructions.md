# Copilot Instructions for AI Agents

## Project Overview
This is a Flutter project for a multi-platform app (Android, iOS, web, desktop) named `the_cook`. The workspace contains platform-specific folders (`android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`) and the main Dart code in `lib/`.

## Architecture & Data Flow
- **Main entry point:** `lib/main.dart` (Flutter app root)
- **Assets:** Card data and images are stored in `assets/` and subfolders (e.g., `assets/card_data.csv`, `assets/cards/`).
- **Platform code:** Native code and configs are in respective platform folders.
- **Build artifacts:** Output in `build/` and `web/` (for web builds).

## Developer Workflows
- **Build:** Use `flutter build <platform>` (e.g., `flutter build apk`, `flutter build web`).
- **Run:** Use `flutter run` for local development.
- **Test:** Place tests in `test/` and run with `flutter test`.
- **Assets:** Ensure assets are declared in `pubspec.yaml` under `flutter/assets`.
- **CSV Sanitization:** Use `assets/sanitize_csv.py` to preprocess card data before app use.

## Conventions & Patterns
- **Card Data:** Card images and CSVs are organized by set in `assets/cards/<SET>/`.
- **Python Scripts:** Used for asset preprocessing, not for app runtime.
- **State Management:** Follow Flutter best practices for state management (e.g., Provider, Riverpod).
- **UI:** Use Flutter widgets and follow Material Design guidelines.
- **Code Style:** Follow Dart and Flutter style guides. Focus on readability and maintainability.
- **Version Control:** Use Git for version control. Commit messages should be clear and descriptive.

## Integration Points
- **External dependencies:** Managed via `pubspec.yaml` (Dart/Flutter packages).
- **Native integration:** Android/iOS configs in respective folders; web assets in `web/`.

## Key Files & Directories
- `lib/main.dart`: App entry point
- `assets/card_data.csv`: Main card data
- `assets/sanitize_csv.py`: Data cleaning script
- `pubspec.yaml`: Dependency and asset declaration
- `test/`: Unit and widget tests

## Example: Adding a Card Set
1. Place images in `assets/cards/<SET>/`
2. Update `assets/card_data.csv` and sanitize with `assets/sanitize_csv.py`
3. Declare new assets in `pubspec.yaml`
4. Rebuild the app

---
For questions about build, test, or asset workflows, see the above directories and scripts. If any conventions or workflows are unclear, ask for clarification or examples from the user.
