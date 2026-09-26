import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/digilocker_connection_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/scholarships/presentation/pages/scholarship_dashboard_page.dart';
import '../../features/scholarships/presentation/pages/scholarship_discovery_page.dart';
import '../../features/scholarships/presentation/pages/scholarship_detail_page.dart';
import '../../features/eligibility/presentation/pages/eligibility_checker_page.dart';
import '../../features/applications/presentation/pages/applications_list_page.dart';
import '../../features/applications/presentation/pages/application_tracking_page.dart';
import '../../features/applications/presentation/pages/application_detail_page.dart';
import '../../features/applications/presentation/pages/application_form_page.dart';
import '../../features/verification/presentation/pages/verification_centre_page.dart';
import '../../features/documents/presentation/pages/document_wallet_page.dart';
import '../../features/documents/presentation/pages/document_detail_page.dart';
import '../../features/documents/presentation/pages/digilocker_consent_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/pages/notification_detail_page.dart';
import '../../features/jago/presentation/pages/jago_chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/models/models.dart';
import '../../core/enums/app_enums.dart';

/// Application router configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Auth Routes ─────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phoneNumber'] as String? ?? '9876543210';
          return OtpVerificationPage(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: RouteNames.connectDigiLocker,
        name: 'connectDigiLocker',
        builder: (context, state) => const DigiLockerConnectionPage(),
      ),

      // ── Main Routes ─────────────────────────────────────────────
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: RouteNames.scholarshipDashboard,
        name: 'scholarshipDashboard',
        builder: (context, state) => const ScholarshipDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.scholarshipDiscovery,
        name: 'scholarshipDiscovery',
        builder: (context, state) => const ScholarshipDiscoveryPage(),
      ),
      GoRoute(
        path: RouteNames.scholarshipDetails,
        name: 'scholarshipDetails',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ScholarshipDetailPage(
            name: extra?['name'] as String? ?? 'Scholarship Scheme',
            type: extra?['type'] as ScholarshipType? ?? ScholarshipType.postMatric,
            description: extra?['description'] as String? ??
                'Comprehensive scholarship scheme for ST students.',
            amount: extra?['amount'] as String? ?? 'Up to ₹1,30,000/year',
            deadline: extra?['deadline'] as String? ?? '31 Jan 2026',
          );
        },
      ),

      // ── Applications ────────────────────────────────────────────
      GoRoute(
        path: RouteNames.applicationsList,
        name: 'applicationsList',
        builder: (context, state) => const ApplicationsListPage(),
      ),
      GoRoute(
        path: RouteNames.applicationTracking,
        name: 'applicationTracking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ApplicationTrackingPage(
            application: extra?['application'] as ScholarshipApplication?,
            applicationId: extra?['applicationId'] as String?,
          );
        },
      ),
      GoRoute(
        path: RouteNames.applicationForm,
        name: 'applicationForm',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ApplicationFormPage(
            initialScholarship: extra?['scholarship'] as Scholarship?,
          );
        },
      ),
      GoRoute(
        path: RouteNames.applicationDetails,
        name: 'applicationDetails',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ApplicationDetailPage(
            application: extra?['application'] as ScholarshipApplication?,
            applicationId: extra?['applicationId'] as String?,
          );
        },
      ),

      // ── Eligibility ─────────────────────────────────────────────
      GoRoute(
        path: RouteNames.eligibilityChecker,
        name: 'eligibilityChecker',
        builder: (context, state) {
          final extra = state.extra;
          String? schemeId;
          if (extra is Map<String, dynamic>) {
            schemeId = extra['schemeId'] as String? ?? extra['scholarshipId'] as String?;
          } else if (extra is String) {
            schemeId = extra;
          }
          schemeId ??= state.uri.queryParameters['schemeId'];
          return EligibilityCheckerPage(initialSchemeId: schemeId);
        },
      ),

      // ── Verification ────────────────────────────────────────────
      GoRoute(
        path: RouteNames.verificationCentre,
        name: 'verificationCentre',
        builder: (context, state) => const VerificationCentrePage(),
      ),

      // ── Documents ───────────────────────────────────────────────
      GoRoute(
        path: RouteNames.documentWallet,
        name: 'documentWallet',
        builder: (context, state) => const DocumentWalletPage(),
      ),
      GoRoute(
        path: RouteNames.documentUpload,
        name: 'documentUpload',
        builder: (context, state) => const DocumentWalletPage(),
      ),
      GoRoute(
        path: RouteNames.documentDetails,
        name: 'documentDetails',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DocumentDetailPage(
            name: extra?['name'] as String? ?? 'Document',
            category: extra?['category'] as DocumentCategory? ?? DocumentCategory.identity,
            status: extra?['status'] as DocumentStatus? ?? DocumentStatus.uploaded,
            isFromDigiLocker: extra?['isFromDigiLocker'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: RouteNames.digiLockerConsent,
        name: 'digiLockerConsent',
        builder: (context, state) => const DigiLockerConsentPage(
          autoImportToWallet: true,
        ),
      ),

      // ── Payments ────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.payments,
        name: 'payments',
        builder: (context, state) => const PaymentsPage(),
      ),

      // ── Notifications ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: RouteNames.notificationDetails,
        name: 'notificationDetails',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return NotificationDetailPage(
            title: extra?['title'] as String? ?? 'Notification',
            message: extra?['message'] as String? ?? 'No message content available.',
            time: extra?['time'] as String? ?? 'Just now',
            type: extra?['type'] as NotificationType? ?? NotificationType.system,
          );
        },
      ),

      // ── JAGO Chatbot ────────────────────────────────────────────
      GoRoute(
        path: RouteNames.jago,
        name: 'jago',
        builder: (context, state) => const JagoChatPage(),
      ),

      // ── Profile ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: RouteNames.profileEdit,
        name: 'profileEdit',
        builder: (context, state) => const ProfileEditPage(),
      ),

      // ── Settings ────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
