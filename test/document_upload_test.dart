import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tribal_scholar_saathi/core/enums/app_enums.dart';
import 'package:tribal_scholar_saathi/features/applications/presentation/pages/application_form_page.dart';
import 'package:tribal_scholar_saathi/features/documents/presentation/pages/document_wallet_page.dart';
import 'package:tribal_scholar_saathi/features/documents/presentation/widgets/upload_document_dialog.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';
import 'package:tribal_scholar_saathi/services/storage/document_storage_service.dart';

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
      expect(doc.fileType, 'pdf');
      expect(doc.fileSizeBytes, 5);
      expect(service.documents.length, initialCount + 1);
      expect(service.documents.any((d) => d.id == doc.id), isTrue);
    });

    test('DocumentStorageService enforces user isolation on private paths', () async {
      final storage = LocalDocumentStorageService();
      final userA = 'student-101';
      final userB = 'student-202';
      final bytes = Uint8List.fromList([1, 2, 3, 4]);

      final uploadA = await storage.uploadUserDocument(
        userId: userA,
        documentId: 'doc-001',
        fileName: 'income_cert.pdf',
        bytes: bytes,
      );

      expect(uploadA.success, isTrue);
      expect(uploadA.storagePath, startsWith('documents/$userA/'));

      // User A can access their own document
      final urlA = await storage.getAuthenticatedUrl(
        userId: userA,
        storagePath: uploadA.storagePath,
      );
      expect(urlA, isNotNull);

      // User B is prevented from accessing User A's storage path
      final urlB = await storage.getAuthenticatedUrl(
        userId: userB,
        storagePath: uploadA.storagePath,
      );
      expect(urlB, isNull);
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

    testWidgets('UploadDocumentDialog validates empty document name and missing file', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UploadDocumentDialog(service: service),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Attempt to upload without file or name
      final uploadBtn = find.widgetWithText(ElevatedButton, 'Upload');
      await tester.tap(uploadBtn);
      await tester.pumpAndSettle();

      // Error message is displayed gracefully without crashing
      expect(find.text('Please enter a document name.'), findsOneWidget);

      // Enter a name but don't pick a file
      await tester.enterText(find.byType(TextField), 'My Certificate');
      await tester.tap(uploadBtn);
      await tester.pumpAndSettle();

      // Prompts for file selection
      expect(find.text('Please choose a document from your device first.'), findsOneWidget);
    });

    testWidgets('ApplicationFormPage Step 4 provides both Connect DigiLocker and Upload Manually', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1100));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ScholarshipDataService>.value(value: service),
          ],
          child: const MaterialApp(
            home: ApplicationFormPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Step 4 (Bank & Documents)
      // Step 1 -> Next
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Step 2 -> Next
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Step 3 -> Next
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // We are now on Step 4: Bank & Documents
      final uploadManuallyFinder = find.widgetWithText(OutlinedButton, 'Upload Manually');
      await tester.ensureVisible(uploadManuallyFinder);
      expect(uploadManuallyFinder, findsOneWidget);

      // Tap "Upload Manually"
      await tester.tap(uploadManuallyFinder);
      await tester.pumpAndSettle();

      // Upload dialog appears
      expect(find.text('Upload Document'), findsAtLeastNWidgets(1));
      expect(find.text('Browse Files'), findsOneWidget);

      // Select sample ST Certificate chip inside Dialog
      final chipFinder = find.descendant(
        of: find.byType(Dialog),
        matching: find.text('ST Certificate'),
      );
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      // Upload it
      await tester.tap(find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(ElevatedButton, 'Upload'),
      ));
      await tester.pumpAndSettle();

      // Success SnackBar and document appears in list
      expect(find.text('ST Certificate uploaded successfully!'), findsOneWidget);
    });
  });
}
