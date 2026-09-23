import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tribal_scholar_saathi/core/constants/india_location_data.dart';
import 'package:tribal_scholar_saathi/features/applications/presentation/pages/application_form_page.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';

Widget _wrapWithProvider(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => ScholarshipDataService(),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('IndiaLocationData Tests', () {
    test('Contains all 36 States and Union Territories with districts', () {
      final states = IndiaLocationData.states;
      expect(states.length, equals(36));

      // Key states present
      expect(states.contains('Odisha'), isTrue);
      expect(states.contains('Jharkhand'), isTrue);
      expect(states.contains('Madhya Pradesh'), isTrue);
      expect(states.contains('Chhattisgarh'), isTrue);
      expect(states.contains('Delhi'), isTrue);
      expect(states.contains('Ladakh'), isTrue);

      // Verify every state/UT has non-empty districts
      for (final state in states) {
        final districts = IndiaLocationData.getDistricts(state);
        expect(districts.isNotEmpty, isTrue, reason: '$state should have districts');
      }
    });

    test('Odisha districts include Mayurbhanj and others', () {
      final districts = IndiaLocationData.getDistricts('Odisha');
      expect(districts.contains('Mayurbhanj'), isTrue);
      expect(districts.contains('Sundargarh'), isTrue);
      expect(districts.contains('Koraput'), isTrue);
      expect(districts.length, equals(30));
    });

    test('Unknown state returns empty district list', () {
      expect(IndiaLocationData.getDistricts('NonExistentState'), isEmpty);
    });
  });

  group('ApplicationFormPage Multi-Step Flow Tests', () {
    testWidgets('Prevents Next Step when required field is empty', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithProvider(const ApplicationFormPage()));
      await tester.pumpAndSettle();

      // Clear the Full Name field
      final nameField = find.widgetWithText(TextFormField, 'Rajesh Soren');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Tap Next Step
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Validation error message should be displayed
      expect(find.text('Full Name is required'), findsOneWidget);

      // Form should remain on Step 1 (Personal Information still visible)
      expect(find.text('Personal Information'), findsOneWidget);
    });

    testWidgets('Complete multi-step navigation preserves data across steps and reaches Review & Submit', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithProvider(const ApplicationFormPage()));
      await tester.pumpAndSettle();

      // Step 1: Default valid data -> Tap Next Step
      expect(find.text('Select Scholarship Scheme'), findsOneWidget);
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Step 2: Address / Tribal
      expect(find.text('Tribal Identity & Domicile'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Tap Next Step to Step 3
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Step 3: Academic
      expect(find.text('Academic & Institution Details'), findsOneWidget);

      // Tap Next Step to Step 4
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Step 4: Bank & Documents
      expect(find.text('Aadhaar-Seeded Bank Account'), findsOneWidget);

      // Tap Next Step to Step 5 (Review)
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Step 5: Review & Submit
      expect(find.text('Application Summary'), findsOneWidget);
      expect(find.text('Review & Submit'), findsOneWidget);

      // Go Back to Step 4
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Aadhaar-Seeded Bank Account'), findsOneWidget);

      // Data preserved in Bank field
      expect(find.text('State Bank of India'), findsOneWidget);
    });
  });
}
