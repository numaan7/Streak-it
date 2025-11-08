# 🚀 Quick Reference - Streak it

## ⚡ Commands

```bash
# Setup
flutter pub get                    # Install dependencies
flutter doctor                     # Check environment

# Development
flutter run                        # Run app
flutter run -d chrome             # Run on web
flutter run -d <device-id>        # Run on specific device
flutter devices                    # List available devices

# Hot Reload (while app is running)
r                                  # Hot reload
R                                  # Hot restart
q                                  # Quit

# Build
flutter build apk --release       # Android APK
flutter build appbundle          # Android App Bundle
flutter build ios --release       # iOS

# Maintenance
flutter clean                     # Clean build
flutter pub upgrade              # Update packages
flutter analyze                  # Check code
```

## 📁 File Structure

```
lib/
├── main.dart                    # App entry
├── models/habit.dart           # Data model
├── providers/habit_provider.dart # State
├── screens/
│   ├── home_screen.dart        # Main screen
│   ├── add_habit_screen.dart   # Create habit
│   └── habit_detail_screen.dart # Details
├── widgets/
│   ├── habit_card.dart         # List item
│   └── streak_stats_card.dart  # Stats
├── services/storage_service.dart # Persistence
└── utils/app_theme.dart        # Theme
```

## 🎨 Theme Colors

```dart
// Primary
AppColors.primary        // #6C5CE7 Purple
AppColors.secondary      // #A29BFE Light Purple

// Background
AppColors.background     // #0D0D0D Dark
AppColors.cardBackground // #1A1A1A

// Status
AppColors.success        // #00D9A3 Green
AppColors.warning        // #FFA500 Orange
AppColors.error          // #FF4757 Red

// Text
AppColors.textPrimary    // #FFFFFF White
AppColors.textSecondary  // #B0B0B0 Gray
AppColors.textTertiary   // #707070 Dark Gray
```

## 📏 Spacing

```dart
AppConstants.spacingXS   // 4.0
AppConstants.spacingS    // 8.0
AppConstants.spacingM    // 16.0
AppConstants.spacingL    // 24.0
AppConstants.spacingXL   // 32.0

AppConstants.radiusS     // 8.0
AppConstants.radiusM     // 16.0
AppConstants.radiusL     // 24.0
AppConstants.radiusXL    // 32.0
```

## 🔄 Common Patterns

### Using Provider
```dart
// Listen to changes
final habits = context.watch<HabitProvider>().habits;

// Read without listening
final provider = context.read<HabitProvider>();
provider.addHabit(newHabit);

// Consumer widget
Consumer<HabitProvider>(
  builder: (context, provider, child) {
    return Text('${provider.habits.length}');
  },
)
```

### Navigation
```dart
// Push new screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// Pop back
Navigator.pop(context);
```

### Adding a Habit
```dart
final habit = Habit(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'Morning Exercise',
  description: 'Start the day right',
  color: AppColors.habitColors[0],
  icon: Icons.fitness_center,
  createdAt: DateTime.now(),
  completedDates: [],
  frequency: FrequencyType.daily,
);

await context.read<HabitProvider>().addHabit(habit);
```

### Toggling Completion
```dart
await context.read<HabitProvider>().toggleHabitCompletion(habitId);
```

## 📊 Model Properties

```dart
habit.id                 // Unique identifier
habit.name               // Habit name
habit.description        // Optional description
habit.color              // Custom color
habit.icon               // Custom icon
habit.createdAt          // Creation date
habit.completedDates     // List of completions
habit.frequency          // Daily/Weekly/Custom

// Computed
habit.currentStreak      // Days in a row
habit.longestStreak      // Personal best
habit.isCompletedToday   // Boolean
habit.totalCompletions   // Count
habit.completionRate     // Percentage (30 days)
```

## 🎯 Provider Methods

```dart
provider.addHabit(habit)              // Create
provider.updateHabit(id, habit)       // Update
provider.deleteHabit(id)              // Delete
provider.toggleHabitCompletion(id)    // Toggle today
provider.loadHabits()                 // Load from storage

// Getters
provider.habits                       // All habits
provider.habitsSortedByStreak        // Sorted list
provider.activeHabits                // With streaks > 0
provider.totalActiveStreaks          // Sum of streaks
provider.todayCompletionRate         // Today's %
```

## 🐛 Troubleshooting

```bash
# Issue: Package conflicts
flutter pub cache repair
flutter clean
flutter pub get

# Issue: Hot reload not working
# Press 'R' for full restart

# Issue: Build errors
flutter clean
flutter pub get
flutter run

# Issue: Device not found
flutter devices
# Restart ADB or emulator
```

## 📦 Dependencies

```yaml
provider: ^6.1.1              # State management
shared_preferences: ^2.2.2    # Local storage
flutter_animate: ^4.5.0       # Animations
fl_chart: ^0.66.0            # Charts
intl: ^0.19.0                # Date formatting
google_fonts: ^6.1.0         # Typography
```

## 🔍 Debugging

```dart
// Print debug info
print('Habit: ${habit.name}, Streak: ${habit.currentStreak}');

// Debug mode check
assert(habit.name.isNotEmpty, 'Habit name required');

// Flutter DevTools
flutter run --profile
# Open DevTools URL in browser
```

## 🧪 Testing Tips

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/habit_test.dart

# Coverage
flutter test --coverage
```

## 📱 Platform Specific

### Android
```bash
# Build APK
flutter build apk --release

# Install on device
flutter install

# View logs
flutter logs
adb logcat
```

### iOS
```bash
# Build
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# View logs
flutter logs
```

## 🎨 Custom Widget Template

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Text(
        'Hello',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
```

## 🚀 Performance Tips

1. Use `const` constructors
2. Limit Provider scope with `Consumer`
3. Use `ListView.builder` for long lists
4. Cache heavy computations
5. Optimize images and assets
6. Profile with DevTools

## 📚 Documentation Files

- `README.md` - Project overview
- `SETUP.md` - Installation guide
- `GETTING_STARTED.md` - User guide
- `DEVELOPER_GUIDE.md` - Technical docs
- `FEATURES.md` - Feature list
- `SCREENS.md` - UI reference
- `PROJECT_SUMMARY.md` - Complete summary

## 🎯 Key Concepts

1. **Streaks** - Consecutive days of completion
2. **Provider** - State management pattern
3. **Habit** - Core data model
4. **Persistence** - Local storage with SharedPreferences
5. **Material Design** - UI framework
6. **Hot Reload** - Live code updates

## ⚡ Keyboard Shortcuts (VS Code)

```
Ctrl/Cmd + S           # Save
Ctrl/Cmd + Shift + F5  # Hot restart
Ctrl/Cmd + P           # Quick open
Ctrl/Cmd + Shift + P   # Command palette
F5                     # Start debugging
Shift + F5             # Stop debugging
```

## 🌟 Best Practices

✅ Always use `const` when possible
✅ Handle null safely
✅ Async/await for async operations
✅ Try-catch for error handling
✅ Meaningful variable names
✅ Comment complex logic
✅ Format code (Ctrl+Shift+I)
✅ Run analyzer before commit

## 🔗 Useful Links

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design](https://m3.material.io/)

---

**Keep this file handy for quick reference! 📌**
