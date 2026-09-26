import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/scholarship/scholarship_eligibility_service.dart';
import '../../../../services/scholarship/scholarship_mock_data.dart';
import '../../../../services/database/relational_data_store.dart';
import '../../../../services/jago/jago_context_service.dart';

/// Full-featured, criteria-grounded Eligibility Checker.
///
/// Automatically uses the authenticated user's actual profile (including DigiLocker data)
/// as primary input, evaluates official MoTA scholarship criteria deterministically,
/// and clearly displays satisfied, failed, and indeterminate conditions without false certainty.
class EligibilityCheckerPage extends StatefulWidget {
  final String? initialSchemeId;

  const EligibilityCheckerPage({
    super.key,
    this.initialSchemeId,
  });

  @override
  State<EligibilityCheckerPage> createState() => _EligibilityCheckerPageState();
}

class _EligibilityCheckerPageState extends State<EligibilityCheckerPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? _selectedSchemeId;
  double? _tempIncomeOverride;
  final TextEditingController _missingIncomeController = TextEditingController();
  bool _isRecalculating = false;

  TabController get _effectiveTabController {
    return _tabController ??= TabController(length: 2, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialSchemeId != null) {
      _selectedSchemeId = widget.initialSchemeId;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _missingIncomeController.dispose();
    super.dispose();
  }

  void _onSchemeIdSelected(String schemeId) {
    setState(() {
      _selectedSchemeId = schemeId;
      _tempIncomeOverride = null;
      _missingIncomeController.clear();
    });
  }

  void _applyIncomeInput(Student? student) {
    final text = _missingIncomeController.text.trim().replaceAll(',', '').replaceAll('₹', '');
    final val = double.tryParse(text);
    if (val != null && val >= 0) {
      setState(() {
        _isRecalculating = true;
        _tempIncomeOverride = val;
      });

      // Also persist to current user profile via AuthProvider if available
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (student != null) {
        final updatedStudent = student.copyWith(annualFamilyIncome: val);
        authProvider.updateProfile(updatedStudent);
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isRecalculating = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final scholarshipService = Provider.of<ScholarshipDataService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Ensure student profile is always resolved even if authProvider is hydrating
    final student = authProvider.currentUser ??
        RelationalDataStore().getUser(scholarshipService.currentUserId) ??
        RelationalDataStore().getUser(RelationalDataStore.demoUserId);

    final rawSchemes = scholarshipService.schemes.isNotEmpty
        ? scholarshipService.schemes
        : ScholarshipMockData.schemes;

    // Guarantee unique schemes by id to prevent dropdown collisions
    final uniqueMap = <String, Scholarship>{};
    for (final s in rawSchemes) {
      uniqueMap[s.id] = s;
    }
    final schemes = uniqueMap.values.toList();

    // Handle empty schemes state gracefully
    if (schemes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
          title: const Text('Eligibility Checker'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text(
                  'No Scholarship Schemes Available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unable to load scholarship scheme guidelines. Please check your connection and retry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Retry',
                  onPressed: () => scholarshipService.loadUserData(student?.id ?? 'session_user'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default to Post-Matric if not selected
    _selectedSchemeId ??= widget.initialSchemeId ??
        schemes.firstWhere(
          (s) => s.type == ScholarshipType.postMatric,
          orElse: () => schemes.first,
        ).id;

    final activeScheme = schemes.firstWhere(
      (s) => s.id == _selectedSchemeId,
      orElse: () => schemes.firstWhere(
        (s) => s.type == ScholarshipType.postMatric,
        orElse: () => schemes.first,
      ),
    );

    // Deterministic evaluation against user profile
    final result = ScholarshipEligibilityService.evaluate(
      scholarship: activeScheme,
      student: student,
      overrideIncome: _tempIncomeOverride,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
        title: const Text('Eligibility Checker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Preliminary Eligibility',
            onPressed: () => _showPreliminaryDisclaimerDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _effectiveTabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.fact_check_outlined, size: 18),
              text: 'Detailed Evaluation',
            ),
            Tab(
              icon: Icon(Icons.dashboard_outlined, size: 18),
              text: 'All Schemes Overview',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _effectiveTabController,
        children: [
          // ── TAB 1: Detailed Evaluation View ───────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick horizontal scheme switch chips
                _buildQuickSchemeChips(schemes, activeScheme, isDark),
                const SizedBox(height: 12),

                // Step 1: Scheme Selector Dropdown Section
                _buildSchemeSelector(schemes, activeScheme, isDark, colorScheme),
                const SizedBox(height: 16),

                // Step 2: Auto-filled Profile Summary
                _buildProfileDataCard(student, result, isDark, colorScheme),
                const SizedBox(height: 16),

                // Step 3: Clear Eligibility Result Banner
                _buildResultBanner(result, isDark, colorScheme),
                const SizedBox(height: 16),

                // Step 4: Missing Information Prompt (if applicable)
                if (result.hasMissingInformation) ...[
                  _buildMissingInfoPrompt(result, student, isDark, colorScheme),
                  const SizedBox(height: 16),
                ],

                // Step 5: "Why" Detailed Breakdown (✓, ✕, ?)
                _buildCriteriaBreakdownCard(result, isDark, colorScheme),
                const SizedBox(height: 16),

                // Step 6: Required Documents Section
                _buildRequiredDocumentsCard(activeScheme, isDark, colorScheme),
                const SizedBox(height: 16),

                // Step 7: Official Non-Binding Disclaimer
                _buildDisclaimerBox(result.disclaimer, isDark, colorScheme),
                const SizedBox(height: 24),

                // Step 8: Action Buttons
                _buildActionButtons(result, activeScheme, schemes),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── TAB 2: All Schemes Overview ───────────────────────────────────
          _buildAllSchemesTab(schemes, student, isDark, colorScheme),
        ],
      ),
    );
  }

  // ── Quick Scheme Switch Chips ─────────────────────────────────────────────

  Widget _buildQuickSchemeChips(List<Scholarship> schemes, Scholarship current, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: schemes.map((s) {
          final isSelected = s.id == current.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(s.type.shortCode),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.primary),
              ),
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              checkmarkColor: Colors.white,
              onSelected: (_) => _onSchemeIdSelected(s.id),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── UI Components ─────────────────────────────────────────────────────────

  Widget _buildSchemeSelector(
    List<Scholarship> schemes,
    Scholarship current,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select Scholarship Scheme',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${schemes.length} Available',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: current.id,
                  isExpanded: true,
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  onChanged: (newSchemeId) {
                    if (newSchemeId != null) _onSchemeIdSelected(newSchemeId);
                  },
                  items: schemes.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.id,
                      child: Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              current.description,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDataCard(
    Student? student,
    EligibilityResult result,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Input Profile Data (Auto-filled)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (student?.isDigiLockerLinked == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'DigiLocker Linked',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (student == null) ...[
              const Text(
                'No user profile data found. Please log in to check eligibility against your registered details.',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ] else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDataChip('Student', student.fullName, isDark, colorScheme),
                  _buildDataChip('Category', student.category ?? 'ST', isDark, colorScheme),
                  if (student.tribeName != null)
                    _buildDataChip('Tribe', student.tribeName!, isDark, colorScheme),
                  if (student.state != null)
                    _buildDataChip('State', student.state!, isDark, colorScheme),
                  if (student.currentCourse != null)
                    _buildDataChip('Course', student.currentCourse!, isDark, colorScheme),
                  if (student.institutionName != null)
                    _buildDataChip('Institute', student.institutionName!, isDark, colorScheme),
                  _buildDataChip(
                    'Annual Family Income',
                    (_tempIncomeOverride ?? student.annualFamilyIncome) != null
                        ? '₹${(_tempIncomeOverride ?? student.annualFamilyIncome)!.toInt()}'
                        : 'Missing from profile',
                    isDark,
                    colorScheme,
                    isWarning: (_tempIncomeOverride ?? student.annualFamilyIncome) == null,
                  ),
                  _buildDataChip(
                    'Aadhaar / Bank DBT',
                    (student.aadhaarNumber != null && student.bankAccountNumber != null)
                        ? 'Seeded & Active'
                        : 'Action required',
                    isDark,
                    colorScheme,
                    isWarning: student.aadhaarNumber == null || student.bankAccountNumber == null,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataChip(
    String label,
    String value,
    bool isDark,
    ColorScheme colorScheme, {
    bool isWarning = false,
  }) {
    final bgColor = isWarning
        ? AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1)
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.surface);
    final borderColor = isWarning
        ? AppColors.warning.withValues(alpha: 0.6)
        : (isDark ? AppColors.darkBorder : AppColors.border);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isWarning ? AppColors.warning : colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isWarning ? AppColors.warning : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBanner(EligibilityResult result, bool isDark, ColorScheme colorScheme) {
    Color bannerColor;
    Color textColor;
    IconData icon;
    String statusTitle;

    switch (result.status) {
      case EligibilityStatus.eligible:
        bannerColor = AppColors.success.withValues(alpha: isDark ? 0.2 : 0.12);
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        statusTitle = 'Eligible';
        break;
      case EligibilityStatus.notEligible:
        bannerColor = AppColors.error.withValues(alpha: isDark ? 0.2 : 0.12);
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
        statusTitle = 'Not Eligible';
        break;
      case EligibilityStatus.indeterminate:
        bannerColor = AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.12);
        textColor = AppColors.warning;
        icon = Icons.help_outline_rounded;
        statusTitle = 'Unable to Determine / Missing Information';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: textColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eligibility Result',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.summaryMessage ?? '',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingInfoPrompt(
    EligibilityResult result,
    Student? student,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final needsIncome = result.missingFields.any((f) => f.toLowerCase().contains('income'));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.warning, width: 1.2),
      ),
      color: AppColors.warning.withValues(alpha: isDark ? 0.15 : 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.warning, size: 22),
                SizedBox(width: 8),
                Text(
                  'Missing Information Required',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Instead of guessing, the app asks only for what is missing to evaluate this scheme accurately.',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            ...result.missingFields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                    Expanded(
                      child: Text(
                        field,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (needsIncome) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _missingIncomeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Enter Annual Family Income (₹)',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        hintText: 'e.g. 180000',
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(color: colorScheme.onSurface),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isRecalculating ? null : () => _applyIncomeInput(student),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isRecalculating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Recalculate', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaBreakdownCard(
    EligibilityResult result,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rule_folder_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Why: Criteria Breakdown',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...result.criteria.map((c) => _buildCriterionRow(c, isDark, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionRow(
    EligibilityCriterion criterion,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    Widget icon;
    Color statusBgColor;

    switch (criterion.status) {
      case CriterionStatus.satisfied:
        icon = const Text('✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 16));
        statusBgColor = AppColors.success.withValues(alpha: isDark ? 0.2 : 0.12);
        break;
      case CriterionStatus.notSatisfied:
        icon = const Text('✕', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 16));
        statusBgColor = AppColors.error.withValues(alpha: isDark ? 0.2 : 0.12);
        break;
      case CriterionStatus.indeterminate:
        icon = const Text('?', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w900, fontSize: 16));
        statusBgColor = AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.12);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  criterion.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                if (criterion.reason != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      criterion.reason!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: criterion.status == CriterionStatus.notSatisfied
                            ? AppColors.error
                            : criterion.status == CriterionStatus.indeterminate
                                ? AppColors.warning
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Text(
                  criterion.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocumentsCard(Scholarship scheme, bool isDark, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (scheme.requiredDocuments.isEmpty)
              Text(
                'No document requirements recorded for this scheme.',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              )
            else
              ...scheme.requiredDocuments.map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.attach_file, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          doc,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerBox(String? disclaimer, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_outlined, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              disclaimer ?? ScholarshipEligibilityService.preliminaryDisclaimer,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EligibilityResult result, Scholarship current, List<Scholarship> schemes) {
    return Column(
      children: [
        if (result.status == EligibilityStatus.eligible) ...[
          AppButton(
            label: 'Apply for ${current.name}',
            onPressed: () {
              context.push('/scholarships/${current.id}');
            },
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Check Another Scheme',
                variant: AppButtonVariant.outline,
                onPressed: () => _showSchemePickerBottomSheet(context, schemes, current),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Ask JAGO',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  JagoContextService().setScreenContext(
                    JagoScreenContext(
                      sourceScreen: 'eligibility',
                      sourceLabel: 'Eligibility Check',
                      scholarship: current,
                    ),
                  );
                  context.push(RouteNames.jago);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── TAB 2: All Schemes Overview ───────────────────────────────────────────

  Widget _buildAllSchemesTab(
    List<Scholarship> schemes,
    Student? student,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final allResults = ScholarshipEligibilityService.evaluateAll(
      schemes: schemes,
      student: student,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Intro banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your profile was automatically evaluated across all official MoTA scholarship schemes.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // List of all 5 scheme evaluation cards
        ...schemes.map((scheme) {
          final res = allResults[scheme.id] ??
              ScholarshipEligibilityService.evaluate(
                scholarship: scheme,
                student: student,
              );

          Color statusColor;
          String statusBadgeText;
          IconData statusIcon;

          switch (res.status) {
            case EligibilityStatus.eligible:
              statusColor = AppColors.success;
              statusBadgeText = 'Eligible';
              statusIcon = Icons.check_circle;
              break;
            case EligibilityStatus.notEligible:
              statusColor = AppColors.error;
              statusBadgeText = 'Not Eligible';
              statusIcon = Icons.cancel;
              break;
            case EligibilityStatus.indeterminate:
              statusColor = AppColors.warning;
              statusBadgeText = 'Missing Info';
              statusIcon = Icons.help_outline;
              break;
          }

          final satisfiedCriteria = res.criteria.where((c) => c.status == CriterionStatus.satisfied).length;
          final totalCriteria = res.criteria.length;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: isDark ? AppColors.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: res.status == EligibilityStatus.eligible
                    ? AppColors.success.withValues(alpha: 0.5)
                    : (isDark ? AppColors.darkBorder : AppColors.border),
                width: res.status == EligibilityStatus.eligible ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scheme.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Up to ₹${(scheme.maxAmount ?? 0).toInt()}/yr • ${scheme.duration ?? ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusBadgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    res.summaryMessage ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Progress indicator of satisfied conditions
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalCriteria > 0 ? satisfiedCriteria / totalCriteria : 0,
                            backgroundColor: isDark ? AppColors.darkBorder : AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$satisfiedCriteria / $totalCriteria Met',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Ask JAGO', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          JagoContextService().setScreenContext(
                            JagoScreenContext(
                              sourceScreen: 'eligibility',
                              sourceLabel: 'Eligibility Check',
                              scholarship: scheme,
                            ),
                          );
                          context.push(RouteNames.jago);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward, size: 14),
                        label: const Text('Inspect Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          _onSchemeIdSelected(scheme.id);
                          _effectiveTabController.animateTo(0);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showSchemePickerBottomSheet(BuildContext context, List<Scholarship> schemes, Scholarship current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Select Another Scholarship Scheme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Divider(color: isDark ? AppColors.darkBorder : AppColors.divider),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: schemes.length,
                  itemBuilder: (ctx, index) {
                    final s = schemes[index];
                    final isCurrent = s.id == current.id;
                    return ListTile(
                      leading: Icon(
                        isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isCurrent ? AppColors.primary : colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        s.name,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.primary : colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        s.duration ?? '',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _onSchemeIdSelected(s.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreliminaryDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Official Verification Notice'),
        content: const Text(
          'This tool performs an automated preliminary check against registered profile details and official guidelines.\n\n'
          'Final eligibility is officially determined by the Ministry of Tribal Affairs and state verifying authorities upon submission of your full application and original documents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
