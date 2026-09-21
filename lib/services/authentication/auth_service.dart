import '../../shared/models/student.dart';

/// Abstract authentication service.
abstract class AuthService {
  Future<bool> sendOtp(String phoneNumber);
  Future<String?> verifyOtp(String phoneNumber, String otp);
  Future<Student?> getCurrentUser();
  Future<void> logout();
  bool get isLoggedIn;
}

/// Mock authentication service for development.
class MockAuthService implements AuthService {
  bool _isLoggedIn = false;

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // OTP "sent" successfully
  }

  @override
  Future<String?> verifyOtp(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      _isLoggedIn = true;
      return 'mock_auth_token_xyz';
    }
    return null;
  }

  @override
  Future<Student?> getCurrentUser() async {
    if (!_isLoggedIn) return null;
    return const Student(
      id: 'TSS-2025-45678',
      fullName: 'Rajesh Singh',
      fatherName: 'Manoj Singh',
      mobileNumber: '9876543210',
      email: 'rajesh.singh@email.com',
      tribeName: 'Santal',
      state: 'Odisha',
      district: 'Mayurbhanj',
      currentCourse: 'B.Tech Computer Science',
      currentYear: '2nd Year',
      institutionName: 'NIT Rourkela',
      profileCompletionPercent: 0.72,
    );
  }

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
  }

  @override
  bool get isLoggedIn => _isLoggedIn;
}
