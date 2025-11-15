import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Provider for managing app theme (light/dark mode)
/// Persists theme preference using Hive
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _settingsBox = 'settings';
  
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  /// Load theme preference from Hive
  void _loadTheme() {
    try {
      final box = Hive.box(_settingsBox);
      _isDarkMode = box.get(_themeKey, defaultValue: false) as bool;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    try {
      final box = Hive.box(_settingsBox);
      await box.put(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Set specific theme mode
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    
    try {
      final box = Hive.box(_settingsBox);
      await box.put(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Get light theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF1A237E), // Dark blue
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A237E),
        brightness: Brightness.light,
        primary: const Color(0xFF1A237E),
        secondary: const Color(0xFF7CB342), // Lime green
        error: const Color(0xFFFF6F00), // Orange
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  /// Get dark theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF7CB342), // Lime green
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7CB342),
        brightness: Brightness.dark,
        primary: const Color(0xFF7CB342),
        secondary: const Color(0xFF1A237E),
        error: const Color(0xFFFF6F00),
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7CB342),
        foregroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF7CB342),
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
      ),
    );
  }
}
