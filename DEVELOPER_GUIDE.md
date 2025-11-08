# Developer Guide - Streak it

## 🏗️ Architecture Overview

### Design Pattern: Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────┐
│                  Presentation Layer              │
│  (Screens, Widgets, UI Components)              │
│  - home_screen.dart                             │
│  - add_habit_screen.dart                        │
│  - habit_detail_screen.dart                     │
│  - habit_card.dart                              │
│  - streak_stats_card.dart                       │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│              Business Logic Layer                │
│  (Providers, State Management)                  │
│  - habit_provider.dart                          │
│  - ChangeNotifier pattern                       │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│                  Data Layer                      │
│  (Models, Services, Storage)                    │
│  - habit.dart (model)                           │
│  - storage_service.dart                         │
│  - SharedPreferences                            │
└─────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
│   ├── MyApp (MaterialApp)
│   └── ChangeNotifierProvider setup
│
├── models/
│   └── habit.dart              # Core data model
│       ├── Habit class
│       ├── FrequencyType enum
│       ├── Streak calculations
│       ├── JSON serialization
│       └── Business logic methods
│
├── providers/
│   └── habit_provider.dart     # State management
│       ├── HabitProvider class
│       ├── CRUD operations
│       ├── State notifications
│       └── Computed properties
│
├── screens/
│   ├── home_screen.dart        # Main screen
│   │   ├── App header
│   │   ├── Stats card
│   │   ├── Habits list
│   │   └── FAB for adding habits
│   │
│   ├── add_habit_screen.dart   # Create habit
│   │   ├── Form validation
│   │   ├── Color picker
│   │   ├── Icon selector
│   │   └── Frequency options
│   │
│   └── habit_detail_screen.dart # Habit details
│       ├── Header with icon
│       ├── Statistics cards
│       ├── Activity calendar
│       ├── Weekly chart
│       └── Delete option
│
├── widgets/
│   ├── habit_card.dart         # Habit list item
│   │   ├── Icon & color
│   │   ├── Name & description
│   │   ├── Streak indicator
│   │   └── Check button
│   │
│   └── streak_stats_card.dart  # Dashboard stats
│       ├── Active streaks
│       ├── Total days
│       └── Today's progress
│
├── services/
│   └── storage_service.dart    # Data persistence
│       ├── Singleton pattern
│       ├── SharedPreferences wrapper
│       ├── JSON encoding/decoding
│       └── Error handling
│
└── utils/
    └── app_theme.dart          # Design system
        ├── AppColors
        ├── AppConstants
        ├── AppTheme
        └── Style definitions
```

## 🔄 Data Flow

### Creating a Habit
```
AddHabitScreen
    ↓ User inputs data
FormValidation
    ↓ Valid
Create Habit object
    ↓
HabitProvider.addHabit()
    ↓
Add to internal list
    ↓
StorageService.saveHabits()
    ↓
SharedPreferences (JSON)
    ↓
notifyListeners()
    ↓
UI updates automatically
```

### Toggling Habit Completion
```
HabitCard (check button tap)
    ↓
HabitProvider.toggleHabitCompletion(id)
    ↓
Find habit by id
    ↓
Check if completed today
    ↓
Add/Remove today's date
    ↓
Update habit with new dates
    ↓
StorageService.saveHabits()
    ↓
notifyListeners()
    ↓
UI updates (check mark, streak count)
```

## 🧩 Key Components

### 1. Habit Model

```dart
class Habit {
  // Properties
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final List<DateTime> completedDates;
  
  // Computed properties (getters)
  int get currentStreak { ... }
  int get longestStreak { ... }
  bool get isCompletedToday { ... }
  int get totalCompletions { ... }
  double get completionRate { ... }
  
  // Methods
  Map<String, dynamic> toJson() { ... }
  factory Habit.fromJson(Map<String, dynamic> json) { ... }
  Habit copyWith({...}) { ... }
}
```

**Key Logic:**
- `currentStreak`: Counts consecutive days from today backwards
- `longestStreak`: Finds maximum consecutive days in history
- `isCompletedToday`: Checks if today is in completedDates
- Normalizes dates to ignore time component

### 2. HabitProvider (State Management)

```dart
class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  
  // Public API
  List<Habit> get habits => _habits;
  Future<void> addHabit(Habit habit) { ... }
  Future<void> updateHabit(String id, Habit habit) { ... }
  Future<void> deleteHabit(String id) { ... }
  Future<void> toggleHabitCompletion(String id) { ... }
  
  // Computed properties
  List<Habit> get habitsSortedByStreak { ... }
  List<Habit> get activeHabits { ... }
  int get totalActiveStreaks { ... }
  double get todayCompletionRate { ... }
}
```

**Pattern:**
1. Modify internal state
2. Persist to storage
3. Call `notifyListeners()`
4. UI rebuilds automatically

### 3. StorageService (Persistence)

```dart
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;
  
  // Singleton pattern
  static Future<StorageService> getInstance() { ... }
  
  // Operations
  Future<bool> saveHabits(List<Habit> habits) { ... }
  Future<List<Habit>> loadHabits() { ... }
}
```

**Storage Format:**
```json
{
  "habits": [
    {
      "id": "1699123456789",
      "name": "Morning Meditation",
      "color": 4294198070,
      "icon": 58210,
      "completedDates": ["2024-11-01T00:00:00.000", ...],
      ...
    }
  ]
}
```

## 🎨 UI/UX Patterns

### Color System
```dart
AppColors.primary          // #6C5CE7 Purple
AppColors.secondary        // #A29BFE Light Purple
AppColors.background       // #0D0D0D Dark
AppColors.cardBackground   // #1A1A1A
AppColors.success          // #00D9A3 Green
AppColors.warning          // #FFA500 Orange
AppColors.error            // #FF4757 Red
```

### Spacing System
```dart
AppConstants.spacingXS     // 4.0
AppConstants.spacingS      // 8.0
AppConstants.spacingM      // 16.0
AppConstants.spacingL      // 24.0
AppConstants.spacingXL     // 32.0
```

### Border Radius
```dart
AppConstants.radiusS       // 8.0
AppConstants.radiusM       // 16.0
AppConstants.radiusL       // 24.0
AppConstants.radiusXL      // 32.0
```

## 🔧 Development Workflow

### Adding a New Feature

1. **Model Changes** (if needed)
   - Update `habit.dart` with new properties
   - Add to `toJson()` and `fromJson()`
   - Update `copyWith()` method

2. **Provider Updates**
   - Add new methods to `HabitProvider`
   - Handle state updates
   - Add `notifyListeners()`

3. **UI Implementation**
   - Create/modify screen or widget
   - Use `Consumer<HabitProvider>` or `context.watch()`
   - Handle loading states

4. **Testing**
   - Test with empty state
   - Test with data
   - Test edge cases

### Code Style

```dart
// ✅ Good
final habit = context.watch<HabitProvider>().habits.first;

// ✅ Good - read without listening
final provider = context.read<HabitProvider>();
provider.addHabit(newHabit);

// ❌ Avoid - can cause unnecessary rebuilds
final provider = Provider.of<HabitProvider>(context);
```

### Error Handling

```dart
try {
  await provider.addHabit(habit);
  // Success
} catch (e) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

## 🧪 Testing Approach

### Unit Tests
```dart
test('Habit calculates current streak correctly', () {
  final habit = Habit(
    completedDates: [
      DateTime(2024, 11, 6),
      DateTime(2024, 11, 5),
      DateTime(2024, 11, 4),
    ],
    // ...
  );
  
  expect(habit.currentStreak, 3);
});
```

### Widget Tests
```dart
testWidgets('HabitCard shows correct information', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HabitCard(habit: testHabit),
    ),
  );
  
  expect(find.text('Morning Meditation'), findsOneWidget);
  expect(find.byIcon(Icons.check), findsOneWidget);
});
```

## 🚀 Performance Optimization

### Best Practices

1. **Use const constructors**
   ```dart
   const SizedBox(height: 16)  // ✅
   SizedBox(height: 16)         // ❌
   ```

2. **Limit Provider scope**
   ```dart
   Consumer<HabitProvider>(
     builder: (context, provider, child) {
       // Only this rebuilds
       return Text('${provider.habits.length}');
     },
   )
   ```

3. **Use Selector for specific properties**
   ```dart
   Selector<HabitProvider, int>(
     selector: (context, provider) => provider.habits.length,
     builder: (context, count, child) {
       return Text('$count habits');
     },
   )
   ```

4. **Cache computed values**
   ```dart
   // In model
   int? _cachedStreak;
   int get currentStreak => _cachedStreak ??= _calculateStreak();
   ```

## 🐛 Common Issues & Solutions

### Issue: UI not updating after state change
**Solution:** Ensure `notifyListeners()` is called

### Issue: Date comparison failing
**Solution:** Normalize dates (remove time component)

### Issue: Data not persisting
**Solution:** Verify `saveHabits()` is called after modifications

### Issue: Performance lag with many habits
**Solution:** Use `ListView.builder` instead of `ListView`

## 📦 Dependencies Explained

```yaml
provider: ^6.1.1              # State management
shared_preferences: ^2.2.2     # Local storage
flutter_animate: ^4.5.0        # Animations
google_fonts: ^6.1.0           # Typography
fl_chart: ^0.66.0              # Charts/graphs
intl: ^0.19.0                  # Date formatting
```

## 🔄 State Management Flow

```
User Action
    ↓
Widget Event Handler
    ↓
Provider Method Call
    ↓
Update Internal State
    ↓
Persist to Storage
    ↓
notifyListeners()
    ↓
Consumer/Selector Rebuilds
    ↓
UI Updates
```

## 🎯 Future Architecture Improvements

1. **Repository Pattern**
   - Abstract storage layer
   - Easy to swap SharedPreferences for SQLite

2. **Dependency Injection**
   - Use GetIt or Injectable
   - Better testability

3. **BLoC Pattern** (Alternative)
   - More predictable state
   - Better for large apps

4. **Feature-based Structure**
   ```
   lib/
   ├── features/
   │   ├── habit_tracking/
   │   ├── statistics/
   │   └── settings/
   ```

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design](https://m3.material.io/)
- [Dart Language](https://dart.dev/)

## 🤝 Contributing Guidelines

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Follow existing code style
4. Add comments for complex logic
5. Test thoroughly
6. Submit pull request

---

**Happy coding! Build amazing features! 🚀**
