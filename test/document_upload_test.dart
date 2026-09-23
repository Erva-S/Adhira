import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tribal_scholar_saathi/core/enums/app_enums.dart';
import 'package:tribal_scholar_saathi/features/documents/presentation/pages/document_wallet_page.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Document Upload Tests', () {
    late ScholarshipDataService service;

    setUp(() async {
      service = ScholarshipDataService();
    });

    test('ScholarshipDataService uploadDocument stores file and updates wallet', () async {
      final initialCount = service.documents.length;
      final fileBytes = Uint8List.fromList([10, 20, 30, 40, 50]);

      final doc = await service.uploadDocument(
        name: 'Bonafide Certificate',
        category: DocumentCategory.academic,
        documentType: 'BONAFIDE_CERTIFICATE',
        fileName: 'bonafide.pdf',
        bytes: fileBytes,
      );

      expect(doc, isNotNull);
      expect(doc.name, 'Bonafide Certificate');
      expect(doc.status, DocumentStatus.uploaded);
      expect(service.documents.length, initialCount + 1);
      expect(service.documents.any((d) => d.id == doc.id), isTrue);
    });

    testWidgets('DocumentWalletPage displays upload button and opens enhanced dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ScholarshipDataService>.value(value: service),
          ],
          child: const MaterialApp(
            home: DocumentWalletPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check FAB / Upload button is present
      final uploadBtn = find.text('Upload Document');
      expect(uploadBtn, findsAtLeastNWidgets(1));

      // Tap Upload Document button
      await tester.tap(uploadBtn.first);
      await tester.pumpAndSettle();

      // Modal dialog is open
      expect(find.text('Upload Document'), findsAtLeastNWidgets(1));
      expect(find.text('Document Name *'), findsOneWidget);
      expect(find.text('Category *'), findsOneWidget);
      expect(find.text('Browse Files'), findsOneWidget);

      // Quick sample document chips are present
      expect(find.text('ST Certificate'), findsAtLeastNWidgets(1));
      expect(find.text('Bonafide'), findsAtLeastNWidgets(1));

      // Tap quick sample doc chip "Bonafide"
      await tester.tap(find.text('Bonafide').first);
      await tester.pumpAndSettle();

      // Check name text field inside dialog is auto-filled
      expect(
        find.descendant(of: find.byType(Dialog), matching: find.text('Bonafide Certificate')),
        findsOneWidget,
      );

      // Tap dialog Upload button
      final dialogUploadBtn = find.widgetWithText(ElevatedButton, 'Upload');
      expect(dialogUploadBtn, findsOneWidget);

      final initialDocCount = service.documents.length;
      await tester.tap(dialogUploadBtn);
      await tester.pumpAndSettle();

      // Dialog closed and document count increased
      expect(service.documents.length, initialDocCount + 1);
      expect(find.text('Bonafide Certificate uploaded successfully!'), findsOneWidget);
    });
  });
}
