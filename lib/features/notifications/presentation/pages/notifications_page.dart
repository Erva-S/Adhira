import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Notifications list page.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotifData(type: NotificationType.verification, title: 'ST Certificate Verification In Progress', message: 'Your ST certificate is being verified by the district office. Expected completion: 3-5 working days.', time: '2 hours ago', isRead: false),
      _NotifData(type: NotificationType.payment, title: 'Payment Disbursed', message: '₹20,000 maintenance allowance has been credited to your bank account.', time: '1 day ago', isRead: false),
      _NotifData(type: NotificationType.application, title: 'Application Update', message: 'Your Post-Matric Scholarship application status changed to "Under Review".', time: '3 days ago', isRead: true),
      _NotifData(type: NotificationType.document, title: 'Document Rejected', message: 'Your Income Certificate was rejected. Reason: Expired document. Please re-upload.', time: '5 days ago', isRead: true),
      _NotifData(type: NotificationType.alert, title: 'Deadline Approaching', message: 'Post-Matric Scholarship application deadline is 31 Jan 2026. Complete your profile now.', time: '1 week ago', isRead: true),
      _NotifData(type: NotificationType.system, title: 'Welcome to Tribal Scholar Saathi', message: 'Your account has been created successfully. Complete your profile to start applying.', time: '2 weeks ago', isRead: true),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
        ],
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Material(
            color: notif.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.03),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () {
                context.push(
                  RouteNames.notificationDetails,
                  extra: {
                    'title': notif.title,
                    'message': notif.message,
                    'time': notif.time,
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
              title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w600, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notif.message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(notif.time, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
              trailing: !notif.isRead
                  ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
                  : null,
            ),
          );
        },
      ),
    );
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.application: return AppColors.info;
      case NotificationType.verification: return AppColors.warning;
      case NotificationType.payment: return AppColors.success;
      case NotificationType.document: return AppColors.error;
      case NotificationType.alert: return AppColors.accent;
      case NotificationType.system: return AppColors.textSecondary;
      case NotificationType.reminder: return AppColors.info;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.application: return Icons.description;
      case NotificationType.verification: return Icons.verified_user;
      case NotificationType.payment: return Icons.payment;
      case NotificationType.document: return Icons.folder;
      case NotificationType.alert: return Icons.warning_amber;
      case NotificationType.system: return Icons.info;
      case NotificationType.reminder: return Icons.notifications;
    }
  }
}

class _NotifData {
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  const _NotifData({required this.type, required this.title, required this.message, required this.time, required this.isRead});
}
