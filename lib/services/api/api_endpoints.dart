/// API endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';

  // ── Student ───────────────────────────────────────────────────
  static const String profile = '/student/profile';
  static const String profileUpdate = '/student/profile/update';

  // ── Scholarships ──────────────────────────────────────────────
  static const String scholarships = '/scholarships';
  static const String scholarshipDetails = '/scholarships/{id}';
  static const String eligibilityCheck = '/scholarships/eligibility';

  // ── Applications ──────────────────────────────────────────────
  static const String applications = '/applications';
  static const String applicationDetails = '/applications/{id}';
  static const String applicationSubmit = '/applications/submit';

  // ── Verification ──────────────────────────────────────────────
  static const String verifications = '/verifications';
  static const String verificationStatus = '/verifications/{id}';

  // ── Documents ─────────────────────────────────────────────────
  static const String documents = '/documents';
  static const String documentUpload = '/documents/upload';
  static const String digilockerFetch = '/documents/digilocker';

  // ── Payments ──────────────────────────────────────────────────
  static const String payments = '/payments';
  static const String paymentHistory = '/payments/history';

  // ── Notifications ─────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationRead = '/notifications/{id}/read';

  // ── JAGO ──────────────────────────────────────────────────────
  static const String jagoChat = '/jago/chat';
  static const String jagoSuggestions = '/jago/suggestions';
}
