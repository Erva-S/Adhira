import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/app_enums.dart';
import '../../core/localization/app_localizations_extension.dart';
import '../../core/localization/localized_helpers.dart';
import 'status_badge.dart';
import 'app_button.dart';

/// Scholarship card for discovery/listing pages.
class ScholarshipCard extends StatelessWidget {
  final String name;
  final ScholarshipType type;
  final String description;
  final String? amount;
  final String? deadline;
  final bool isOpen;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const ScholarshipCard({
    super.key,
    required this.name,
    required this.type,
    required this.description,
    this.amount,
    this.deadline,
    this.isOpen = true,
    this.onTap,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localizedName = LocalizedHelpers.getScholarshipTypeName(context, type);
    final localizedDesc = LocalizedHelpers.getScholarshipTypeDesc(context, type);

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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getSchemeColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSchemeIcon(),
                      color: _getSchemeColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedName.isNotEmpty ? localizedName : name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          type.shortCode,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getSchemeColor(),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: isOpen ? 'Open' : 'Closed',
                    variant: isOpen
                        ? StatusBadgeVariant.success
                        : StatusBadgeVariant.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                localizedDesc.isNotEmpty ? localizedDesc : description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (amount != null) ...[
                    const Icon(Icons.currency_rupee, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      amount!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (deadline != null) ...[
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      deadline!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                  const Spacer(),
                  if (onApply != null)
                    AppButton(
                      label: l10n.applyNow,
                      size: AppButtonSize.small,
                      isFullWidth: false,
                      onPressed: onApply,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSchemeColor() {
    switch (type) {
      case ScholarshipType.preMatric: return AppColors.preMatric;
      case ScholarshipType.postMatric: return AppColors.postMatric;
      case ScholarshipType.topClass: return AppColors.topClass;
      case ScholarshipType.nfst: return AppColors.nfst;
      case ScholarshipType.nos: return AppColors.nos;
    }
  }

  IconData _getSchemeIcon() {
    switch (type) {
      case ScholarshipType.preMatric: return Icons.school;
      case ScholarshipType.postMatric: return Icons.menu_book;
      case ScholarshipType.topClass: return Icons.star;
      case ScholarshipType.nfst: return Icons.science;
      case ScholarshipType.nos: return Icons.flight;
    }
  }
}
