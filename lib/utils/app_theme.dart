import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFFA29BFE);
  
  // Background Colors
  static const Color background = Color(0xFF0D0D0D);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color cardBackgroundLight = Color(0xFF252525);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);
  
  // Accent Colors
  static const Color success = Color(0xFF00D9A3);
  static const Color warning = Color(0xFFFFA500);
  static const Color error = Color(0xFFFF4757);
  
  // Habit Colors
  static const List<Color> habitColors = [
    Color(0xFFFF6B9D), // Pink
    Color(0xFFC44569), // Deep Rose
    Color(0xFFFF7F50), // Coral
    Color(0xFFFFA502), // Orange
    Color(0xFFFFC048), // Yellow
    Color(0xFF26E7A6), // Mint
    Color(0xFF0ABDE3), // Cyan
    Color(0xFF4834DF), // Purple
    Color(0xFF5F27CD), // Deep Purple
    Color(0xFF341F97), // Dark Purple
    Color(0xFF3C40C6), // Blue
    Color(0xFF00B8D4), // Light Blue
  ];

  static Color getHabitColor(int index) {
    return habitColors[index % habitColors.length];
  }
}

class AppConstants {
  static const String appName = 'Streak it';
  static const String appTagline = 'Vibe check your habits';
  
  // Habit Categories
  static const List<String> categories = [
    '💪 Health & Fitness',
    '🧠 Mindfulness',
    '📚 Learning',
    '💼 Productivity',
    '🎨 Creativity',
    '🤝 Social',
    '💰 Finance',
    '🏠 Lifestyle',
    '🌱 Personal Growth',
    '🎯 Goals',
  ];
  
  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    "Small steps every day lead to big changes! 🚀",
    "You're building something amazing, keep going! ✨",
    "Consistency is the key to success! 🔑",
    "Every streak starts with day one! 🌟",
    "Your future self will thank you! 💪",
    "Progress, not perfection! 🎯",
    "One day at a time, you've got this! 🔥",
    "Building habits, building character! 💎",
    "Stay committed to your growth! 🌱",
    "The best time to start was yesterday. The next best time is now! ⏰",
    "Your dedication is inspiring! 🌈",
    "Keep the momentum going! 🎉",
    "Success is the sum of small efforts! ⭐",
    "You're stronger than you think! 💪",
    "Believe in the power of consistency! 🌊",
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  
  // Icon Sizes
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.cardBackground,
      background: AppColors.background,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12,
      ),
    ),
  );
}
