import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribal_scholar_saathi/core/enums/app_enums.dart';
import 'package:tribal_scholar_saathi/repositories/repositories.dart';
import 'package:tribal_scholar_saathi/services/database/relational_data_store.dart';
import 'package:tribal_scholar_saathi/services/storage/document_storage_service.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';

void main() {
  group('Backend & Data Architecture Tests', () {
    late RelationalDataStore dataStore;
    late ScholarshipRepository scholarshipRepo;
    late UserRepository userRepo;
    late ApplicationRepository appRepo;
    late DocumentRepository docRepo;
    late PaymentRepository paymentRepo;
    late NotificationRepository notifRepo;
    late DocumentStorageService storageService;

    setUp(() {
      dataStore = RelationalDataStore();
      scholarshipRepo = AppScholarshipRepository(dataStore: dataStore);
      userRepo = AppUserRepository(dataStore: dataStore);
      appRepo = AppApplicationRepository(dataStore: dataStore);
      docRepo = AppDocumentRepository(dataStore: dataStore);
      paymentRepo = AppPaymentRepository(dataStore: dataStore);
      notifRepo = AppNotificationRepository(dataStore: dataStore);
      storageService = LocalDocumentStorageService();
    });

    test('1. Scholarship Master Data: All 5 MoTA schemes exist', () async {
      final schemes = await scholarshipRepo.getScholarships();
      expect(schemes.length, 5);

      final types = schemes.map((s) => s.type).toSet();
      expect(types, contains(ScholarshipType.preMatric));
      expect(types, contains(ScholarshipType.postMatric));
      expect(types, contains(ScholarshipType.topClass));
      expect(types, contains(ScholarshipType.nfst));
      expect(types, contains(ScholarshipType.nos));
    });

    test('2. User Isolation: User A cannot retrieve User B records', () async {
      const userAId = RelationalDataStore.demoUserId; // Rajesh Soren

      // Create a fresh User B
      final userB = await userRepo.getOrCreateUser(phoneNumber: '9876543299', fullName: 'Sunil Munda');
      final userBId = userB.id;

      expect(userBId, isNot(equals(userAId)));

      // Check applications
      final appsA = await appRepo.getApplicationsForUser(userAId);
      final appsB = await appRepo.getApplicationsForUser(userBId);
      expect(appsA.isNotEmpty, isTrue);
      expect(appsB.isEmpty, isTrue); // User B has zero applications

      // User B cannot access User A's application by ID
      final appAId = appsA.first.id;
      final unauthorizedAccess = await appRepo.getApplicationById(appAId, userBId);
      expect(unauthorizedAccess, isNull);

      // Check documents
      final docsA = await docRepo.getDocumentsForUser(userAId);
      final docsB = await docRepo.getDocumentsForUser(userBId);
      expect(docsA.isNotEmpty, isTrue);
      expect(docsB.isEmpty, isTrue);

      // Check payments
      final paymentsA = await paymentRepo.getPaymentsForUser(userAId);
      final paymentsB = await paymentRepo.getPaymentsForUser(userBId);
      expect(paymentsA.isNotEmpty, isTrue);
      expect(paymentsB.isEmpty, isTrue);

      // Check pending actions
      final actionsA = await appRepo.getPendingActions(userAId);
      final actionsB = await appRepo.getPendingActions(userBId);
      expect(actionsA.isNotEmpty, isTrue);
      expect(actionsB.isEmpty, isTrue);
    });

    test('3. Document Storage & Path Isolation', () async {
      const userA = 'user_001';
      const userB = 'user_002';

      final uploadResult = await storageService.uploadUserDocument(
        userId: userA,
        documentId: 'doc_123',
        fileName: 'caste_cert.pdf',
        bytes: Uint8List.fromList([1, 2, 3, 4]),
      );

      expect(uploadResult.success, isTrue);
      expect(uploadResult.storagePath, startsWith('documents/$userA/'));

      // User A can access signed URL
      final urlA = await storageService.getAuthenticatedUrl(
        userId: userA,
        storagePath: uploadResult.storagePath,
      );
      expect(urlA, isNotNull);

      // User B attempting to access User A's storage path is blocked
      final urlB = await storageService.getAuthenticatedUrl(
        userId: userB,
        storagePath: uploadResult.storagePath,
      );
      expect(urlB, isNull);
    });

    test('4. Document Reuse Across Applications (Part 9)', () async {
      const userId = RelationalDataStore.demoUserId;
      final verifiedDocs = await docRepo.getReusableVerifiedDocuments(userId);
      expect(verifiedDocs.isNotEmpty, isTrue);

      final reusedDocIds = verifiedDocs.take(2).map((d) => d.id).toList();

      // Submit new application using existing verified documents
      final newApp = await appRepo.submitApplication(
        userId: userId,
        scholarshipId: 'sch-top-class',
        scholarshipName: 'Top Class Education',
        scholarshipType: ScholarshipType.topClass,
        academicYear: '2025-26',
        requestedAmount: 250000,
        reusedDocumentIds: reusedDocIds,
      );

      expect(newApp.id, isNotEmpty);
      expect(newApp.studentId, userId);

      // Verify application documents junction links
      final appDocs = await docRepo.getDocumentsForApplication(newApp.id);
      expect(appDocs.length, 2);
      expect(appDocs.every((ad) => ad.isReused), isTrue);
    });

    test('5. Application Status History & Timeline (Part 6)', () async {
      const userId = RelationalDataStore.demoUserId;
      final apps = await appRepo.getApplicationsForUser(userId);
      expect(apps.isNotEmpty, isTrue);

      final app = apps.firstWhere((a) => a.id == 'app-pms-2025-001');
      final history = await appRepo.getStatusHistory(app.id);

      expect(history.isNotEmpty, isTrue);
      expect(history.first.stage, ApplicationStage.application);
      expect(history.first.status, VerificationStatus.verified);
      expect(history.any((h) => h.stage == ApplicationStage.documentVerification), isTrue);
    });

    test('6. Pending Actions & Deficiencies Resolution (Part 11)', () async {
      const userId = RelationalDataStore.demoUserId;
      final actions = await appRepo.getPendingActions(userId, onlyOpen: true);
      expect(actions.isNotEmpty, isTrue);

      final action = actions.first;
      expect(action.isOpen, isTrue);

      // Resolve action
      final resolved = await appRepo.resolveAction(action.id, userId);
      expect(resolved, isNotNull);
      expect(resolved!.status, ActionStatus.resolved);
      expect(resolved.resolvedAt, isNotNull);
    });

    test('7. Notifications & Dynamic Badge Count (Part 13)', () async {
      const userId = RelationalDataStore.demoUserId;
      final initialUnread = await notifRepo.getUnreadCount(userId);
      expect(initialUnread, greaterThanOrEqualTo(1));

      final notifs = await notifRepo.getNotificationsForUser(userId);
      final unreadNotif = notifs.firstWhere((n) => !n.isRead);

      // Mark single notification as read
      await notifRepo.markAsRead(unreadNotif.id, userId);
      final afterRead = await notifRepo.getUnreadCount(userId);
      expect(afterRead, equals(initialUnread - 1));

      // Mark all as read
      await notifRepo.markAllAsRead(userId);
      final finalUnread = await notifRepo.getUnreadCount(userId);
      expect(finalUnread, equals(0));
    });

    test('8. State Management (ScholarshipDataService) Reactive Switching', () async {
      final service = ScholarshipDataService(
        scholarshipRepo: scholarshipRepo,
        applicationRepo: appRepo,
        documentRepo: docRepo,
        paymentRepo: paymentRepo,
        notificationRepo: notifRepo,
        initialUserId: RelationalDataStore.demoUserId,
      );

      await service.loadUserData(RelationalDataStore.demoUserId);
      expect(service.applications.isNotEmpty, isTrue);
      expect(service.documents.isNotEmpty, isTrue);

      // Switch to new user
      const newUserId = 'TSS-TEST-99999';
      dataStore.createOrFindUser(phoneNumber: '9876543299', fullName: 'Fresh Student');
      await service.switchUser(newUserId);

      expect(service.currentUserId, newUserId);
      expect(service.applications.isEmpty, isTrue);
      expect(service.documents.isEmpty, isTrue);
    });
  });
}
