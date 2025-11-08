import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/streak_stats_card.dart';
import '../widgets/home_widgets.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppConstants.appTagline,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReportsScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                child: const Icon(
                                  Icons.bar_chart,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    // Motivational Quote
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Expanded(
                            child: Text(
                              AppConstants.motivationalQuotes[
                                DateTime.now().day % AppConstants.motivationalQuotes.length
                              ],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                ),
                child: const StreakStatsCard(),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacingL),
            ),

            // Daily Insight Widget
            const SliverToBoxAdapter(
              child: DailyInsightWidget(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacingL),
            ),

            // Time-based Suggestions
            const SliverToBoxAdapter(
              child: TimeBasedSuggestionsWidget(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacingM),
            ),

            // Quick Actions
            const SliverToBoxAdapter(
              child: QuickActionsWidget(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacingL),
            ),

            // Habits Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Habits',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Consumer<HabitProvider>(
                      builder: (context, provider, child) {
                        final completed = provider.habits
                            .where((h) => h.isCompletedToday)
                            .length;
                        final total = provider.habits.length;
                        
                        if (total == 0) return const SizedBox.shrink();
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$completed/$total',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: completed == total 
                                  ? AppColors.success 
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacingM),
            ),

            // Habits List
            Consumer<HabitProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (provider.habits.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 80,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppConstants.spacingM),
                          Text(
                            'No habits yet',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            'Start building your streak!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final activeHabits = provider.habits.where((h) => !h.isArchived).toList();

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                    ),
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeHabits.length,
                      onReorder: (oldIndex, newIndex) {
                        provider.reorderHabits(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final habit = activeHabits[index];
                        return Padding(
                          key: ValueKey(habit.id),
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spacingM,
                          ),
                          child: HabitCard(
                            habit: habit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HabitDetailScreen(
                                    habit: habit,
                                  ),
                                ),
                              );
                            },
                            onToggle: () {
                              provider.toggleHabitCompletion(habit.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHabitScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Habit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
