# Streak it 🔥

**Vibe check your habits.**

A beautiful and energizing habit tracking app built with Flutter, designed to help you build and maintain positive habits with streak tracking, statistics, and a clean, modern UI.

## Features

### 🎨 Core Features
✨ **Beautiful UI** - Modern, clean interface with smooth animations  
🎯 **Habit Tracking** - Create and track daily habits with custom emojis and colors  
🔥 **Streak Tracking** - See your current streak and longest streak for each habit  
📊 **Statistics** - View detailed statistics and completion rates  
📈 **Progress Charts** - Visualize your weekly habit completions  
🌓 **Dark Mode** - Automatic dark/light theme support

### 🚀 New Features
📂 **Habit Categories** - Organize habits into 8 categories (Health, Mindfulness, Productivity, etc.)  
🏆 **Achievements** - Unlock badges for milestones (3-day, 7-day, 30-day, 100-day streaks)  
💭 **Daily Motivation** - Inspirational quotes to keep you motivated  
📝 **Habit Notes** - Add notes to your habits for better tracking (coming soon)

### ☁️ Cloud Features
🔐 **Google Authentication** - Sign in with your Google account  
☁️ **Cloud Sync** - Sync your habits across all devices with Firestore  
💾 **Offline Support** - Works offline with local storage, syncs when online  
👤 **User Profiles** - Personalized experience with profile management

## Screenshots

> Add screenshots here once the app is running

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio

### Installation

1. Clone the repository:
```bash
git clone https://github.com/numaan7/Streak-it.git
cd Streak-it
```

2. Install dependencies:
```bash
flutter pub get
```

3. **Set up Firebase** (Required for authentication and cloud sync):
   - Follow the detailed setup guide in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Configure your Firebase project and update `lib/firebase_options.dart`
   - Enable Google Sign-In in Firebase Console
   - Set up Cloud Firestore

4. Run the app:
```bash
flutter run
```

> **Note**: The app will work without Firebase configuration, but you'll only be able to use it without signing in (local storage only).

## Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase init
├── firebase_options.dart        # Firebase configuration
├── models/
│   └── habit.dart              # Habit data model
├── providers/
│   └── habit_provider.dart     # State management with Firestore sync
├── services/
│   ├── auth_service.dart       # Google authentication
│   └── firestore_service.dart  # Cloud Firestore operations
├── screens/
│   ├── home_screen.dart        # Main dashboard
│   ├── login_screen.dart       # Google sign-in
│   ├── profile_screen.dart     # User profile & settings
│   ├── add_habit_screen.dart   # Create/edit habits
│   └── statistics_screen.dart  # Stats and charts
└── widgets/
    ├── habit_card.dart         # Habit list item
    └── stats_overview.dart     # Overview stats card
```

## Dependencies

### Core
- **provider** - State management
- **shared_preferences** - Local data persistence
- **uuid** - Unique IDs for habits

### Firebase
- **firebase_core** - Firebase initialization
- **firebase_auth** - Google authentication
- **cloud_firestore** - Cloud database
- **google_sign_in** - Google sign-in integration

### UI & Visualization
- **google_fonts** - Custom typography
- **flutter_animate** - Smooth animations
- **fl_chart** - Charts and graphs
- **intl** - Date formatting

## How to Use

### Getting Started
1. **Sign In**: Sign in with your Google account for cloud sync, or continue without signing in for local-only storage
2. **Create a Habit**: Tap the "Add Habit" button and customize:
   - Choose an emoji from 24 options
   - Select a color from 10 vibrant options
   - Pick a category (Health, Mindfulness, Productivity, etc.)
   - Add a name and optional description
3. **Track Daily**: Tap on a habit card to mark it as completed for today
4. **View Stats**: Check the statistics screen to see your progress, completion rates, and weekly charts
5. **Achievements**: Unlock badges for streak milestones and habit counts
6. **Daily Motivation**: Get inspired by daily motivational quotes
7. **Manage Habits**: Long press on a habit to edit, archive, or delete it
8. **Profile**: Access your profile to view stats, manage account, and sign out

## Features in Detail

### Habit Creation
- Choose from 24 different emojis
- Select from 10 vibrant colors
- Add a name and optional description
- Automatic streak calculation

### Streak Tracking
- Current streak shows consecutive days completed
- Longest streak tracks your personal best
- Visual indicators for active streaks
- Automatic streak calculation

### Statistics
- Overall completion rate across all habits
- Per-habit statistics with current and best streaks
- Weekly bar chart showing daily completions
- Completion percentage for the last 30 days

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Numaan**  
GitHub: [@numaan7](https://github.com/numaan7)

## Acknowledgments

- Inspired by Momentum: Energising Habits
- Built with Flutter and love ❤️

---

**Streak it** - Vibe check your habits! 🎯🔥
