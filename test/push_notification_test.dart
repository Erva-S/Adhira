import 'package:flutter_test/flutter_test.dart';
import 'package:tribal_scholar_saathi/core/enums/app_enums.dart';
import 'package:tribal_scholar_saathi/shared/models/notification_item.dart';
import 'package:tribal_scholar_saathi/services/database/relational_data_store.dart';
import 'package:tribal_scholar_saathi/repositories/notification_repository.dart';
import 'package:tribal_scholar_saathi/services/scholarship/scholarship_data_service.dart';
import 'package:tribal_scholar_saathi/app/router/route_names.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Push Notification System - Model & Serialization', () {
    test('NotificationItem serializes to and from map with deep-link fields', () {
      final item = NotificationItem(
        id: 'notif-test-001',
        userId: 'user-001',
        type: NotificationType.application,
        title: 'Status: Under Verification',
        message: 'Your scholarship application has moved to verification.',
        timestamp: DateTime(2026, 9, 27, 12, 0),
        isRead: false,
        actionRoute: RouteNames.applicationTracking,
        relatedId: 'app-pms-2025-001',
      );

      final map = item.toMap();
      expect(map['id'], 'notif-test-001');
      expect(map['user_id'], 'user-001');
      expect(map['type'], 'application');
      expect(map['action_route'], RouteNames.applicationTracking);
      expect(map['related_id'], 'app-pms-2025-001');
      expect(map['is_read'], false);

      final reconstructed = NotificationItem.fromMap(map);
      expect(reconstructed.id, item.id);
      expect(reconstructed.userId, item.userId);
      expect(reconstructed.type, item.type);
      expect(reconstructed.title, item.title);
      expect(reconstructed.message, item.message);
      expect(reconstructed.actionRoute, item.actionRoute);
      expect(reconstructed.relatedId, item.relatedId);
      expect(reconstructed.isRead, false);
    });

    test('NotificationItem copyWith updates read status', () {
      final item = NotificationItem(
        id: 'notif-002',
        type: NotificationType.payment,
        title: 'Payment Disbursed',
        message: 'Funds released via DBT',
        timestamp: DateTime(2026, 9, 27, 10, 0),
        isRead: false,
      );

      final readItem = item.copyWith(isRead: true);
      expect(readItem.isRead, true);
      expect(readItem.id, item.id);
      expect(readItem.title, item.title);
    });
  });

  group('Push Notification System - Real-Time Stream & Repository', () {
    late RelationalDataStore store;
    late NotificationRepository repo;

    setUp(() {
      store = RelationalDataStore();
      repo = AppNotificationRepository(dataStore: store);
    });

    test('addNotification immediately broadcasts item on notificationStream', () async {
      final emittedItems = <NotificationItem>[];
      final subscription = store.notificationStream.listen(emittedItems.add);

      final notif = NotificationItem(
        id: 'notif-stream-001',
        userId: 'user-stream-test',
        type: NotificationType.verification,
        title: 'ST Certificate Verified',
        message: 'Official verification complete.',
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: RouteNames.verificationCentre,
      );

      store.addNotification(notif);

      // Wait a moment for stream delivery
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emittedItems.length, 1);
      expect(emittedItems.first.id, 'notif-stream-001');
      expect(emittedItems.first.type, NotificationType.verification);

      await subscription.cancel();
    });

    test('markAsRead updates unread count and persists read state', () async {
      const userId = 'user-read-test';
      final notif = NotificationItem(
        id: 'notif-unread-1',
        userId: userId,
        type: NotificationType.alert,
        title: 'Action Required',
        message: 'Re-upload income cert',
        timestamp: DateTime.now(),
        isRead: false,
      );

      store.addNotification(notif);
      expect(await repo.getUnreadCount(userId), 1);

      await repo.markAsRead('notif-unread-1', userId);
      expect(await repo.getUnreadCount(userId), 0);

      final all = await repo.getNotificationsForUser(userId);
      final updated = all.firstWhere((n) => n.id == 'notif-unread-1');
      expect(updated.isRead, true);
    });
  });

  group('Push Notification System - User Isolation & Token Management', () {
    late RelationalDataStore store;

    setUp(() {
      store = RelationalDataStore();
    });

    test('User A notifications are strictly isolated from User B', () {
      const userA = 'user-alpha-001';
      const userB = 'user-beta-002';

      store.addNotification(
        NotificationItem(
          id: 'notif-a1',
          userId: userA,
          type: NotificationType.payment,
          title: 'User A Disbursement',
          message: 'Disbursed ₹50,000',
          timestamp: DateTime.now(),
        ),
      );

      store.addNotification(
        NotificationItem(
          id: 'notif-b1',
          userId: userB,
          type: NotificationType.payment,
          title: 'User B Disbursement',
          message: 'Disbursed ₹30,000',
          timestamp: DateTime.now(),
        ),
      );

      final userANotifs = store.getNotificationsForUser(userA);
      final userBNotifs = store.getNotificationsForUser(userB);

      expect(userANotifs.any((n) => n.id == 'notif-a1'), true);
      expect(userANotifs.any((n) => n.id == 'notif-b1'), false);

      expect(userBNotifs.any((n) => n.id == 'notif-b1'), true);
      expect(userBNotifs.any((n) => n.id == 'notif-a1'), false);
    });

    test('Device tokens are registered, isolated per user, and cleared on logout', () {
      const userA = 'user-token-a';
      const userB = 'user-token-b';
      const tokenA = 'fcm-device-token-aaa-111';
      const tokenB = 'fcm-device-token-bbb-222';

      store.registerDeviceToken(userA, tokenA);
      store.registerDeviceToken(userB, tokenB);

      final tokensA = store.getDeviceTokensForUser(userA);
      final tokensB = store.getDeviceTokensForUser(userB);

      expect(tokensA.contains(tokenA), true);
      expect(tokensA.contains(tokenB), false);
      expect(tokensB.contains(tokenB), true);
      expect(tokensB.contains(tokenA), false);

      // Simulate User A logout -> token cleared
      store.unregisterDeviceToken(userA);
      expect(store.getDeviceTokensForUser(userA).isEmpty, true);
      // User B tokens untouched
      expect(store.getDeviceTokensForUser(userB).contains(tokenB), true);
    });
  });

  group('Push Notification System - Real-Time Service Integration', () {
    test('ScholarshipDataService reacts in real-time when new notification arrives', () async {
      final service = ScholarshipDataService(
        initialUserId: 'service-test-user',
      );

      final initialCount = service.unreadNotificationCount;

      // Send real-time notification
      await service.sendRealtimeNotification(
        title: 'Real-Time Alert',
        message: 'Your document verification has been completed.',
        type: NotificationType.verification,
        actionRoute: RouteNames.verificationCentre,
      );

      // Wait a moment for reactive stream update
      await Future.delayed(const Duration(milliseconds: 50));

      expect(service.unreadNotificationCount, initialCount + 1);
      expect(service.notifications.first.title, 'Real-Time Alert');
      expect(service.notifications.first.actionRoute, RouteNames.verificationCentre);

      // Mark as read
      await service.markNotificationAsRead(service.notifications.first.id);
      expect(service.unreadNotificationCount, initialCount);

      service.dispose();
    });
  });
}
