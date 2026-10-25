# HerCare — A Thoughtful Menstrual Care Companion for Android

HerCare is a personal menstrual-cycle awareness and care companion designed primarily for boyfriends and husbands who want to better understand, support, and care for their female partners during different phases of the menstrual cycle.

Unlike conventional tracking applications designed for women to track themselves, HerCare is built specifically for the partner with a focus on **minimal user input, useful contextual estimates, and natural human-centered care suggestions**.

---

## Key Features

- **Estimated Cycle Phase:** Displays the estimated menstrual cycle phase (**Menstrual Phase**, **Follicular Phase**, **Ovulation Phase**, and **Luteal Phase**) with cycle day badges and accessible biological explanations.
- **Automated Possibility Estimation:** Automatically estimates possible physical sensations and emotional experiences based on cycle timing and natural hormonal fluctuations, removing the need for tedious manual symptom logging.
- **Contextual Care Suggestions:** Generates gentle, actionable, and respectful care suggestions (e.g., preparing a warm compress, offering comforting tea, giving emotional space) matched to today's estimated cycle context.
- **Bilingual Support (English & Tiếng Việt):** Complete native localization for all navigation items, dashboards, dialogs, estimation notices, and care recommendations. Preferences persist across app restarts.
- **100% Offline & Private:** Zero remote servers, cloud databases, external analytics, or AI APIs. All data is persisted locally via SQLite.
- **Visual Cycle Calendar & Personal Notes:** Month view with period indicators, cycle phase legend, and private notes for comfort preferences.

---

## Technology Stack

- **Framework:** Flutter 3.x with sound null safety
- **Language:** Dart
- **UI:** Material 3 with custom warm ivory, soft rose, and lavender design palette
- **State Management:** Riverpod 2.x
- **Local Persistence:** SQLite (Drift) & SharedPreferences
- **Testing:** Automated unit, widget, and regression test suites

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Android SDK & Android Studio

### Running Locally
```bash
# Clone the repository
git clone https://github.com/bbaotrungg/HerCareApplication.git
cd HerCareApplication

# Install dependencies
flutter pub get

# Run automated tests
flutter test

# Run the application
flutter run
```

### Building Release APK
```bash
flutter build apk --release
```
The output APK will be placed in `build/app/outputs/flutter-apk/app-release.apk`.

---

## License

This project is licensed under the MIT License.
