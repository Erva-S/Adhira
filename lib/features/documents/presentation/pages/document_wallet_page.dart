import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/doc_card.dart';
import '../widgets/upload_document_dialog.dart';
import 'digilocker_consent_page.dart';

/// Document wallet page — manage and view uploaded documents dynamically.
class DocumentWalletPage extends StatefulWidget {
  const DocumentWalletPage({super.key});

  @override
  State<DocumentWalletPage> createState() => _DocumentWalletPageState();
}

class _DocumentWalletPageState extends State<DocumentWalletPage> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Identity', 'Caste', 'Income', 'Academic', 'Bank'];

  void _openDigiLockerPage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const DigiLockerConsentPage(autoImportToWallet: true),
      ),
    );
    if (result == true && mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('DigiLocker documents added to wallet!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showUploadDialog(BuildContext context, ScholarshipDataService service) {
    showUploadDocumentDialog(
      context: context,
      service: service,
      defaultCategory: DocumentCategory.academic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScholarshipDataService>(
      builder: (context, scholarshipService, _) {
        final allDocs = scholarshipService.documents;

        // Dynamic stats
        final total = allDocs.length;
        final verified = allDocs.where((d) => d.status == DocumentStatus.verified).length;
        final pending = allDocs.where((d) => d.status == DocumentStatus.uploaded).length;
        final rejected = allDocs.where((d) => d.status == DocumentStatus.rejected).length;

        // Filtered docs
        final filteredDocs = allDocs.where((doc) {
          if (_selectedCategory == 'All') return true;
          return doc.category.label.toLowerCase() == _selectedCategory.toLowerCase();
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.docWallet),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: () => _openDigiLockerPage(context),
                  icon: const Icon(Icons.verified_user_rounded, size: 16),
                  label: const Text(
                    'DigiLocker',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B57D0),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _DocStat(label: 'Total', value: '$total', color: AppColors.primary),
                    _DocStat(label: context.l10n.statusVerified, value: '$verified', color: AppColors.success),
                    _DocStat(label: context.l10n.statusPending, value: '$pending', color: AppColors.warning),
                    _DocStat(label: context.l10n.statusRejected, value: '$rejected', color: AppColors.error),
                  ],
                ),
              ),
              // Category chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Document cards
              Expanded(
                child: filteredDocs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              _selectedCategory == 'All'
                                  ? 'No documents uploaded yet.'
                                  : 'No $_selectedCategory documents found.',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Upload First Document',
                              variant: AppButtonVariant.outline,
                              size: AppButtonSize.small,
                              onPressed: () => _showUploadDialog(context, scholarshipService),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          return DocCard(
                            name: doc.name,
                            category: doc.category,
                            status: doc.status,
                            isFromDigiLocker: doc.isFromDigiLocker,
                            onTap: () => context.push(
                              RouteNames.documentDetails,
                              extra: {
                                'name': doc.name,
                                'category': doc.category,
                                'status': doc.status,
                                'isFromDigiLocker': doc.isFromDigiLocker,
                                'rejectionReason': doc.rejectionReason,
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showUploadDialog(context, scholarshipService),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
          ),
          bottomNavigationBar: const AppBottomNav(currentIndex: 2),
        );
      },
    );
  }
}

class _DocStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DocStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
