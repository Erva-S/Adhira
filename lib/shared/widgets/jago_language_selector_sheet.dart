import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/jago/jago_context_service.dart';

/// Shows a bottom sheet allowing the user to select JAGO's chat language
/// independently of the app language. Includes a "Use App Language" option.
void showJagoLanguageSelectorSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _JagoLanguageSelectorSheetContent(),
  );
}

class _JagoLanguageSelectorSheetContent extends StatelessWidget {
  const _JagoLanguageSelectorSheetContent();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final jagoContext = JagoContextService();
    final effectiveCode = jagoContext.getEffectiveLanguageCode(localeProvider);
    final hasOverride = jagoContext.hasLanguageOverride;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Row(
            children: [
              Icon(Icons.translate, color: AppColors.primary, size: 24),
              SizedBox(width: 10),
              Text(
                'JAGO Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hasOverride
                  ? 'JAGO is using a custom language. Tap "Use App Language" to follow the app.'
                  : 'JAGO follows the app language. Choose a different language for JAGO only.',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),

          // "Use App Language" option
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor:
                  !hasOverride ? AppColors.primary : AppColors.surfaceVariant,
              child: Icon(
                Icons.sync,
                size: 16,
                color: !hasOverride ? Colors.white : AppColors.textPrimary,
              ),
            ),
            title: Text(
              'Use App Language',
              style: TextStyle(
                fontSize: 15,
                fontWeight: !hasOverride ? FontWeight.w700 : FontWeight.w500,
                color:
                    !hasOverride ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Currently: ${localeProvider.currentLanguage.nativeName} (${localeProvider.currentLanguage.englishName})',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: !hasOverride
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : const Icon(Icons.radio_button_unchecked,
                    color: AppColors.textTertiary),
            onTap: () {
              jagoContext.clearLanguageOverride();
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),

          // Languages list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: LocaleProvider.supportedLanguages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final lang = LocaleProvider.supportedLanguages[index];
                final isSelected =
                    hasOverride && lang.code == effectiveCode;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    child: Text(
                      lang.code.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    lang.englishName,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary)
                      : const Icon(Icons.radio_button_unchecked,
                          color: AppColors.textTertiary),
                  onTap: () {
                    jagoContext.setLanguageOverride(lang.code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
