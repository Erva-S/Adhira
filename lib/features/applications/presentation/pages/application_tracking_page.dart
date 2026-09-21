import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/scholarship/scholarship_mock_data.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/timeline_stage.dart';
import '../../../../shared/widgets/app_button.dart';

/// Application tracking page with dynamic timeline visualization.
class ApplicationTrackingPage extends StatelessWidget {
  final ScholarshipApplication? application;
  final String? applicationId;

  const ApplicationTrackingPage({
    super.key,
    this.application,
    this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    ScholarshipDataService? service;
    try {
      service = Provider.of<ScholarshipDataService>(context);
    } catch (_) {
      // Fallback for standalone widget tests
    }

    final allApps = service?.applications ?? ScholarshipMockData.applications;
    final app = application ??
        (applicationId != null
            ? (service?.getApplicationById(applicationId!) ??
                allApps.where((a) => a.id == applicationId).firstOrNull)
            : allApps.firstOrNull);

    final title = app?.scholarshipName ?? 'Post-Matric Scholarship';
    final appNumber = app?.applicationNumber ?? 'PMS-2025-78432';
    final status = app?.status ?? ApplicationStatus.underReview;
    final appliedDate = app != null ? _formatDate(app.appliedDate) : '15 Aug 2025';
    final academicYear = app?.academicYear ?? '2025-26';

    final isPaymentDisbursed = app != null &&
        (service != null
            ? service.getPaymentsForApplication(app.id).any((p) => p.status == PaymentStatus.disbursed)
            : ScholarshipMockData.payments
                .where((p) => p.applicationId == app.id)
                .any((p) => p.status == PaymentStatus.disbursed));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
        title: const Text('Application Tracking'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Application summary card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Application #$appNumber',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.fromApplicationStatus(status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Applied: $appliedDate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.school, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        academicYear,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Application Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  TimelineStage(
                    title: 'Application Submitted',
                    subtitle: 'All required fields completed & certified',
                    date: appliedDate,
                    status: VerificationStatus.verified,
                    isFirst: true,
                  ),
                  TimelineStage(
                    title: 'Document Upload & DigiLocker',
                    subtitle: 'Aadhaar, ST certificate & marksheets attached',
                    date: appliedDate,
                    status: VerificationStatus.verified,
                  ),
                  TimelineStage(
                    title: 'Institute Verification',
                    subtitle: 'Enrollment & bonafide verified by institution',
                    status: (status != ApplicationStatus.draft && status != ApplicationStatus.submitted)
                        ? VerificationStatus.verified
                        : VerificationStatus.inProgress,
                  ),
                  TimelineStage(
                    title: 'Tribal Welfare / District Verification',
                    subtitle: 'ST community & family income verification',
                    status: status == ApplicationStatus.underReview
                        ? VerificationStatus.inProgress
                        : (status == ApplicationStatus.approved || status == ApplicationStatus.sanctioned
                            ? VerificationStatus.verified
                            : VerificationStatus.pending),
                  ),
                  TimelineStage(
                    title: 'State Nodal Officer Approval',
                    subtitle: 'State government sanction & recommendation',
                    status: (status == ApplicationStatus.approved || status == ApplicationStatus.sanctioned)
                        ? VerificationStatus.verified
                        : VerificationStatus.pending,
                  ),
                  TimelineStage(
                    title: 'Scholarship Sanctioned',
                    subtitle: 'Central MoTA fund allocation',
                    status: status == ApplicationStatus.sanctioned
                        ? VerificationStatus.verified
                        : VerificationStatus.pending,
                  ),
                  TimelineStage(
                    title: 'DBT Payment Disbursed',
                    subtitle: 'Fund transferred to Aadhaar-seeded bank account',
                    status: isPaymentDisbursed
                        ? VerificationStatus.verified
                        : VerificationStatus.pending,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(
                label: 'Download Application PDF',
                icon: Icons.download,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading PDF for $appNumber...')),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
