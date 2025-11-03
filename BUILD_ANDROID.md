# Building Android APK for Streak it

Due to memory constraints in the codespace environment, it's recommended to build the Android APK on your local machine. Here's how:

## Prerequisites

1. **Flutter SDK** installed on your machine
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Android Studio** or Android SDK
   - Download Android Studio from: https://developer.android.com/studio
   - Or install command-line tools only

3. **Java JDK 11 or higher**
   - Verify with: `java -version`

## Build Steps

### 1. Clone the Repository

```bash
git clone https://github.com/numaan7/Streak-it.git
cd Streak-it
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Build the APK

#### Option A: Build Single APK (Universal - works on all devices)
```bash
flutter build apk --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```
**Size**: ~35-45 MB

#### Option B: Build Split APKs (Smaller size per architecture)
```bash
flutter build apk --release --split-per-abi
```

This creates 3 separate APKs (one for each architecture):
```
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  (~20 MB)
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    (~25 MB)
build/app/outputs/flutter-apk/app-x86_64-release.apk       (~28 MB)
```

**Recommended**: Use `app-arm64-v8a-release.apk` for most modern devices.

#### Option C: Build App Bundle (For Play Store)
```bash
flutter build appbundle --release
```

The AAB will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

### 4. Sign the APK (Optional - for production)

#### Generate a Keystore
```bash
keytool -genkey -v -keystore ~/streak-it-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias streak-it
```

#### Update android/app/build.gradle.kts

Add before `android {`:
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Update the `buildTypes`:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}

signingConfigs {
    create("release") {
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
    }
}
```

#### Create android/key.properties
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=streak-it
storeFile=/path/to/streak-it-key.jks
```

Then build:
```bash
flutter build apk --release
```

## Configuration Already Applied

The following configurations have already been set up in the project:

✅ **Core Library Desugaring** enabled (required for `flutter_local_notifications`)
✅ **Gradle memory settings** optimized
✅ **Firebase configuration** included
✅ **App permissions** configured in AndroidManifest.xml

## Install APK on Device

### Via USB:
```bash
flutter install
# or
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via File Transfer:
1. Copy the APK to your phone
2. Open the APK file
3. Allow installation from unknown sources if prompted
4. Install

## Troubleshooting

### Build Fails with Memory Error
Adjust memory in `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4G
```

### Missing Android SDK
Set ANDROID_HOME environment variable:
```bash
export ANDROID_HOME=/path/to/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### Flutter Not Found
Add Flutter to PATH:
```bash
export PATH=$PATH:/path/to/flutter/bin
```

## App Features

The built APK includes all features:
- ✅ Habit tracking with streaks
- ✅ Firebase authentication (Google Sign-In)
- ✅ Cloud Firestore sync
- ✅ Local notifications
- ✅ Morning reminders
- ✅ Weekly review
- ✅ Achievements system
- ✅ Statistics and charts
- ✅ Dark mode support

## APK Details

- **Package Name**: com.example.streak_it
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 33 (Android 13)
- **Permissions**:
  - Internet (for Firebase)
  - Notifications (for reminders)
  - Boot completed (for persistent reminders)
  - Exact alarms (for precise notifications)

## Next Steps

After building, you can:
1. Install on your Android device for testing
2. Submit to Google Play Store (use App Bundle)
3. Distribute directly via APK file

## Support

For issues or questions:
- Repository: https://github.com/numaan7/Streak-it
- Flutter docs: https://flutter.dev/docs
