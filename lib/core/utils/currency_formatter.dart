import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format numeric amount to Indonesian Rupiah standard format (e.g., Rp 150.000).
  static String format(num amount) {
    return _formatter.format(amount);
  }

  /// Parses a string formatted in IDR or plain numbers back into a double.
  /// Returns 0.0 if parsing fails.
  static double parse(String rawText) {
    if (rawText.trim().isEmpty) return 0.0;
    final cleanDigits = rawText.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanDigits) ?? 0.0;
  }
}
