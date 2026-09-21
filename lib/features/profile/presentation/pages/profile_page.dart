import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';

/// Student profile page.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar + name
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryLight,
              child: Text('RS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            Text('Rajesh Singh', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            Text('Student ID: TSS-2025-45678', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            // Profile completion
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
              child: const Text('Profile: 72% Complete', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            const SizedBox(height: 24),

            // Profile sections
            _ProfileSection(title: 'Personal Details', items: [
              _ProfileItem(label: 'Full Name', value: 'Rajesh Singh'),
              _ProfileItem(label: 'Father\'s Name', value: 'Manoj Singh'),
              _ProfileItem(label: 'Date of Birth', value: '15 Mar 2003'),
              _ProfileItem(label: 'Gender', value: 'Male'),
              _ProfileItem(label: 'Mobile', value: '+91 98765 43210'),
              _ProfileItem(label: 'Email', value: 'rajesh.singh@email.com'),
            ]),
            _ProfileSection(title: 'ST/Tribal Details', items: [
              _ProfileItem(label: 'Tribe', value: 'Santal'),
              _ProfileItem(label: 'PVTG', value: 'No'),
              _ProfileItem(label: 'ST Certificate', value: 'SC/OD/2023/12345'),
              _ProfileItem(label: 'State', value: 'Odisha'),
              _ProfileItem(label: 'District', value: 'Mayurbhanj'),
            ]),
            _ProfileSection(title: 'Education', items: [
              _ProfileItem(label: 'Course', value: 'B.Tech Computer Science'),
              _ProfileItem(label: 'Year', value: '2nd Year'),
              _ProfileItem(label: 'Institution', value: 'NIT Rourkela'),
              _ProfileItem(label: 'AISHE Code', value: 'C-12345'),
            ]),
            _ProfileSection(title: 'Bank Details', items: [
              _ProfileItem(label: 'Bank', value: 'State Bank of India'),
              _ProfileItem(label: 'Account', value: '****7890'),
              _ProfileItem(label: 'IFSC', value: 'SBIN0001234'),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;
  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
