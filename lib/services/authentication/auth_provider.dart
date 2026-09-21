import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../shared/models/student.dart';
import 'auth_service.dart';

/// State management Provider for Authentication lifecycle.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _lastSentPhone;
  String? _debugLastOtp;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AppAuthService() {
    restoreSession();
  }

  // ── Getters ────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.isLoggedIn;
  Student? get currentUser => _authService.currentUser;
  String? get currentPhoneNumber => _authService.currentPhoneNumber;
  String? get errorMessage => _errorMessage;
  String? get lastSentPhone => _lastSentPhone;
  String? get debugLastOtp => _debugLastOtp;
  int get cooldownSeconds => _cooldownSeconds;
  bool get canResend => _cooldownSeconds == 0;

  // ── Restore Session on Startup ─────────────────────────────────────
  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.restoreSession();
    } catch (_) {
      // Ignored
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Send OTP ───────────────────────────────────────────────────────
  Future<OtpSendResult> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.sendOtp(phoneNumber);
      if (result.success) {
        _lastSentPhone = phoneNumber;
        _debugLastOtp = result.debugOtp;
        _startCooldown(result.cooldownSeconds);
      } else {
        _errorMessage = result.message;
        if (result.cooldownSeconds > 0) {
          _startCooldown(result.cooldownSeconds);
        }
      }
      return result;
    } catch (e) {
      final res = OtpSendResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
      _errorMessage = res.message;
      return res;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────────
  Future<AuthResult> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyOtp(phoneNumber, otp);
      if (!result.success) {
        _errorMessage = result.errorMessage;
      } else {
        _errorMessage = null;
        _debugLastOtp = null;
        _stopCooldown();
      }
      return result;
    } catch (e) {
      final res = const AuthResult(
        success: false,
        errorMessage: 'Verification failed. Please check network connection.',
      );
      _errorMessage = res.errorMessage;
      return res;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _errorMessage = null;
      _lastSentPhone = null;
      _debugLastOtp = null;
      _stopCooldown();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update Profile ─────────────────────────────────────────────────
  Future<void> updateProfile(Student updated) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateCurrentUser(updated);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Cooldown Timer ─────────────────────────────────────────────────
  void _startCooldown(int seconds) {
    _stopCooldown();
    _cooldownSeconds = seconds;
    notifyListeners();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 1) {
        _cooldownSeconds--;
        notifyListeners();
      } else {
        _stopCooldown();
      }
    });
  }

  void _stopCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _cooldownSeconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
