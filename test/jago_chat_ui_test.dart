import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tribal_scholar_saathi/features/jago/presentation/pages/jago_chat_page.dart';
import 'package:tribal_scholar_saathi/services/authentication/auth_provider.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';
import 'package:tribal_scholar_saathi/services/jago/jago_session_service.dart';
import 'package:tribal_scholar_saathi/shared/widgets/jago_typing_indicator.dart';
import 'package:tribal_scholar_saathi/shared/widgets/chat_bubble.dart';
import 'package:tribal_scholar_saathi/core/localization/locale_provider.dart';
import 'package:tribal_scholar_saathi/l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';

Widget _createJagoTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => ScholarshipDataService()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: JagoChatPage(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    JagoSessionService().clearAllSessions();
  });

  tearDown(() {
    JagoSessionService().clearAllSessions();
  });

  testWidgets('JagoChatPage renders greeting and retains messages across widget rebuilds', (tester) async {
    await tester.pumpWidget(_createJagoTestApp());
    await tester.pumpAndSettle();

    // Verify initial greeting is present
    expect(find.textContaining('JAGO'), findsWidgets);

    // Send a message
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Which scholarships are available?');
    final sendButton = find.byIcon(Icons.send_rounded);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    // User message is displayed in chat
    expect(find.text('Which scholarships are available?'), findsOneWidget);

    // JAGO response is displayed in chat
    expect(find.byType(ChatBubble), findsWidgets);

    // Verify leaving screen and reopening preserves conversation
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Other Page'))));
    await tester.pumpAndSettle();
    expect(find.text('Other Page'), findsOneWidget);

    // Reopen JAGO
    await tester.pumpWidget(_createJagoTestApp());
    await tester.pumpAndSettle();

    // The user's previous message must still be visible in the session
    expect(find.text('Which scholarships are available?'), findsOneWidget);
  });

  testWidgets('Three-dot typing indicator animates correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JagoTypingIndicator(),
        ),
      ),
    );

    expect(find.byType(JagoTypingIndicator), findsOneWidget);

    // Animate forward in time and verify no exceptions
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 900));
  });
}
