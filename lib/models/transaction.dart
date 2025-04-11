
import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String description;
  final DateTime date;

  Transaction({
    String? id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.description,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'categoryId': categoryId,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: json['categoryId'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? description,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
