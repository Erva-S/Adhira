import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Document detail page showing metadata and preview.
class DocumentDetailPage extends StatelessWidget {
  final String name;
  final DocumentCategory category;
  final DocumentStatus status;
  final bool isFromDigiLocker;

  const DocumentDetailPage({
    super.key,
    this.name = 'ST Certificate',
    this.category = DocumentCategory.caste,
    this.status = DocumentStatus.verified,
    this.isFromDigiLocker = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.documentWallet),
        title: const Text('Document Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFromDigiLocker ? Icons.verified : Icons.picture_as_pdf,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFromDigiLocker ? 'Verified via DigiLocker' : 'PDF Document • 1.2 MB',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metadata Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _MetaRow(label: 'Document Type', value: category.label),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Verification Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        StatusBadge(
                          label: status.label,
                          variant: status == DocumentStatus.verified
                              ? StatusBadgeVariant.success
                              : status == DocumentStatus.rejected
                                  ? StatusBadgeVariant.error
                                  : StatusBadgeVariant.warning,
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _MetaRow(label: 'Uploaded On', value: '16 Aug 2025'),
                    const Divider(height: 20),
                    _MetaRow(label: 'Source', value: isFromDigiLocker ? 'DigiLocker Verified' : 'Manual Upload'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading document...')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Document'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Document Wallet'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
