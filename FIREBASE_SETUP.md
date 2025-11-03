# Firebase Setup Guide for Streak it

This guide will help you set up Firebase for your Streak it app to enable Google authentication and cloud sync.

## Prerequisites

- A Google account
- Flutter installed on your machine
- A web browser

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `streak-it` (or your preferred name)
4. Accept terms and click "Continue"
5. Enable/disable Google Analytics as per your preference
6. Click "Create project"

## Step 2: Register Your Web App

1. In your Firebase project, click the **Web** icon (`</>`) to add a web app
2. Register app name: `Streak it Web`
3. Check "Also set up Firebase Hosting" (optional)
4. Click "Register app"
5. Copy the Firebase configuration object

## Step 3: Configure Firebase in Your App

1. Copy `/lib/firebase_options.dart.example` to `/lib/firebase_options.dart`
2. Open `/lib/firebase_options.dart`
3. Replace the placeholder values with your Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_HERE',
  appId: 'YOUR_APP_ID_HERE',
  messagingSenderId: 'YOUR_SENDER_ID_HERE',
  projectId: 'YOUR_PROJECT_ID_HERE',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

## Step 4: Enable Authentication

1. In Firebase Console, go to **Build** > **Authentication**
2. Click "Get started"
3. Click on the **Sign-in method** tab
4. Enable **Google** sign-in provider:
   - Click on "Google"
   - Toggle "Enable"
   - Enter project support email
   - Click "Save"

## Step 5: Configure Google Sign-In for Web

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services** > **Credentials**
4. Find your OAuth 2.0 Client ID for Web
5. Add authorized JavaScript origins:
   - `http://localhost:8080`
   - `http://localhost:3000`
   - Your production domain
6. Add authorized redirect URIs:
   - `http://localhost:8080`
   - Your production domain

## Step 6: Set Up Cloud Firestore

1. In Firebase Console, go to **Build** > **Firestore Database**
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select your preferred location
5. Click "Enable"

### Security Rules (Important!)

After testing, update your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 7: Test Your Setup

1. Run your app:
   ```bash
   flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
   ```

2. Click "Sign in with Google"
3. Complete the authentication flow
4. Verify that your habits sync to Firestore:
   - Open Firebase Console > Firestore Database
   - You should see a `users` collection with your user ID
   - Your habits should appear under `users/{userId}/habits`

## Optional: Set Up for Mobile (Android/iOS)

### Android Setup

1. In Firebase Console, click "Add app" and select Android
2. Enter Android package name: `com.example.streak_it`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`
   - A template file `google-services.json.example` is provided for reference
5. Add your SHA-1 fingerprint (for Google Sign-In):
   ```bash
   cd android
   ./gradlew signingReport
   ```
6. Follow the Firebase setup instructions for Android

### iOS Setup

1. In Firebase Console, click "Add app" and select iOS
2. Enter iOS bundle ID (e.g., `com.example.streakIt`)
3. Download `GoogleService-Info.plist`
4. Add it to your Xcode project
5. Follow the Firebase setup instructions for iOS

## Troubleshooting

### "Firebase initialization error"
- Check that `firebase_options.dart` has the correct configuration
- Ensure all required Firebase packages are installed

### "Google sign-in failed"
- Verify that Google sign-in is enabled in Firebase Console
- Check that authorized domains are configured correctly
- Clear browser cache and try again

### "Permission denied" in Firestore
- Check your Firestore security rules
- Ensure the user is authenticated before accessing data

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules to production mode
- [ ] Add your production domain to authorized domains
- [ ] Set up proper error handling
- [ ] Enable App Check for additional security
- [ ] Configure backup and recovery
- [ ] Set up Firebase Analytics (optional)
- [ ] Review and optimize Firestore indexes

## Support

For more information, visit:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

---

Happy habit tracking! 🔥
