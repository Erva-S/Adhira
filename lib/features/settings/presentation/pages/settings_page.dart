import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Settings page.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.profile),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SettingsSection(title: 'Preferences', items: [
            _SettingsTile(icon: Icons.language, title: 'Language', subtitle: 'English', onTap: () {}),
            _SettingsTile(icon: Icons.dark_mode, title: 'Dark Mode', subtitle: 'System default', onTap: () {}),
            _SettingsTile(icon: Icons.notifications, title: 'Notifications', subtitle: 'Enabled', onTap: () {}),
          ]),
          _SettingsSection(title: 'Privacy & Security', items: [
            _SettingsTile(icon: Icons.lock, title: 'Privacy Policy', onTap: () {}),
            _SettingsTile(icon: Icons.gavel, title: 'Terms of Service', onTap: () {}),
            _SettingsTile(icon: Icons.security, title: 'Data Consent', subtitle: 'Manage your data sharing preferences', onTap: () {}),
          ]),
          _SettingsSection(title: 'Support', items: [
            _SettingsTile(icon: Icons.help_outline, title: 'Help & FAQ', onTap: () {}),
            _SettingsTile(icon: Icons.headset_mic, title: 'Contact Support', subtitle: 'Helpline: 1800-xxx-xxxx', onTap: () {}),
            _SettingsTile(icon: Icons.feedback, title: 'Send Feedback', onTap: () {}),
          ]),
          _SettingsSection(title: 'About', items: [
            _SettingsTile(icon: Icons.info, title: 'App Version', subtitle: '1.0.0 (Build 1)', onTap: () {}),
            _SettingsTile(icon: Icons.public, title: 'MoTA Website', subtitle: 'tribal.nic.in', onTap: () {}),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => context.go(RouteNames.login),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Logout', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsTile> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
