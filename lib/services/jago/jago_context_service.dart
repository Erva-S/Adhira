import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/locale_provider.dart';
import '../../shared/models/models.dart';
import '../scholarship/scholarship_data_service.dart';
import '../authentication/auth_provider.dart';

/// Represents the screen/feature context from which JAGO was launched.
class JagoScreenContext {
  /// The source screen name (e.g., 'applicationTracking', 'eligibility').
  final String sourceScreen;

  /// Human-readable label for the source screen.
  final String sourceLabel;

  /// The specific application being viewed, if any.
  final ScholarshipApplication? application;

  /// The specific scholarship scheme being viewed, if any.
  final Scholarship? scholarship;

  /// Additional context data (e.g., eligibility result summary).
  final Map<String, dynamic> extra;

  const JagoScreenContext({
    required this.sourceScreen,
    required this.sourceLabel,
    this.application,
    this.scholarship,
    this.extra = const {},
  });

  /// Generates a context summary string for JAGO's system prompt.
  String toContextSummary() {
    final buffer = StringBuffer();
    buffer.writeln('User opened JAGO from: $sourceLabel');

    if (application != null) {
      final app = application!;
      buffer.writeln('Current application: ${app.scholarshipName}');
      buffer.writeln('Application number: ${app.applicationNumber ?? app.id}');
      buffer.writeln('Application status: ${app.status.label}');
      buffer.writeln('Current stage: ${app.currentStage.label}');
      if (app.remarks != null && app.remarks!.isNotEmpty) {
        buffer.writeln('Remarks: ${app.remarks}');
      }
      if (app.pendingActions.isNotEmpty) {
        buffer.writeln('Pending actions: ${app.pendingActions.join(", ")}');
      }
    }

    if (scholarship != null) {
      buffer.writeln('Current scholarship scheme: ${scholarship!.name}');
    }

    for (final entry in extra.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }

    return buffer.toString().trim();
  }
}

/// Represents a supported language in JAGO.
class JagoLanguage {
  final String code;
  final String englishName;
  final String nativeName;

  const JagoLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
  });
}

/// Singleton service managing JAGO's language preference and screen context.
///
/// Design principles:
/// 1. Does NOT duplicate LocaleProvider or ScholarshipDataService state.
/// 2. Provides a single integration point for all JAGO context needs.
/// 3. Language defaults to following the app locale (followAppLanguage = true) unless overridden.
/// 4. When overridden, only JAGO changes - the rest of Adhira does NOT change.
/// 5. Screen context is set by entry points before navigating to JAGO.
/// 6. Clears user-specific state on logout.
class JagoContextService extends ChangeNotifier {
  static final JagoContextService _instance = JagoContextService._internal();
  factory JagoContextService() => _instance;
  JagoContextService._internal();

  static const String _jagoLangPrefKey = 'jago_language_override';

  /// The 9 official supported languages for JAGO chatbot:
  /// 1. English (en)
  /// 2. Hindi (hi)
  /// 3. Gujarati (gu)
  /// 4. Marathi (mr)
  /// 5. Bengali (bn)
  /// 6. Tamil (ta)
  /// 7. Telugu (te)
  /// 8. Kannada (kn)
  /// 9. Malayalam (ml)
  static const List<JagoLanguage> supportedLanguages = [
    JagoLanguage(code: 'en', englishName: 'English', nativeName: 'English'),
    JagoLanguage(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
    JagoLanguage(code: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી'),
    JagoLanguage(code: 'mr', englishName: 'Marathi', nativeName: 'मराठी'),
    JagoLanguage(code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
    JagoLanguage(code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்'),
    JagoLanguage(code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
    JagoLanguage(code: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    JagoLanguage(code: 'ml', englishName: 'Malayalam', nativeName: 'മലയാളം'),
  ];

  // ── Language State ──────────────────────────────────────────────

  /// null means "follow app language" (default behavior)
  String? _languageOverride;

  /// Whether JAGO is following the main Adhira app language.
  bool get followAppLanguage => _languageOverride == null;

  /// Whether the user has manually overridden the JAGO language.
  bool get isManualOverride => _languageOverride != null;

  /// Whether the user has explicitly set a JAGO-specific language.
  bool get hasLanguageOverride => _languageOverride != null;

  /// The current manual language override, if any.
  String? get selectedLanguageOverride => _languageOverride;

  /// The effective JAGO language code, considering override and app locale.
  String getEffectiveLanguageCode(LocaleProvider localeProvider) {
    if (_languageOverride != null) {
      return _languageOverride!;
    }
    final appCode = localeProvider.locale.languageCode;
    // If app locale is one of the 9 supported JAGO languages, use it directly
    if (supportedLanguages.any((l) => l.code == appCode)) {
      return appCode;
    }
    return 'en';
  }

  /// The effective language name for display.
  String getEffectiveLanguageName(LocaleProvider localeProvider) {
    final code = getEffectiveLanguageCode(localeProvider);
    final lang = supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => supportedLanguages.first,
    );
    return lang.nativeName;
  }

  /// Set a JAGO-specific language override.
  /// Only changes JAGO without affecting the rest of the Adhira application.
  Future<void> setLanguageOverride(String languageCode) async {
    if (!supportedLanguages.any((l) => l.code == languageCode)) {
      return;
    }
    _languageOverride = languageCode;
    notifyListeners();
    await _persistLanguageOverride();
  }

  /// Re-enable following the main Adhira app language.
  Future<void> useAppLanguage() async {
    await clearLanguageOverride();
  }

  /// Reset JAGO to follow the app language.
  Future<void> clearLanguageOverride() async {
    _languageOverride = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jagoLangPrefKey);
    } catch (_) {}
  }

  /// Load persisted language override on startup.
  Future<void> loadPersistedLanguageOverride() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_jagoLangPrefKey);
      if (code != null &&
          supportedLanguages.any((l) => l.code == code)) {
        _languageOverride = code;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _persistLanguageOverride() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_languageOverride != null) {
        await prefs.setString(_jagoLangPrefKey, _languageOverride!);
      }
    } catch (_) {}
  }

  // ── Screen Context State ────────────────────────────────────────

  JagoScreenContext? _screenContext;

  /// The current screen context, if JAGO was launched from a specific feature.
  JagoScreenContext? get screenContext => _screenContext;

  /// Set the screen context before navigating to JAGO.
  void setScreenContext(JagoScreenContext context) {
    _screenContext = context;
    notifyListeners();
  }

  /// Clear the screen context (e.g., after JAGO has consumed it).
  void clearScreenContext() {
    _screenContext = null;
  }

  /// Consume and return the screen context (read once, then clear).
  JagoScreenContext? consumeScreenContext() {
    final ctx = _screenContext;
    _screenContext = null;
    return ctx;
  }

  // ── App Action Tools ────────────────────────────────────────────
  // These delegate to existing services without creating duplicate state.

  /// Get the current user's profile from the auth provider.
  Student? getUserProfile(AuthProvider authProvider) {
    return authProvider.currentUser;
  }

  /// Get all scholarship schemes from the scholarship data service.
  List<Scholarship> getScholarshipSchemes(ScholarshipDataService service) {
    return service.schemes;
  }

  /// Get the user's applications from the scholarship data service.
  List<ScholarshipApplication> getApplications(ScholarshipDataService service) {
    return service.applications;
  }

  /// Get active applications.
  List<ScholarshipApplication> getActiveApplications(
      ScholarshipDataService service) {
    return service.activeApplications;
  }

  /// Get pending actions for the user.
  List<ApplicationAction> getPendingActions(ScholarshipDataService service) {
    return service.pendingActions;
  }

  /// Get the user's documents.
  List<Document> getDocuments(ScholarshipDataService service) {
    return service.documents;
  }

  /// Get the user's payments.
  List<Payment> getPayments(ScholarshipDataService service) {
    return service.payments;
  }

  /// Get application by ID.
  ScholarshipApplication? getApplicationById(
      ScholarshipDataService service, String id) {
    return service.getApplicationById(id);
  }

  /// Get payments for a specific application.
  List<Payment> getPaymentsForApplication(
      ScholarshipDataService service, String applicationId) {
    return service.getPaymentsForApplication(applicationId);
  }

  // ── Navigation Action Identifiers ───────────────────────────────

  /// Known navigation targets that JAGO can suggest.
  static const Map<String, String> navigationActions = {
    'applicationTracking': '/applications/tracking',
    'documentWallet': '/documents',
    'payments': '/payments',
    'eligibility': '/eligibility',
    'scholarshipDiscovery': '/scholarships',
    'profile': '/profile',
    'applicationForm': '/applications/new',
  };

  // ── Logout / Cleanup ───────────────────────────────────────────

  /// Clear all JAGO-specific state on logout.
  Future<void> clearOnLogout() async {
    _screenContext = null;
    _languageOverride = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jagoLangPrefKey);
    } catch (_) {}
  }
}
