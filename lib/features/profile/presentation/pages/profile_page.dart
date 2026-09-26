import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../core/localization/app_localizations_extension.dart';

/// Student profile page — dynamically populated from authenticated student profile.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final student = authProvider.currentUser;
        final displayName = student?.fullName ?? 'Student';
        final initials = displayName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();
        final profilePercent = ((student?.profileCompletionPercent ?? 0.72) * 100).toInt();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myProfileTitle),
            actions: [
              IconButton(
                onPressed: () => context.push(RouteNames.profileEdit),
                icon: const Icon(Icons.edit),
                tooltip: l10n.editProfile,
              ),
              IconButton(
                onPressed: () => context.push(RouteNames.settings),
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.settingsTitle,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Avatar + name
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    initials.isNotEmpty ? initials : 'ST',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Student ID: ${student?.id ?? "N/A"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),

                // Profile completion badge + DigiLocker status
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.profileCompletion(profilePercent),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    if (student?.isDigiLockerLinked == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Verified with DigiLocker',
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Profile sections (Dynamic)
                _ProfileSection(title: l10n.personalDetails, items: [
                  _ProfileItem(label: l10n.fullName, value: student?.fullName ?? '—'),
                  _ProfileItem(label: l10n.fatherName, value: student?.fatherName ?? '—'),
                  _ProfileItem(label: l10n.motherName, value: student?.motherName ?? '—'),
                  _ProfileItem(
                    label: l10n.dateOfBirth,
                    value: student?.dateOfBirth != null
                        ? '${student!.dateOfBirth!.day}/${student.dateOfBirth!.month}/${student.dateOfBirth!.year}'
                        : '14 Aug 2004',
                  ),
                  _ProfileItem(label: l10n.gender, value: student?.gender ?? l10n.male),
                  _ProfileItem(label: 'Aadhaar (Masked)', value: student?.aadhaarNumber ?? 'XXXX-XXXX-4892'),
                  _ProfileItem(label: l10n.mobileNumber, value: student?.mobileNumber != null ? '+91 ${student!.mobileNumber}' : '—'),
                  _ProfileItem(label: 'Email', value: student?.email ?? '—'),
                ]),
                _ProfileSection(title: l10n.tribalDetails, items: [
                  _ProfileItem(label: l10n.category, value: student?.category ?? 'ST'),
                  _ProfileItem(label: l10n.tribeName, value: student?.tribeName ?? 'Santal'),
                  _ProfileItem(label: l10n.pvtgStatus, value: (student?.isPVTG == true) ? l10n.yes : l10n.no),
                  _ProfileItem(label: l10n.casteCertificate, value: student?.stCertificateNumber ?? 'SC/OD/2023/12345'),
                  _ProfileItem(label: 'Address', value: student?.address ?? 'Plot 42, Baripada'),
                  _ProfileItem(label: l10n.district, value: student?.district ?? 'Mayurbhanj'),
                  _ProfileItem(label: l10n.state, value: student?.state ?? 'Odisha'),
                  if (student?.pinCode != null) _ProfileItem(label: 'PIN Code', value: student!.pinCode!),
                ]),
                _ProfileSection(title: l10n.educationDetails, items: [
                  _ProfileItem(label: 'Level', value: student?.educationLevel ?? 'Undergraduate'),
                  _ProfileItem(label: l10n.courseName, value: student?.currentCourse ?? 'B.Tech Computer Science'),
                  _ProfileItem(label: l10n.currentYear, value: student?.currentYear ?? '2nd Year'),
                  _ProfileItem(label: l10n.institutionName, value: student?.institutionName ?? 'NIT Rourkela'),
                  _ProfileItem(label: 'AISHE Code', value: student?.institutionId ?? 'AISHE-U-0355'),
                ]),
                _ProfileSection(title: l10n.bankDetails, items: [
                  _ProfileItem(label: l10n.bankName, value: student?.bankName ?? 'State Bank of India'),
                  _ProfileItem(label: l10n.accountNumber, value: student?.bankAccountNumber ?? '****7890'),
                  _ProfileItem(label: l10n.ifscCode, value: student?.ifscCode ?? 'SBIN0001234'),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNav(currentIndex: 4),
        );
      },
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
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.map((item) => _buildRow(context, item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, _ProfileItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(item.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final String label;
  final String value;
  const _ProfileItem({required this.label, required this.value});
}
