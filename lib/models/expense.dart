// models/expense.dart
import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Expense({
    String? id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    amount: map['amount'],
    category: map['category'],
    date: DateTime.parse(map['date']),
    note: map['note'],
  );
}
