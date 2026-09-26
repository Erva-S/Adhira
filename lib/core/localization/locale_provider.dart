import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a language option in the application.
class AppLanguage {
  final String code;
  final String englishName;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
  });

  Locale get locale => Locale(code);
}

/// Provider for managing and persisting the application's active locale.
class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_locale';

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', englishName: 'English', nativeName: 'English'),
    AppLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
    AppLanguage(code: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી'),
    AppLanguage(code: 'mr', englishName: 'Marathi', nativeName: 'मराठी'),
    AppLanguage(code: 'or', englishName: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    AppLanguage(code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
    AppLanguage(code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
    AppLanguage(code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்'),
    AppLanguage(code: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    AppLanguage(code: 'ml', englishName: 'Malayalam', nativeName: 'മലയാളം'),
  ];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  AppLanguage get currentLanguage {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _locale.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && supportedLanguages.any((lang) => lang.code == code)) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // Fallback silently to English default
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode == newLocale.languageCode) return;
    if (!supportedLanguages.any((lang) => lang.code == newLocale.languageCode)) return;

    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (_) {
      // Ignored
    }
  }
}
