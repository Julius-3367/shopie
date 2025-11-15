# 🚀 Setup and Run Guide - Shopie

## Current Issue

Your Flutter installation appears to be incomplete. The Flutter SDK is located at:
```
/mnt/c/flutter_windows_3.32.6-stable/flutter/
```

However, the Dart SDK binaries are missing from the cache directory.

---

## ✅ Solution Options

### Option 1: Fix Flutter Installation (Recommended)

Since you're using WSL (Windows Subsystem for Linux), you have two choices:

#### A. Use Flutter in Windows
1. **Open Windows Command Prompt or PowerShell** (not WSL)
2. Navigate to your project:
   ```cmd
   cd C:\path\to\your\shopie\folder
   ```
3. Run Flutter commands from Windows:
   ```cmd
   flutter doctor
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter run
   ```

#### B. Install Flutter Natively in WSL/Linux
1. **Remove the Windows Flutter reference** and install Flutter for Linux:
   ```bash
   # Download Flutter for Linux
   cd ~
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
   
   # Extract
   tar xf flutter_linux_3.24.0-stable.tar.xz
   
   # Add to PATH (add this to ~/.bashrc)
   echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   
   # Verify installation
   flutter doctor
   ```

2. **Install dependencies**:
   ```bash
   sudo apt-get update
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

---

## 📱 Running Shopie App

### Step 1: Install Dependencies
```bash
cd /home/julius/shopie
flutter pub get
```

### Step 2: Generate Hive Type Adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate the `transaction.g.dart` file needed for Hive database.

### Step 3: Check Available Devices
```bash
flutter devices
```

You should see available devices like:
- Android emulator (if running)
- Chrome (for web)
- Linux desktop (if installed)

### Step 4: Run the App

#### For Android Emulator:
```bash
# Start Android emulator first from Android Studio
# Then run:
flutter run
```

#### For Chrome (Web):
```bash
flutter run -d chrome
```

#### For Linux Desktop:
```bash
flutter run -d linux
```

#### For Specific Device:
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

---

## 🔧 Alternative: Quick Test with DartPad

If you want to quickly test the code logic without a full Flutter setup:

1. Visit [DartPad](https://dartpad.dev/)
2. Copy individual Dart files to test logic
3. Note: Full app won't run, but you can test individual functions

---

## 📋 Pre-Run Checklist

Before running the app, ensure:

- [ ] Flutter SDK is properly installed
- [ ] `flutter doctor` shows no critical issues
- [ ] Android Studio/Xcode is installed (for mobile)
- [ ] An emulator is running OR a physical device is connected
- [ ] Project dependencies are installed (`flutter pub get`)
- [ ] Hive adapters are generated (`build_runner`)

---

## 🎯 Testing the Currency Feature

Once the app is running:

### Test 1: Default Currency (KES)
1. Launch the app
2. **Expected**: All amounts show "KSh" symbol (Kenyan Shilling)
3. Add a transaction for KSh 1,000
4. **Expected**: Transaction shows as "KSh 1000.00"

### Test 2: Change Currency
1. Tap the **Settings icon** (gear) in the top-right of HomeScreen
2. You should see current currency: **KES - Kenyan Shilling**
3. Tap **"Change Currency"** button
4. Modal sheet opens with 12 currencies
5. Select **USD - US Dollar**
6. **Expected**: Success message appears
7. Navigate back to HomeScreen
8. **Expected**: All amounts now show "$" symbol

### Test 3: Currency Persistence
1. Change currency to **EUR** (Euro)
2. Close the app completely
3. Reopen the app
4. **Expected**: Currency is still EUR, amounts show "€" symbol

### Test 4: CSV Export with Currency
1. Add a few transactions
2. Export to CSV
3. Open the CSV file
4. **Expected**: 
   - Header shows "Amount (KES)" or current currency
   - Summary shows "Currency,KES (Kenyan Shilling)"

### Test 5: All Screens Update
After changing currency, verify these screens update:
- [ ] HomeScreen (balance cards)
- [ ] TransactionList (transaction amounts)
- [ ] AddTransactionScreen (amount hint)
- [ ] SummaryScreen (charts and stats)
- [ ] CategoryStatsScreen (category amounts)

---

## 🐛 Common Issues

### Issue: "Unable to find package"
**Solution**: Run `flutter pub get` again

### Issue: "No devices found"
**Solution**: 
- For Android: Start an emulator from Android Studio
- For Web: Ensure Chrome is installed
- For Desktop: Install Linux desktop support with `flutter config --enable-linux-desktop`

### Issue: "Hive adapters not found"
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: "Build failed"
**Solution**: 
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## 📊 Expected App Behavior

### On First Launch:
1. App initializes Hive database
2. Creates empty transaction box
3. Creates settings box with default currency: **KES**
4. Shows HomeScreen with balance: KSh 0.00

### After Adding Transactions:
1. Transactions appear in chronological order
2. Balance updates automatically
3. Charts show income vs expense breakdown
4. Category statistics display properly

### Currency Features:
1. All amounts format with current currency symbol
2. Currency changes update entire UI instantly
3. CSV exports include currency metadata
4. Currency selection persists across app restarts

---

## 🎨 What to Look For

### Visual Elements:
- **Colors**: Lime Green (income), Orange (expenses), Dark Blue (headers)
- **Icons**: 23 different category icons
- **Charts**: Interactive pie and bar charts
- **Animations**: Smooth transitions and swipe gestures

### Functionality:
- **Swipe to delete**: Swipe transaction left to delete
- **Pull to refresh**: Pull down on HomeScreen to refresh
- **Date grouping**: Transactions grouped by date
- **Category picker**: Grid layout with icons

---

## 💡 Tips for Testing

1. **Add sample data**: Add 10-15 transactions with different categories
2. **Test edge cases**: Try very large amounts, zero amounts
3. **Test all currencies**: Switch between different currencies
4. **Test exports**: Export and verify CSV format
5. **Test persistence**: Close and reopen app multiple times

---

## 📞 Need Help?

If you encounter issues:

1. Check Flutter installation: `flutter doctor -v`
2. Check project structure: Ensure all files are present
3. Check logs: Look for error messages in terminal
4. Clean and rebuild: `flutter clean && flutter pub get`

---

## ✨ Features to Test

- [x] Add transaction (income/expense)
- [x] Delete transaction (swipe left)
- [x] View transaction details (tap transaction)
- [x] Change currency (Settings screen)
- [x] View charts (Summary screen)
- [x] Filter by period (Daily/Weekly/Monthly)
- [x] Category statistics
- [x] CSV export
- [x] Pull to refresh
- [x] Empty state UI

---

**Happy Testing! 🎉**

Made with ❤️ for Kenya 🇰🇪
