import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Payments & DBT tracking page — dynamically wired to PaymentRepository.
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Pending';
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScholarshipDataService>(
      builder: (context, scholarshipService, _) {
        final payments = scholarshipService.payments;
        final totalSanctioned = scholarshipService.totalSanctioned.toInt();
        final totalDisbursed = scholarshipService.totalDisbursed.toInt();
        final totalPending = scholarshipService.totalPending.toInt();

        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
            title: const Text('Payments & DBT'),
          ),
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
                      Text('₹$totalSanctioned', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _PayStat(label: 'Sanctioned', value: '₹$totalSanctioned', icon: Icons.check_circle_outline),
                          _PayStat(label: 'Disbursed', value: '₹$totalDisbursed', icon: Icons.account_balance),
                          _PayStat(label: 'Pending', value: '₹$totalPending', icon: Icons.hourglass_top),
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
                if (payments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.payment_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'No payment or disbursement records yet.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Disbursement status will update once your application is sanctioned.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...payments.map((p) {
                    final dateText = p.status == PaymentStatus.disbursed
                        ? _formatDate(p.disbursedDate)
                        : (p.sanctionedDate != null ? 'Sanctioned: ${_formatDate(p.sanctionedDate)}' : 'Awaiting Sanction');
                    return _TransactionItem(
                      title: '${p.scholarshipName} — ${p.installmentLabel ?? "Installment"}',
                      amount: '₹${p.amount.toInt()}',
                      date: dateText,
                      status: p.status,
                      dbtStatus: p.dbtStatus,
                      txnId: p.transactionId ?? p.referenceNumber ?? 'Pending PFMS',
                    );
                  }),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Aadhaar-Seeded DBT Account', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              'Scholarship payments are credited directly into your Aadhaar-linked bank account via PFMS DBT. Ensure bank account is NPCI active.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
  final DbtStatus? dbtStatus;
  final String txnId;

  const _TransactionItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
    this.dbtStatus,
    required this.txnId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const Spacer(),
              StatusBadge.fromPaymentStatus(status),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Ref: $txnId', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              if (dbtStatus != null) ...[
                const SizedBox(width: 8),
                Text('• ${dbtStatus!.label}', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
