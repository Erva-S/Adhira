import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/localized_helpers.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Scholarship Scheme Detail page.
class ScholarshipDetailPage extends StatelessWidget {
  final String name;
  final ScholarshipType type;
  final String description;
  final String amount;
  final String deadline;

  const ScholarshipDetailPage({
    super.key,
    this.name = 'Post-Matric Scholarship for ST',
    this.type = ScholarshipType.postMatric,
    this.description =
        'Financial assistance to Scheduled Tribe students studying at post-matriculation or post-secondary stages to enable them to complete their education.',
    this.amount = 'Up to ₹1,30,000/year',
    this.deadline = '31 Jan 2026',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final schemeColor = _getSchemeColor();
    final displayName = LocalizedHelpers.getScholarshipTypeName(context, type);
    final displayDesc = LocalizedHelpers.getScholarshipTypeDesc(context, type);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.scholarshipDiscovery),
        title: Text(l10n.schemeDetails),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: schemeColor.withOpacity(0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: schemeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          type.shortCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const StatusBadge(label: 'Applications Open', variant: StatusBadgeVariant.success),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.motaTitle}, ${l10n.motaGov}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Content body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.currency_rupee,
                          title: 'Max Amount',
                          value: amount,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.calendar_month,
                          title: l10n.applicationDeadline,
                          value: deadline,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    displayDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Eligibility Checklist
                  Text(l10n.eligibilityCriteria, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const _CheckItem(text: 'Must belong to a notified Scheduled Tribe (ST) category.'),
                  const _CheckItem(text: 'Family annual income from all sources must not exceed ₹2.50 Lakh.'),
                  const _CheckItem(text: 'Must be enrolled in a recognised post-matric/post-secondary course.'),
                  const _CheckItem(text: 'Must hold a valid Aadhaar-linked bank account.'),
                  const SizedBox(height: 20),

                  // Required Documents
                  Text(l10n.requiredDocuments, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DocBadge(l10n.casteCertificate),
                      _DocBadge(l10n.incomeCertificate),
                      _DocBadge(l10n.aadhaarCard),
                      _DocBadge(l10n.marksheet12),
                      const _DocBadge('Bank Passbook'),
                      _DocBadge(l10n.bonafideCertificate),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  AppButton(
                    label: l10n.applyNow,
                    icon: Icons.send,
                    onPressed: () {
                      final scheme = context.read<ScholarshipDataService>().getScholarshipByType(type);
                      context.push(
                        RouteNames.applicationForm,
                        extra: {'scholarship': scheme},
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go(RouteNames.scholarshipDiscovery);
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.back),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSchemeColor() {
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
}

class _DocBadge extends StatelessWidget {
  final String label;
  const _DocBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3)),
          ),
        ],
      ),
    );
  }
}
