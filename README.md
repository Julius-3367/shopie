# 💰 Shopie - Smart Budget Tracking App

<p align="center">
  <img src="assets/logo.png" alt="Shopie Logo" width="200"/>
</p>

<p align="center">
  <strong>A beautiful and intuitive Flutter budget tracking application to help you manage your finances effectively.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue.svg" alt="Flutter Version"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-blue.svg" alt="Dart Version"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License"/>
</p>

---

## 📖 Overview

**Shopie** is a modern, feature-rich budget tracking application built with Flutter. It helps users track their income and expenses, visualize spending patterns through interactive charts, and gain insights into their financial habits. With a clean Material Design interface and powerful local storage, Shopie makes personal finance management simple and enjoyable.

---

## ✨ Features

### 💳 Transaction Management
- ✅ Add, edit, and delete transactions with ease
- ✅ Categorize transactions (23 predefined categories)
- ✅ Support for both income and expense tracking
- ✅ **Multi-Currency Support** (12 currencies, KES default) 🇰🇪
- ✅ Add notes and custom details to transactions
- ✅ Date and time tracking for each transaction
- ✅ Swipe-to-delete with undo functionality
- ✅ Search and filter transactions

### 📊 Financial Insights
- ✅ **Interactive Charts**: Beautiful pie and bar charts using fl_chart
- ✅ **Income vs Expense**: Visual breakdown of your finances
- ✅ **Category Analysis**: See where your money goes
- ✅ **Period Filtering**: Daily, weekly, and monthly views
- ✅ **Statistics Dashboard**: Average spending, savings rate, and more
- ✅ **Real-time Balance**: Track current balance at a glance

### 🎨 User Interface
- ✅ Modern Material Design 3
- ✅ Custom color scheme (Lime Green, Dark Blue, Orange, Maroon, Violet, Gray)
- ✅ Smooth animations and transitions
- ✅ Intuitive navigation and user experience
- ✅ Responsive layout for all screen sizes
- ✅ Pull-to-refresh functionality

### 💾 Data Management
- ✅ **Local Storage**: Fast and secure with Hive database
- ✅ **CSV Export**: Export transactions to spreadsheet with currency info
- ✅ **Data Persistence**: All data saved locally on device
- ✅ **Currency Settings**: Persistent currency preference
- ✅ **No Internet Required**: Works completely offline
- ✅ **Privacy First**: Your data never leaves your device

### 📂 Categories

**Income Categories (8):**
- Salary, Freelance, Business, Investment, Gift, Bonus, Rental, Other Income

**Expense Categories (15):**
- Food & Dining, Shopping, Transportation, Bills & Utilities, Entertainment, Healthcare, Education, Travel, Housing, Personal Care, Fitness, Gifts & Donations, Insurance, Pets, Other Expense

---

## 🛠️ Tech Stack

### Core Technologies
- **Framework**: [Flutter](https://flutter.dev/) 3.0+
- **Language**: [Dart](https://dart.dev/) 3.0+
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter)

### Key Packages
- **fl_chart**: Interactive charts and data visualization
- **intl**: Internationalization and date formatting
- **path_provider**: File system path access
- **permission_handler**: Storage permissions management

### Architecture
- **Design Pattern**: Provider pattern for state management
- **Data Layer**: Hive for local NoSQL storage
- **UI Layer**: Material Design 3 components
- **Utils**: Reusable utilities for categories, CSV export, currency management
- **Localization**: Built for Kenyan market with multi-currency support

---

## 📱 Screenshots

### Home Screen
*Overview of transactions with balance summary*

### Add Transaction
*Easy-to-use form with category selection*

### Financial Summary
*Interactive charts showing income vs expenses*

### Category Breakdown
*Detailed view of spending by category*

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (3.0 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- Android SDK or Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Julius-3367/shopie.git
   cd shopie
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For a specific device
   flutter devices
   flutter run -d <device-id>
   ```

### Building for Production

#### Android (APK)
```bash
flutter build apk --release
```

#### Android (App Bundle)
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

---

## 📂 Project Structure

```
shopie/
├── lib/
│   ├── models/              # Data models
│   │   └── transaction.dart
│   ├── providers/           # State management
│   │   └── transaction_provider.dart
│   ├── screens/             # App screens
│   │   ├── home_screen.dart
│   │   ├── add_transaction_screen.dart
│   │   ├── summary_screen.dart
│   │   ├── category_stats_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/             # Reusable widgets
│   │   ├── transaction_list.dart
│   │   └── charts_widget.dart
│   ├── services/            # Business logic
│   │   └── hive_boxes.dart
│   ├── utils/               # Utility functions
│   │   ├── category_manager.dart
│   │   ├── currency_manager.dart
│   │   └── csv_exporter.dart
│   └── main.dart            # App entry point
├── test/                    # Unit tests
│   ├── transaction_provider_test.dart
│   ├── transaction_model_test.dart
│   ├── category_manager_test.dart
│   └── csv_exporter_test.dart
├── assets/                  # Images, fonts, etc.
├── pubspec.yaml            # Dependencies
├── README.md               # This file
└── CURRENCY_INTEGRATION.md # Currency feature documentation
```

---

## 🎯 Usage Guide

### Adding a Transaction

1. Tap the **floating action button (+)** on the home screen
2. Select transaction type: **Income** or **Expense**
3. Fill in the details:
   - Title (required)
   - Amount (required)
   - Category (required)
   - Date (optional, defaults to today)
   - Notes (optional)
4. Tap **Save Transaction**

### Viewing Summaries

1. Navigate to the **Summary** tab
2. Select period: Daily, Weekly, or Monthly
3. View interactive charts and statistics
4. Analyze spending patterns

### Exporting Data

1. Go to HomeScreen or SummaryScreen
2. Access export functionality (e.g., through menu)
3. Choose export type (All, Income, Expense, or Date Range)
4. File will be saved to device storage with currency information

### Changing Currency

1. Tap the **Settings icon** on the home screen
2. View current currency selection
3. Tap **Change Currency**
4. Select from 12 supported currencies:
   - **KES** - Kenyan Shilling (Default) 🇰🇪
   - **TZS, UGX, ZAR, NGN, GHS** - African currencies
   - **USD, EUR, GBP** - Major global currencies
   - **JPY, CNY, INR** - Asian currencies
5. All amounts update immediately across the app
6. Currency preference is saved automatically

### Managing Categories

Categories are pre-defined with icons and colors. Each transaction must be assigned to a category for better organization and analytics.

---

## 🎨 Color Scheme

The app uses a carefully selected color palette:

- **Lime Green** (#7CB342): Income, positive actions
- **Dark Blue** (#1A237E): Headers, primary text
- **Orange** (#FF6F00): Expenses, warnings
- **Maroon** (#6D4C41): Secondary expenses
- **Violet** (#8E24AA): Highlights, analytics
- **Gray** (#9E9E9E): Neutral elements

---

## 🔧 Configuration

### Customizing Categories

Edit `lib/utils/category_manager.dart` to add or modify categories:

```dart
static final Map<String, CategoryData> expenseCategories = {
  'Your Category': CategoryData(
    name: 'Your Category',
    icon: Icons.your_icon,
    color: const Color(0xFFYOURCOLOR),
    description: 'Category description',
  ),
};
```

### Changing Theme

Modify the theme in `lib/main.dart`:

```dart
theme: ThemeData(
  primaryColor: const Color(0xFFYOURCOLOR),
  // ... other theme properties
),
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Write meaningful commit messages
- Add comments for complex logic
- Test your changes on both Android and iOS
- Update documentation as needed

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Julius**
- GitHub: [@Julius-3367](https://github.com/Julius-3367)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- fl_chart for beautiful charts
- Hive team for fast local storage
- Material Design for UI guidelines
- All open-source contributors

---

## 📧 Support

If you encounter any issues or have questions:

- Open an [issue](https://github.com/Julius-3367/shopie/issues)
- Star ⭐ the repository if you find it helpful
- Share with others who might benefit from it

---

## 🗺️ Roadmap

### Completed Features
- [x] Transaction management (add, edit, delete)
- [x] 23 predefined categories with icons
- [x] Interactive charts and analytics
- [x] CSV export functionality
- [x] **Multi-currency support (12 currencies)**
- [x] **Kenyan Shilling (KES) as default**
- [x] **Settings screen with currency picker**
- [x] Comprehensive unit tests (100+ test cases)

### Planned Features
- [ ] Budget limits and alerts
- [ ] Recurring transactions
- [ ] Exchange rate integration
- [ ] Cloud backup and sync
- [ ] Biometric authentication
- [ ] Custom categories
- [ ] Dark mode theme
- [ ] Reports and analytics export
- [ ] Multi-account support
- [ ] Multi-language support
- [ ] Widget for home screen
- [ ] More African currencies (EGP, MAD, XAF, XOF)

---

<p align="center">
  Made with ❤️ in Kenya 🇰🇪
</p>

---

## 📊 Stats

![GitHub stars](https://img.shields.io/github/stars/Julius-3367/shopie?style=social)
![GitHub forks](https://img.shields.io/github/forks/Julius-3367/shopie?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/Julius-3367/shopie?style=social)

---

<p align="center">
  Made with ❤️ using Flutter
</p>

<p align="center">
  <strong>Happy Budgeting! 💰</strong>
</p>
