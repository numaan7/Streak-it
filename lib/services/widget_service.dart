import 'package:home_widget/home_widget.dart';
import '../models/habit.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  // Update widget with current habits data
  Future<void> updateWidget(List<Habit> habits) async {
    try {
      // Get today's date normalized
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      // Filter active habits (not archived)
      final activeHabits = habits.where((h) => !h.isArchived).take(3).toList();

      // Calculate total streak (longest current streak)
      int maxStreak = 0;
      for (var habit in activeHabits) {
        if (habit.currentStreak > maxStreak) {
          maxStreak = habit.currentStreak;
        }
      }

      // Save streak count
      await HomeWidget.saveWidgetData('streak_count', maxStreak);

      // Update habit 1
      if (activeHabits.isNotEmpty) {
        final habit1 = activeHabits[0];
        final isDone = habit1.completedDates.any((date) {
          final normalized = DateTime(date.year, date.month, date.day);
          return normalized == normalizedToday;
        });

        await HomeWidget.saveWidgetData('habit_1_name', habit1.name);
        await HomeWidget.saveWidgetData('habit_1_icon', _getHabitEmoji(habit1));
        await HomeWidget.saveWidgetData('habit_1_done', isDone);
      } else {
        await HomeWidget.saveWidgetData('habit_1_name', 'Add your first habit');
        await HomeWidget.saveWidgetData('habit_1_icon', '✨');
        await HomeWidget.saveWidgetData('habit_1_done', false);
      }

      // Update habit 2
      if (activeHabits.length > 1) {
        final habit2 = activeHabits[1];
        final isDone = habit2.completedDates.any((date) {
          final normalized = DateTime(date.year, date.month, date.day);
          return normalized == normalizedToday;
        });

        await HomeWidget.saveWidgetData('habit_2_name', habit2.name);
        await HomeWidget.saveWidgetData('habit_2_icon', _getHabitEmoji(habit2));
        await HomeWidget.saveWidgetData('habit_2_done', isDone);
      } else {
        await HomeWidget.saveWidgetData('habit_2_name', '');
      }

      // Update habit 3
      if (activeHabits.length > 2) {
        final habit3 = activeHabits[2];
        final isDone = habit3.completedDates.any((date) {
          final normalized = DateTime(date.year, date.month, date.day);
          return normalized == normalizedToday;
        });

        await HomeWidget.saveWidgetData('habit_3_name', habit3.name);
        await HomeWidget.saveWidgetData('habit_3_icon', _getHabitEmoji(habit3));
        await HomeWidget.saveWidgetData('habit_3_done', isDone);
      } else {
        await HomeWidget.saveWidgetData('habit_3_name', '');
      }

      // Update the widget
      await HomeWidget.updateWidget(
        name: 'StreakWidgetProvider',
        androidName: 'StreakWidgetProvider',
      );
    } catch (e) {
      print('Widget update error: $e');
    }
  }

  String _getHabitEmoji(Habit habit) {
    // Map icon to emoji
    final iconMap = {
      'favorite': '❤️',
      'fitness_center': '💪',
      'self_improvement': '🧘',
      'local_drink': '💧',
      'menu_book': '📚',
      'directions_run': '🏃',
      'spa': '🌸',
      'nightlight': '🌙',
      'wb_sunny': '☀️',
      'restaurant': '🍽️',
      'music_note': '🎵',
      'palette': '🎨',
      'code': '💻',
      'camera_alt': '📷',
      'savings': '💰',
      'school': '🎓',
      'cleaning_services': '🧹',
      'pets': '🐾',
      'forest': '🌲',
      'water_drop': '💧',
    };
    return iconMap[habit.icon.toString()] ?? '🔥';
  }
}
