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

/// Singleton service managing JAGO's language preference and screen context.
///
/// Design principles:
/// 1. Does NOT duplicate LocaleProvider or ScholarshipDataService state.
/// 2. Provides a single integration point for all JAGO context needs.
/// 3. Language defaults to following the app locale unless overridden.
/// 4. Screen context is set by entry points before navigating to JAGO.
/// 5. Clears user-specific state on logout.
class JagoContextService extends ChangeNotifier {
  static final JagoContextService _instance = JagoContextService._internal();
  factory JagoContextService() => _instance;
  JagoContextService._internal();

  static const String _jagoLangPrefKey = 'jago_language_override';

  // ── Language State ──────────────────────────────────────────────

  /// null means "follow app language" (default behavior)
  String? _languageOverride;

  /// Whether the user has explicitly set a JAGO-specific language.
  bool get hasLanguageOverride => _languageOverride != null;

  /// The effective JAGO language code, considering override and app locale.
  String getEffectiveLanguageCode(LocaleProvider localeProvider) {
    return _languageOverride ?? localeProvider.locale.languageCode;
  }

  /// The effective language name for display.
  String getEffectiveLanguageName(LocaleProvider localeProvider) {
    final code = getEffectiveLanguageCode(localeProvider);
    final lang = LocaleProvider.supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => LocaleProvider.supportedLanguages.first,
    );
    return lang.nativeName;
  }

  /// Set a JAGO-specific language override.
  Future<void> setLanguageOverride(String languageCode) async {
    if (!LocaleProvider.supportedLanguages.any((l) => l.code == languageCode)) {
      return;
    }
    _languageOverride = languageCode;
    notifyListeners();
    await _persistLanguageOverride();
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
          LocaleProvider.supportedLanguages.any((l) => l.code == code)) {
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
