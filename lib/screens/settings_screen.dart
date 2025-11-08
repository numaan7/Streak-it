import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        children: [
          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          const SizedBox(height: AppConstants.spacingM),
          _buildSettingCard(
            context,
            'Export Data',
            'Download your habits as JSON',
            Icons.download,
            AppColors.success,
            () => _exportData(context),
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildSettingCard(
            context,
            'Import Data',
            'Restore from backup',
            Icons.upload,
            AppColors.primary,
            () => _importData(context),
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildSettingCard(
            context,
            'Clear All Data',
            'Delete all habits (cannot be undone)',
            Icons.delete_forever,
            AppColors.error,
            () => _clearData(context),
          ),
          
          const SizedBox(height: AppConstants.spacingXL),
          
          // Archive Section
          _buildSectionHeader(context, 'Archive'),
          const SizedBox(height: AppConstants.spacingM),
          _buildSettingCard(
            context,
            'Archived Habits',
            'View completed or paused habits',
            Icons.archive,
            AppColors.warning,
            () => _viewArchived(context),
          ),
          
          const SizedBox(height: AppConstants.spacingXL),
          
          // About Section
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: AppConstants.spacingM),
          _buildInfoCard(context, 'Version', '1.0.0'),
          const SizedBox(height: AppConstants.spacingM),
          _buildInfoCard(context, 'App Name', AppConstants.appName),
          const SizedBox(height: AppConstants.spacingM),
          _buildInfoCard(context, 'Tagline', AppConstants.appTagline),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final habits = provider.habits;
    
    final jsonData = jsonEncode({
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
    });

    await Clipboard.setData(ClipboardData(text: jsonData));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data copied to clipboard! Save it to a file.'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _importData(BuildContext context) async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    
    if (clipboard?.text == null || clipboard!.text!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clipboard is empty. Copy your backup data first.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      final jsonData = jsonDecode(clipboard.text!);
      final provider = Provider.of<HabitProvider>(context, listen: false);
      
      // Show confirmation dialog
      if (context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Data'),
            content: const Text(
              'This will replace all your current habits. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Import'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          // Import the data
          final habitsList = (jsonData['habits'] as List)
              .map((h) => Habit.fromJson(h as Map<String, dynamic>))
              .toList();
          
          // This is a simplified version - you'd need to implement proper import in provider
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import functionality requires provider update'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid backup data format'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _clearData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your habits and progress. This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final provider = Provider.of<HabitProvider>(context, listen: false);
      final habitsToDelete = List.from(provider.habits);
      
      for (var habit in habitsToDelete) {
        provider.deleteHabit(habit.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _viewArchived(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final archivedHabits = provider.habits.where((h) => h.isArchived).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Archived Habits',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: archivedHabits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.archive_outlined,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No archived habits',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppConstants.spacingL),
                      itemCount: archivedHabits.length,
                      itemBuilder: (context, index) {
                        final habit = archivedHabits[index];
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.spacingM,
                          ),
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusM,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: habit.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  habit.icon,
                                  color: habit.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                      'Archived ${_formatDate(habit.archivedAt)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${(difference / 30).floor()} months ago';
  }
}
