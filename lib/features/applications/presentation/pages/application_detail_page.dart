import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../services/pdf/application_pdf_service.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/timeline_stage.dart';
import '../../../../shared/widgets/digilocker_preview_sheet.dart';

/// Detailed view of an individual scholarship application.
class ApplicationDetailPage extends StatelessWidget {
  final ScholarshipApplication? application;
  final String? applicationId;

  const ApplicationDetailPage({
    super.key,
    this.application,
    this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ScholarshipDataService>(
      builder: (context, scholarshipService, _) {
        final app = application ??
            (applicationId != null
                ? scholarshipService.getApplicationById(applicationId!)
                : scholarshipService.applications.firstOrNull);

        if (app == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const AppBackButton(fallbackRoute: RouteNames.applicationsList),
              title: const Text('Application Detail'),
            ),
            body: const Center(
              child: Text('Application not found.'),
            ),
          );
        }

        final schemeColor = _getSchemeColor(app.scholarshipType);
        final linkedPayments = scholarshipService.getPaymentsForApplication(app.id);

        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(fallbackRoute: RouteNames.applicationsList),
            title: const Text('Application Details'),
            actions: [
              IconButton(
                tooltip: 'Track Timeline',
                icon: const Icon(Icons.timeline),
                onPressed: () => context.push(
                  RouteNames.applicationTracking,
                  extra: {'application': app},
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Scheme Summary Card ──────────────────────────────
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: schemeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              app.scholarshipType.shortCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          StatusBadge.fromApplicationStatus(app.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        app.scholarshipName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Application #${app.applicationNumber ?? "N/A"}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          _buildDetailColumn('Academic Year', app.academicYear ?? '2025-26'),
                          _buildDetailColumn(
                            'Applied On',
                            _formatDate(app.appliedDate),
                          ),
                          _buildDetailColumn(
                            'Amount',
                            app.sanctionedAmount != null
                                ? '₹${app.sanctionedAmount!.toInt()}'
                                : (app.requestedAmount != null
                                    ? '₹${app.requestedAmount!.toInt()}'
                                    : 'Under eval'),
                            highlight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Pending Actions Alert (if any) ───────────────────
                if (app.pendingActions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Pending Actions Required',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warningDark,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...app.pendingActions.map(
                            (action) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: AppColors.warningDark)),
                                  Expanded(
                                    child: Text(
                                      action,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.warningDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Quick Actions Row ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            RouteNames.applicationTracking,
                            extra: {'application': app},
                          ),
                          icon: const Icon(Icons.timeline, size: 18),
                          label: const Text('View Timeline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            AuthProvider? authProvider;
                            try {
                              authProvider = Provider.of<AuthProvider>(context, listen: false);
                            } catch (_) {}
                            final student = authProvider?.currentUser ??
                                Student(
                                  id: app.studentId,
                                  fullName: 'Rajesh Kumar Munda',
                                  category: 'ST',
                                );
                            final history = await scholarshipService.getStatusHistory(app.id);
                            if (context.mounted) {
                              await ApplicationPdfService.downloadOrShareApplicationPdf(
                                context,
                                application: app,
                                student: student,
                                statusHistory: history,
                                payments: linkedPayments,
                              );
                            }
                          },
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Download PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Submitted Documents (DigiLocker) ─────────────────
                SectionHeader(
                  title: 'Submitted Documents (3)',
                  actionText: 'View Wallet',
                  onAction: () => context.push(RouteNames.documentWallet),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildSubmittedDocTile(
                            context,
                            name: 'Aadhaar Card',
                            category: 'Identity Document',
                            issuer: 'UIDAI',
                            maskedId: 'XXXX XXXX 4401',
                            icon: Icons.fingerprint,
                            assetPath: 'assets/images/aadhaar_card.png',
                          ),
                          const Divider(height: 12),
                          _buildSubmittedDocTile(
                            context,
                            name: 'Caste Certificate (SEBC / ST)',
                            category: 'Caste / Community',
                            issuer: 'Govt. of Gujarat',
                            maskedId: 'Certificate No. 809/XXXX',
                            icon: Icons.badge_outlined,
                            assetPath: 'assets/images/caste_certificate.jpg',
                          ),
                          const Divider(height: 12),
                          _buildSubmittedDocTile(
                            context,
                            name: 'Class 12 Marksheet',
                            category: 'Academic Qualification',
                            issuer: 'CBSE',
                            maskedId: 'Roll No. 1163XXXX',
                            icon: Icons.school_outlined,
                            assetPath: 'assets/images/class12_marksheet.jpg',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Verification Stages Preview ──────────────────────
                SectionHeader(
                  title: 'Verification Status',
                  actionText: 'Full Timeline',
                  onAction: () => context.push(
                    RouteNames.applicationTracking,
                    extra: {'application': app},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TimelineStage(
                            title: 'Application Submitted',
                            subtitle: 'Submitted on ${_formatDate(app.appliedDate)}',
                            status: VerificationStatus.verified,
                            isFirst: true,
                          ),
                          const TimelineStage(
                            title: 'Institute Verification',
                            subtitle: 'NIT Rourkela enrollment confirmation',
                            status: VerificationStatus.verified,
                          ),
                          TimelineStage(
                            title: 'District ST Office',
                            subtitle: 'Tribe & domicile certificate validation',
                            status: app.status == ApplicationStatus.underReview
                                ? VerificationStatus.inProgress
                                : (app.status == ApplicationStatus.approved ||
                                        app.status == ApplicationStatus.sanctioned
                                    ? VerificationStatus.verified
                                    : VerificationStatus.pending),
                          ),
                          TimelineStage(
                            title: 'DBT Payment Disbursal',
                            subtitle: 'Transfer to Aadhaar-seeded bank account',
                            status: linkedPayments.any((p) => p.status == PaymentStatus.disbursed)
                                ? VerificationStatus.verified
                                : VerificationStatus.pending,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Payment Information (if any) ─────────────────────
                if (linkedPayments.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Disbursement & Payment',
                    actionText: 'All Payments',
                    onAction: () => context.push(RouteNames.payments),
                  ),
                  ...linkedPayments.map((p) => Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: p.status == PaymentStatus.disbursed
                                ? AppColors.successLight
                                : AppColors.warningLight,
                            child: Icon(
                              p.status == PaymentStatus.disbursed
                                  ? Icons.check
                                  : Icons.hourglass_top,
                              color: p.status == PaymentStatus.disbursed
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          title: Text(
                            p.installmentLabel ?? 'Scholarship Installment',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          subtitle: Text(
                            p.transactionId != null
                                ? 'TXN: ${p.transactionId}'
                                : 'Processing via PFMS',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          trailing: Text(
                            '₹${p.amount.toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: p.status == PaymentStatus.disbursed
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                // ── Support & Help ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.support_agent, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need help with this application?',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Ask JAGO AI or contact your district tribal officer.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteNames.jago),
                            child: const Text('Ask JAGO'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailColumn(String label, String value, {bool highlight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSchemeColor(ScholarshipType type) {
    switch (type) {
      case ScholarshipType.preMatric:
        return AppColors.preMatric;
      case ScholarshipType.postMatric:
        return AppColors.postMatric;
      case ScholarshipType.topClass:
        return AppColors.topClass;
      case ScholarshipType.nfst:
        return AppColors.nfst;
      case ScholarshipType.nos:
        return AppColors.nos;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSubmittedDocTile(
    BuildContext context, {
    required String name,
    required String category,
    required String issuer,
    required String maskedId,
    required IconData icon,
    required String assetPath,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.success),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.verified, size: 13, color: AppColors.success),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$issuer • $maskedId',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            showDigiLockerDocumentPreview(
              context,
              name: name,
              category: category,
              issuer: issuer,
              maskedNumber: maskedId,
              isVerified: true,
              assetImagePath: assetPath,
            );
          },
          icon: const Icon(Icons.visibility_outlined, size: 14, color: AppColors.primary),
          label: const Text(
            'View',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
