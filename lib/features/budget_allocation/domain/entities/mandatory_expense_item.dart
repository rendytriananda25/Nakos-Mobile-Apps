import 'package:equatable/equatable.dart';

class MandatoryExpenseItem extends Equatable {
  final String id;
  final String title;
  final double amount;
  final bool isPaid;
  final String? category;

  const MandatoryExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    this.isPaid = false,
    this.category,
  });

  MandatoryExpenseItem copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isPaid,
    String? category,
  }) {
    return MandatoryExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isPaid': isPaid,
        'category': category,
      };

  factory MandatoryExpenseItem.fromJson(Map<String, dynamic> json) =>
      MandatoryExpenseItem(
        id: json['id'] as String? ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Kebutuhan Wajib',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        isPaid: json['isPaid'] as bool? ?? false,
        category: json['category'] as String?,
      );

  @override
  List<Object?> get props => [id, title, amount, isPaid, category];
}
