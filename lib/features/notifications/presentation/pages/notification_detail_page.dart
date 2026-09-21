import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Notification detail page showing the complete notification content.
class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final NotificationType type;

  const NotificationDetailPage({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.type = NotificationType.system,
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
                    color: _getColor(type).withOpacity(0.12),
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
