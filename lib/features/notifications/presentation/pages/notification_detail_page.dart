import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_back_button.dart';

import '../../../../services/notifications/push_notification_service.dart';

/// Notification detail page showing the complete notification content.
class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final String? actionRoute;
  final String? relatedId;

  const NotificationDetailPage({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.type = NotificationType.system,
    this.actionRoute,
    this.relatedId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.notifications),
        title: const Text('Notification Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getColor(type).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIcon(type), color: _getColor(type), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.name.toUpperCase(),
                        style: TextStyle(
                          color: _getColor(type),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            if (actionRoute != null && actionRoute!.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () {
                  PushNotificationService.navigateFromPayload({
                    'action_route': actionRoute,
                    'type': type.name,
                    'related_id': relatedId,
                  });
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(_getActionLabel(type)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Notifications'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getActionLabel(NotificationType type) {
    switch (type) {
      case NotificationType.application:
        return 'View Application Status';
      case NotificationType.verification:
        return 'Open Verification Centre';
      case NotificationType.payment:
        return 'View DBT Disbursements';
      case NotificationType.document:
        return 'Go to Document Wallet';
      case NotificationType.reminder:
      case NotificationType.alert:
      case NotificationType.system:
        return 'Take Action';
    }
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.application:
        return AppColors.info;
      case NotificationType.verification:
        return AppColors.warning;
      case NotificationType.payment:
        return AppColors.success;
      case NotificationType.document:
        return AppColors.error;
      case NotificationType.alert:
        return AppColors.accent;
      case NotificationType.system:
        return AppColors.textSecondary;
      case NotificationType.reminder:
        return AppColors.info;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.application:
        return Icons.description;
      case NotificationType.verification:
        return Icons.verified_user;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.document:
        return Icons.folder;
      case NotificationType.alert:
        return Icons.warning_amber;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.reminder:
        return Icons.notifications;
    }
  }
}
