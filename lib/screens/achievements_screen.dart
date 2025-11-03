import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/habit_extras.dart';
import '../providers/habit_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          // Calculate achievement progress
          final maxStreak = provider.habits.fold<int>(
            0,
            (max, habit) => habit.longestStreak > max ? habit.longestStreak : max,
          );
          
          final totalCompletions = provider.habits.fold<int>(
            0,
            (sum, habit) => sum + habit.totalCompletions,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Your Achievements',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Keep building habits to unlock more badges!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 32),

                // Achievements Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: Achievement.achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = Achievement.achievements[index];
                    final isUnlocked = _isAchievementUnlocked(
                      achievement,
                      maxStreak,
                      provider.totalHabits,
                      totalCompletions,
                    );

                    return _buildAchievementCard(
                      context,
                      achievement,
                      isUnlocked,
                      index,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isAchievementUnlocked(
    Achievement achievement,
    int maxStreak,
    int habitCount,
    int totalCompletions,
  ) {
    switch (achievement.type) {
      case AchievementType.streak:
        return maxStreak >= achievement.requiredValue;
      case AchievementType.habitCount:
        return habitCount >= achievement.requiredValue;
      case AchievementType.totalCompletions:
        return totalCompletions >= achievement.requiredValue;
      case AchievementType.perfectDays:
        return false; // TODO: Implement perfect days tracking
    }
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
    bool isUnlocked,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isUnlocked ? null : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.white.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Description
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked
                  ? Colors.white.withOpacity(0.9)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (!isUnlocked) ...[
            const SizedBox(height: 8),
            Icon(
              Icons.lock,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(
      delay: (index * 50).ms,
      duration: 400.ms,
    ).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
