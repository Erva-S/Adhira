import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../services/pdf/application_pdf_service.dart';
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
                'Application Timeline (Status History)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: app == null
                  ? const Center(child: Text('No application selected.'))
                  : FutureBuilder<List<ApplicationStatusHistory>>(
                      future: service?.getStatusHistory(app.id),
                      builder: (context, snapshot) {
                        final history = snapshot.data ?? [];
                        if (history.isEmpty) {
                          // Fallback initial stage
                          return Column(
                            children: [
                              TimelineStage(
                                title: 'Application Submitted',
                                subtitle: 'Application registered in system',
                                date: appliedDate,
                                status: VerificationStatus.verified,
                                isFirst: true,
                              ),
                              TimelineStage(
                                title: 'Document Verification',
                                subtitle: 'Under verification by authorities',
                                status: VerificationStatus.inProgress,
                                isLast: true,
                              ),
                            ],
                          );
                        }

                        // Render dynamic stages from application_status_history
                        final stages = <Widget>[];
                        for (int i = 0; i < history.length; i++) {
                          final h = history[i];
                          final isFirst = i == 0;
                          final isLast = i == history.length - 1 &&
                              (app.status == ApplicationStatus.disbursed ||
                                  app.status == ApplicationStatus.rejected);

                          stages.add(
                            TimelineStage(
                              title: h.stage.label,
                              subtitle: '${h.message} (${h.changedBy})',
                              date: _formatDate(h.changedAt),
                              status: h.status,
                              isFirst: isFirst,
                              isLast: isLast,
                            ),
                          );
                        }

                        // Add pending future stages if not yet disbursed or rejected
                        if (app.status != ApplicationStatus.disbursed &&
                            app.status != ApplicationStatus.rejected) {
                          if (!history.any((h) => h.stage == ApplicationStage.sanction)) {
                            stages.add(
                              const TimelineStage(
                                title: 'Scholarship Sanction',
                                subtitle: 'Pending sanction approval by Department',
                                status: VerificationStatus.pending,
                              ),
                            );
                          }
                          if (!history.any((h) => h.stage == ApplicationStage.disbursement)) {
                            stages.add(
                              TimelineStage(
                                title: 'DBT Payment Disbursement',
                                subtitle: 'Direct transfer to Aadhaar-seeded bank account',
                                status: isPaymentDisbursed
                                    ? VerificationStatus.verified
                                    : VerificationStatus.pending,
                                isLast: true,
                              ),
                            );
                          }
                        }

                        return Column(children: stages);
                      },
                    ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(
                label: 'Download Application PDF',
                icon: Icons.download,
                variant: AppButtonVariant.outline,
                onPressed: () async {
                  if (app == null) return;
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
                  final history = service != null
                      ? await service.getStatusHistory(app.id)
                      : <ApplicationStatusHistory>[];
                  final payments = service != null
                      ? service.getPaymentsForApplication(app.id)
                      : <Payment>[];
                  if (context.mounted) {
                    await ApplicationPdfService.downloadOrShareApplicationPdf(
                      context,
                      application: app,
                      student: student,
                      statusHistory: history,
                      payments: payments,
                    );
                  }
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
