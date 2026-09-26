import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tribal_scholar_saathi/features/auth/presentation/pages/login_page.dart';
import 'package:tribal_scholar_saathi/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:tribal_scholar_saathi/services/authentication/auth_service.dart';
import 'package:tribal_scholar_saathi/services/authentication/auth_provider.dart';
import 'package:tribal_scholar_saathi/services/integrations/digilocker/digilocker_service.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';
import 'package:tribal_scholar_saathi/services/storage/local_storage_service.dart';
import 'package:tribal_scholar_saathi/features/auth/presentation/pages/digilocker_connection_page.dart';
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

  group('DigiLocker Profile Auto-Population Tests', () {
    test('AppAuthService.populateProfileFromDigiLocker updates student profile with realistic details', () async {
      final authService = AppAuthService();
      final sendRes = await authService.sendOtp('9876543210');
      await authService.verifyOtp('9876543210', sendRes.debugOtp!);

      final digiLockerService = MockDigiLockerService();
      final profile = await digiLockerService.fetchUserProfile('TSS-2025-45678');

      final updated = await authService.populateProfileFromDigiLocker(profile);

      expect(updated.fullName, 'Rajesh Soren');
      expect(updated.fatherName, 'Manoj Soren');
      expect(updated.motherName, 'Sunita Soren');
      expect(updated.gender, 'Male');
      expect(updated.category, 'ST');
      expect(updated.tribeName, 'Santal');
      expect(updated.stCertificateNumber, 'ST/OD/2023/88921');
      expect(updated.district, 'Mayurbhanj');
      expect(updated.state, 'Odisha');
      expect(updated.institutionName, 'NIT Rourkela');
      expect(updated.currentCourse, 'B.Tech Computer Science');
      expect(updated.aadhaarNumber, 'XXXX-XXXX-4892');
      expect(updated.isDigiLockerLinked, isTrue);
      expect(updated.profileCompletionPercent, 0.95);
    });

    testWidgets('DigiLockerConnectionPage renders idle state and triggers simulated fetch', (WidgetTester tester) async {
      final authService = AppAuthService();
      final authProvider = AuthProvider(authService: authService);
      final scholarshipService = ScholarshipDataService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ScholarshipDataService>.value(value: scholarshipService),
          ],
          child: const MaterialApp(
            home: DigiLockerConnectionPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Idle UI elements
      expect(find.text('Connect DigiLocker'), findsNWidgets(2)); // Title and button
      expect(
        find.textContaining('Connect your DigiLocker account to securely fetch your verified details'),
        findsOneWidget,
      );
      expect(find.text('Instant Profile Auto-Fill'), findsOneWidget);
      expect(find.text('Authentic Government Verification'), findsOneWidget);
      expect(find.text('100% Private & Masked'), findsOneWidget);
      expect(find.text('Skip for now (I will fill manually)'), findsOneWidget);

      // Tap Connect DigiLocker
      final btn = find.widgetWithText(ElevatedButton, 'Connect DigiLocker');
      await tester.ensureVisible(btn);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(btn);
      await tester.pump();

      // Check transition to connecting state
      expect(find.text('Connecting to DigiLocker...'), findsOneWidget);

      // Advance clock past connection and fetching delays
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Success state and auto-populated preview
      expect(find.text('DigiLocker Connected'), findsOneWidget);
      expect(find.text('Your verified details have been successfully fetched.'), findsOneWidget);
      expect(find.text('Rajesh Soren'), findsOneWidget);
      expect(find.text('Manoj Soren'), findsOneWidget);
      expect(find.text('NIT Rourkela'), findsOneWidget);
      expect(find.text('B.Tech Computer Science'), findsOneWidget);
      expect(find.text('XXXX-XXXX-4892'), findsOneWidget);
      expect(find.text('Continue to Dashboard'), findsOneWidget);
    });

    test('Mobile number 9898418407 populates Erva Savaliya demo profile', () async {
      final authService = AppAuthService();
      final sendRes = await authService.sendOtp('9898418407');
      final authResult = await authService.verifyOtp('9898418407', sendRes.debugOtp!);
      expect(authResult.success, isTrue);

      final digiLockerService = MockDigiLockerService();
      final profile = await digiLockerService.fetchUserProfile(
        authResult.user!.id,
        phoneNumber: '9898418407',
      );

      // Verify DigiLocker returns Erva Savaliya details
      expect(profile.fullName, 'Erva Savaliya');
      expect(profile.fatherName, 'Dilip Savaliya');
      expect(profile.motherName, 'Vaishali Savaliya');
      expect(profile.dateOfBirth, DateTime(2007, 4, 18));
      expect(profile.gender, 'Female');
      expect(profile.mobileNumber, '9898418407');
      expect(profile.email, 'erva.savaliya.20@gmail.com');
      expect(profile.state, 'Gujarat');
      expect(profile.district, 'Valsad');
      expect(profile.pinCode, '396195');

      // Populate into student profile
      final updatedStudent = await authService.populateProfileFromDigiLocker(profile);
      expect(updatedStudent.fullName, 'Erva Savaliya');
      expect(updatedStudent.fatherName, 'Dilip Savaliya');
      expect(updatedStudent.motherName, 'Vaishali Savaliya');
      expect(updatedStudent.dateOfBirth, DateTime(2007, 4, 18));
      expect(updatedStudent.gender, 'Female');
      expect(updatedStudent.mobileNumber, '9898418407');
      expect(updatedStudent.email, 'erva.savaliya.20@gmail.com');
      expect(updatedStudent.state, 'Gujarat');
      expect(updatedStudent.district, 'Valsad');
      expect(updatedStudent.pinCode, '396195');
      expect(updatedStudent.isDigiLockerLinked, isTrue);
    });

    test('Other mobile numbers do NOT return Erva Savaliya demo profile', () async {
      final authService = AppAuthService();
      final sendRes = await authService.sendOtp('9876543211');
      final authResult = await authService.verifyOtp('9876543211', sendRes.debugOtp!);
      expect(authResult.success, isTrue);

      final digiLockerService = MockDigiLockerService();
      final profile = await digiLockerService.fetchUserProfile(
        authResult.user!.id,
        phoneNumber: '9876543211',
      );

      // Verify it does NOT return Erva Savaliya
      expect(profile.fullName, isNot('Erva Savaliya'));
      expect(profile.fullName, 'Rajesh Soren');
      expect(profile.fatherName, 'Manoj Soren');
      expect(profile.state, 'Odisha');
      expect(profile.district, 'Mayurbhanj');
    });
  });
}
