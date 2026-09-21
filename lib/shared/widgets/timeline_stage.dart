import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/app_enums.dart';
import 'status_badge.dart';

/// Timeline stage for application tracking.
class TimelineStage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? date;
  final VerificationStatus status;
  final bool isLast;
  final bool isFirst;

  const TimelineStage({
    super.key,
    required this.title,
    this.subtitle,
    this.date,
    required this.status,
    this.isLast = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == VerificationStatus.verified;
    final isActive = status == VerificationStatus.inProgress;
    final dotColor = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textTertiary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 8, color: dotColor),
                Container(
                  width: isActive ? 16 : 12,
                  height: isActive ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isCompleted ? dotColor : Colors.transparent,
                    border: Border.all(color: dotColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: dotColor.withOpacity(0.3))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isCompleted || isActive
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                        ),
                      ),
                      StatusBadge.fromVerificationStatus(status),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      date!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
