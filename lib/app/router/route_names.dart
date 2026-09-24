/// Centralized route name constants for type-safe navigation.
class RouteNames {
  RouteNames._();

  // ── Auth ──────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';

  // ── Main ──────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ── Scholarships ──────────────────────────────────────────────
  static const String scholarshipDashboard = '/scholarship-dashboard';
  static const String scholarshipDiscovery = '/scholarships';
  static const String scholarshipDetails = '/scholarships/:id';

  // ── Eligibility ───────────────────────────────────────────────
  static const String eligibilityChecker = '/eligibility';
  static const String eligibilityResult = '/eligibility/result';

  // ── Applications ──────────────────────────────────────────────
  static const String applicationsList = '/applications';
  static const String applicationTracking = '/applications/tracking';
  static const String applicationForm = '/applications/new';
  static const String applicationDetails = '/applications/detail';

  // ── Verification ──────────────────────────────────────────────
  static const String verificationCentre = '/verification';
  static const String verificationDetails = '/verification/:id';

  // ── Documents ─────────────────────────────────────────────────
  static const String documentWallet = '/documents';
  static const String documentDetails = '/documents/detail';
  static const String documentUpload = '/documents/upload';

  // ── DigiLocker ────────────────────────────────────────────────
  static const String digiLockerConsent = '/digilocker/connect';

  // ── Payments ──────────────────────────────────────────────────
  static const String payments = '/payments';
  static const String paymentDetails = '/payments/:id';

  // ── Notifications ─────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationDetails = '/notifications/detail';

  // ── JAGO Chatbot ──────────────────────────────────────────────
  static const String jago = '/jago';

  // ── Profile ───────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';

  // ── Settings ──────────────────────────────────────────────────
  static const String settings = '/settings';
}
