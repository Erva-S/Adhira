import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Payments & DBT tracking page.
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments & DBT')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.success, Color(0xFF1E8449)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Total Scholarship Amount', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('₹70,000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _PayStat(label: 'Sanctioned', value: '₹70,000', icon: Icons.check_circle_outline),
                      _PayStat(label: 'Disbursed', value: '₹45,000', icon: Icons.account_balance),
                      _PayStat(label: 'Pending', value: '₹25,000', icon: Icons.hourglass_top),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction history
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Transaction History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            _TransactionItem(title: 'Tuition Fee — Sem 1', amount: '₹25,000', date: '15 Sep 2025', status: PaymentStatus.disbursed, txnId: 'TXN-78432-001'),
            _TransactionItem(title: 'Maintenance Allowance — Sem 1', amount: '₹20,000', date: '20 Sep 2025', status: PaymentStatus.disbursed, txnId: 'TXN-78432-002'),
            _TransactionItem(title: 'Tuition Fee — Sem 2', amount: '₹25,000', date: 'Expected: Jan 2026', status: PaymentStatus.pending, txnId: '—'),
            const SizedBox(height: 16),

            // DBT info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All payments are made via Direct Benefit Transfer (DBT) to your linked Aadhaar-seeded bank account.',
                      style: TextStyle(fontSize: 12, color: AppColors.infoDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PayStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _PayStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final PaymentStatus status;
  final String txnId;
  const _TransactionItem({required this.title, required this.amount, required this.date, required this.status, required this.txnId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: status == PaymentStatus.disbursed ? AppColors.successLight : AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                status == PaymentStatus.disbursed ? Icons.check_circle : Icons.schedule,
                color: status == PaymentStatus.disbursed ? AppColors.success : AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text('$date • $txnId', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                StatusBadge.fromPaymentStatus(status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
