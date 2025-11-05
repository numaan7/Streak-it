import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/habit_extras.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  String _selectedEmoji = '🎯';
  Color _selectedColor = const Color(0xFF6366F1);
  String? _selectedCategory;
  String _repeatOption = 'daily'; // daily, specific_days, no_repeat
  List<int> _selectedDays = []; // 1=Monday to 7=Sunday
  TimeOfDay? _reminderTime;
  bool _showMorningReminder = false; // Morning reminder on phone unlock
  
  final List<String> _emojis = [
    '🎯', '💪', '📚', '🏃', '🧘', '💧', '🥗', '😴',
    '✍️', '🎨', '🎵', '💻', '🌱', '🔥', '⭐', '🌟',
    '💎', '🚀', '🎮', '📱', '☕', '🍎', '🏋️', '🧠',
  ];
  
  final List<Color> _colors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFF97316), // Orange
    const Color(0xFF06B6D4), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descriptionController = TextEditingController(text: widget.habit?.description ?? '');
    
    if (widget.habit != null) {
      _selectedEmoji = widget.habit!.emoji;
      _selectedColor = widget.habit!.color;
      _selectedCategory = widget.habit!.category;
      _repeatOption = widget.habit!.frequency;
      _selectedDays = widget.habit!.specificDays ?? [];
      _reminderTime = widget.habit!.reminderTime;
      _showMorningReminder = widget.habit!.showMorningReminder;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji Selection
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Emoji Grid
              Text(
                'Choose an emoji',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _emojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojis[index];
                    final isSelected = emoji == _selectedEmoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = emoji),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Color Selection
              Text(
                'Choose a color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Habit Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Morning Workout',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'What motivates you?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Choose a category (optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitCategory.categories.map((category) {
                  final isSelected = _selectedCategory == category.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = isSelected ? null : category.name;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.2)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Repeat Options
              Text(
                'Repeat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Daily'),
                      subtitle: const Text('Repeat every day'),
                      value: 'daily',
                      groupValue: _repeatOption,
                      onChanged: (value) {
                        setState(() => _repeatOption = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Specific Days'),
                      subtitle: const Text('Choose which days to repeat'),
                      value: 'specific_days',
                      groupValue: _repeatOption,
                      onChanged: (value) {
                        setState(() => _repeatOption = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('No Repeat'),
                      subtitle: const Text('One-time task'),
                      value: 'no_repeat',
                      groupValue: _repeatOption,
                      onChanged: (value) {
                        setState(() => _repeatOption = value!);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Specific Days Selection
              if (_repeatOption == 'specific_days') ...[
                Text(
                  'Select Days',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDayChip('Mon', 1),
                    _buildDayChip('Tue', 2),
                    _buildDayChip('Wed', 3),
                    _buildDayChip('Thu', 4),
                    _buildDayChip('Fri', 5),
                    _buildDayChip('Sat', 6),
                    _buildDayChip('Sun', 7),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Reminder Time
              Text(
                'Reminder Time (optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(Icons.access_time, color: _selectedColor),
                title: Text(
                  _reminderTime != null
                      ? _reminderTime!.format(context)
                      : 'Set reminder time',
                ),
                trailing: _reminderTime != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _reminderTime = null);
                        },
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _pickReminderTime,
              ),
              const SizedBox(height: 24),

              // Advanced Options Header
              Text(
                'Advanced Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Morning Reminder Option
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Morning Reminder'),
                  subtitle: const Text(
                    'Get notified when you unlock your phone in the morning (5 AM - 12 PM)',
                  ),
                  secondary: Icon(
                    Icons.wb_sunny,
                    color: _showMorningReminder ? Colors.orange : null,
                  ),
                  value: _showMorningReminder,
                  onChanged: (value) {
                    setState(() => _showMorningReminder = value);
                  },
                  activeColor: _selectedColor,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Habit' : 'Create Habit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, int dayNumber) {
    final isSelected = _selectedDays.contains(dayNumber);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(dayNumber);
            _selectedDays.sort();
          } else {
            _selectedDays.remove(dayNumber);
          }
        });
      },
      selectedColor: _selectedColor.withOpacity(0.3),
      checkmarkColor: _selectedColor,
    );
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      // Validate specific days selection
      if (_repeatOption == 'specific_days' && _selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<HabitProvider>(context, listen: false);
      
      if (widget.habit != null) {
        // Update existing habit
        final updatedHabit = widget.habit!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          emoji: _selectedEmoji,
          color: _selectedColor,
          category: _selectedCategory,
          frequency: _repeatOption,
          specificDays: _repeatOption == 'specific_days' ? _selectedDays : null,
          reminderTime: _reminderTime,
          showMorningReminder: _showMorningReminder,
        );
        await provider.updateHabit(updatedHabit);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit updated successfully!')),
          );
        }
      } else {
        // Create new habit
        final newHabit = Habit(
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          emoji: _selectedEmoji,
          color: _selectedColor,
          category: _selectedCategory,
          frequency: _repeatOption,
          specificDays: _repeatOption == 'specific_days' ? _selectedDays : null,
          reminderTime: _reminderTime,
          showMorningReminder: _showMorningReminder,
        );
        await provider.addHabit(newHabit);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit added successfully!')),
          );
        }
      }
      
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
