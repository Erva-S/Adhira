import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/scholarship_card.dart';

/// Scholarship discovery page — browse and filter all 5 schemes.
class ScholarshipDiscoveryPage extends StatefulWidget {
  const ScholarshipDiscoveryPage({super.key});

  @override
  State<ScholarshipDiscoveryPage> createState() => _ScholarshipDiscoveryPageState();
}

class _ScholarshipDiscoveryPageState extends State<ScholarshipDiscoveryPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      ('All', l10n.allSchemes),
      ('Pre-Matric', l10n.preMatric),
      ('Post-Matric', l10n.postMatric),
      ('Top Class', l10n.topClass),
      ('NFST', l10n.nfst),
      ('NOS', l10n.nos),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scholarshipSchemes),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              hintText: '${l10n.scholarshipSchemes}...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filterItem = filters[index];
                final isSelected = filterItem.$1 == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(filterItem.$2),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filterItem.$1),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Scholarship list
          Expanded(
            child: ListView(
              children: [
                ScholarshipCard(
                  name: 'Pre-Matric Scholarship for ST',
                  type: ScholarshipType.preMatric,
                  description: 'Financial assistance for ST students studying in classes 9 and 10 to reduce dropout rates.',
                  amount: 'Up to ₹10,000/year',
                  deadline: '31 Dec 2025',
                  onTap: () => context.push(
                    RouteNames.scholarshipDetails,
                    extra: {
                      'name': 'Pre-Matric Scholarship for ST',
                      'type': ScholarshipType.preMatric,
                      'description': 'Financial assistance for ST students studying in classes 9 and 10 to reduce dropout rates.',
                      'amount': 'Up to ₹10,000/year',
                      'deadline': '31 Dec 2025',
                    },
                  ),
                ),
                ScholarshipCard(
                  name: 'Post-Matric Scholarship for ST',
                  type: ScholarshipType.postMatric,
                  description: 'Support for ST students pursuing post-matriculation courses including professional and technical courses.',
                  amount: 'Up to ₹1,30,000/year',
                  deadline: '31 Jan 2026',
                  onTap: () => context.push(
                    RouteNames.scholarshipDetails,
                    extra: {
                      'name': 'Post-Matric Scholarship for ST',
                      'type': ScholarshipType.postMatric,
                      'description': 'Support for ST students pursuing post-matriculation courses including professional and technical courses.',
                      'amount': 'Up to ₹1,30,000/year',
                      'deadline': '31 Jan 2026',
                    },
                  ),
                ),
                ScholarshipCard(
                  name: 'Top Class Education for ST',
                  type: ScholarshipType.topClass,
                  description: 'Full financial support for ST students admitted to top institutions like IITs, IIMs, NITs, AIIMS.',
                  amount: 'Full tuition + allowance',
                  deadline: '28 Feb 2026',
                  onTap: () => context.push(
                    RouteNames.scholarshipDetails,
                    extra: {
                      'name': 'Top Class Education for ST',
                      'type': ScholarshipType.topClass,
                      'description': 'Full financial support for ST students admitted to top institutions like IITs, IIMs, NITs, AIIMS.',
                      'amount': 'Full tuition + allowance',
                      'deadline': '28 Feb 2026',
                    },
                  ),
                ),
                ScholarshipCard(
                  name: 'National Fellowship for ST (NFST)',
                  type: ScholarshipType.nfst,
                  description: 'Fellowship for ST students pursuing M.Phil and Ph.D in universities, colleges, and institutions.',
                  amount: '₹31,000-₹35,000/month',
                  deadline: '15 Mar 2026',
                  onTap: () => context.push(
                    RouteNames.scholarshipDetails,
                    extra: {
                      'name': 'National Fellowship for ST (NFST)',
                      'type': ScholarshipType.nfst,
                      'description': 'Fellowship for ST students pursuing M.Phil and Ph.D in universities, colleges, and institutions.',
                      'amount': '₹31,000-₹35,000/month',
                      'deadline': '15 Mar 2026',
                    },
                  ),
                ),
                ScholarshipCard(
                  name: 'National Overseas Scholarship',
                  type: ScholarshipType.nos,
                  description: 'Support for ST students to study abroad at Masters and Ph.D level in accredited institutions.',
                  amount: 'Full funding abroad',
                  deadline: '30 Apr 2026',
                  onTap: () => context.push(
                    RouteNames.scholarshipDetails,
                    extra: {
                      'name': 'National Overseas Scholarship',
                      'type': ScholarshipType.nos,
                      'description': 'Support for ST students to study abroad at Masters and Ph.D level in accredited institutions.',
                      'amount': 'Full funding abroad',
                      'deadline': '30 Apr 2026',
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
