import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/currency_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'services/hive_boxes.dart';
import 'dart:io' show Platform;

bool _firebaseInitialized = false;

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive first (works on all platforms)
  await HiveBoxes.init();
  
  // Try to initialize Firebase (optional for Linux)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase not available on this platform (using local storage): $e');
    _firebaseInitialized = false;
  }
  
  runApp(const ShopieApp());
}

class ShopieApp extends StatelessWidget {
  const ShopieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          // Skip Firebase auth on Linux - go straight to app
          final bool skipAuth = !_firebaseInitialized;
          
          // Set user ID in TransactionProvider when auth state changes
          if (!skipAuth && authProvider.isAuthenticated && authProvider.userId.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final transactionProvider = Provider.of<TransactionProvider>(
                context,
                listen: false,
              );
              transactionProvider.setUser(authProvider.userId);
            });
          } else if (!skipAuth) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final transactionProvider = Provider.of<TransactionProvider>(
                context,
                listen: false,
              );
              transactionProvider.clearUser();
            });
          }

          return MaterialApp(
            title: 'Shopie',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: skipAuth
                ? const MainNavigation() // Skip auth on Linux
                : authProvider.isLoading
                    ? const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : authProvider.isAuthenticated
                        ? const MainNavigation()
                        : const LoginScreen(),
          );
        },
      ),
    );
  }
}
