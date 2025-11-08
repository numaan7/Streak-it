# Streak it

**Vibe check your habits** 🔥

A beautiful, modern habit tracking app built with Flutter that helps you build and maintain positive habits through streak tracking and engaging visualizations.

## ✨ Features

### Core Features
- **Habit Tracking**: Create and manage your daily habits
- **Streak Counting**: Track your current and longest streaks
- **Visual Progress**: Beautiful activity calendar showing your completion history
- **Statistics Dashboard**: View your momentum with active streaks, total days, and completion rates
- **Weekly Charts**: Visualize your progress over the last 7 days

### UI/UX
- **Dark Theme**: Sleek, modern dark interface
- **Color Customization**: Choose from 12 vibrant colors for each habit
- **Icon Library**: 20+ icons to personalize your habits
- **Smooth Animations**: Delightful micro-interactions and transitions
- **Responsive Design**: Works beautifully on all screen sizes

### Data Management
- **Local Storage**: Your data stays on your device
- **Persistent State**: All habits and progress are saved automatically
- **Quick Actions**: Toggle habit completion with a single tap

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator or Android Emulator (or physical device)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Streak-it
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── habit.dart           # Habit data model
├── providers/
│   └── habit_provider.dart  # State management
├── screens/
│   ├── home_screen.dart     # Main screen
│   ├── add_habit_screen.dart # Create new habit
│   └── habit_detail_screen.dart # Habit statistics & details
├── widgets/
│   ├── habit_card.dart      # Habit list item
│   └── streak_stats_card.dart # Stats display
├── services/
│   └── storage_service.dart # Local data persistence
└── utils/
    └── app_theme.dart       # Colors, theme, constants
```

## 🎨 Customization

### Adding New Colors
Edit `lib/utils/app_theme.dart` and add colors to the `habitColors` list:

```dart
static const List<Color> habitColors = [
  Color(0xFFYourColor),
  // ... more colors
];
```

### Adding New Icons
Edit `lib/screens/add_habit_screen.dart` and add icons to `_availableIcons`:

```dart
final List<IconData> _availableIcons = [
  Icons.your_icon,
  // ... more icons
];
```

## 📦 Dependencies

- **provider**: State management
- **shared_preferences**: Local data storage
- **fl_chart**: Beautiful charts and graphs
- **flutter_animate**: Smooth animations
- **google_fonts**: Typography
- **intl**: Date formatting

## 🎯 Key Features Explained

### Streak Calculation
The app calculates streaks intelligently:
- **Current Streak**: Counts consecutive days including today/yesterday
- **Longest Streak**: Tracks your best performance ever
- **Completion Rate**: Shows your success rate over the last 30 days

### Activity Calendar
- Shows 42 days (6 weeks) of activity
- Completed days are highlighted in your habit's color
- Today's date is outlined for easy reference

### Statistics
- **Active Streaks**: Number of habits with active streaks
- **Total Days**: Sum of all current streak days
- **Today's Progress**: Percentage of habits completed today

## 🛠️ Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Known Issues & Limitations

- No cloud sync (local storage only)
- No reminders/notifications yet
- No habit editing (must delete and recreate)
- No data export/import

## 🚀 Future Enhancements

- [ ] Push notifications for daily reminders
- [ ] Cloud backup and sync
- [ ] Habit editing functionality
- [ ] Data export (CSV/JSON)
- [ ] Custom frequency patterns
- [ ] Achievement badges
- [ ] Social features (share progress)
- [ ] Widget support
- [ ] More chart types

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Built with ❤️ using Flutter

---

**Vibe check your habits and build momentum every day!** 🚀✨
