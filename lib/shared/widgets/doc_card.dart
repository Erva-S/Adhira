import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/app_enums.dart';
import 'status_badge.dart';

/// Document card for the document wallet.
class DocCard extends StatelessWidget {
  final String name;
  final DocumentCategory category;
  final DocumentStatus status;
  final String? uploadDate;
  final bool isFromDigiLocker;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const DocCard({
    super.key,
    required this.name,
    required this.category,
    required this.status,
    this.uploadDate,
    this.isFromDigiLocker = false,
    this.onTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, color: AppColors.info, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          category.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        if (isFromDigiLocker) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DigiLocker',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge.fromDocumentStatus(status),
              if (onDownload != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
