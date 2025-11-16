import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Service for fetching and caching currency exchange rates
class CurrencyService {
  static const String _boxName = 'currency_rates';
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const String _baseCurrency = 'KES'; // Base currency is Kenyan Shilling
  
  // Cache duration: 1 hour
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Get exchange rates with caching
  /// Returns a map of currency codes to their exchange rates relative to KES
  static Future<Map<String, double>> getExchangeRates() async {
    try {
      final box = await Hive.openBox(_boxName);
      
      // Check if we have cached rates
      final lastUpdate = box.get('last_update') as int?;
      final cachedRates = box.get('rates') as Map?;
      
      if (lastUpdate != null && cachedRates != null) {
        final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
        final now = DateTime.now();
        
        // If cache is still valid, return cached rates
        if (now.difference(lastUpdateTime) < _cacheDuration) {
          debugPrint('Using cached exchange rates');
          return Map<String, double>.from(cachedRates);
        }
      }
      
      // Fetch fresh rates from API
      debugPrint('Fetching fresh exchange rates from API');
      final response = await http.get(
        Uri.parse('$_baseUrl/$_baseCurrency'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(data['rates']);
        
        // Cache the rates
        await box.put('rates', rates);
        await box.put('last_update', DateTime.now().millisecondsSinceEpoch);
        
        debugPrint('Exchange rates updated successfully');
        return rates;
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
      
      // Return cached rates if available, even if expired
      try {
        final box = await Hive.openBox(_boxName);
        final cachedRates = box.get('rates') as Map?;
        if (cachedRates != null) {
          debugPrint('Using expired cached rates due to fetch error');
          return Map<String, double>.from(cachedRates);
        }
      } catch (e) {
        debugPrint('Error loading cached rates: $e');
      }
      
      // Return default rates if all else fails
      return _getDefaultRates();
    }
  }

  /// Convert amount from one currency to another
  /// All conversions go through KES as the base currency
  static Future<double> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;
    
    final rates = await getExchangeRates();
    
    // Convert from source currency to KES
    double amountInKES = amount;
    if (fromCurrency != _baseCurrency) {
      final fromRate = rates[fromCurrency];
      if (fromRate == null) {
        throw Exception('Exchange rate not found for $fromCurrency');
      }
      amountInKES = amount / fromRate;
    }
    
    // Convert from KES to target currency
    if (toCurrency == _baseCurrency) {
      return amountInKES;
    }
    
    final toRate = rates[toCurrency];
    if (toRate == null) {
      throw Exception('Exchange rate not found for $toCurrency');
    }
    
    return amountInKES * toRate;
  }

  /// Get default exchange rates (fallback when API is unavailable)
  /// These are approximate rates and should be updated periodically
  static Map<String, double> _getDefaultRates() {
    debugPrint('Using default exchange rates (fallback)');
    return {
      'KES': 1.0,
      'NGN': 11.85, // 1 KES ≈ 11.85 NGN
      'USD': 0.0077, // 1 KES ≈ 0.0077 USD
      'EUR': 0.0071, // 1 KES ≈ 0.0071 EUR
      'GBP': 0.0061, // 1 KES ≈ 0.0061 GBP
      'ZAR': 0.14, // 1 KES ≈ 0.14 ZAR
      'UGX': 28.5, // 1 KES ≈ 28.5 UGX
      'TZS': 19.5, // 1 KES ≈ 19.5 TZS
      'GHS': 0.12, // 1 KES ≈ 0.12 GHS
      'INR': 0.65, // 1 KES ≈ 0.65 INR
      'CNY': 0.056, // 1 KES ≈ 0.056 CNY
      'JPY': 1.19, // 1 KES ≈ 1.19 JPY
      'AUD': 0.012, // 1 KES ≈ 0.012 AUD
      'CAD': 0.011, // 1 KES ≈ 0.011 CAD
    };
  }

  /// Clear cached exchange rates (force refresh on next fetch)
  static Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.clear();
      debugPrint('Exchange rate cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
