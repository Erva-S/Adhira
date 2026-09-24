import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

/// Extension on [BuildContext] to access [AppLocalizations] concisely.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this) ?? AppLocalizationsEn();
}
