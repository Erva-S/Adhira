import 'package:flutter/foundation.dart';
import '../../core/enums/app_enums.dart';
import '../../shared/models/chat_message.dart';

/// Service to manage in-memory session chat history for JAGO AI Assistant.
///
/// Ensures:
/// 1. Chat history is preserved during the current login session across screen navigations.
/// 2. Chat history is strictly isolated per authenticated user ID.
/// 3. Chat history is completely cleared on logout.
/// 4. Fresh session starts upon next login.
class JagoSessionService extends ChangeNotifier {
  static final JagoSessionService _instance = JagoSessionService._internal();
  factory JagoSessionService() => _instance;
  JagoSessionService._internal();

  /// Map of userId -> List of ChatMessage
  final Map<String, List<ChatMessage>> _userSessions = {};

  /// Map of userId -> last failed user message (for retry)
  final Map<String, String?> _lastFailedMessages = {};

  String _resolveKey(String? userId) {
    if (userId != null && userId.trim().isNotEmpty) {
      return userId.trim();
    }
    return '__anonymous_session__';
  }

  /// Returns the current chat messages for the specified user.
  List<ChatMessage> getMessages(String? userId) {
    final key = _resolveKey(userId);
    return List.unmodifiable(_userSessions[key] ?? []);
  }

  /// Whether there are existing messages for the specified user.
  bool hasMessages(String? userId) {
    final key = _resolveKey(userId);
    return _userSessions[key]?.isNotEmpty ?? false;
  }

  /// Seeds the initial assistant greeting if the session is empty.
  void seedGreetingIfEmpty(String? userId, String greetingText) {
    final key = _resolveKey(userId);
    if (_userSessions[key] == null || _userSessions[key]!.isEmpty) {
      _userSessions[key] = [
        ChatMessage(
          id: 'greeting_${DateTime.now().millisecondsSinceEpoch}',
          sender: ChatSender.bot,
          content: greetingText,
          timestamp: DateTime.now(),
        ),
      ];
      notifyListeners();
    }
  }

  /// Appends a new message to the user's session history.
  void addMessage(String? userId, ChatMessage message) {
    final key = _resolveKey(userId);
    _userSessions.putIfAbsent(key, () => []);
    _userSessions[key]!.add(message);
    notifyListeners();
  }

  /// Retrieves the last failed user message text for retry, if any.
  String? getLastFailedMessage(String? userId) {
    final key = _resolveKey(userId);
    return _lastFailedMessages[key];
  }

  /// Sets or clears the last failed user message.
  void setLastFailedMessage(String? userId, String? message) {
    final key = _resolveKey(userId);
    if (message == null) {
      _lastFailedMessages.remove(key);
    } else {
      _lastFailedMessages[key] = message;
    }
  }

  /// Clears the session for a specific user ID, or all if none provided.
  void clearSession([String? userId]) {
    if (userId != null && userId.trim().isNotEmpty) {
      final key = _resolveKey(userId);
      _userSessions.remove(key);
      _lastFailedMessages.remove(key);
    } else {
      clearAllSessions();
    }
    notifyListeners();
  }

  /// Clears all stored sessions (called on logout to ensure zero cross-user pollution).
  void clearAllSessions() {
    _userSessions.clear();
    _lastFailedMessages.clear();
    notifyListeners();
  }
}
