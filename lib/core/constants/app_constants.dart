/// App-wide constants.
class AppConstants {
  AppConstants._();

  // ── Scholarship IDs ───────────────────────────────────────────
  static const String preMatricId = 'SCH_PRE_MATRIC';
  static const String postMatricId = 'SCH_POST_MATRIC';
  static const String topClassId = 'SCH_TOP_CLASS';
  static const String nfstId = 'SCH_NFST';
  static const String nosId = 'SCH_NOS';

  // ── Validation ────────────────────────────────────────────────
  static const int minPasswordLength = 8;
  static const int otpLength = 6;
  static const int phoneNumberLength = 10;
  static const int aadhaarLength = 12;
  static const int pinCodeLength = 6;

  // ── Date Formats ──────────────────────────────────────────────
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';

  // ── External URLs ─────────────────────────────────────────────
  static const String nspPortalUrl = 'https://scholarships.gov.in';
  static const String digiLockerUrl = 'https://www.digilocker.gov.in';
  static const String motaUrl = 'https://tribal.nic.in';
  static const String helplineNumber = '1800-xxx-xxxx';
}
