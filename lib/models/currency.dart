/// Currency model for multi-currency support
class Currency {
  final String code; // ISO 4217 code (e.g., KES, NGN, USD)
  final String name;
  final String symbol;
  final String flag; // Emoji flag

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'symbol': symbol,
    'flag': flag,
  };

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    code: json['code'],
    name: json['name'],
    symbol: json['symbol'],
    flag: json['flag'],
  );
}

/// List of supported currencies
class Currencies {
  static const Currency kes = Currency(
    code: 'KES',
    name: 'Kenyan Shilling',
    symbol: 'KSh',
    flag: '🇰🇪',
  );

  static const Currency ngn = Currency(
    code: 'NGN',
    name: 'Nigerian Naira',
    symbol: '₦',
    flag: '🇳🇬',
  );

  static const Currency usd = Currency(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    flag: '🇺🇸',
  );

  static const Currency eur = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    flag: '🇪🇺',
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    flag: '🇬🇧',
  );

  static const Currency zar = Currency(
    code: 'ZAR',
    name: 'South African Rand',
    symbol: 'R',
    flag: '🇿🇦',
  );

  static const Currency ugx = Currency(
    code: 'UGX',
    name: 'Ugandan Shilling',
    symbol: 'USh',
    flag: '🇺🇬',
  );

  static const Currency tzs = Currency(
    code: 'TZS',
    name: 'Tanzanian Shilling',
    symbol: 'TSh',
    flag: '🇹🇿',
  );

  static const Currency ghs = Currency(
    code: 'GHS',
    name: 'Ghanaian Cedi',
    symbol: 'GH₵',
    flag: '🇬🇭',
  );

  static const Currency inr = Currency(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    flag: '🇮🇳',
  );

  static const Currency cny = Currency(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    flag: '🇨🇳',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    flag: '🇯🇵',
  );

  static const Currency aud = Currency(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
    flag: '🇦🇺',
  );

  static const Currency cad = Currency(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    flag: '🇨🇦',
  );

  static const List<Currency> all = [
    kes,
    ngn,
    usd,
    eur,
    gbp,
    zar,
    ugx,
    tzs,
    ghs,
    inr,
    cny,
    jpy,
    aud,
    cad,
  ];

  /// Get currency by code
  static Currency? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }
}
