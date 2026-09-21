import '../../shared/models/notification_item.dart';
import '../../services/database/relational_data_store.dart';
import 'base_repository.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotificationsForUser(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId, String userId);
  Future<void> markAllAsRead(String userId);
}

class AppNotificationRepository extends BaseRepository implements NotificationRepository {
  final RelationalDataStore _dataStore;

  AppNotificationRepository({RelationalDataStore? dataStore})
      : _dataStore = dataStore ?? RelationalDataStore();

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
}
