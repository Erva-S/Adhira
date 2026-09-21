import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/application_card.dart';

/// Applications List Page — View, filter, and search all scholarship applications.
class ApplicationsListPage extends StatefulWidget {
  const ApplicationsListPage({super.key});

  @override
  State<ApplicationsListPage> createState() => _ApplicationsListPageState();
}

class _ApplicationsListPageState extends State<ApplicationsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScholarshipDataService>(
      builder: (context, scholarshipService, _) {
        final allApps = scholarshipService.applications;

        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(fallbackRoute: RouteNames.scholarshipDashboard),
            title: const Text('My Applications'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'All (${allApps.length})'),
                Tab(text: 'Active (${scholarshipService.activeCount})'),
                Tab(text: 'Approved (${scholarshipService.completedApplications.length})'),
                Tab(text: 'Drafts (${scholarshipService.draftApplications.length})'),
                Tab(text: 'Rejected (${scholarshipService.rejectedApplications.length})'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by scheme or application number...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildApplicationList(allApps),
                    _buildApplicationList(scholarshipService.activeApplications),
                    _buildApplicationList(scholarshipService.completedApplications),
                    _buildApplicationList(scholarshipService.draftApplications),
                    _buildApplicationList(scholarshipService.rejectedApplications),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Application'),
            onPressed: () => context.push(RouteNames.applicationForm),
          ),
        );
      },
    );
  }

  Widget _buildApplicationList(List<ScholarshipApplication> apps) {
    final filtered = apps.where((a) {
      if (_searchQuery.isEmpty) return true;
      final nameMatches = a.scholarshipName.toLowerCase().contains(_searchQuery);
      final numMatches = a.applicationNumber?.toLowerCase().contains(_searchQuery) ?? false;
      return nameMatches || numMatches;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open, size: 56, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              const Text(
                'No applications found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try adjusting your search criteria.'
                    : 'You have no applications in this category.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push(RouteNames.applicationForm),
                  icon: const Icon(Icons.add),
                  label: const Text('Apply for a Scheme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final app = filtered[index];
        return ApplicationCard(
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
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
