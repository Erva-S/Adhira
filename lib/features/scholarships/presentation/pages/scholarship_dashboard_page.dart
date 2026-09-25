import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/scholarship/scholarship_mock_data.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/application_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';

/// Unified Scholarship Dashboard covering all 5 MoTA schemes,
/// application lifecycle status, quick access tools, and live activity.
class ScholarshipDashboardPage extends StatelessWidget {
  const ScholarshipDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScholarshipDataService>(
      builder: (context, scholarshipService, _) {
        final activeApps = scholarshipService.activeApplications;
        final schemes = scholarshipService.schemes;
        final recentActivity = scholarshipService.recentActivity;

        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
            title: const Text('Scholarship Dashboard'),
            actions: [
              IconButton(
                tooltip: 'All Applications',
                icon: const Icon(Icons.folder_outlined),
                onPressed: () => context.push(RouteNames.applicationsList),
              ),
              IconButton(
                tooltip: 'AI Assistant',
                icon: const Icon(Icons.smart_toy_outlined),
                onPressed: () => context.push(RouteNames.jago),
              ),
            ],
          ),
          body: scholarshipService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => scholarshipService.refreshData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Hero KPI Banner ──────────────────────────────────
                        _buildHeroBanner(context, scholarshipService),

                        const SizedBox(height: 16),

                        // ── Quick Access Row ─────────────────────────────────
                        _buildQuickActionShortcuts(context),

                        const SizedBox(height: 20),

                        // ── My Active Applications ───────────────────────────
                        SectionHeader(
                          title: 'My Applications',
                          actionText: activeApps.isNotEmpty
                              ? 'View All (${scholarshipService.applications.length})'
                              : null,
                          onAction: () => context.push(RouteNames.applicationsList),
                        ),
                        if (activeApps.isEmpty)
                          _buildEmptyApplicationsCard(context)
                        else
                          ...activeApps.take(3).map((app) => ApplicationCard(
                                scholarshipName: app.scholarshipName,
                                scholarshipType: app.scholarshipType,
                                status: app.status,
                                applicationNumber: app.applicationNumber,
                                lastUpdated: app.lastUpdated != null ? _formatDate(app.lastUpdated!) : null,
                                pendingActionsCount: app.pendingActions.length,
                                onTap: () => context.push(
                                  RouteNames.applicationDetails,
                                  extra: {'application': app},
                                ),
                              )),

                        const SizedBox(height: 20),

                        // ── MoTA Scholarship Schemes ─────────────────────────
                        SectionHeader(
                          title: 'MoTA Scholarship Schemes',
                          actionText: 'Explore (${schemes.length})',
                          onAction: () => context.go(RouteNames.scholarshipDiscovery),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: schemes.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final scheme = schemes[index];
                              return _buildSchemeSummaryCard(context, scheme);
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Recent Activity Feed ─────────────────────────────
                        const SectionHeader(title: 'Recent Activity'),
                        if (recentActivity.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'No recent activity to show.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recentActivity.take(4).length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final activity = recentActivity[index];
                                return _buildActivityTile(context, activity);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_task),
            label: const Text('Apply Now'),
            onPressed: () => context.push(RouteNames.applicationForm),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner(BuildContext context, ScholarshipDataService service) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MoTA Tribal Scholarship Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Direct Benefit Transfer (DBT) Portal',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Apps',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${service.activeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.white24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Disbursed',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${service.totalDisbursed.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.white24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Schemes Open',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.schemes.where((s) => s.isOpen).length}/5',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionShortcuts(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildShortcutChip(
            context: context,
            icon: Icons.edit_document,
            label: 'New Application',
            color: AppColors.primary,
            onTap: () => context.push(RouteNames.applicationForm),
          ),
          const SizedBox(width: 8),
          _buildShortcutChip(
            context: context,
            icon: Icons.checklist_rtl,
            label: 'Eligibility Checker',
            color: AppColors.preMatric,
            onTap: () => context.push(RouteNames.eligibilityChecker),
          ),
          const SizedBox(width: 8),
          _buildShortcutChip(
            context: context,
            icon: Icons.track_changes,
            label: 'Track Status',
            color: AppColors.topClass,
            onTap: () => context.push(RouteNames.applicationTracking),
          ),
          const SizedBox(width: 8),
          _buildShortcutChip(
            context: context,
            icon: Icons.account_balance_wallet,
            label: 'DBT Payments',
            color: AppColors.success,
            onTap: () => context.push(RouteNames.payments),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyApplicationsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.assignment_outlined, size: 44, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            const Text(
              'No active scholarship applications',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose from 5 MoTA schemes and apply to receive financial support.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.applicationForm),
              icon: const Icon(Icons.add),
              label: const Text('Apply for a Scholarship'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeSummaryCard(BuildContext context, Scholarship scheme) {
    final color = _getColorForScheme(scheme.type);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  scheme.type.shortCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(
                label: scheme.isOpen ? 'Open' : 'Closed',
                variant: scheme.isOpen
                    ? StatusBadgeVariant.success
                    : StatusBadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            scheme.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  scheme.maxAmount != null
                      ? 'Max ₹${(scheme.maxAmount! / 1000).toStringAsFixed(0)}K/yr'
                      : 'Variable grant',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push(
                  RouteNames.scholarshipDetails,
                  extra: {
                    'name': scheme.name,
                    'type': scheme.type,
                    'description': scheme.description,
                    'amount': scheme.maxAmount != null
                        ? 'Up to ₹${scheme.maxAmount!.toInt()}/year'
                        : 'Variable amount',
                    'deadline': scheme.applicationDeadline != null
                        ? _formatDate(scheme.applicationDeadline!)
                        : 'Open',
                  },
                ),
                child: const Text(
                  'Details →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, ActivityItem activity) {
    IconData icon;
    Color iconColor;

    switch (activity.type) {
      case ActivityType.payment:
        icon = Icons.currency_rupee;
        iconColor = AppColors.success;
        break;
      case ActivityType.verification:
        icon = Icons.verified;
        iconColor = AppColors.primary;
        break;
      case ActivityType.document:
        icon = Icons.upload_file;
        iconColor = AppColors.warning;
        break;
      case ActivityType.application:
        icon = Icons.assignment_turned_in;
        iconColor = AppColors.topClass;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        activity.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        activity.description,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
      trailing: Text(
        _formatDate(activity.timestamp),
        style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
      ),
    );
  }

  Color _getColorForScheme(ScholarshipType type) {
    switch (type) {
      case ScholarshipType.preMatric:
        return AppColors.preMatric;
      case ScholarshipType.postMatric:
        return AppColors.postMatric;
      case ScholarshipType.topClass:
        return AppColors.topClass;
      case ScholarshipType.nfst:
        return AppColors.nfst;
      case ScholarshipType.nos:
        return AppColors.nos;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
