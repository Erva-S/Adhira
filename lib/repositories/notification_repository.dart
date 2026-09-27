import '../../shared/models/notification_item.dart';
import '../../services/database/relational_data_store.dart';
import 'base_repository.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotificationsForUser(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId, String userId);
  Future<void> markAllAsRead(String userId);
  Stream<NotificationItem> get notificationStream;
  Future<NotificationItem> createNotification(NotificationItem notification);
  Future<void> registerDeviceToken(String userId, String token);
  Future<void> unregisterDeviceToken(String userId, [String? token]);
  Future<Set<String>> getDeviceTokens(String userId);
}

class AppNotificationRepository extends BaseRepository implements NotificationRepository {
  final RelationalDataStore _dataStore;

  AppNotificationRepository({RelationalDataStore? dataStore})
      : _dataStore = dataStore ?? RelationalDataStore();

  @override
  Stream<NotificationItem> get notificationStream => _dataStore.notificationStream;

  @override
  Future<List<NotificationItem>> getNotificationsForUser(String userId) async {
    return safeCall(() async {
      return _dataStore.getNotificationsForUser(userId);
    });
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return safeCall(() async {
      return _dataStore.getUnreadNotificationCount(userId);
    });
  }

  @override
  Future<NotificationItem> createNotification(NotificationItem notification) async {
    return safeCall(() async {
      return _dataStore.addNotification(notification);
    });
  }

  @override
  Future<void> markAsRead(String notificationId, String userId) async {
    return safeCall(() async {
      _dataStore.markNotificationAsRead(notificationId, userId);
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    return safeCall(() async {
      _dataStore.markAllNotificationsAsRead(userId);
    });
  }

  @override
  Future<void> registerDeviceToken(String userId, String token) async {
    return safeCall(() async {
      _dataStore.registerDeviceToken(userId, token);
    });
  }

  @override
  Future<void> unregisterDeviceToken(String userId, [String? token]) async {
    return safeCall(() async {
      _dataStore.unregisterDeviceToken(userId, token);
    });
  }

  @override
  Future<Set<String>> getDeviceTokens(String userId) async {
    return safeCall(() async {
      return _dataStore.getDeviceTokensForUser(userId);
    });
  }
}
