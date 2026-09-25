import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/app_enums.dart';
import 'status_badge.dart';

/// Compact card for displaying a scholarship application in lists.
class ApplicationCard extends StatelessWidget {
  final String scholarshipName;
  final ScholarshipType scholarshipType;
  final ApplicationStatus status;
  final String? applicationNumber;
  final String? lastUpdated;
  final int pendingActionsCount;
  final VoidCallback? onTap;

  const ApplicationCard({
    super.key,
    required this.scholarshipName,
    required this.scholarshipType,
    required this.status,
    this.applicationNumber,
    this.lastUpdated,
    this.pendingActionsCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final schemeColor = _getSchemeColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Scheme color indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: schemeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Scheme icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: schemeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSchemeIcon(),
                      color: schemeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & app number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scholarshipName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (applicationNumber != null)
                          Text(
                            applicationNumber!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                          ),
                      ],
                    ),
                  ),
                  StatusBadge.fromApplicationStatus(status),
                ],
              ),
              if (lastUpdated != null || pendingActionsCount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 16), // align with content
                    if (lastUpdated != null) ...[
                      const Icon(Icons.access_time, size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        lastUpdated!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                    const Spacer(),
                    if (pendingActionsCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              '$pendingActionsCount pending',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warningDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSchemeColor() {
    switch (scholarshipType) {
      case ScholarshipType.preMatric: return AppColors.preMatric;
      case ScholarshipType.postMatric: return AppColors.postMatric;
      case ScholarshipType.topClass: return AppColors.topClass;
      case ScholarshipType.nfst: return AppColors.nfst;
      case ScholarshipType.nos: return AppColors.nos;
    }
  }

  IconData _getSchemeIcon() {
    switch (scholarshipType) {
      case ScholarshipType.preMatric: return Icons.school;
      case ScholarshipType.postMatric: return Icons.menu_book;
      case ScholarshipType.topClass: return Icons.star;
      case ScholarshipType.nfst: return Icons.science;
      case ScholarshipType.nos: return Icons.flight;
    }
  }
}
