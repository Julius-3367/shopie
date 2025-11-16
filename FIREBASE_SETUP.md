# Firebase Setup Guide for Shopie

This guide will help you configure Firebase for the Shopie budget tracking app.

## Prerequisites
- Firebase account (you already have this!)
- FlutterFire CLI installed (already done)

## Step-by-Step Setup

### 1. Create/Select Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Either:
   - **Create a new project**: Click "Add project" and follow the steps
   - **Use existing project**: Select your existing project

### 2. Enable Authentication

1. In your Firebase project, click on **"Authentication"** in the left sidebar
2. Click **"Get started"**
3. Go to the **"Sign-in method"** tab
4. Click on **"Email/Password"**
5. **Enable** the Email/Password provider
6. Click **"Save"**

### 3. Create Firestore Database

1. In your Firebase project, click on **"Firestore Database"** in the left sidebar
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll add security rules later)
4. Select your preferred location (choose closest to Kenya for best performance)
5. Click **"Enable"**

### 4. Configure Firebase for Flutter (IMPORTANT!)

Run this command in your terminal from the shopie directory:

```bash
cd /home/julius/shopie
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutterfire configure
```

This will:
- Connect to your Firebase account
- Let you select your project
- Generate the `firebase_options.dart` file with your actual credentials
- Configure Firebase for all platforms (Android, iOS, Web, Linux)

**Follow the prompts:**
1. Select your Firebase project from the list
2. Choose which platforms to support (select Linux for now, you can add others later)
3. The tool will automatically update `firebase_options.dart`

### 5. Security Rules for Firestore (Optional but Recommended)

To secure your data, update Firestore security rules:

1. Go to **Firestore Database** → **Rules** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions are user-specific
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
                          resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click **"Publish"**

### 6. Test the Setup

After running `flutterfire configure`, you can test the app:

```bash
cd /home/julius/shopie
~/flutter/bin/flutter run -d linux
```

The app should now:
- Show the login screen
- Allow you to create an account
- Sign in with email/password
- Access the main app after authentication

## Firestore Data Structure

The app will store data in this structure:

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile/
│       │   ├── displayName
│       │   ├── email
│       │   └── createdAt
│       └── transactions/
│           └── {transactionId}/
│               ├── title
│               ├── amount
│               ├── category
│               ├── date
│               ├── isIncome
│               └── note
```

## Troubleshooting

### "DefaultFirebaseOptions have not been configured"
- Run `flutterfire configure` command
- Make sure you select your Firebase project
- The tool will generate the correct configuration

### "Email/Password sign-in is not enabled"
- Go to Firebase Console → Authentication
- Enable Email/Password provider

### "Permission denied" errors
- Update Firestore security rules (see Step 5)
- Make sure users are authenticated

### Firebase CLI not found
- Add to PATH: `export PATH="$PATH":"$HOME/.pub-cache/bin"`
- Add to ~/.bashrc to make it permanent

## Next Steps

Once Firebase is configured:
1. The app will require users to sign up/login
2. Each user's transactions will be stored in Firestore
3. Data syncs across devices when logged in
4. Local Hive storage will be used as cache/backup

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
