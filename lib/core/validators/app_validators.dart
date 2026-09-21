/// Form validation helpers.
class AppValidators {
  AppValidators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  static String? aadhaar(String? value) {
    if (value == null || value.trim().isEmpty) return 'Aadhaar number is required';
    final regex = RegExp(r'^\d{12}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid 12-digit Aadhaar number';
    return null;
  }

  static String? pinCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'PIN code is required';
    final regex = RegExp(r'^\d{6}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid 6-digit PIN code';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required';
    final regex = RegExp(r'^\d{6}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid 6-digit OTP';
    return null;
  }

  static String? minLength(String? value, int minLen, [String fieldName = 'This field']) {
    if (value == null || value.trim().length < minLen) {
      return '$fieldName must be at least $minLen characters';
    }
    return null;
  }
}
