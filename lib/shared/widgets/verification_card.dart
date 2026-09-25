import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/app_enums.dart';
import 'status_badge.dart';

/// Verification card showing a verification item's status.
class VerificationCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VerificationStatus status;
  final String? sourceSystem;
  final bool isAutomatic;
  final VoidCallback? onTap;

  const VerificationCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.status,
    this.sourceSystem,
    this.isAutomatic = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null || sourceSystem != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle ?? (isAutomatic ? 'Auto • $sourceSystem' : sourceSystem ?? ''),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.fromVerificationStatus(status),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case VerificationStatus.verified: return AppColors.success;
      case VerificationStatus.failed: return AppColors.error;
      case VerificationStatus.inProgress: return AppColors.info;
      case VerificationStatus.mismatch: return AppColors.mismatch;
      case VerificationStatus.manualReview: return AppColors.warning;
      case VerificationStatus.pending: return AppColors.textTertiary;
      case VerificationStatus.notApplicable: return AppColors.textTertiary;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case VerificationStatus.verified: return Icons.check_circle;
      case VerificationStatus.failed: return Icons.cancel;
      case VerificationStatus.inProgress: return Icons.hourglass_top;
      case VerificationStatus.mismatch: return Icons.warning;
      case VerificationStatus.manualReview: return Icons.person_search;
      case VerificationStatus.pending: return Icons.schedule;
      case VerificationStatus.notApplicable: return Icons.remove_circle_outline;
    }
  }
}
