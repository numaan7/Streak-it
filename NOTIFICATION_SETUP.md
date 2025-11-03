# Notification Setup Guide

This app uses `flutter_local_notifications` to send reminder notifications for habits. The notifications are already configured for web, but require additional setup for Android and iOS.

## 📱 Platform-Specific Setup

### Android Setup

1. **Update `android/app/src/main/AndroidManifest.xml`:**

Add these permissions before the `<application>` tag:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

Add these inside the `<application>` tag:

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

2. **Create notification icon:**
   - Place a notification icon at `android/app/src/main/res/drawable/ic_notification.png`
   - Recommended size: 48x48dp (white icon on transparent background)

### iOS Setup

1. **Update `ios/Runner/AppDelegate.swift`:**

```swift
import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

2. **Request notification permissions:**
   The app automatically requests notification permissions on startup.

## 🔔 How Notifications Work

1. **Setting Reminders:**
   - When creating or editing a habit, set a reminder time
   - The app schedules notifications based on the repeat schedule:
     - **Daily**: Notification every day at the specified time
     - **Specific Days**: Notifications only on selected weekdays
     - **No Repeat**: One-time notification

2. **Notification Management:**
   - Notifications are automatically scheduled when habits are created/updated
   - When a habit is deleted, its notifications are canceled
   - Notifications persist even after app restart (Android with BOOT_COMPLETED)

3. **Notification Content:**
   - Title: Habit emoji + habit name
   - Body: Motivational message
   - Color: Uses the habit's custom color (Android only)
   - Payload: Contains habit ID for future tap handling

## 🌐 Web Platform

Notifications on web require:
- HTTPS connection (production)
- User permission prompt
- Service worker for background notifications

Currently, the web platform has limited notification support. For full functionality, deploy to mobile platforms.

## 🧪 Testing Notifications

1. Create a habit with a reminder time
2. Set the time to 1-2 minutes in the future
3. Close or minimize the app
4. Wait for the notification to appear

## ⚠️ Known Limitations

- **Web**: Limited support, requires HTTPS
- **iOS Simulator**: Notifications may not work in simulator, test on real device
- **Battery Optimization**: Some Android devices may restrict background notifications
- **Timezone**: Uses device's local timezone

## 📦 Dependencies

```yaml
flutter_local_notifications: ^17.0.0
timezone: ^0.9.2
```

Both packages are already added to `pubspec.yaml` and installed.
