import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/doc_card.dart';

/// Document wallet page — manage and view uploaded documents.
class DocumentWalletPage extends StatefulWidget {
  const DocumentWalletPage({super.key});

  @override
  State<DocumentWalletPage> createState() => _DocumentWalletPageState();
}

class _DocumentWalletPageState extends State<DocumentWalletPage> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Identity', 'Caste', 'Income', 'Academic', 'Bank'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Wallet'),
        actions: [
          TextButton.icon(
            onPressed: () {},
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
                _DocStat(label: 'Total', value: '8', color: AppColors.primary),
                _DocStat(label: 'Verified', value: '5', color: AppColors.success),
                _DocStat(label: 'Pending', value: '2', color: AppColors.warning),
                _DocStat(label: 'Rejected', value: '1', color: AppColors.error),
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
            child: ListView(
              children: [
                DocCard(
                  name: 'Aadhaar Card',
                  category: DocumentCategory.identity,
                  status: DocumentStatus.verified,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'Aadhaar Card',
                      'category': DocumentCategory.identity,
                      'status': DocumentStatus.verified,
                      'isFromDigiLocker': false,
                    },
                  ),
                ),
                DocCard(
                  name: 'ST Certificate',
                  category: DocumentCategory.caste,
                  status: DocumentStatus.uploaded,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'ST Certificate',
                      'category': DocumentCategory.caste,
                      'status': DocumentStatus.uploaded,
                      'isFromDigiLocker': false,
                    },
                  ),
                ),
                DocCard(
                  name: 'Income Certificate',
                  category: DocumentCategory.income,
                  status: DocumentStatus.rejected,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'Income Certificate',
                      'category': DocumentCategory.income,
                      'status': DocumentStatus.rejected,
                      'isFromDigiLocker': false,
                    },
                  ),
                ),
                DocCard(
                  name: 'Class 12 Marksheet',
                  category: DocumentCategory.academic,
                  status: DocumentStatus.verified,
                  isFromDigiLocker: true,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'Class 12 Marksheet',
                      'category': DocumentCategory.academic,
                      'status': DocumentStatus.verified,
                      'isFromDigiLocker': true,
                    },
                  ),
                ),
                DocCard(
                  name: 'College Enrollment',
                  category: DocumentCategory.academic,
                  status: DocumentStatus.verified,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'College Enrollment',
                      'category': DocumentCategory.academic,
                      'status': DocumentStatus.verified,
                      'isFromDigiLocker': false,
                    },
                  ),
                ),
                DocCard(
                  name: 'Bank Passbook',
                  category: DocumentCategory.bank,
                  status: DocumentStatus.uploaded,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'Bank Passbook',
                      'category': DocumentCategory.bank,
                      'status': DocumentStatus.uploaded,
                      'isFromDigiLocker': false,
                    },
                  ),
                ),
                DocCard(
                  name: 'Domicile Certificate',
                  category: DocumentCategory.address,
                  status: DocumentStatus.verified,
                  isFromDigiLocker: true,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'Domicile Certificate',
                      'category': DocumentCategory.address,
                      'status': DocumentStatus.verified,
                      'isFromDigiLocker': true,
                    },
                  ),
                ),
                DocCard(
                  name: 'Passport Photo',
                  category: DocumentCategory.photo,
                  status: DocumentStatus.verified,
                  onTap: () => context.push(
                    RouteNames.documentDetails,
                    extra: {
                      'name': 'Passport Photo',
                      'category': DocumentCategory.photo,
                      'status': DocumentStatus.verified,
                      'isFromDigiLocker': false,
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
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
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
