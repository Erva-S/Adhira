import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/app_button.dart';

/// Main dashboard — student overview with key stats and actions.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryLight,
                      child: Text('RS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Namaste, Rajesh 🙏', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Post-Matric Scholarship • 2025-26', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go(RouteNames.notifications),
                      icon: Badge(
                        label: const Text('3'),
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
                          const Text('72%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.72,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Complete your profile to apply for scholarships', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Quick Actions ────────────────────────────────────
              SectionHeader(title: 'Quick Actions'),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _QuickAction(icon: Icons.search, label: 'Find\nSchemes', color: AppColors.postMatric, onTap: () => context.go(RouteNames.scholarshipDiscovery)),
                    _QuickAction(icon: Icons.checklist, label: 'Check\nEligibility', color: AppColors.preMatric, onTap: () => context.go(RouteNames.eligibilityChecker)),
                    _QuickAction(icon: Icons.track_changes, label: 'Track\nApplication', color: AppColors.nfst, onTap: () => context.go(RouteNames.applicationTracking)),
                    _QuickAction(icon: Icons.verified_user, label: 'Verification\nCentre', color: AppColors.topClass, onTap: () => context.go(RouteNames.verificationCentre)),
                    _QuickAction(icon: Icons.payment, label: 'Payment\nStatus', color: AppColors.nos, onTap: () => context.go(RouteNames.payments)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Current Application ──────────────────────────────
              SectionHeader(title: 'Current Application', actionText: 'View All', onAction: () => context.go(RouteNames.applicationTracking)),
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
                            child: Text('Post-Matric Scholarship', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          const StatusBadge(label: 'Under Review', variant: StatusBadgeVariant.warning),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Application #PMS-2025-78432', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatChip(label: 'Verified', value: '5/7', color: AppColors.success),
                          const SizedBox(width: 8),
                          _StatChip(label: 'Pending', value: '2', color: AppColors.warning),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppButton(label: 'View Details', variant: AppButtonVariant.outline, size: AppButtonSize.small, onPressed: () => context.go(RouteNames.applicationTracking)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Payment Status ───────────────────────────────────
              SectionHeader(title: 'Payment Status', actionText: 'Details', onAction: () => context.go(RouteNames.payments)),
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
                            Text('₹45,000', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.success)),
                            const SizedBox(height: 4),
                            Text('Disbursed', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.divider),
                      Expanded(
                        child: Column(
                          children: [
                            Text('₹25,000', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.warning)),
                            const SizedBox(height: 4),
                            Text('Pending', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
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
                    _SchemeChip(name: 'Pre-Matric', icon: Icons.school, color: AppColors.preMatric),
                    _SchemeChip(name: 'Post-Matric', icon: Icons.menu_book, color: AppColors.postMatric),
                    _SchemeChip(name: 'Top Class', icon: Icons.star, color: AppColors.topClass),
                    _SchemeChip(name: 'NFST', icon: Icons.science, color: AppColors.nfst),
                    _SchemeChip(name: 'NOS', icon: Icons.flight, color: AppColors.nos),
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
  const _SchemeChip({required this.name, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
    );
  }
}
