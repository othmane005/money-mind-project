
# Firebase Setup for MoneyMind

This document explains how to set up Firebase for the MoneyMind application.

## Prerequisites

- A Google account
- Flutter SDK installed
- Firebase CLI (optional, but recommended)

## Steps to Set Up Firebase

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter a project name (e.g., "MoneyMind")
4. Choose whether to enable Google Analytics (recommended)
5. Accept the terms and continue
6. Configure Google Analytics if you enabled it
7. Click "Create project"

### 2. Register Your App with Firebase

#### Android Setup

1. In the Firebase console, click the Android icon to add an Android app
2. Enter your app's package name (e.g., `com.example.money_mind`)
3. Enter a nickname for your app (optional)
4. Enter your app's SHA-1 key (optional for now, but required for some Firebase services)
5. Click "Register app"
6. Download the `google-services.json` file
7. Place the file in your Flutter project's `android/app` directory
8. Follow the instructions provided by Firebase to update your build files

#### iOS Setup

1. In the Firebase console, click the iOS icon to add an iOS app
2. Enter your app's bundle ID (found in Xcode under the General tab)
3. Enter a nickname for your app (optional)
4. Enter your App Store ID (optional)
5. Click "Register app"
6. Download the `GoogleService-Info.plist` file
7. In Xcode, right-click on the Runner folder and select "Add Files to Runner"
8. Select the downloaded `GoogleService-Info.plist` file
9. Make sure "Copy items if needed" is checked and click "Add"

### 3. Update Firebase Configuration in the App

1. Open the `lib/firebase_options.dart` file
2. Replace the placeholder values with the actual values from your Firebase project
   - These values can be found in your Firebase project settings

### 4. Set Up Firebase Firestore

1. In the Firebase console, go to "Firestore Database"
2. Click "Create database"
3. Choose either "Start in production mode" or "Start in test mode"
   - For development, "test mode" is easier as it allows all reads and writes
   - For production, you'll need to set up security rules
4. Select a location for your database (choose a location close to your users)
5. Click "Enable"

### 5. Configure Firestore Security Rules

For development (not recommended for production):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

For a more secure setup (recommended for production):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /transactions/{transactionId} {
      allow read, write: if true;  // In a real app, replace with authentication checks
    }
    match /categories/{categoryId} {
      allow read, write: if true;  // In a real app, replace with authentication checks
    }
  }
}
```

## Testing the Firebase Setup

1. Run the app in debug mode
2. The app should connect to Firebase and initialize correctly
3. Check the Firebase console to verify that data is being stored in Firestore

## Troubleshooting

- If you encounter any issues with Firebase setup, check the Flutter Firebase documentation for detailed troubleshooting steps.
- Make sure your package names and bundle IDs match exactly between your Flutter project and Firebase registration.
- Verify that the `google-services.json` and `GoogleService-Info.plist` files are in the correct locations.
