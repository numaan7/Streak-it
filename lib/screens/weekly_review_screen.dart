import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Review'),
        centerTitle: true,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = provider.habits;
          final weekData = _getWeekData(habits);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week header
                _buildWeekHeader(context),
                const SizedBox(height: 24),

                // Overall stats cards
                _buildStatsCards(context, weekData),
                const SizedBox(height: 24),

                // Weekly completion chart
                _buildWeeklyChart(context, weekData),
                const SizedBox(height: 24),

                // Habit breakdown
                _buildHabitBreakdown(context, habits, weekData),
                const SizedBox(height: 24),

                // Insights and patterns
                _buildInsights(context, weekData, habits),
                const SizedBox(height: 24),

                // Achievements this week
                _buildWeeklyAchievements(context, weekData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Week ${_getWeekNumber(now)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(endOfWeek)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Map<String, dynamic> weekData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle,
            label: 'Completed',
            value: '${weekData['totalCompleted']}',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.percent,
            label: 'Success Rate',
            value: '${weekData['successRate']}%',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department,
            label: 'Best Streak',
            value: '${weekData['bestStreak']}',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, Map<String, dynamic> weekData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Completion',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (weekData['dailyData'] as List)
                    .map((d) => d['total'] as int)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble() + 2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[value.toInt()],
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(context, weekData['dailyData']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    BuildContext context,
    List<Map<String, dynamic>> dailyData,
  ) {
    return List.generate(7, (index) {
      final data = dailyData[index];
      final completed = data['completed'] as int;
      final total = data['total'] as int;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: completed.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: (total - completed).toDouble(),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  Widget _buildHabitBreakdown(
    BuildContext context,
    List<Habit> habits,
    Map<String, dynamic> weekData,
  ) {
    final habitStats = weekData['habitStats'] as List<Map<String, dynamic>>;
    
    if (habitStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...habitStats.take(5).map((stat) {
            final habit = habits.firstWhere((h) => h.id == stat['habitId']);
            final completed = stat['completed'] as int;
            final total = stat['total'] as int;
            final percentage = total > 0 ? (completed / total * 100).round() : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(habit.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          habit.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(
                        '$completed/$total',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsights(
    BuildContext context,
    Map<String, dynamic> weekData,
    List<Habit> habits,
  ) {
    final insights = _generateInsights(weekData, habits);

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Insights & Patterns',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklyAchievements(BuildContext context, Map<String, dynamic> weekData) {
    final achievements = weekData['achievements'] as List<String>;

    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                'Achievements This Week',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...achievements.map((achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        achievement,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.orange.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Map<String, dynamic> _getWeekData(List<Habit> habits) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Initialize daily data for all 7 days
    final dailyData = List.generate(7, (index) {
      return {
        'completed': 0,
        'total': 0,
      };
    });

    int totalCompleted = 0;
    int totalPossible = 0;
    int bestStreak = 0;

    // Per-habit statistics
    final Map<String, Map<String, int>> habitStatsMap = {};

    for (final habit in habits) {
      habitStatsMap[habit.id] = {'completed': 0, 'total': 0};
      
      if (habit.currentStreak > bestStreak) {
        bestStreak = habit.currentStreak;
      }

      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final isScheduled = habit.isScheduledFor(date);
        
        if (isScheduled) {
          dailyData[i]['total'] = (dailyData[i]['total'] as int) + 1;
          habitStatsMap[habit.id]!['total'] = habitStatsMap[habit.id]!['total']! + 1;
          totalPossible++;

          if (habit.isCompletedOnDate(date)) {
            dailyData[i]['completed'] = (dailyData[i]['completed'] as int) + 1;
            habitStatsMap[habit.id]!['completed'] = habitStatsMap[habit.id]!['completed']! + 1;
            totalCompleted++;
          }
        }
      }
    }

    final successRate = totalPossible > 0
        ? ((totalCompleted / totalPossible) * 100).round()
        : 0;

    // Convert habit stats to list
    final habitStats = habitStatsMap.entries
        .map((e) => {
              'habitId': e.key,
              'completed': e.value['completed']!,
              'total': e.value['total']!,
            })
        .where((stat) => (stat['total'] as int) > 0)
        .toList()
      ..sort((a, b) {
        final aTotal = a['total'] as int;
        final aCompleted = a['completed'] as int;
        final bTotal = b['total'] as int;
        final bCompleted = b['completed'] as int;
        final aRate = aTotal > 0 ? aCompleted / aTotal : 0.0;
        final bRate = bTotal > 0 ? bCompleted / bTotal : 0.0;
        return bRate.compareTo(aRate);
      });

    return {
      'dailyData': dailyData,
      'totalCompleted': totalCompleted,
      'totalPossible': totalPossible,
      'successRate': successRate,
      'bestStreak': bestStreak,
      'habitStats': habitStats,
      'achievements': _getWeeklyAchievements(totalCompleted, successRate, habits),
    };
  }

  List<String> _generateInsights(Map<String, dynamic> weekData, List<Habit> habits) {
    final insights = <String>[];
    final successRate = weekData['successRate'] as int;
    final totalCompleted = weekData['totalCompleted'] as int;
    final dailyData = weekData['dailyData'] as List<Map<String, dynamic>>;

    // Success rate insights
    if (successRate >= 90) {
      insights.add('Amazing work! You\'re crushing it with a ${successRate}% success rate this week!');
    } else if (successRate >= 70) {
      insights.add('Great job! You\'re maintaining a strong ${successRate}% completion rate.');
    } else if (successRate >= 50) {
      insights.add('You\'re doing well at ${successRate}%. Small improvements each day add up!');
    } else if (successRate > 0) {
      insights.add('Keep going! Every habit completed is progress. Current rate: ${successRate}%');
    }

    // Find best day
    int bestDayIndex = 0;
    int bestDayCompleted = 0;
    for (int i = 0; i < dailyData.length; i++) {
      final completed = dailyData[i]['completed'] as int;
      if (completed > bestDayCompleted) {
        bestDayCompleted = completed;
        bestDayIndex = i;
      }
    }
    
    if (bestDayCompleted > 0) {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      insights.add('${days[bestDayIndex]} was your best day with $bestDayCompleted habits completed!');
    }

    // Total completed milestone
    if (totalCompleted >= 50) {
      insights.add('Incredible! You\'ve completed $totalCompleted habits this week!');
    } else if (totalCompleted >= 30) {
      insights.add('Impressive! $totalCompleted habits completed this week!');
    } else if (totalCompleted >= 15) {
      insights.add('Good progress with $totalCompleted habits completed!');
    }

    // Active habits count
    if (habits.length >= 5) {
      insights.add('You\'re managing ${habits.length} active habits. That\'s dedication!');
    }

    return insights;
  }

  List<String> _getWeeklyAchievements(int totalCompleted, int successRate, List<Habit> habits) {
    final achievements = <String>[];

    if (successRate == 100) {
      achievements.add('Perfect Week - 100% completion rate!');
    }
    if (successRate >= 90) {
      achievements.add('Consistency Champion - 90%+ success rate!');
    }
    if (totalCompleted >= 50) {
      achievements.add('Half Century - 50+ habits completed!');
    } else if (totalCompleted >= 30) {
      achievements.add('Thirty Strong - 30+ habits completed!');
    }
    
    final perfectHabits = habits.where((h) {
      // Check if completed every scheduled day this week
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      int completed = 0;
      int scheduled = 0;
      
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        if (h.isScheduledFor(date)) {
          scheduled++;
          if (h.isCompletedOnDate(date)) {
            completed++;
          }
        }
      }
      
      return scheduled > 0 && completed == scheduled;
    }).length;

    if (perfectHabits > 0) {
      achievements.add('$perfectHabits Perfect Habit${perfectHabits > 1 ? 's' : ''} this week!');
    }

    final longStreaks = habits.where((h) => h.currentStreak >= 7).length;
    if (longStreaks > 0) {
      achievements.add('$longStreaks Habit${longStreaks > 1 ? 's' : ''} with 7+ day streaks!');
    }

    return achievements;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }
}
