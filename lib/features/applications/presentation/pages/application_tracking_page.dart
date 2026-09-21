import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/timeline_stage.dart';
import '../../../../shared/widgets/app_button.dart';

/// Application tracking page with timeline visualization.
class ApplicationTrackingPage extends StatelessWidget {
  const ApplicationTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                            Text('Post-Matric Scholarship', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Application #PMS-2025-78432', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const StatusBadge(label: 'Under Review', variant: StatusBadgeVariant.warning),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('Applied: 15 Aug 2025', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(width: 16),
                      const Icon(Icons.school, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('B.Tech, Year 2', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            // Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Application Timeline', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  TimelineStage(title: 'Application Submitted', subtitle: 'All required fields completed', date: '15 Aug 2025', status: VerificationStatus.verified, isFirst: true),
                  TimelineStage(title: 'Document Upload', subtitle: '5 documents uploaded successfully', date: '16 Aug 2025', status: VerificationStatus.verified),
                  TimelineStage(title: 'Institute Verification', subtitle: 'Verified by NIT Rourkela', date: '22 Aug 2025', status: VerificationStatus.verified),
                  TimelineStage(title: 'Identity Verification', subtitle: 'Aadhaar verified via UIDAI', date: '23 Aug 2025', status: VerificationStatus.verified),
                  TimelineStage(title: 'ST Certificate Verification', subtitle: 'Under review by district office', status: VerificationStatus.inProgress),
                  TimelineStage(title: 'Income Verification', subtitle: 'Pending e-District verification', status: VerificationStatus.pending),
                  TimelineStage(title: 'State Approval', subtitle: 'Waiting for state nodal officer', status: VerificationStatus.pending),
                  TimelineStage(title: 'Scholarship Sanctioned', subtitle: 'Final approval and disbursement', status: VerificationStatus.pending, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(label: 'Download Application PDF', icon: Icons.download, variant: AppButtonVariant.outline, onPressed: () {}),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
