import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/app_theme.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  late Color _selectedColor;
  late IconData _selectedIcon;
  late FrequencyType _selectedFrequency;
  String? _selectedCategory;
  TimeOfDay? _selectedTime;
  TimeSlot? _selectedTimeSlot;

  final List<IconData> _availableIcons = [
    Icons.favorite,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.local_drink,
    Icons.menu_book,
    Icons.directions_run,
    Icons.spa,
    Icons.nightlight,
    Icons.wb_sunny,
    Icons.restaurant,
    Icons.music_note,
    Icons.palette,
    Icons.code,
    Icons.camera_alt,
    Icons.savings,
    Icons.school,
    Icons.cleaning_services,
    Icons.pets,
    Icons.forest,
    Icons.water_drop,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _descriptionController = TextEditingController(text: widget.habit.description ?? '');
    _selectedColor = widget.habit.color;
    _selectedIcon = widget.habit.icon;
    _selectedFrequency = widget.habit.frequency;
    _selectedCategory = widget.habit.category;
    _selectedTime = widget.habit.reminderTime;
    _selectedTimeSlot = widget.habit.timeSlot;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final updatedHabit = widget.habit.copyWith(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        color: _selectedColor,
        icon: _selectedIcon,
        frequency: _selectedFrequency,
        category: _selectedCategory,
        reminderTime: _selectedTime,
        timeSlot: _selectedTimeSlot,
      );

      context.read<HabitProvider>().updateHabit(widget.habit.id, updatedHabit);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.cardBackground,
              hourMinuteTextColor: AppColors.textPrimary,
              dayPeriodTextColor: AppColors.textPrimary,
              dialHandColor: AppColors.primary,
              dialBackgroundColor: AppColors.cardBackgroundLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _selectedIcon,
                    color: _selectedColor,
                    size: 56,
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.spacingXL),

              // Habit Name
              Text(
                'Habit Name',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingS),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Morning Meditation',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(AppConstants.spacingM),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Description
              Text(
                'Description (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingS),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add some motivation...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(AppConstants.spacingM),
                ),
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Category Selection
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: const Text(
                      'Select a category',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: AppConstants.categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Time Slot Selection
              Text(
                'Recommended Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingS),
              Wrap(
                spacing: AppConstants.spacingM,
                children: [
                  _buildTimeSlotChip('Morning (5-9 AM)', TimeSlot.morning, Icons.wb_sunny),
                  _buildTimeSlotChip('Evening (9 PM-2 AM)', TimeSlot.evening, Icons.nightlight),
                  _buildTimeSlotChip('Anytime', TimeSlot.anytime, Icons.schedule),
                ],
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Reminder Time
              Text(
                'Reminder Time (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingS),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        color: _selectedTime != null 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Set reminder time',
                        style: TextStyle(
                          color: _selectedTime != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          color: AppColors.textSecondary,
                          onPressed: () => setState(() => _selectedTime = null),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Color Selection
              Text(
                'Choose Color',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Wrap(
                spacing: AppConstants.spacingM,
                runSpacing: AppConstants.spacingM,
                children: AppColors.habitColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Icon Selection
              Text(
                'Choose Icon',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Wrap(
                spacing: AppConstants.spacingM,
                runSpacing: AppConstants.spacingM,
                children: _availableIcons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.2)
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? _selectedColor 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected 
                            ? _selectedColor 
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Frequency Selection
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Wrap(
                spacing: AppConstants.spacingM,
                children: [
                  _buildFrequencyChip('Daily', FrequencyType.daily),
                  _buildFrequencyChip('Weekly', FrequencyType.weekly),
                  _buildFrequencyChip('Custom', FrequencyType.custom),
                ],
              ),

              const SizedBox(height: AppConstants.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotChip(String label, TimeSlot slot, IconData icon) {
    final isSelected = _selectedTimeSlot == slot;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedTimeSlot = selected ? slot : null);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFrequencyChip(String label, FrequencyType frequency) {
    final isSelected = _selectedFrequency == frequency;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFrequency = frequency);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }
}
