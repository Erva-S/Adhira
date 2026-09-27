import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router/app_router.dart';
import '../../app/router/route_names.dart';
import '../../core/enums/app_enums.dart';
import '../../shared/models/notification_item.dart';
import '../database/relational_data_store.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
/// Must be annotated with `@pragma('vm:entry-point')` to run when the app is in background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM background message received: ${message.messageId}, data: ${message.data}');
}

/// Centralized Real-Time Push Notification Engine for Adhira.
///
/// Implements:
/// - Firebase Cloud Messaging (FCM) push token management.
/// - High-importance heads-up notification channel on Android & iOS.
/// - Real-time in-app foreground notification handling.
/// - Background and terminated app deep-linking.
/// - Strict user isolation (clearing device-token association on logout).
/// - Resilient fallback operation (never crashes if Firebase project is offline).
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const String channelId = 'adhira_high_importance_channel';
  static const String channelName = 'Adhira Scholarship Alerts';
  static const String channelDescription =
      'Real-time notifications for scholarship status, document verification, and DBT disbursements.';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  String? _currentFCMToken;
  String? _activeUserId;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<NotificationItem>? _dataStoreStreamSub;

  String? get currentFCMToken => _currentFCMToken;
  String? get activeUserId => _activeUserId;
  bool get isInitialized => _isInitialized;

  /// Initializes push notification infrastructure:
  /// 1. Firebase Core (safe initialization with graceful fallback).
  /// 2. Android Notification Channel & Local Notifications Plugin.
  /// 3. Message listeners for foreground, background, and cold start.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize Firebase Core safely
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase Core initialized successfully for push notifications.');
    } catch (e) {
      debugPrint('Firebase Core initialization notice (running with native local push engine): $e');
    }

    // 2. Initialize Local Notifications Plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Create High-Importance Notification Channel for Android
    final androidNotificationPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidNotificationPlugin != null) {
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await androidNotificationPlugin.createNotificationChannel(androidChannel);
    }

    // 4. Setup FCM Listeners if Firebase is available
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Foreground message stream
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Background app opened by notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened from background push notification: ${message.data}');
        navigateFromPayload(message.data);
      });

      // Cold start / Terminated notification tap
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from terminated state via push notification: ${initialMessage.data}');
        Future.delayed(const Duration(milliseconds: 600), () {
          navigateFromPayload(initialMessage.data);
        });
      }
    } catch (e) {
      debugPrint('FirebaseMessaging setup notice: $e');
    }

    _isInitialized = true;
  }

  /// Requests notification permissions (Android 13+ runtime permission and iOS alert/sound/badge).
  /// Designed to be called after login or when entering authenticated flows.
  Future<bool> requestNotificationPermission() async {
    if (!_isInitialized) return false;
    bool granted = false;

    // Android 13+ (API 33+) permission request
    try {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final androidGranted = await androidPlugin.requestNotificationsPermission();
        if (androidGranted != null) granted = androidGranted;
      }
    } catch (e) {
      debugPrint('Local notifications permission notice: $e');
    }

    // Firebase Messaging / iOS permission request
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      granted = granted || (settings.authorizationStatus == AuthorizationStatus.authorized);
      debugPrint('Notification authorization status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('FCM permission request notice: $e');
    }

    return granted;
  }

  /// Called when a user successfully authenticates.
  /// Associates the device FCM token with the authenticated user ID and subscribes to real-time events.
  Future<void> onUserLoggedIn(String userId) async {
    try {
      _activeUserId = userId;
      await requestNotificationPermission();

      // 1. Retrieve & Register FCM Device Token
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          _currentFCMToken = token;
          _registerTokenWithBackend(userId, token);
        }
      } catch (e) {
        debugPrint('FCM getToken notice: $e');
        // Assign fallback mock device token if offline/emulator
        final fallbackToken = 'dev-token-${userId.hashCode.abs()}';
        _currentFCMToken = fallbackToken;
        _registerTokenWithBackend(userId, fallbackToken);
      }

      // 2. Listen for Token Refresh
      _tokenRefreshSub?.cancel();
      try {
        _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          debugPrint('FCM token refreshed for user $userId: $newToken');
          _currentFCMToken = newToken;
          _registerTokenWithBackend(userId, newToken);
        });
      } catch (_) {}

      // 3. Listen to real-time notifications in RelationalDataStore
      _dataStoreStreamSub?.cancel();
      _dataStoreStreamSub = RelationalDataStore().notificationStream.listen((item) {
        if (item.userId == _activeUserId) {
          // Display high-priority system notification banner when new event is dispatched
          showNotification(item);
        }
      });

      debugPrint('Push notification service bound to user: $userId');
    } catch (e) {
      debugPrint('Error binding push notification service for user $userId: $e');
    }
  }

  /// Called when the user logs out.
  /// Disassociates the device token to prevent User A's notifications from going to User B.
  Future<void> onUserLoggedOut(String userId) async {
    try {
      debugPrint('Unregistering push notification token for user: $userId');
      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
      _dataStoreStreamSub?.cancel();
      _dataStoreStreamSub = null;

      RelationalDataStore().unregisterDeviceToken(userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('adhira_fcm_token_$userId');

      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}

      _activeUserId = null;
      _currentFCMToken = null;
    } catch (e) {
      debugPrint('Error unbinding push notification service for user $userId: $e');
    }
  }

  void _registerTokenWithBackend(String userId, String token) async {
    try {
      RelationalDataStore().registerDeviceToken(userId, token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('adhira_fcm_token_$userId', token);
      debugPrint('Device token successfully registered for user $userId: $token');
    } catch (e) {
      debugPrint('Error registering token with backend: $e');
    }
  }

  /// Handles incoming FCM messages while app is in foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('FCM foreground message received: ${message.messageId}, data: ${message.data}');

    final title = message.notification?.title ?? message.data['title'] ?? 'Adhira Scholarship Alert';
    final body = message.notification?.body ?? message.data['message'] ?? '';
    final typeString = message.data['type'] ?? 'system';
    final actionRoute = message.data['action_route'] ?? message.data['actionRoute'];
    final relatedId = message.data['related_id'] ?? message.data['relatedId'];

    final notifType = NotificationType.values.firstWhere(
      (t) => t.name.toLowerCase() == typeString.toString().toLowerCase(),
      orElse: () => NotificationType.system,
    );

    final item = NotificationItem(
      id: message.messageId ?? 'notif-${DateTime.now().millisecondsSinceEpoch}',
      userId: _activeUserId ?? RelationalDataStore.demoUserId,
      type: notifType,
      title: title,
      message: body,
      timestamp: DateTime.now(),
      isRead: false,
      actionRoute: actionRoute,
      relatedId: relatedId,
    );

    // Save to relational datastore (broadcasts to UI subscribers)
    RelationalDataStore().addNotification(item);

    // Display high-importance system notification
    await showNotification(item);
  }

  /// Displays a native system notification with sound, vibration, and banner.
  Future<void> showNotification(NotificationItem item) async {
    if (!_isInitialized) return;
    try {
      final payloadMap = item.toMap();
      final payloadString = jsonEncode(payloadMap);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        color: Color(0xFF137547), // Adhira Forest Green
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notifId = item.id.hashCode.abs() % 100000;

      await _localNotifications.show(
        id: notifId,
        title: item.title,
        body: item.message,
        notificationDetails: details,
        payload: payloadString,
      );
    } catch (e) {
      debugPrint('Local notification display notice (safe fallback): $e');
    }
  }

  /// Notification tap callback from system notification shade.
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      AppRouter.router.push(RouteNames.notifications);
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      navigateFromPayload(data);
    } catch (e) {
      debugPrint('Error parsing notification tap payload: $e');
      AppRouter.router.push(RouteNames.notifications);
    }
  }

  /// Actionable Deep-Link Navigation handler.
  /// Directs the user to the exact target screen based on route or notification type.
  static void navigateFromPayload(Map<String, dynamic> data) {
    final actionRoute = data['action_route'] as String? ?? data['actionRoute'] as String?;
    final typeString = data['type'] as String?;
    final relatedId = data['related_id'] as String? ?? data['relatedId'] as String?;

    debugPrint('Navigating from notification payload: route=$actionRoute, type=$typeString, id=$relatedId');

    // 1. Direct route if specified
    if (actionRoute != null && actionRoute.isNotEmpty) {
      try {
        AppRouter.router.push(actionRoute);
        return;
      } catch (e) {
        debugPrint('Direct route push failed ($actionRoute): $e. Using fallback.');
      }
    }

    // 2. Type-based contextual navigation
    switch (typeString?.toLowerCase()) {
      case 'application':
        AppRouter.router.push(RouteNames.applicationTracking);
        break;
      case 'verification':
        AppRouter.router.push(RouteNames.verificationCentre);
        break;
      case 'payment':
        AppRouter.router.push(RouteNames.payments);
        break;
      case 'document':
        AppRouter.router.push(RouteNames.documentWallet);
        break;
      case 'jago':
        AppRouter.router.push(RouteNames.jago);
        break;
      case 'alert':
      case 'system':
      case 'reminder':
      default:
        AppRouter.router.push(RouteNames.notifications);
        break;
    }
  }
}
