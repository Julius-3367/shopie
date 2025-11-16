import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

/// Provider for managing currency settings and conversions
class CurrencyProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _currencyKey = 'selected_currency';
  
  Currency _selectedCurrency = Currencies.kes; // Default to KES
  Map<String, double> _exchangeRates = {};
  bool _isLoadingRates = false;

  Currency get selectedCurrency => _selectedCurrency;
  Map<String, double> get exchangeRates => _exchangeRates;
  bool get isLoadingRates => _isLoadingRates;

  CurrencyProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadSelectedCurrency();
    await refreshExchangeRates();
  }

  /// Load the saved currency preference
  Future<void> _loadSelectedCurrency() async {
    try {
      final box = await Hive.openBox(_boxName);
      final savedCode = box.get(_currencyKey) as String?;
      
      if (savedCode != null) {
        final currency = Currencies.getByCode(savedCode);
        if (currency != null) {
          _selectedCurrency = currency;
          notifyListeners();
          debugPrint('Loaded saved currency: ${_selectedCurrency.code}');
        }
      }
    } catch (e) {
      debugPrint('Error loading currency preference: $e');
    }
  }

  /// Change the selected currency
  Future<void> setCurrency(Currency currency) async {
    if (_selectedCurrency.code == currency.code) return;
    
    _selectedCurrency = currency;
    
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_currencyKey, currency.code);
      debugPrint('Currency changed to: ${currency.code}');
    } catch (e) {
      debugPrint('Error saving currency preference: $e');
    }
    
    notifyListeners();
  }

  /// Refresh exchange rates from API
  Future<void> refreshExchangeRates() async {
    _isLoadingRates = true;
    notifyListeners();
    
    try {
      _exchangeRates = await CurrencyService.getExchangeRates();
      debugPrint('Exchange rates loaded: ${_exchangeRates.length} currencies');
    } catch (e) {
      debugPrint('Error loading exchange rates: $e');
    } finally {
      _isLoadingRates = false;
      notifyListeners();
    }
  }

  /// Convert an amount from KES (base currency) to the selected currency
  double convertFromBase(double amountInKES) {
    if (_selectedCurrency.code == 'KES') return amountInKES;
    
    final rate = _exchangeRates[_selectedCurrency.code];
    if (rate == null) {
      debugPrint('Exchange rate not found for ${_selectedCurrency.code}, using base amount');
      return amountInKES;
    }
    
    return amountInKES * rate;
  }

  /// Convert an amount from the selected currency to KES (base currency)
  double convertToBase(double amountInSelectedCurrency) {
    if (_selectedCurrency.code == 'KES') return amountInSelectedCurrency;
    
    final rate = _exchangeRates[_selectedCurrency.code];
    if (rate == null) {
      debugPrint('Exchange rate not found for ${_selectedCurrency.code}, using amount as-is');
      return amountInSelectedCurrency;
    }
    
    return amountInSelectedCurrency / rate;
  }

  /// Format an amount with the current currency symbol
  String formatAmount(double amount) {
    final convertedAmount = convertFromBase(amount);
    return '${_selectedCurrency.symbol}${convertedAmount.toStringAsFixed(2)}';
  }

  /// Clear exchange rate cache and refresh
  Future<void> clearCache() async {
    await CurrencyService.clearCache();
    await refreshExchangeRates();
  }
}
