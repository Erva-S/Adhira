import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tribal_scholar_saathi/features/scholarships/presentation/pages/scholarship_dashboard_page.dart';
import 'package:tribal_scholar_saathi/features/applications/presentation/pages/applications_list_page.dart';
import 'package:tribal_scholar_saathi/features/applications/presentation/pages/application_detail_page.dart';
import 'package:tribal_scholar_saathi/features/applications/presentation/pages/application_form_page.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';
import 'package:tribal_scholar_saathi/shared/widgets/app_back_button.dart';

Widget _wrapWithProvider(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => ScholarshipDataService(),
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('ScholarshipDashboardPage renders correctly with data service', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProvider(const ScholarshipDashboardPage()));
    await tester.pumpAndSettle();

    expect(find.text('Scholarship Dashboard'), findsOneWidget);
    expect(find.text('MoTA Tribal Scholarship Hub'), findsOneWidget);
    expect(find.text('Apply Now'), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
  });

  testWidgets('ApplicationsListPage renders tabs and search bar', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProvider(const ApplicationsListPage()));
    await tester.pumpAndSettle();

    expect(find.text('My Applications'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
  });

  testWidgets('ApplicationDetailPage renders application details', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProvider(const ApplicationDetailPage(applicationId: 'app-001')));
    await tester.pumpAndSettle();

    expect(find.text('Application Details'), findsOneWidget);
    expect(find.text('Post-Matric Scholarship for ST'), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
  });

  testWidgets('ApplicationFormPage renders multi-step form with step navigation', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProvider(const ApplicationFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Scholarship Application'), findsOneWidget);
    expect(find.text('Next Step'), findsOneWidget);
    expect(find.text('Save Draft'), findsOneWidget);

    // Tap Next Step to go to Step 2
    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();

    expect(find.text('Tribal Identity & Domicile'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}
