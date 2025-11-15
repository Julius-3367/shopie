import 'package:hive/hive.dart';

/// Currency manager for handling multi-currency support
/// Default currency is Kenyan Shilling (KES)
class CurrencyManager {
  // Private constructor
  CurrencyManager._();

  static const String _settingsBox = 'settings';
  static const String _currencyKey = 'selected_currency';

  /// Supported currencies with their symbols and details
  static final Map<String, CurrencyData> supportedCurrencies = {
    'KES': CurrencyData(
      code: 'KES',
      symbol: 'KSh',
      name: 'Kenyan Shilling',
      country: 'Kenya',
      symbolPosition: SymbolPosition.before,
    ),
    'USD': CurrencyData(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      country: 'United States',
      symbolPosition: SymbolPosition.before,
    ),
    'EUR': CurrencyData(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      country: 'European Union',
      symbolPosition: SymbolPosition.before,
    ),
    'GBP': CurrencyData(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      country: 'United Kingdom',
      symbolPosition: SymbolPosition.before,
    ),
    'TZS': CurrencyData(
      code: 'TZS',
      symbol: 'TSh',
      name: 'Tanzanian Shilling',
      country: 'Tanzania',
      symbolPosition: SymbolPosition.before,
    ),
    'UGX': CurrencyData(
      code: 'UGX',
      symbol: 'USh',
      name: 'Ugandan Shilling',
      country: 'Uganda',
      symbolPosition: SymbolPosition.before,
    ),
    'ZAR': CurrencyData(
      code: 'ZAR',
      symbol: 'R',
      name: 'South African Rand',
      country: 'South Africa',
      symbolPosition: SymbolPosition.before,
    ),
    'NGN': CurrencyData(
      code: 'NGN',
      symbol: '₦',
      name: 'Nigerian Naira',
      country: 'Nigeria',
      symbolPosition: SymbolPosition.before,
    ),
    'GHS': CurrencyData(
      code: 'GHS',
      symbol: 'GH₵',
      name: 'Ghanaian Cedi',
      country: 'Ghana',
      symbolPosition: SymbolPosition.before,
    ),
    'JPY': CurrencyData(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      country: 'Japan',
      symbolPosition: SymbolPosition.before,
    ),
    'CNY': CurrencyData(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      country: 'China',
      symbolPosition: SymbolPosition.before,
    ),
    'INR': CurrencyData(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      country: 'India',
      symbolPosition: SymbolPosition.before,
    ),
  };

  /// Get current selected currency
  static CurrencyData getCurrentCurrency() {
    try {
      final box = Hive.box(_settingsBox);
      final currencyCode = box.get(_currencyKey, defaultValue: 'KES') as String;
      return supportedCurrencies[currencyCode] ?? supportedCurrencies['KES']!;
    } catch (e) {
      // Return default KES if any error
      return supportedCurrencies['KES']!;
    }
  }

  /// Set current currency
  static Future<bool> setCurrentCurrency(String currencyCode) async {
    try {
      if (!supportedCurrencies.containsKey(currencyCode)) {
        return false;
      }
      
      final box = Hive.box(_settingsBox);
      await box.put(_currencyKey, currencyCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Format amount with current currency
  static String formatAmount(double amount, {bool showSymbol = true}) {
    final currency = getCurrentCurrency();
    final formattedAmount = amount.toStringAsFixed(2);
    
    if (!showSymbol) {
      return formattedAmount;
    }

    if (currency.symbolPosition == SymbolPosition.before) {
      return '${currency.symbol} $formattedAmount';
    } else {
      return '$formattedAmount ${currency.symbol}';
    }
  }

  /// Format amount with specific currency
  static String formatAmountWithCurrency(
    double amount,
    String currencyCode, {
    bool showSymbol = true,
  }) {
    final currency = supportedCurrencies[currencyCode];
    if (currency == null) {
      return formatAmount(amount, showSymbol: showSymbol);
    }

    final formattedAmount = amount.toStringAsFixed(2);
    
    if (!showSymbol) {
      return formattedAmount;
    }

    if (currency.symbolPosition == SymbolPosition.before) {
      return '${currency.symbol} $formattedAmount';
    } else {
      return '$formattedAmount ${currency.symbol}';
    }
  }

  /// Get currency symbol
  static String getCurrencySymbol() {
    return getCurrentCurrency().symbol;
  }

  /// Get currency code
  static String getCurrencyCode() {
    return getCurrentCurrency().code;
  }

  /// Get list of all currency codes
  static List<String> getAllCurrencyCodes() {
    return supportedCurrencies.keys.toList();
  }

  /// Get list of all currencies sorted by name
  static List<CurrencyData> getAllCurrencies() {
    final currencies = supportedCurrencies.values.toList();
    currencies.sort((a, b) => a.name.compareTo(b.name));
    return currencies;
  }

  /// Get currency by code
  static CurrencyData? getCurrencyByCode(String code) {
    return supportedCurrencies[code];
  }

  /// Check if currency is supported
  static bool isCurrencySupported(String code) {
    return supportedCurrencies.containsKey(code);
  }

  /// Reset to default currency (KES)
  static Future<bool> resetToDefault() async {
    return await setCurrentCurrency('KES');
  }
}

/// Currency data model
class CurrencyData {
  final String code;
  final String symbol;
  final String name;
  final String country;
  final SymbolPosition symbolPosition;

  const CurrencyData({
    required this.code,
    required this.symbol,
    required this.name,
    required this.country,
    required this.symbolPosition,
  });

  @override
  String toString() => '$symbol $name ($code)';
}

/// Symbol position enum
enum SymbolPosition {
  before,
  after,
}
