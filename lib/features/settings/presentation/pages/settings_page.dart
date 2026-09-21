import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Settings page with real session logout and confirmation.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 10),
            Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of your account? You will need to verify your mobile number again to log in.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      if (context.mounted) {
        context.go(RouteNames.login);
      }
    }
  }

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
            _SettingsTile(icon: Icons.language, title: 'Language', subtitle: 'English (English)', onTap: () {}),
            _SettingsTile(icon: Icons.notifications_none, title: 'Notification Preferences', onTap: () {}),
            _SettingsTile(icon: Icons.dark_mode_outlined, title: 'Theme', subtitle: 'System Default', onTap: () {}),
          ]),
          _SettingsSection(title: 'Security', items: [
            _SettingsTile(icon: Icons.fingerprint, title: 'Biometric Login', subtitle: 'Enabled', onTap: () {}),
            _SettingsTile(icon: Icons.pin_outlined, title: 'App PIN', subtitle: 'Change PIN', onTap: () {}),
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
              onPressed: () => _handleLogout(context),
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
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppColors.textPrimary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
