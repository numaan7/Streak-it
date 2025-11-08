import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import '../utils/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Insights'),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          final habits = provider.habits.where((h) => !h.isArchived).toList();
          
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 80,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data to show yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking habits to see your reports',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly Overview
                _buildSectionHeader(context, 'Weekly Overview'),
                const SizedBox(height: AppConstants.spacingM),
                _buildWeeklyChart(context, habits),
                
                const SizedBox(height: AppConstants.spacingXL),
                
                // Monthly Stats
                _buildSectionHeader(context, 'This Month'),
                const SizedBox(height: AppConstants.spacingM),
                _buildMonthlyStats(context, provider),
                
                const SizedBox(height: AppConstants.spacingXL),
                
                // Top Habits
                _buildSectionHeader(context, 'Top Performers'),
                const SizedBox(height: AppConstants.spacingM),
                _buildTopHabits(context, habits),
                
                const SizedBox(height: AppConstants.spacingXL),
                
                // Category Breakdown
                _buildSectionHeader(context, 'By Category'),
                const SizedBox(height: AppConstants.spacingM),
                _buildCategoryBreakdown(context, habits),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List habits) {
    final last7Days = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final completions = habits.fold<int>(0, (sum, habit) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final isCompleted = habit.completedDates.any((d) {
          final nd = DateTime(d.year, d.month, d.day);
          return nd == normalizedDate;
        });
        return sum + (isCompleted ? 1 : 0);
      });
      return completions;
    });

    return Container(
      height: 250,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: habits.length.toDouble() + 2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.cardBackgroundLight,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: last7Days[index].toDouble(),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(BuildContext context, HabitProvider provider) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    final habits = provider.habits.where((h) => !h.isArchived).toList();
    
    int totalCompletions = 0;
    int totalPossible = habits.length * now.day;
    
    for (var habit in habits) {
      totalCompletions += habit.completedDates.where((date) {
        return date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
               date.isBefore(now.add(const Duration(days: 1)));
      }).length;
    }
    
    final completionRate = totalPossible > 0 
        ? (totalCompletions / totalPossible * 100).toInt() 
        : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Completions',
            totalCompletions.toString(),
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildStatCard(
            context,
            'Completion Rate',
            '$completionRate%',
            Icons.trending_up,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTopHabits(BuildContext context, List habits) {
    final sortedHabits = List.from(habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    
    final topThree = sortedHabits.take(3).toList();

    return Column(
      children: topThree.asMap().entries.map((entry) {
        final index = entry.key;
        final habit = entry.value;
        final medals = ['🥇', '🥈', '🥉'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            children: [
              Text(
                medals[index],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: AppConstants.spacingM),
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
                    Text(
                      '${habit.currentStreak} day streak 🔥',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, List habits) {
    final categoryCount = <String, int>{};
    
    for (var habit in habits) {
      final category = habit.category ?? '🎯 Goals';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return Column(
      children: categoryCount.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.value}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
