import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/enums/app_enums.dart';

/// Unified status badge widget — replaces 4 FlutterFlow StatusBadge variants.
/// Configurable via [variant] and [status]-based auto-coloring.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fontSize,
  });

  /// Create from an [ApplicationStatus].
  factory StatusBadge.fromApplicationStatus(ApplicationStatus status) {
    return StatusBadge(
      label: status.label,
      variant: _variantFromAppStatus(status),
    );
  }

  /// Create from a [VerificationStatus].
  factory StatusBadge.fromVerificationStatus(VerificationStatus status) {
    return StatusBadge(
      label: status.label,
      variant: _variantFromVerifStatus(status),
    );
  }

  /// Create from a [PaymentStatus].
  factory StatusBadge.fromPaymentStatus(PaymentStatus status) {
    return StatusBadge(
      label: status.label,
      variant: _variantFromPaymentStatus(status),
    );
  }

  /// Create from a [DocumentStatus].
  factory StatusBadge.fromDocumentStatus(DocumentStatus status) {
    return StatusBadge(
      label: status.label,
      variant: _variantFromDocStatus(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? colors.$2),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? colors.$2,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (variant) {
      case StatusBadgeVariant.success:
        return (AppColors.successLight, AppColors.successDark);
      case StatusBadgeVariant.warning:
        return (AppColors.warningLight, AppColors.warningDark);
      case StatusBadgeVariant.error:
        return (AppColors.errorLight, AppColors.errorDark);
      case StatusBadgeVariant.info:
        return (AppColors.infoLight, AppColors.infoDark);
      case StatusBadgeVariant.neutral:
        return (AppColors.surfaceVariant, AppColors.textSecondary);
      case StatusBadgeVariant.accent:
        return (AppColors.accentLight, AppColors.accentDark);
      case StatusBadgeVariant.mismatch:
        return (const Color(0xFFF3E5F5), AppColors.mismatch);
    }
  }

  static StatusBadgeVariant _variantFromAppStatus(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.draft: return StatusBadgeVariant.neutral;
      case ApplicationStatus.submitted: return StatusBadgeVariant.info;
      case ApplicationStatus.underReview: return StatusBadgeVariant.warning;
      case ApplicationStatus.verified: return StatusBadgeVariant.success;
      case ApplicationStatus.approved: return StatusBadgeVariant.success;
      case ApplicationStatus.sanctioned: return StatusBadgeVariant.accent;
      case ApplicationStatus.disbursementInitiated: return StatusBadgeVariant.info;
      case ApplicationStatus.disbursed: return StatusBadgeVariant.success;
      case ApplicationStatus.rejected: return StatusBadgeVariant.error;
      case ApplicationStatus.incomplete: return StatusBadgeVariant.warning;
      case ApplicationStatus.withdrawn: return StatusBadgeVariant.neutral;
    }
  }

  static StatusBadgeVariant _variantFromVerifStatus(VerificationStatus s) {
    switch (s) {
      case VerificationStatus.pending: return StatusBadgeVariant.neutral;
      case VerificationStatus.inProgress: return StatusBadgeVariant.info;
      case VerificationStatus.verified: return StatusBadgeVariant.success;
      case VerificationStatus.failed: return StatusBadgeVariant.error;
      case VerificationStatus.mismatch: return StatusBadgeVariant.mismatch;
      case VerificationStatus.manualReview: return StatusBadgeVariant.warning;
      case VerificationStatus.notApplicable: return StatusBadgeVariant.neutral;
    }
  }

  static StatusBadgeVariant _variantFromPaymentStatus(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.sanctioned: return StatusBadgeVariant.info;
      case PaymentStatus.processing: return StatusBadgeVariant.warning;
      case PaymentStatus.disbursed: return StatusBadgeVariant.success;
      case PaymentStatus.failed: return StatusBadgeVariant.error;
      case PaymentStatus.pending: return StatusBadgeVariant.neutral;
      case PaymentStatus.returned: return StatusBadgeVariant.error;
    }
  }

  static StatusBadgeVariant _variantFromDocStatus(DocumentStatus s) {
    switch (s) {
      case DocumentStatus.notUploaded: return StatusBadgeVariant.neutral;
      case DocumentStatus.uploaded: return StatusBadgeVariant.info;
      case DocumentStatus.verified: return StatusBadgeVariant.success;
      case DocumentStatus.rejected: return StatusBadgeVariant.error;
      case DocumentStatus.expired: return StatusBadgeVariant.warning;
      case DocumentStatus.digilockerLinked: return StatusBadgeVariant.accent;
    }
  }
}

/// Visual variants for the status badge.
enum StatusBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
  accent,
  mismatch,
}
