# Android Fixes Applied

This document describes all the fixes applied to make Firebase, Google Authentication, and Notifications work properly on Android.

## Issues Fixed

### 1. **Android Permissions** ✅
Added the following permissions to `android/app/src/main/AndroidManifest.xml`:
- `INTERNET` - Required for Firebase and Google Sign-In
- `RECEIVE_BOOT_COMPLETED` - Required to restart scheduled notifications after device reboot
- `VIBRATE` - For notification vibrations
- `USE_FULL_SCREEN_INTENT` - For full-screen notifications
- `SCHEDULE_EXACT_ALARM` - For exact alarm scheduling
- `POST_NOTIFICATIONS` - Required for Android 13+ (API 33+)
- `WAKE_LOCK` - To wake device for notifications

### 2. **Notification Receivers** ✅
Added notification broadcast receivers in AndroidManifest.xml:
- `ScheduledNotificationReceiver` - Handles scheduled notifications
- `ScheduledNotificationBootReceiver` - Restores notifications after device reboot

### 3. **Google Services Plugin** ✅
Added Google Services plugin to Gradle build files:
- Updated `android/build.gradle.kts` to include the Google Services classpath
- Updated `android/app/build.gradle.kts` to apply the Google Services plugin

### 4. **google-services.json** ✅
Created `android/app/google-services.json` with Firebase configuration for Android:
- Project ID: sample-c07f9
- Package name: com.example.streak_it
- API Key configured

**IMPORTANT**: If Google Sign-In still doesn't work, you need to:
1. Go to Firebase Console (https://console.firebase.google.com)
2. Select your project "sample-c07f9"
3. Add an Android app with package name: `com.example.streak_it`
4. Download the proper `google-services.json` file
5. Replace the file at `android/app/google-services.json`
6. In Firebase Console, enable Google Sign-In authentication method
7. Add your app's SHA-1 fingerprint (get it by running: `cd android && ./gradlew signingReport`)

### 5. **Notification Channels** ✅
Updated `MainActivity.kt` to create notification channels:
- `habit_reminders` channel - For regular habit reminders
- `morning_reminders` channel - For morning reminders when device is unlocked

### 6. **Activity Attributes** ✅
Added attributes to MainActivity in AndroidManifest.xml:
- `android:showWhenLocked="true"` - Show notification when screen is locked
- `android:turnScreenOn="true"` - Turn screen on for important notifications

## Files Modified

1. `/android/app/src/main/AndroidManifest.xml` - Added permissions and receivers
2. `/android/build.gradle.kts` - Added Google Services classpath
3. `/android/app/build.gradle.kts` - Applied Google Services plugin
4. `/android/app/google-services.json` - Created Firebase configuration
5. `/android/app/src/main/kotlin/com/example/streak_it/MainActivity.kt` - Added notification channels

## Testing the Fixed App

After installing the new APK:

1. **Firebase/Firestore Test**:
   - Sign in with Google
   - Create a habit
   - Check if it syncs to Firestore
   - Close and reopen app to see if habits persist

2. **Google Authentication Test**:
   - Tap "Sign in with Google"
   - Should show Google account picker
   - Should sign in successfully

3. **Notifications Test**:
   - Create a habit with a reminder time
   - Wait for the scheduled time
   - Should receive notification
   - For morning reminders, enable the option and test between 5 AM - 12 PM

4. **Boot Persistence Test**:
   - Create habits with reminders
   - Restart your device
   - Notifications should still work after reboot

## Troubleshooting

### Google Sign-In Not Working?
1. Check if you added the Android app in Firebase Console
2. Verify the package name is `com.example.streak_it`
3. Add SHA-1 fingerprint to Firebase Console
4. Download and replace `google-services.json` from Firebase Console
5. Rebuild the APK

### Notifications Not Showing?
1. Go to Android Settings → Apps → Streak it → Notifications
2. Ensure all notification permissions are enabled
3. Check if "Allow from other sources" is enabled for alarms
4. Some manufacturers (Xiaomi, Huawei) have aggressive battery optimization - disable it for this app

### Firebase Not Connecting?
1. Check internet connection
2. Verify `google-services.json` has correct configuration
3. Check Firebase Console that the Android app is properly configured
4. Look at Android Logcat for Firebase initialization errors

## Build Commands

To rebuild the app after making changes:

```bash
# Clean build
cd /workspaces/Streak-it
export PATH="$PATH:/workspaces/flutter/bin"
export ANDROID_HOME=/workspaces/android-sdk
flutter clean

# Build release APKs
flutter build apk --release --split-per-abi

# APKs will be at:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

## About Home Widgets

You mentioned home widgets not working - they haven't been implemented yet. To add home widgets:

1. Add `home_widget` package to `pubspec.yaml`
2. Create widget layouts in `android/app/src/main/res/layout/`
3. Create widget provider class
4. Update AndroidManifest.xml with widget receiver
5. Add Dart code to update widget data

Would you like me to implement home widgets as well?
