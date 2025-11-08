import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/app_theme.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: habit),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(habit.isArchived ? Icons.unarchive : Icons.archive_outlined),
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false)
                  .toggleArchiveHabit(habit.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    habit.isArchived 
                        ? 'Habit unarchived' 
                        : 'Habit archived',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    habit.color,
                    habit.color.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      ),
                      child: Icon(
                        habit.icon,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (habit.description != null) ...[
                      const SizedBox(height: AppConstants.spacingS),
                      Text(
                        habit.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingL),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Current Streak',
                      value: '${habit.currentStreak}',
                      subtitle: 'days',
                      icon: Icons.local_fire_department,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: _StatCard(
                      title: 'Longest Streak',
                      value: '${habit.longestStreak}',
                      subtitle: 'days',
                      icon: Icons.emoji_events,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingM),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total',
                      value: '${habit.totalCompletions}',
                      subtitle: 'completions',
                      icon: Icons.check_circle,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: _StatCard(
                      title: 'Success Rate',
                      value: '${habit.completionRate.toStringAsFixed(0)}%',
                      subtitle: 'last 30 days',
                      icon: Icons.trending_up,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingL),

            // Activity Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _ActivityCalendar(habit: habit),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingL),

            // Weekly Chart
            if (habit.completedDates.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 Days',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    _WeeklyChart(habit: habit),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingL),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Habit', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to delete this habit? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitProvider>().deleteHabit(habit.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ActivityCalendar extends StatelessWidget {
  final Habit habit;

  const _ActivityCalendar({required this.habit});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daysToShow = 42; // 6 weeks
    final startDate = today.subtract(Duration(days: daysToShow - 1));

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: daysToShow,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final isCompleted = habit.completedDates.any((d) =>
              DateTime(d.year, d.month, d.day) == normalizedDate);
          final isToday = normalizedDate == DateTime(today.year, today.month, today.day);

          return Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? habit.color.withOpacity(0.8)
                  : AppColors.cardBackgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isCompleted ? Colors.white : AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Habit habit;

  const _WeeklyChart({required this.habit});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final isCompleted = habit.completedDates.any((d) =>
          DateTime(d.year, d.month, d.day) == normalizedDate);
      spots.add(FlSpot((6 - i).toDouble(), isCompleted ? 1 : 0));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = today.subtract(Duration(days: 6 - value.toInt()));
                  return Text(
                    DateFormat('E').format(date),
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: habit.color,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: habit.color,
                    strokeWidth: 2,
                    strokeColor: AppColors.cardBackground,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: habit.color.withOpacity(0.2),
              ),
            ),
          ],
          minY: 0,
          maxY: 1,
        ),
      ),
    );
  }
}
