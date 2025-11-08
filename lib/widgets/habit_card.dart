import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: isCompleted 
                ? habit.color.withOpacity(0.5) 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              // Drag Handle
              Icon(
                Icons.drag_indicator,
                color: AppColors.textTertiary,
                size: 24,
              ),
              const SizedBox(width: AppConstants.spacingS),
              
              // Habit Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: habit.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  habit.icon,
                  color: habit.color,
                  size: AppConstants.iconL,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              
              // Habit Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        decoration: isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        color: isCompleted 
                            ? AppColors.textSecondary 
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: habit.currentStreak > 0 
                              ? AppColors.warning 
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: habit.currentStreak > 0 
                                ? AppColors.warning 
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${habit.totalCompletions} total',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Check Button
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? habit.color 
                        : habit.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.check,
                    color: isCompleted 
                        ? Colors.white 
                        : habit.color,
                    size: AppConstants.iconM,
                  ),
                )
                    .animate(
                      target: isCompleted ? 1 : 0,
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 200.ms,
                    ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, end: 0, duration: 300.ms);
  }
}
