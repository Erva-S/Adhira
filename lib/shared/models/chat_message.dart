import '../../core/enums/app_enums.dart';

/// Represents a single chat message in the JAGO assistant.
class ChatMessage {
  final String id;
  final ChatSender sender;
  final String content;
  final DateTime timestamp;
  final bool isRichCard; // if true, display as a card instead of text bubble
  final Map<String, dynamic>? richCardData;
  final List<String>? suggestedActions;

  final bool isError;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isRichCard = false,
    this.richCardData,
    this.suggestedActions,
    this.isError = false,
  });
}
