import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribal_scholar_saathi/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tribal_scholar_saathi/features/notifications/presentation/pages/notification_detail_page.dart';
import 'package:tribal_scholar_saathi/features/scholarships/presentation/pages/scholarship_detail_page.dart';
import 'package:tribal_scholar_saathi/features/documents/presentation/pages/document_detail_page.dart';
import 'package:tribal_scholar_saathi/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:tribal_scholar_saathi/features/applications/presentation/pages/application_tracking_page.dart';
import 'package:tribal_scholar_saathi/features/settings/presentation/pages/settings_page.dart';
import 'package:tribal_scholar_saathi/shared/widgets/app_back_button.dart';

void main() {
  testWidgets('NotificationsPage has AppBackButton and marks list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsPage(),
      ),
    );

    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('NotificationDetailPage has AppBackButton and pops on click', (WidgetTester tester) async {
    bool popped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onPopPage: (route, result) {
            popped = true;
            return route.didPop(result);
          },
          pages: const [
            MaterialPage(
              child: Scaffold(body: Text('Root')),
            ),
            MaterialPage(
              child: NotificationDetailPage(
                title: 'Test Notification',
                message: 'Test Content',
                time: 'Just now',
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Notification Detail'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsWidgets);

    // Tap back button
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();

    expect(popped, isTrue);
  });

  testWidgets('ScholarshipDetailPage has AppBackButton and pops on click', (WidgetTester tester) async {
    bool popped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onPopPage: (route, result) {
            popped = true;
            return route.didPop(result);
          },
          pages: const [
            MaterialPage(
              child: Scaffold(body: Text('Root')),
            ),
            MaterialPage(
              child: ScholarshipDetailPage(
                name: 'Top Class Scheme',
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Scheme Details'), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);

    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();

    expect(popped, isTrue);
  });

  testWidgets('DocumentDetailPage has AppBackButton and pops on click', (WidgetTester tester) async {
    bool popped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onPopPage: (route, result) {
            popped = true;
            return route.didPop(result);
          },
          pages: const [
            MaterialPage(
              child: Scaffold(body: Text('Root')),
            ),
            MaterialPage(
              child: DocumentDetailPage(
                name: 'Aadhaar Card',
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Document Details'), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);

    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();

    expect(popped, isTrue);
  });

  testWidgets('ApplicationTrackingPage has AppBackButton', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ApplicationTrackingPage(),
      ),
    );

    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.text('Application Tracking'), findsOneWidget);
  });

  testWidgets('SettingsPage has AppBackButton', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsPage(),
      ),
    );

    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('ProfileEditPage has AppBackButton', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileEditPage(),
      ),
    );

    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
  });
}
