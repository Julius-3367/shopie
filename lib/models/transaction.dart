import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late bool isIncome;

  @HiveField(5)
  String? category;

  @HiveField(6)
  String? notes;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.category,
    this.notes,
  });

  // Factory constructor for creating a new Transaction with generated ID
  factory Transaction.create({
    required String title,
    required double amount,
    required DateTime date,
    required bool isIncome,
    String? category,
    String? notes,
  }) {
    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: date,
      isIncome: isIncome,
      category: category,
      notes: notes,
    );
  }

  // Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
      'category': category,
      'notes': notes,
    };
  }

  // Create from Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      isIncome: map['isIncome'] as bool,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
    );
  }

  // Copy with method for immutable updates
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    bool? isIncome,
    String? category,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, date: $date, isIncome: $isIncome, category: $category, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.date == date &&
        other.isIncome == isIncome &&
        other.category == category &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        isIncome.hashCode ^
        category.hashCode ^
        notes.hashCode;
  }
}
