import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/integrations/digilocker/digilocker_service.dart';
import '../../../../shared/models/document.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/doc_card.dart';

/// Document wallet page — manage and view uploaded documents dynamically.
class DocumentWalletPage extends StatefulWidget {
  const DocumentWalletPage({super.key});

  @override
  State<DocumentWalletPage> createState() => _DocumentWalletPageState();
}

class _DocumentWalletPageState extends State<DocumentWalletPage> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Identity', 'Caste', 'Income', 'Academic', 'Bank'];
  final DigiLockerService _digiLockerService = MockDigiLockerService();

  void _showDigiLockerSheet(BuildContext context, ScholarshipDataService service) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<List<DigiLockerDocument>>(
          future: _digiLockerService.getAvailableDocuments(),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 480,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Import from DigiLocker',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _digiLockerService.status.label,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select issued government certificate to import into your wallet:',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty)
                    const Expanded(child: Center(child: Text('No DigiLocker documents found.')))
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final doc = snapshot.data![i];
                          return ListTile(
                            leading: const Icon(Icons.file_present_outlined, color: AppColors.primary),
                            title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(doc.issuer, style: const TextStyle(fontSize: 12)),
                            trailing: TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final imported = await _digiLockerService.importDocument(
                                  doc.uri,
                                  service.currentUserId,
                                );
                                if (imported != null) {
                                  await service.uploadDocument(
                                    name: doc.name,
                                    category: _mapDocTypeToCategory(doc.docType),
                                    documentType: doc.docType,
                                    fileName: '${doc.docType.toLowerCase()}.pdf',
                                    bytes: imported.bytes,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${doc.name} imported and verified from DigiLocker!')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Import'),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUploadDialog(BuildContext context, ScholarshipDataService service) {
    final nameCtrl = TextEditingController();
    DocumentCategory selectedCat = DocumentCategory.academic;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Upload Document'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Document Name',
                      hintText: 'e.g., Bonafide Certificate',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DocumentCategory>(
                    value: selectedCat,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: DocumentCategory.values.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCat = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);

                    // Simulated upload payload
                    final dummyBytes = Uint8List.fromList(
                      'Document file content for ${nameCtrl.text}'.codeUnits,
                    );

                    await service.uploadDocument(
                      name: nameCtrl.text.trim(),
                      category: selectedCat,
                      documentType: nameCtrl.text.trim().toUpperCase().replaceAll(' ', '_'),
                      fileName: '${nameCtrl.text.trim().toLowerCase().replaceAll(" ", "_")}.pdf',
                      bytes: dummyBytes,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${nameCtrl.text.trim()} uploaded successfully!')),
                      );
                    }
                  },
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DocumentCategory _mapDocTypeToCategory(String docType) {
    if (docType.contains('ADHAR') || docType.contains('ID')) return DocumentCategory.identity;
    if (docType.contains('CASTE') || docType.contains('ST')) return DocumentCategory.caste;
    if (docType.contains('INCOME')) return DocumentCategory.income;
    if (docType.contains('12') || docType.contains('MRKSHT')) return DocumentCategory.academic;
    if (docType.contains('BANK')) return DocumentCategory.bank;
    return DocumentCategory.other;
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
            title: const Text('Document Wallet'),
            actions: [
              TextButton.icon(
                onPressed: () => _showDigiLockerSheet(context, scholarshipService),
                icon: const Icon(Icons.link, size: 18),
                label: const Text('DigiLocker'),
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
                    _DocStat(label: 'Verified', value: '$verified', color: AppColors.success),
                    _DocStat(label: 'Pending', value: '$pending', color: AppColors.warning),
                    _DocStat(label: 'Rejected', value: '$rejected', color: AppColors.error),
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
                            Icon(Icons.folder_open_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
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
