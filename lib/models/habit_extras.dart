class HabitCategory {
  final String name;
  final String emoji;
  final String description;

  const HabitCategory({
    required this.name,
    required this.emoji,
    required this.description,
  });

  static const List<HabitCategory> categories = [
    HabitCategory(
      name: 'Health & Fitness',
      emoji: '💪',
      description: 'Physical health and exercise',
    ),
    HabitCategory(
      name: 'Mindfulness',
      emoji: '🧘',
      description: 'Meditation and mental wellness',
    ),
    HabitCategory(
      name: 'Productivity',
      emoji: '📚',
      description: 'Work and learning habits',
    ),
    HabitCategory(
      name: 'Social',
      emoji: '👥',
      description: 'Relationships and connections',
    ),
    HabitCategory(
      name: 'Creativity',
      emoji: '🎨',
      description: 'Art and creative pursuits',
    ),
    HabitCategory(
      name: 'Finance',
      emoji: '💰',
      description: 'Money management',
    ),
    HabitCategory(
      name: 'Self-Care',
      emoji: '✨',
      description: 'Personal wellness',
    ),
    HabitCategory(
      name: 'Nutrition',
      emoji: '🥗',
      description: 'Diet and eating habits',
    ),
  ];

  static HabitCategory? getCategoryByName(String name) {
    try {
      return categories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredValue;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredValue,
    required this.type,
  });

  static const List<Achievement> achievements = [
    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'Getting Started',
      description: 'Complete a 3-day streak',
      emoji: '🔥',
      requiredValue: 3,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_7',
      title: 'One Week Warrior',
      description: 'Complete a 7-day streak',
      emoji: '⭐',
      requiredValue: 7,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Master',
      description: 'Complete a 30-day streak',
      emoji: '🏆',
      requiredValue: 30,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Century Club',
      description: 'Complete a 100-day streak',
      emoji: '💎',
      requiredValue: 100,
      type: AchievementType.streak,
    ),
    // Habit count achievements
    Achievement(
      id: 'habits_5',
      title: 'Habit Starter',
      description: 'Create 5 habits',
      emoji: '🌱',
      requiredValue: 5,
      type: AchievementType.habitCount,
    ),
    Achievement(
      id: 'habits_10',
      title: 'Habit Builder',
      description: 'Create 10 habits',
      emoji: '🌿',
      requiredValue: 10,
      type: AchievementType.habitCount,
    ),
    // Completion achievements
    Achievement(
      id: 'complete_50',
      title: 'Half Century',
      description: 'Complete 50 habits',
      emoji: '🎯',
      requiredValue: 50,
      type: AchievementType.totalCompletions,
    ),
    Achievement(
      id: 'complete_100',
      title: 'Centurion',
      description: 'Complete 100 habits',
      emoji: '🚀',
      requiredValue: 100,
      type: AchievementType.totalCompletions,
    ),
    Achievement(
      id: 'complete_365',
      title: 'Year Round',
      description: 'Complete 365 habits',
      emoji: '🌟',
      requiredValue: 365,
      type: AchievementType.totalCompletions,
    ),
    // Perfect day achievements
    Achievement(
      id: 'perfect_7',
      title: 'Perfect Week',
      description: 'Complete all habits for 7 days',
      emoji: '✨',
      requiredValue: 7,
      type: AchievementType.perfectDays,
    ),
  ];
}

enum AchievementType {
  streak,
  habitCount,
  totalCompletions,
  perfectDays,
}

class MotivationalQuote {
  final String text;
  final String author;

  const MotivationalQuote({
    required this.text,
    required this.author,
  });

  static const List<MotivationalQuote> quotes = [
    MotivationalQuote(
      text: 'The secret of getting ahead is getting started.',
      author: 'Mark Twain',
    ),
    MotivationalQuote(
      text: 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
      author: 'Aristotle',
    ),
    MotivationalQuote(
      text: 'Success is the sum of small efforts repeated day in and day out.',
      author: 'Robert Collier',
    ),
    MotivationalQuote(
      text: 'Don\'t watch the clock; do what it does. Keep going.',
      author: 'Sam Levenson',
    ),
    MotivationalQuote(
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
    ),
    MotivationalQuote(
      text: 'Believe you can and you\'re halfway there.',
      author: 'Theodore Roosevelt',
    ),
    MotivationalQuote(
      text: 'Small daily improvements are the key to staggering long-term results.',
      author: 'Unknown',
    ),
    MotivationalQuote(
      text: 'You don\'t have to be great to start, but you have to start to be great.',
      author: 'Zig Ziglar',
    ),
  ];

  static MotivationalQuote getRandom() {
    final now = DateTime.now();
    final index = now.day % quotes.length;
    return quotes[index];
  }
}
