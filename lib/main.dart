import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style immediately
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize storage service (fast)
  final storageService = await StorageService.getInstance();

  runApp(MyApp(storageService: storageService));
  
  // Initialize notifications in background after app starts
  _initializeNotificationsInBackground();
}

void _initializeNotificationsInBackground() async {
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
    
    // Set up notification action callbacks
    NotificationService.onCompleteFromNotification = (habitId) {
      debugPrint('Complete habit from notification: $habitId');
      // This will be handled by the provider when app is running
    };
    
    NotificationService.onSnoozeFromNotification = (habitId, minutes) {
      debugPrint('Snooze habit $habitId for $minutes minutes');
      // This will be handled by the provider when app is running
    };
    
    NotificationService.onOpenHabitFromNotification = (habitId) {
      debugPrint('Open habit from notification: $habitId');
      // Navigate to habit details when app opens
    };
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }
}

class MyApp extends StatefulWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late HabitProvider _habitProvider;

  @override
  void initState() {
    super.initState();
    _habitProvider = HabitProvider(widget.storageService);
    _setupNotificationCallbacks();
  }

  void _setupNotificationCallbacks() {
    // Wire up notification callbacks to provider
    NotificationService.onCompleteFromNotification = (habitId) {
      debugPrint('Complete habit from notification: $habitId');
      _habitProvider.completeHabitFromNotification(habitId);
    };
    
    NotificationService.onSnoozeFromNotification = (habitId, minutes) {
      debugPrint('Snooze habit $habitId for $minutes minutes');
      _habitProvider.snoozeHabitNotification(habitId, minutes);
    };
    
    NotificationService.onOpenHabitFromNotification = (habitId) {
      debugPrint('Open habit from notification: $habitId');
      // App will open to home screen, user can see the habit there
    };
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _habitProvider,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppLoader(),
      ),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    // Load habits in background
    final provider = Provider.of<HabitProvider>(context, listen: false);
    
    // Minimum splash time for smooth UX
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 800)),
      provider.loadHabits(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    return const HomeScreen();
  }
}
