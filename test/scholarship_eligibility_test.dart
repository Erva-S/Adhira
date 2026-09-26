import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tribal_scholar_saathi/core/enums/app_enums.dart';
import 'package:tribal_scholar_saathi/shared/models/models.dart';
import 'package:tribal_scholar_saathi/services/authentication/auth_provider.dart';
import 'package:tribal_scholar_saathi/services/authentication/auth_service.dart';
import 'package:tribal_scholar_saathi/services/integrations/digilocker/digilocker_service.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_mock_data.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_eligibility_service.dart';
import 'package:tribal_scholar_saathi/services/jago/jago_assistant_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tribal_scholar_saathi/features/eligibility/presentation/pages/eligibility_checker_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Scholarship Eligibility Service - Deterministic Evaluation', () {
    final postMatric = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
    final preMatric = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.preMatric);
    final topClass = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.topClass);
    final nfst = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nfst);
    final nos = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nos);

    const eligibleStudent = Student(
      id: 'test-student-001',
      fullName: 'Erva Savaliya',
      category: 'ST',
      tribeName: 'Gamit',
      currentCourse: 'B.Tech Computer Science',
      educationLevel: 'Undergraduate',
      institutionName: 'NIT Surat (SVNIT)',
      annualFamilyIncome: 180000.0,
      aadhaarNumber: 'XXXX-XXXX-4892',
      bankAccountNumber: '987654321012',
      isDigiLockerLinked: true,
    );

    test('Case 1: Eligible profile - Post-Matric and Top Class', () {
      final postMatricResult = ScholarshipEligibilityService.evaluate(
        scholarship: postMatric,
        student: eligibleStudent,
      );

      expect(postMatricResult.status, equals(EligibilityStatus.eligible));
      expect(postMatricResult.isEligible, isTrue);
      expect(postMatricResult.criteria.every((c) => c.status == CriterionStatus.satisfied), isTrue);
      expect(postMatricResult.summaryMessage, contains('appear eligible'));

      final topClassResult = ScholarshipEligibilityService.evaluate(
        scholarship: topClass,
        student: eligibleStudent,
      );
      expect(topClassResult.status, equals(EligibilityStatus.eligible));
      expect(topClassResult.isEligible, isTrue);
    });

    test('Case 2: Clearly ineligible profile - Non-ST student', () {
      final nonStStudent = eligibleStudent.copyWith(category: 'General');
      final result = ScholarshipEligibilityService.evaluate(
        scholarship: postMatric,
        student: nonStStudent,
      );

      expect(result.status, equals(EligibilityStatus.notEligible));
      expect(result.isEligible, isFalse);

      final categoryCriterion = result.criteria.firstWhere((c) => c.label.contains('Community'));
      expect(categoryCriterion.status, equals(CriterionStatus.notSatisfied));
      expect(categoryCriterion.reason, contains('strictly reserved for Scheduled Tribe'));
    });

    test('Case 3: Clearly ineligible profile - Income exceeds ceiling', () {
      final highIncomeStudent = eligibleStudent.copyWith(annualFamilyIncome: 750000.0);
      final result = ScholarshipEligibilityService.evaluate(
        scholarship: postMatric, // Ceiling is 2.50 Lakh
        student: highIncomeStudent,
      );

      expect(result.status, equals(EligibilityStatus.notEligible));
      expect(result.isEligible, isFalse);

      final incomeCriterion = result.criteria.firstWhere((c) => c.label.contains('Income'));
      expect(incomeCriterion.status, equals(CriterionStatus.notSatisfied));
      expect(incomeCriterion.reason, contains('exceeds the scheme ceiling'));
    });

    test('Case 4: Clearly ineligible profile - Course mismatch (B.Tech for Pre-Matric)', () {
      final result = ScholarshipEligibilityService.evaluate(
        scholarship: preMatric, // Strictly for Class 9 and 10
        student: eligibleStudent, // B.Tech
      );

      expect(result.status, equals(EligibilityStatus.notEligible));
      final courseCriterion = result.criteria.firstWhere((c) => c.label.contains('Academic Level'));
      expect(courseCriterion.status, equals(CriterionStatus.notSatisfied));
      expect(courseCriterion.reason, contains('strictly for Class IX and X'));
    });

    test('Case 5: Clearly ineligible profile - Non-premier institute for Top Class', () {
      final nonPremierStudent = eligibleStudent.copyWith(institutionName: 'Local Private Institute');
      final result = ScholarshipEligibilityService.evaluate(
        scholarship: topClass,
        student: nonPremierStudent,
      );

      expect(result.status, equals(EligibilityStatus.notEligible));
      final instCriterion = result.criteria.firstWhere((c) => c.label.contains('Premier Notified Institution'));
      expect(instCriterion.status, equals(CriterionStatus.notSatisfied));
      expect(instCriterion.reason, contains('not in the list of 252 notified premier institutes'));
    });

    test('Case 6: Missing profile information - Missing annual income marks condition as indeterminate (?)', () {
      const noIncomeStudent = Student(
        id: 'test-no-income',
        fullName: 'Erva Savaliya',
        category: 'ST',
        tribeName: 'Gamit',
        currentCourse: 'B.Tech Computer Science',
        educationLevel: 'Undergraduate',
        institutionName: 'NIT Surat (SVNIT)',
        annualFamilyIncome: null,
        aadhaarNumber: 'XXXX-XXXX-4892',
        bankAccountNumber: '987654321012',
      );
      final result = ScholarshipEligibilityService.evaluate(
        scholarship: postMatric,
        student: noIncomeStudent,
      );

      expect(result.status, equals(EligibilityStatus.indeterminate));
      expect(result.hasMissingInformation, isTrue);
      expect(result.missingFields, contains('Annual Family Income'));

      final incomeCriterion = result.criteria.firstWhere((c) => c.label.contains('Income'));
      expect(incomeCriterion.status, equals(CriterionStatus.indeterminate));
      expect(incomeCriterion.reason, contains('missing from your profile'));

      // Instant what-if recalculation with overrideIncome turns it into eligible
      final recalculated = ScholarshipEligibilityService.evaluate(
        scholarship: postMatric,
        student: noIncomeStudent,
        overrideIncome: 150000.0,
      );
      expect(recalculated.status, equals(EligibilityStatus.eligible));
    });

    test('Case 7: NFST has NO income ceiling per official MoTA guidelines', () {
      final researchScholar = eligibleStudent.copyWith(
        currentCourse: 'Ph.D in Tribal Studies',
        educationLevel: 'Doctorate',
        dateOfBirth: DateTime(2000, 1, 1), // 26 years old
        annualFamilyIncome: 1200000.0, // High income, but NFST has no income limit
      );

      final result = ScholarshipEligibilityService.evaluate(
        scholarship: nfst,
        student: researchScholar,
      );

      expect(result.status, equals(EligibilityStatus.eligible));
      final incomeCriterion = result.criteria.firstWhere((c) => c.label.contains('Income'));
      expect(incomeCriterion.status, equals(CriterionStatus.satisfied));
      expect(incomeCriterion.reason, contains('no family income limit for NFST'));
    });

    test('Case 8: Multiple scholarship schemes evaluation (evaluateAll)', () {
      final allResults = ScholarshipEligibilityService.evaluateAll(
        schemes: ScholarshipMockData.schemes,
        student: eligibleStudent,
      );

      expect(allResults.length, equals(5));
      expect(allResults[postMatric.id]?.status, equals(EligibilityStatus.eligible));
      expect(allResults[topClass.id]?.status, equals(EligibilityStatus.eligible));
      expect(allResults[preMatric.id]?.status, equals(EligibilityStatus.notEligible));
      expect(allResults[nfst.id]?.status, equals(EligibilityStatus.notEligible)); // Not enrolled in Ph.D
      expect(allResults[nos.id]?.status, equals(EligibilityStatus.notEligible)); // B.Tech not eligible for NOS Masters/PhD
    });

    test('Case 9: Explanation functions provide exact failed criteria and missing information', () {
      const incompleteStudent = Student(
        id: 'test-incomplete',
        fullName: 'Erva Savaliya',
        category: 'OBC',
        currentCourse: 'B.Tech Computer Science',
        institutionName: 'NIT Surat (SVNIT)',
        annualFamilyIncome: null,
        aadhaarNumber: 'XXXX-XXXX-4892',
        bankAccountNumber: '987654321012',
      );

      final result = ScholarshipEligibilityService.evaluate(
        scholarship: postMatric,
        student: incompleteStudent,
      );

      final failedExplanation = ScholarshipEligibilityService.explainFailedCriteria(result);
      expect(failedExplanation, contains('Community / Category'));
      expect(failedExplanation, contains('✕'));

      final missingExplanation = ScholarshipEligibilityService.explainMissingInformation(result);
      expect(missingExplanation, contains('Family Annual Income'));
      expect(missingExplanation, contains('?'));
    });
  });

  group('JAGO Conversational Integration with ScholarshipEligibilityService', () {
    const demoStudent = Student(
      id: 'student-demo',
      fullName: 'Erva Savaliya',
      category: 'ST',
      currentCourse: 'B.Tech Computer Science',
      institutionName: 'NIT Surat (SVNIT)',
      annualFamilyIncome: 180000.0,
      aadhaarNumber: 'XXXX-XXXX-4892',
      bankAccountNumber: '987654321012',
    );

    test('JAGO responds to "Why am I not eligible?" using deterministic criteria', () {
      final nonSt = demoStudent.copyWith(category: 'General');
      final response = JagoAssistantEngine.respond(
        'Why am I not eligible for Post-Matric Scholarship?',
        student: nonSt,
      );

      expect(response, contains('Community / Category (ST)'));
      expect(response, contains('✕'));
    });

    test('JAGO responds to "What am I missing?" using deterministic criteria', () {
      const missingIncome = Student(
        id: 'student-demo',
        fullName: 'Erva Savaliya',
        category: 'ST',
        currentCourse: 'B.Tech Computer Science',
        institutionName: 'NIT Surat (SVNIT)',
        annualFamilyIncome: null,
        aadhaarNumber: 'XXXX-XXXX-4892',
        bankAccountNumber: '987654321012',
      );
      final response = JagoAssistantEngine.respond(
        'What am I missing for Post-Matric Scholarship?',
        student: missingIncome,
      );

      expect(response, contains('Family Annual Income'));
      expect(response, contains('?'));
    });

    test('JAGO conversational eligibility check for Post-Matric retains official thresholds', () {
      final response = JagoAssistantEngine.respond(
        'Am I eligible for Post-Matric Scholarship?',
        student: demoStudent,
      );

      expect(response, contains('Post-Matric Scholarship for ST Students'));
      expect(response, contains('2.50 Lakh'));
    });
  });

  group('Eligibility Checker Widget Tests', () {
    testWidgets('Displays scheme selector, auto-filled profile card, criteria, and disclaimer', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const student = Student(
        id: 'test-student-ui',
        fullName: 'Erva Savaliya',
        category: 'ST',
        currentCourse: 'B.Tech Computer Science',
        institutionName: 'NIT Surat (SVNIT)',
        annualFamilyIncome: 180000.0,
        aadhaarNumber: 'XXXX-XXXX-4892',
        bankAccountNumber: '987654321012',
        isDigiLockerLinked: true,
      );

      final authProvider = AuthProvider(authService: _FakeAuthService(currentUser: student));
      final scholarshipDataService = ScholarshipDataService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ScholarshipDataService>.value(value: scholarshipDataService),
          ],
          child: const MaterialApp(
            home: EligibilityCheckerPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Title and scheme selector
      expect(find.text('Eligibility Checker'), findsOneWidget);
      expect(find.text('Select Scholarship Scheme'), findsOneWidget);

      // 2. Profile auto-filled summary card
      expect(find.text('Input Profile Data (Auto-filled)'), findsOneWidget);
      expect(find.text('DigiLocker Linked'), findsOneWidget);
      expect(find.textContaining('Erva Savaliya'), findsWidgets);

      // 3. Result status banner
      expect(find.text('Eligibility Result'), findsOneWidget);
      expect(find.text('Eligible'), findsOneWidget);

      // 4. Criteria breakdown with satisfied marks
      expect(find.text('Why: Criteria Breakdown'), findsOneWidget);
      expect(find.text('✓'), findsWidgets);

      // 5. Official non-binding disclaimer
      expect(find.textContaining('This is a preliminary eligibility check'), findsOneWidget);
      expect(find.textContaining('Final eligibility is determined during official verification'), findsOneWidget);

      // 6. Action buttons
      expect(find.text('Check Another Scheme'), findsOneWidget);
      expect(find.text('Ask JAGO'), findsOneWidget);
    });

    testWidgets('Missing income displays inline prompt and allows instant recalculation', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const studentNoIncome = Student(
        id: 'test-no-income',
        fullName: 'Erva Savaliya',
        category: 'ST',
        currentCourse: 'B.Tech Computer Science',
        institutionName: 'NIT Surat (SVNIT)',
        annualFamilyIncome: null, // missing income
        aadhaarNumber: 'XXXX-XXXX-4892',
        bankAccountNumber: '987654321012',
      );

      final authProvider = AuthProvider(authService: _FakeAuthService(currentUser: studentNoIncome));
      final scholarshipDataService = ScholarshipDataService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<ScholarshipDataService>.value(value: scholarshipDataService),
          ],
          child: const MaterialApp(
            home: EligibilityCheckerPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check indeterminate status and missing information prompt
      expect(find.text('Unable to Determine / Missing Information'), findsOneWidget);
      expect(find.text('Missing Information Required'), findsOneWidget);
      expect(find.text('Recalculate'), findsOneWidget);

      // Enter income and tap Recalculate
      await tester.enterText(find.byType(TextField), '180000');
      await tester.tap(find.text('Recalculate'));
      await tester.pumpAndSettle();

      // Now it recalculates to Eligible!
      expect(find.text('Eligible'), findsOneWidget);
    });
  });
}

class _FakeAuthService implements AuthService {
  @override
  Student? currentUser;

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  String? get currentPhoneNumber => currentUser?.mobileNumber;

  @override
  String? get authToken => 'mock_token';

  _FakeAuthService({this.currentUser});

  @override
  Future<Student?> getCurrentUser() async => currentUser;

  @override
  Future<void> updateCurrentUser(Student student) async {
    currentUser = student;
  }

  @override
  Future<Student> populateProfileFromDigiLocker(DigiLockerUserProfile profile) async => currentUser!;

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<OtpSendResult> sendOtp(String phoneNumber) async => const OtpSendResult(success: true, message: 'OTP Sent');

  @override
  Future<AuthResult> verifyOtp(String phoneNumber, String otp) async => AuthResult(success: true, user: currentUser);
}
