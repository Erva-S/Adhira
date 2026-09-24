import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/widgets/language_selector_sheet.dart';

/// Settings page with real session logout and confirmation.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.error),
            const SizedBox(width: 10),
            Text(l10n.signOutConfirmTitle),
          ],
        ),
        content: Text(
          l10n.signOutConfirmMsg,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.signOut),
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
    final l10n = context.l10n;
    LocaleProvider? localeProvider;
    try {
      localeProvider = Provider.of<LocaleProvider>(context, listen: true);
    } catch (_) {}
    final currentLang = localeProvider?.currentLanguage ?? LocaleProvider.supportedLanguages.first;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.profile),
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          _SettingsSection(title: l10n.preferences, items: [
            _SettingsTile(
              icon: Icons.language,
              title: l10n.language,
              subtitle: '${currentLang.nativeName} (${currentLang.englishName})',
              onTap: () => showLanguageSelectorSheet(context),
            ),
            _SettingsTile(icon: Icons.notifications_none, title: 'Notification Preferences', onTap: () {}),
            _SettingsTile(icon: Icons.dark_mode_outlined, title: 'Theme', subtitle: 'System Default', onTap: () {}),
          ]),
          _SettingsSection(title: l10n.security, items: [
            _SettingsTile(icon: Icons.fingerprint, title: 'Biometric Login', subtitle: 'Enabled', onTap: () {}),
            _SettingsTile(icon: Icons.pin_outlined, title: 'App PIN', subtitle: 'Change PIN', onTap: () {}),
          ]),
          _SettingsSection(title: l10n.support, items: [
            _SettingsTile(icon: Icons.help_outline, title: l10n.helpAndFaq, onTap: () {}),
            _SettingsTile(icon: Icons.headset_mic, title: l10n.contactSupport, subtitle: 'Helpline: 1800-xxx-xxxx', onTap: () {}),
            _SettingsTile(icon: Icons.feedback, title: 'Send Feedback', onTap: () {}),
          ]),
          _SettingsSection(title: l10n.about, items: [
            _SettingsTile(icon: Icons.info, title: l10n.appVersion, subtitle: '1.0.0 (Build 1)', onTap: () {}),
            _SettingsTile(icon: Icons.public, title: l10n.motaWebsite, subtitle: 'tribal.nic.in', onTap: () {}),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(l10n.logout, style: const TextStyle(color: AppColors.error)),
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
