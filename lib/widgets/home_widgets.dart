import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/app_theme.dart';
import '../screens/habit_detail_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final activeHabits = provider.habits.where((h) => !h.isArchived).toList();
        final pendingToday = activeHabits.where((h) => !h.isCompletedToday).toList();

        if (pendingToday.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.15),
                AppColors.primary.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                '${pendingToday.length} habit${pendingToday.length > 1 ? 's' : ''} pending today',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.spacingS),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pendingToday.take(5).length,
                  itemBuilder: (context, index) {
                    final habit = pendingToday[index];
                    return GestureDetector(
                      onTap: () {
                        provider.toggleHabitCompletion(habit.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 60,
                        decoration: BoxDecoration(
                          color: habit.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: habit.color.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(habit.icon, color: habit.color, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              habit.name.length > 8 
                                  ? '${habit.name.substring(0, 7)}...' 
                                  : habit.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TimeBasedSuggestionsWidget extends StatelessWidget {
  const TimeBasedSuggestionsWidget({super.key});

  bool _isTimeInSlot(TimeSlot slot) {
    final now = DateTime.now();
    final hour = now.hour;

    switch (slot) {
      case TimeSlot.morning:
        return hour >= 5 && hour < 9;
      case TimeSlot.evening:
        return hour >= 21 || hour < 2;
      case TimeSlot.anytime:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final activeHabits = provider.habits.where((h) => !h.isArchived).toList();
        final suggestedHabits = activeHabits.where((h) {
          if (h.isCompletedToday) return false;
          if (h.timeSlot == null) return false;
          return _isTimeInSlot(h.timeSlot!);
        }).toList();

        if (suggestedHabits.isEmpty) {
          return const SizedBox.shrink();
        }

        String getTitle() {
          final now = DateTime.now();
          final hour = now.hour;
          if (hour >= 5 && hour < 9) return 'Good Morning! ☀️';
          if (hour >= 21 || hour < 2) return 'Good Evening! 🌙';
          return 'Suggested Habits';
        }

        return Container(
          margin: const EdgeInsets.all(AppConstants.spacingL),
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getTitle(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Perfect time for these habits:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.spacingM),
              ...suggestedHabits.map((habit) => _buildSuggestionCard(
                context,
                habit,
                provider,
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestionCard(BuildContext context, Habit habit, HabitProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: InkWell(
          onTap: () {
            provider.toggleHabitCompletion(habit.id);
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 24),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (habit.reminderTime != null)
                        Text(
                          '⏰ ${habit.reminderTime!.format(context)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check,
                    color: habit.color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DailyInsightWidget extends StatelessWidget {
  const DailyInsightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final activeHabits = provider.habits.where((h) => !h.isArchived).toList();
        if (activeHabits.isEmpty) return const SizedBox.shrink();

        final completedToday = activeHabits.where((h) => h.isCompletedToday).length;
        final totalStreaks = provider.totalActiveStreaks;
        final bestStreak = activeHabits.isEmpty 
            ? 0 
            : activeHabits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withOpacity(0.15),
                AppColors.error.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(context, '✅', completedToday.toString(), 'Done Today'),
              Container(width: 1, height: 40, color: AppColors.cardBackgroundLight),
              _buildStat(context, '🔥', totalStreaks.toString(), 'Total Days'),
              Container(width: 1, height: 40, color: AppColors.cardBackgroundLight),
              _buildStat(context, '🏆', bestStreak.toString(), 'Best Streak'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
