# 🔥 Streak it - Habit Tracking App

A beautiful and intuitive Flutter habit tracking app inspired by Momentum, designed to help you build and maintain daily habits with Firebase sync and smart notifications.

## ✨ Features

- **📊 Habit Tracking**: Create and track habits with custom emojis and colors
- **🔄 Flexible Scheduling**: Daily, specific days, or one-time habits
- **⏰ Smart Reminders**: Set custom reminder times for each habit
- **🌅 Morning Notifications**: Get reminded when you unlock your phone (5 AM - 12 PM)
- **📈 Statistics & Analytics**: View your progress with beautiful charts
- **🏆 Achievements**: Unlock achievements as you maintain streaks
- **💭 Motivational Quotes**: Get inspired with daily quotes
- **📅 Weekly Review**: Review your week's progress
- **🔐 Google Sign-In**: Secure authentication with Google
- **☁️ Cloud Sync**: Your habits sync across devices using Firebase
- **📱 Cross-Platform**: Works on Web and Android

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (3.35.7 or later)
- [Firebase Account](https://firebase.google.com/)
- For Android: Android SDK and Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/numaan7/Streak-it.git
   cd Streak-it
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Follow the detailed instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Copy `lib/firebase_options.dart.example` to `lib/firebase_options.dart`
   - Add your Firebase credentials to `lib/firebase_options.dart`
   - For Android: Copy `android/app/google-services.json.example` to `android/app/google-services.json`
   - Download the actual `google-services.json` from Firebase Console and replace it

4. **Run the app**
   
   **For Web:**
   ```bash
   flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
   ```
   
   **For Android:**
   ```bash
   flutter run -d android
   ```

## 🏗️ Building for Production

### Web
```bash
flutter build web --release
```

### Android
See detailed instructions in [BUILD_ANDROID.md](BUILD_ANDROID.md)

```bash
flutter build apk --release --split-per-abi
```

This will create three APK files in `build/app/outputs/flutter-apk/`:
- `app-arm64-v8a-release.apk` (for most modern phones)
- `app-armeabi-v7a-release.apk` (for older phones)
- `app-x86_64-release.apk` (for emulators)

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart.example  # Firebase config template
├── models/                        # Data models
│   ├── habit.dart
│   └── habit_extras.dart
├── providers/                     # State management
│   └── habit_provider.dart
├── screens/                       # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── add_habit_screen.dart
│   ├── statistics_screen.dart
│   ├── achievements_screen.dart
│   ├── weekly_review_screen.dart
│   └── profile_screen.dart
├── services/                      # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
└── widgets/                       # Reusable components
    ├── habit_card.dart
    ├── stats_overview.dart
    └── motivational_quote.dart
```

## 📚 Documentation

- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Complete Firebase configuration guide
- [BUILD_ANDROID.md](BUILD_ANDROID.md) - Android build instructions
- [ANDROID_FIXES.md](ANDROID_FIXES.md) - Android-specific fixes and troubleshooting
- [NOTIFICATION_SETUP.md](NOTIFICATION_SETUP.md) - Notification configuration guide

## 🔧 Configuration

### Required Files (Not in Repository)

These files contain sensitive credentials and must be created:

1. **`lib/firebase_options.dart`**
   - Copy from `lib/firebase_options.dart.example`
   - Add your Firebase credentials

2. **`android/app/google-services.json`**
   - Download from Firebase Console
   - Template available at `android/app/google-services.json.example`

### Android Permissions

The app requires the following Android permissions:
- `INTERNET` - For Firebase and Google Sign-In
- `POST_NOTIFICATIONS` - For habit reminders
- `RECEIVE_BOOT_COMPLETED` - To restore notifications after reboot
- `SCHEDULE_EXACT_ALARM` - For precise notification timing
- `VIBRATE` - For notification vibrations
- `WAKE_LOCK` - To wake device for notifications

All permissions are already configured in `AndroidManifest.xml`.

## 🐛 Troubleshooting

### Google Sign-In Not Working?
1. Ensure you've added your app to Firebase Console
2. Add SHA-1 fingerprint to Firebase (run `cd android && ./gradlew signingReport`)
3. Download fresh `google-services.json` from Firebase Console
4. Verify package name matches: `com.example.streak_it`

### Notifications Not Showing?
1. Check notification permissions in Android Settings
2. Disable battery optimization for the app
3. See [NOTIFICATION_SETUP.md](NOTIFICATION_SETUP.md) for detailed troubleshooting

### Firebase Not Connecting?
1. Verify `firebase_options.dart` has correct credentials
2. Check Firebase Console that your app is properly configured
3. Ensure you've enabled Google Sign-In in Firebase Authentication

## 🛠️ Tech Stack

- **Framework**: Flutter 3.35.7
- **Language**: Dart 3.9.2
- **Backend**: Firebase (Auth, Firestore)
- **Authentication**: Google Sign-In
- **Notifications**: flutter_local_notifications
- **Charts**: fl_chart
- **State Management**: Provider

## 📦 Key Dependencies

```yaml
firebase_core: ^3.15.2
firebase_auth: ^5.7.0
cloud_firestore: ^5.6.12
google_sign_in: ^6.3.0
flutter_local_notifications: ^17.2.4
provider: ^6.1.2
fl_chart: ^0.66.2
timezone: ^0.9.4
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Numaan**
- GitHub: [@numaan7](https://github.com/numaan7)

## 🙏 Acknowledgments

- Inspired by the Momentum app
- Icons and design elements from Material Design
- Firebase for backend services
- The Flutter community for amazing packages

## 📸 Screenshots

_(Add screenshots of your app here)_

## 🔮 Future Features

- [ ] Home screen widgets
- [ ] iOS support
- [ ] Dark mode improvements
- [ ] Habit categories
- [ ] Social features (share achievements)
- [ ] Export data
- [ ] Custom themes
- [ ] Multi-language support

---

**Start building better habits today! 🚀**

If you find this project helpful, please give it a ⭐️
