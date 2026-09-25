import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tribal_scholar_saathi/features/applications/presentation/pages/application_form_page.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';
import 'package:tribal_scholar_saathi/l10n/app_localizations.dart';

void main() {
  testWidgets('Complete Scholarship application flow including DigiLocker and Review step', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
    tester.binding.window.devicePixelRatioTestValue = 2.75;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ScholarshipDataService(),
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ApplicationFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Step 0: Scheme & Personal -> Next Step
    expect(find.text('Select Scholarship Scheme'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Step'));
    await tester.pumpAndSettle();

    // Step 1: Tribal & Domicile -> Next Step
    expect(find.text('Tribal Identity & Domicile'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Step'));
    await tester.pumpAndSettle();

    // Step 2: Academic Details -> Next Step
    expect(find.text('Academic & Institution Details'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Step'));
    await tester.pumpAndSettle();

    // Step 3: Bank & Documents
    expect(find.text('DigiLocker Integration — Demo'), findsOneWidget);
    final linkDigiLockerBtn = find.widgetWithText(ElevatedButton, 'Link from DigiLocker (Demo)');
    expect(linkDigiLockerBtn, findsOneWidget);
    await tester.ensureVisible(linkDigiLockerBtn);
    await tester.tap(linkDigiLockerBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // DigiLocker Consent Page: Tap Link from DigiLocker (Demo)
    final consentLinkBtn = find.widgetWithText(ElevatedButton, 'Link from DigiLocker (Demo)');
    expect(consentLinkBtn, findsOneWidget);
    await tester.ensureVisible(consentLinkBtn);
    await tester.tap(consentLinkBtn);
    await tester.pump();

    // Fast-forward through connection & authentication & import phases
    await tester.pump(const Duration(seconds: 7));

    // Verify Success State
    expect(find.text('Successfully Connected'), findsOneWidget);
    expect(
      find.text('Your DigiLocker has been successfully connected. You can now continue with your scholarship application.'),
      findsOneWidget,
    );
    final continueBtn = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueBtn, findsOneWidget);

    // Tap Continue
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Verify we are now on Step 5: Review & Submit
    expect(find.text('Application Summary'), findsOneWidget);
    expect(find.text('Declaration of Authenticity *'), findsOneWidget);

    // Verify Submit Application button is visible
    final submitAppBtn = find.widgetWithText(ElevatedButton, 'Submit Application');
    expect(submitAppBtn, findsOneWidget);

    // Check Declaration of Authenticity
    final declarationCheckbox = find.byType(CheckboxListTile);
    expect(declarationCheckbox, findsOneWidget);
    await tester.ensureVisible(declarationCheckbox);
    await tester.tap(declarationCheckbox);
    await tester.pumpAndSettle();

    // Tap Submit Application
    await tester.tap(submitAppBtn);
    await tester.pumpAndSettle();

    // Verify Application Submitted dialog
    expect(find.text('Application Submitted!'), findsOneWidget);
  });
}
