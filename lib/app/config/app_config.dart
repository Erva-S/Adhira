/// App-wide configuration constants.
class AppConfig {
  AppConfig._();

  static const String appName = 'Tribal Scholar Saathi';
  static const String appTagline = 'Ministry of Tribal Affairs Scholarship Portal';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // ── API Base URLs (will be replaced by environment config) ────
  static const String apiBaseUrl = 'https://api.tribal-scholar.gov.in/v1';
  static const String mockApiBaseUrl = 'http://localhost:3000/api';

  // ── Timeouts ──────────────────────────────────────────────────
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // ── Storage Keys ──────────────────────────────────────────────
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String selectedLanguageKey = 'selected_language';
  static const String themeModeKey = 'theme_mode';

  // ── Supported Languages ───────────────────────────────────────
  static const List<String> supportedLanguages = [
    'en', // English
    'hi', // Hindi
    'bn', // Bengali
    'te', // Telugu
    'mr', // Marathi
    'ta', // Tamil
    'gu', // Gujarati
    'kn', // Kannada
    'or', // Odia
    'ml', // Malayalam
    'as', // Assamese
  ];

  // ── Pagination ────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Document ──────────────────────────────────────────────────
  static const int maxDocumentSizeMB = 5;
  static const List<String> allowedDocumentTypes = ['pdf', 'jpg', 'jpeg', 'png'];
}
