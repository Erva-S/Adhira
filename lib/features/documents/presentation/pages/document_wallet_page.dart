import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
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
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const DigiLockerConsentPage(autoImportToWallet: true),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
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
    final nameCtrl = TextEditingController();
    DocumentCategory selectedCat = DocumentCategory.academic;
    String? selectedFileName;
    int? selectedFileSize;
    Uint8List? selectedFileBytes;
    bool isUploading = false;
    String? validationError;

    showDialog(
      context: context,
      barrierDismissible: !isUploading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickFileFromDevice() async {
              try {
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  withData: true,
                );
                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  setDialogState(() {
                    selectedFileName = file.name;
                    selectedFileSize = file.size;
                    selectedFileBytes = file.bytes;
                    validationError = null;

                    if (nameCtrl.text.trim().isEmpty) {
                      final cleanName = file.name
                          .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
                          .replaceAll(RegExp(r'[_-]'), ' ')
                          .trim();
                      if (cleanName.isNotEmpty) {
                        nameCtrl.text = cleanName
                            .split(' ')
                            .map((w) => w.isNotEmpty
                                ? '${w[0].toUpperCase()}${w.substring(1)}'
                                : '')
                            .join(' ');
                      }
                    }
                  });
                }
              } catch (e) {
                setDialogState(() => validationError = 'Error selecting file: $e');
              }
            }

            void selectSampleDoc(String name, DocumentCategory cat, String filename) {
              setDialogState(() {
                nameCtrl.text = name;
                selectedCat = cat;
                selectedFileName = filename;
                selectedFileSize = 245 * 1024; // 245 KB
                selectedFileBytes = Uint8List.fromList(
                  '%PDF-1.4 MoTA Sample Document for $name'.codeUnits,
                );
                validationError = null;
              });
            }

            String formatSize(int bytes) {
              if (bytes < 1024) return '$bytes B';
              if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
              return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.upload_file, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Upload Document',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // File picker drop-zone / card
                    InkWell(
                      onTap: isUploading ? null : pickFileFromDevice,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedFileName != null
                              ? AppColors.successLight.withValues(alpha: 0.4)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedFileName != null
                                ? AppColors.success
                                : AppColors.border,
                            width: selectedFileName != null ? 1.5 : 1,
                          ),
                        ),
                        child: selectedFileName != null
                            ? Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.successLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      selectedFileName!.toLowerCase().endsWith('.pdf')
                                          ? Icons.picture_as_pdf
                                          : Icons.image,
                                      color: AppColors.success,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedFileName!,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatSize(selectedFileSize ?? 0),
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: isUploading ? null : pickFileFromDevice,
                                    child: const Text('Change', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Choose a file from device',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'PDF, JPG, or PNG (Max 10 MB)',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: isUploading ? null : pickFileFromDevice,
                                    icon: const Icon(Icons.folder_open, size: 16),
                                    label: const Text('Browse Files'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Sample Helpers
                    const Text(
                      'Or pick quick sample MoTA document:',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          label: const Text('ST Certificate', style: TextStyle(fontSize: 11)),
                          avatar: const Icon(Icons.badge_outlined, size: 14),
                          onPressed: isUploading
                              ? null
                              : () => selectSampleDoc('ST Certificate', DocumentCategory.caste, 'st_certificate.pdf'),
                        ),
                        ActionChip(
                          label: const Text('Income Certificate', style: TextStyle(fontSize: 11)),
                          avatar: const Icon(Icons.receipt_outlined, size: 14),
                          onPressed: isUploading
                              ? null
                              : () => selectSampleDoc('Income Certificate', DocumentCategory.income, 'income_cert.pdf'),
                        ),
                        ActionChip(
                          label: const Text('Bonafide', style: TextStyle(fontSize: 11)),
                          avatar: const Icon(Icons.school_outlined, size: 14),
                          onPressed: isUploading
                              ? null
                              : () => selectSampleDoc('Bonafide Certificate', DocumentCategory.academic, 'bonafide.pdf'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Document Name Field
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Document Name *',
                        hintText: 'e.g., ST Certificate',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      onChanged: (_) {
                        if (validationError != null) {
                          setDialogState(() => validationError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Category Dropdown
                    DropdownButtonFormField<DocumentCategory>(
                      initialValue: selectedCat,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: DocumentCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.label, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCat = val);
                      },
                    ),

                    // Validation Error Text
                    if (validationError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        validationError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isUploading ? null : () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isUploading
                              ? null
                              : () async {
                                  if (nameCtrl.text.trim().isEmpty) {
                                    setDialogState(() => validationError = 'Please enter a document name');
                                    return;
                                  }

                                  setDialogState(() {
                                    isUploading = true;
                                    validationError = null;
                                  });

                                  final bytes = selectedFileBytes ??
                                      Uint8List.fromList(
                                        '%PDF-1.4 MoTA Document Content for ${nameCtrl.text}'.codeUnits,
                                      );
                                  final fileName = selectedFileName ??
                                      '${nameCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), "_")}.pdf';

                                  await service.uploadDocument(
                                    name: nameCtrl.text.trim(),
                                    category: selectedCat,
                                    documentType: nameCtrl.text.trim().toUpperCase().replaceAll(' ', '_'),
                                    fileName: fileName,
                                    bytes: bytes,
                                  );

                                  if (ctx.mounted) Navigator.pop(ctx);

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text('${nameCtrl.text.trim()} uploaded successfully!'),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: isUploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Upload'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
