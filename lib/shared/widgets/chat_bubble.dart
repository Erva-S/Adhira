import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/app_enums.dart';

/// Chat bubble for the JAGO chat assistant.
class ChatBubble extends StatelessWidget {
  final String message;
  final ChatSender sender;
  final String? timestamp;
  final bool isError;
  final VoidCallback? onRetry;

  const ChatBubble({
    super.key,
    required this.message,
    required this.sender,
    this.timestamp,
    this.isError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = sender == ChatSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : (isError ? AppColors.surfaceVariant : AppColors.surfaceVariant),
          border: isError
              ? Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 1)
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isError) ...[
                  const Padding(
                    padding: EdgeInsets.only(right: 6, top: 2),
                    child: Icon(Icons.info_outline, size: 16, color: AppColors.error),
                  ),
                ],
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isError ? AppColors.error : AppColors.textPrimary),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (isError && onRetry != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                timestamp!,
                style: TextStyle(
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
