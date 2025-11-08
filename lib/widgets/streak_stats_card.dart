import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/app_theme.dart';

class StreakStatsCard extends StatelessWidget {
  const StreakStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final activeStreaks = provider.activeHabits.length;
        final totalStreakDays = provider.totalActiveStreaks;
        final completionRate = provider.todayCompletionRate;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.whatshot,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      'Your Momentum',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingL),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      label: 'Active Streaks',
                      value: activeStreaks.toString(),
                      icon: Icons.trending_up,
                    ),
                    _StatItem(
                      label: 'Total Days',
                      value: totalStreakDays.toString(),
                      icon: Icons.calendar_today,
                    ),
                    _StatItem(
                      label: 'Today',
                      value: '${completionRate.toStringAsFixed(0)}%',
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
