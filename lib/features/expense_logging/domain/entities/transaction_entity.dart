import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  food('Makan', '🍜'),
  snacks('Jajan', '🧋'),
  transport('Transport', '🛵'),
  bills('Tagihan', '⚡'),
  emergency('Darurat', '💊'),
  income('Pemasukan', '💰'),
  other('Lainnya', '📦');

  final String label;
  final String emoji;
  const ExpenseCategory(this.label, this.emoji);
}

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime timestamp;
  final bool isIncome;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.timestamp,
    this.isIncome = false,
  });

  @override
  List<Object?> get props => [id, title, amount, category, timestamp, isIncome];
}
