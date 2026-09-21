import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/models/notification_item.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Notifications list page — dynamically connected to NotificationRepository.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScholarshipDataService? scholarshipService;
    try {
      scholarshipService = Provider.of<ScholarshipDataService>(context);
    } catch (_) {}

    final notifications = scholarshipService?.notifications ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => scholarshipService?.markAllNotificationsAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
          body: notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "You're all caught up! Updates will appear here.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final formattedTime = _formatTime(notif.timestamp);

                    return Material(
                      color: notif.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.04),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: () {
                          scholarshipService?.markNotificationAsRead(notif.id);
                          context.push(
                            RouteNames.notificationDetails,
                            extra: {
                              'title': notif.title,
                              'message': notif.message,
                              'time': formattedTime,
                              'type': notif.type,
                            },
                          );
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getColor(notif.type).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_getIcon(notif.type), color: _getColor(notif.type), size: 20),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (!notif.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedTime,
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.application:
        return AppColors.primary;
      case NotificationType.verification:
        return AppColors.accent;
      case NotificationType.payment:
        return AppColors.success;
      case NotificationType.document:
        return AppColors.warning;
      case NotificationType.alert:
        return AppColors.error;
      case NotificationType.system:
        return AppColors.textSecondary;
      case NotificationType.reminder:
        return AppColors.info;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.application:
        return Icons.description_outlined;
      case NotificationType.verification:
        return Icons.verified_user_outlined;
      case NotificationType.payment:
        return Icons.account_balance_wallet_outlined;
      case NotificationType.document:
        return Icons.folder_outlined;
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.reminder:
        return Icons.alarm;
    }
  }
}
