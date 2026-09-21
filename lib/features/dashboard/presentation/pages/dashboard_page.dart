import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/app_button.dart';

/// Main dashboard — student overview with key stats and actions.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScholarshipDataService, AuthProvider>(
      builder: (context, scholarshipService, authProvider, _) {
        final student = authProvider.currentUser;
        if (student != null && scholarshipService.currentUserId != student.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scholarshipService.switchUser(student.id);
          });
        }

        final currentApp = scholarshipService.activeApplications.firstOrNull ??
            scholarshipService.applications.firstOrNull;
        final disbursed = scholarshipService.totalDisbursed.toInt();
        final pending = scholarshipService.totalPending.toInt();
        final displayName = student?.fullName ?? 'Scholar';
        final initials = displayName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();
        final profilePercent = ((student?.profileCompletionPercent ?? 0.72) * 100).toInt();
        final openActions = scholarshipService.pendingActions.where((a) => a.isOpen).toList();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App Bar ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            initials.isNotEmpty ? initials : 'ST',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Namaste, $displayName 🙏',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                currentApp != null
                                    ? '${currentApp.scholarshipName} • ${currentApp.academicYear ?? "2025-26"}'
                                    : 'Tribal Scholar Saathi • MoTA',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.push(RouteNames.notifications),
                          icon: Badge(
                            isLabelVisible: scholarshipService.unreadNotificationCount > 0,
                            label: Text('${scholarshipService.unreadNotificationCount}'),
                            child: const Icon(Icons.notifications_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Profile Completion ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text('Profile Completion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                              ),
                              Text('$profilePercent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (student?.profileCompletionPercent ?? 0.72).clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profilePercent < 100
                                ? 'Complete all profile details to fast-track verification'
                                : 'Profile 100% complete — verified for all schemes',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Pending Actions / Deficiencies (Part 11) ───────────
                  if (openActions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Action Required (Deficiency)',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFB78103)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              openActions.first.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              openActions.first.description,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => scholarshipService.resolvePendingAction(openActions.first.id),
                                  child: const Text('Mark Resolved'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => context.push(RouteNames.documentWallet),
                                  child: const Text('Go to Documents'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (openActions.isNotEmpty) const SizedBox(height: 16),

                  // ── Quick Actions ────────────────────────────────────
                  SectionHeader(title: 'Quick Actions'),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _QuickAction(icon: Icons.dashboard_customize, label: 'Scholarship\nHub', color: AppColors.primary, onTap: () => context.push(RouteNames.scholarshipDashboard)),
                        _QuickAction(icon: Icons.search, label: 'Find\nSchemes', color: AppColors.postMatric, onTap: () => context.go(RouteNames.scholarshipDiscovery)),
                        _QuickAction(icon: Icons.checklist, label: 'Check\nEligibility', color: AppColors.preMatric, onTap: () => context.push(RouteNames.eligibilityChecker)),
                        _QuickAction(icon: Icons.track_changes, label: 'Track\nApplication', color: AppColors.nfst, onTap: () => context.push(RouteNames.applicationTracking)),
                        _QuickAction(icon: Icons.verified_user, label: 'Verification\nCentre', color: AppColors.topClass, onTap: () => context.push(RouteNames.verificationCentre)),
                        _QuickAction(icon: Icons.payment, label: 'Payment\nStatus', color: AppColors.nos, onTap: () => context.push(RouteNames.payments)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Current Application ──────────────────────────────
                  SectionHeader(
                    title: 'Current Application',
                    actionText: 'View All',
                    onAction: () => context.push(RouteNames.applicationsList),
                  ),
                  if (currentApp != null)
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currentApp.scholarshipName,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                StatusBadge.fromApplicationStatus(currentApp.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Application #${currentApp.applicationNumber ?? "N/A"}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _StatChip(label: 'Academic Year', value: currentApp.academicYear ?? '2025-26', color: AppColors.primary),
                                const SizedBox(width: 8),
                                _StatChip(label: 'Pending Actions', value: '${currentApp.pendingActions.length}', color: currentApp.pendingActions.isNotEmpty ? AppColors.warning : AppColors.success),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    label: 'View Details',
                                    variant: AppButtonVariant.outline,
                                    size: AppButtonSize.small,
                                    onPressed: () => context.push(
                                      RouteNames.applicationDetails,
                                      extra: {'application': currentApp},
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppButton(
                                    label: 'Track',
                                    variant: AppButtonVariant.primary,
                                    size: AppButtonSize.small,
                                    onPressed: () => context.push(
                                      RouteNames.applicationTracking,
                                      extra: {'application': currentApp},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('No current applications found.'),
                            const SizedBox(height: 8),
                            AppButton(
                              label: 'Apply for Scholarship',
                              onPressed: () => context.push(RouteNames.applicationForm),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ── Payment Status ───────────────────────────────────
                  SectionHeader(title: 'Payment Status', actionText: 'Details', onAction: () => context.push(RouteNames.payments)),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('₹$disbursed', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.success)),
                                const SizedBox(height: 4),
                                const Text('Disbursed', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: AppColors.divider),
                          Expanded(
                            child: Column(
                              children: [
                                Text('₹$pending', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.warning)),
                                const SizedBox(height: 4),
                                const Text('Pending', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Eligible Schemes ─────────────────────────────────
                  SectionHeader(title: 'Explore Schemes', actionText: 'See All', onAction: () => context.go(RouteNames.scholarshipDiscovery)),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _SchemeChip(
                          name: 'Pre-Matric',
                          icon: Icons.school,
                          color: AppColors.preMatric,
                          onTap: () => context.push(
                            RouteNames.scholarshipDetails,
                            extra: {
                              'name': 'Pre-Matric Scholarship for ST',
                              'type': ScholarshipType.preMatric,
                              'description': 'Financial assistance for ST students studying in classes 9 and 10 to reduce dropout rates.',
                              'amount': 'Up to ₹10,000/year',
                              'deadline': '31 Dec 2025',
                            },
                          ),
                        ),
                        _SchemeChip(
                          name: 'Post-Matric',
                          icon: Icons.menu_book,
                          color: AppColors.postMatric,
                          onTap: () => context.push(
                            RouteNames.scholarshipDetails,
                            extra: {
                              'name': 'Post-Matric Scholarship for ST',
                              'type': ScholarshipType.postMatric,
                              'description': 'Support for ST students pursuing post-matriculation courses including professional and technical courses.',
                              'amount': 'Up to ₹1,30,000/year',
                              'deadline': '31 Jan 2026',
                            },
                          ),
                        ),
                        _SchemeChip(
                          name: 'Top Class',
                          icon: Icons.star,
                          color: AppColors.topClass,
                          onTap: () => context.push(
                            RouteNames.scholarshipDetails,
                            extra: {
                              'name': 'Top Class Education for ST',
                              'type': ScholarshipType.topClass,
                              'description': 'Full financial support for ST students admitted to top institutions like IITs, IIMs, NITs, AIIMS.',
                              'amount': 'Full tuition + allowance',
                              'deadline': '28 Feb 2026',
                            },
                          ),
                        ),
                        _SchemeChip(
                          name: 'NFST',
                          icon: Icons.science,
                          color: AppColors.nfst,
                          onTap: () => context.push(
                            RouteNames.scholarshipDetails,
                            extra: {
                              'name': 'National Fellowship for ST (NFST)',
                              'type': ScholarshipType.nfst,
                              'description': 'Fellowship for ST students pursuing M.Phil and Ph.D in universities, colleges, and institutions.',
                              'amount': '₹31,000-₹35,000/month',
                              'deadline': '15 Mar 2026',
                            },
                          ),
                        ),
                        _SchemeChip(
                          name: 'NOS',
                          icon: Icons.flight,
                          color: AppColors.nos,
                          onTap: () => context.push(
                            RouteNames.scholarshipDetails,
                            extra: {
                              'name': 'National Overseas Scholarship',
                              'type': ScholarshipType.nos,
                              'description': 'Support for ST students to study abroad at Masters and Ph.D level in accredited institutions.',
                              'amount': 'Full funding abroad',
                              'deadline': '30 Apr 2026',
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // space for bottom nav
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNav(currentIndex: 0),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _SchemeChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SchemeChip({
    required this.name,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 10),
              Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
