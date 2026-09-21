import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tribal_scholar_saathi/features/auth/presentation/pages/login_page.dart';
import 'package:tribal_scholar_saathi/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:tribal_scholar_saathi/services/authentication/auth_service.dart';
import 'package:tribal_scholar_saathi/services/authentication/auth_provider.dart';
import 'package:tribal_scholar_saathi/services/storage/local_storage_service.dart';
import 'package:tribal_scholar_saathi/shared/widgets/app_back_button.dart';

Widget _wrapWithAuth(Widget child, AuthProvider authProvider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: authProvider,
    child: MaterialApp(home: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppAuthService Unit Tests', () {
    test('Rejects invalid phone numbers', () async {
      final authService = AppAuthService();

      final res1 = await authService.sendOtp('12345');
      expect(res1.success, isFalse);

      final res2 = await authService.sendOtp('0123456789'); // starts with 0
      expect(res2.success, isFalse);

      final res3 = await authService.sendOtp('5123456789'); // starts with 5
      expect(res3.success, isFalse);
    });

    test('Generates dynamic 6-digit OTP and verifies successfully', () async {
      final authService = AppAuthService();

      final sendRes = await authService.sendOtp('9876543210');
      expect(sendRes.success, isTrue);
      expect(sendRes.debugOtp, isNotNull);
      expect(sendRes.debugOtp!.length, 6);

      // Verify wrong OTP
      final wrongRes = await authService.verifyOtp('9876543210', '000000');
      expect(wrongRes.success, isFalse);
      expect(authService.isLoggedIn, isFalse);

      // Verify correct dynamic OTP
      final correctRes = await authService.verifyOtp('9876543210', sendRes.debugOtp!);
      expect(correctRes.success, isTrue);
      expect(authService.isLoggedIn, isTrue);
      expect(authService.currentUser?.fullName, 'Rajesh Soren');
    });

    test('Enforces rate limiting cooldown', () async {
      final authService = AppAuthService();

      final firstSend = await authService.sendOtp('9876543210');
      expect(firstSend.success, isTrue);

      // Immediate second request within cooldown should fail
      final secondSend = await authService.sendOtp('9876543210');
      expect(secondSend.success, isFalse);
      expect(secondSend.cooldownSeconds, greaterThan(0));
    });

    test('Persists and restores session across restarts', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService();
      final authService = AppAuthService(storage: storage);

      final sendRes = await authService.sendOtp('9876543210');
      await authService.verifyOtp('9876543210', sendRes.debugOtp!);
      expect(authService.isLoggedIn, isTrue);

      // Simulate app restart with a fresh instance sharing the same storage
      final newAuthService = AppAuthService(storage: storage);
      await newAuthService.restoreSession();

      expect(newAuthService.isLoggedIn, isTrue);
      expect(newAuthService.currentPhoneNumber, '9876543210');
      expect(newAuthService.currentUser?.fullName, 'Rajesh Soren');

      // Logout clears session
      await newAuthService.logout();
      expect(newAuthService.isLoggedIn, isFalse);

      final postLogoutService = AppAuthService(storage: storage);
      await postLogoutService.restoreSession();
      expect(postLogoutService.isLoggedIn, isFalse);
    });
  });

  group('Auth UI Tests', () {
    testWidgets('LoginPage validates Indian mobile number format', (WidgetTester tester) async {
      final authProvider = AuthProvider(authService: AppAuthService());
      await tester.pumpWidget(_wrapWithAuth(const LoginPage(), authProvider));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);

      // Tap Send OTP with empty field
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Mobile number is required.'), findsOneWidget);

      // Enter invalid number
      final textField = find.byType(TextField);
      await tester.enterText(textField, '123456');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      expect(find.textContaining('valid 10-digit Indian mobile number'), findsOneWidget);
    });

    testWidgets('OtpVerificationPage renders digit boxes and masks phone', (WidgetTester tester) async {
      final authProvider = AuthProvider(authService: AppAuthService());
      await tester.pumpWidget(
        _wrapWithAuth(
          const OtpVerificationPage(phoneNumber: '9876543210'),
          authProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify your mobile number'), findsOneWidget);
      expect(find.textContaining('+91 98765 43•••'), findsOneWidget);
      expect(find.text('Verify & Proceed'), findsOneWidget);
      expect(find.byType(AppBackButton), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });
  });
}
