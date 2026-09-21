import 'package:intl/intl.dart';

/// Date and currency formatting utilities.
class AppFormatters {
  AppFormatters._();

  // ── Date ──────────────────────────────────────────────────────
  static String date(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String dateTime(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  static String relativeDate(DateTime? dt) {
    if (dt == null) return '—';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return date(dt);
  }

  // ── Currency ──────────────────────────────────────────────────
  static String currency(double? amount) {
    if (amount == null) return '₹0';
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String currencyCompact(double? amount) {
    if (amount == null) return '₹0';
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  // ── Percentage ────────────────────────────────────────────────
  static String percent(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  // ── Phone ─────────────────────────────────────────────────────
  static String phone(String? number) {
    if (number == null || number.length != 10) return number ?? '—';
    return '+91 ${number.substring(0, 5)} ${number.substring(5)}';
  }

  // ── Aadhaar (masked) ──────────────────────────────────────────
  static String maskedAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.length != 12) return '—';
    return 'XXXX XXXX ${aadhaar.substring(8)}';
  }
}
