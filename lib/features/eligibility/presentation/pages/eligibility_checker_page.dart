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

class _EligibilityCheckerPageState extends State<EligibilityCheckerPage> {
  Scholarship? _selectedScheme;
  double? _tempIncomeOverride;
  final TextEditingController _missingIncomeController = TextEditingController();
  bool _isRecalculating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelection();
    });
  }

  @override
  void dispose() {
    _missingIncomeController.dispose();
    super.dispose();
  }

  void _initializeSelection() {
    final scholarshipService = Provider.of<ScholarshipDataService>(context, listen: false);
    final schemes = scholarshipService.schemes.isNotEmpty
        ? scholarshipService.schemes
        : ScholarshipMockData.schemes;

    if (schemes.isEmpty) return;

    if (widget.initialSchemeId != null) {
      _selectedScheme = schemes.firstWhere(
        (s) => s.id == widget.initialSchemeId,
        orElse: () => schemes.first,
      );
    } else {
      // Default to Post-Matric or first available scheme
      _selectedScheme = schemes.firstWhere(
        (s) => s.type == ScholarshipType.postMatric,
        orElse: () => schemes.first,
      );
    }
    setState(() {});
  }

  void _onSchemeSelected(Scholarship scheme) {
    setState(() {
      _selectedScheme = scheme;
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
    final student = authProvider.currentUser;

    final scholarshipService = Provider.of<ScholarshipDataService>(context);
    final schemes = scholarshipService.schemes.isNotEmpty
        ? scholarshipService.schemes
        : ScholarshipMockData.schemes;

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
                const Text(
                  'Unable to load scholarship scheme guidelines. Please check your connection and retry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
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

    final activeScheme = _selectedScheme ?? schemes.first;

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Step 1: Scheme Selector Section ─────────────────────────────
            _buildSchemeSelector(schemes, activeScheme),
            const SizedBox(height: 16),

            // ── Step 2: Auto-filled Profile Summary ─────────────────────────
            _buildProfileDataCard(student, result),
            const SizedBox(height: 16),

            // ── Step 3: Clear Eligibility Result Banner ─────────────────────
            _buildResultBanner(result),
            const SizedBox(height: 16),

            // ── Step 4: Missing Information Prompt (if applicable) ─────────
            if (result.hasMissingInformation) ...[
              _buildMissingInfoPrompt(result, student),
              const SizedBox(height: 16),
            ],

            // ── Step 5: "Why" Detailed Breakdown (✓, ✕, ?) ───────────────────
            _buildCriteriaBreakdownCard(result),
            const SizedBox(height: 16),

            // ── Step 6: Required Documents Section ──────────────────────────
            _buildRequiredDocumentsCard(activeScheme),
            const SizedBox(height: 16),

            // ── Step 7: Official Non-Binding Disclaimer ──────────────────────
            _buildDisclaimerBox(result.disclaimer),
            const SizedBox(height: 24),

            // ── Step 8: Action Buttons ──────────────────────────────────────
            _buildActionButtons(result, activeScheme, schemes),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── UI Components ─────────────────────────────────────────────────────────

  Widget _buildSchemeSelector(List<Scholarship> schemes, Scholarship current) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
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
                const Expanded(
                  child: Text(
                    'Select Scholarship Scheme',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${schemes.length} Available',
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Scholarship>(
                  value: current,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  onChanged: (newScheme) {
                    if (newScheme != null) _onSchemeSelected(newScheme);
                  },
                  items: schemes.map((s) {
                    return DropdownMenuItem<Scholarship>(
                      value: s,
                      child: Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDataCard(Student? student, EligibilityResult result) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Input Profile Data (Auto-filled)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (student?.isDigiLockerLinked == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'DigiLocker Linked',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
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
                  _buildDataChip('Student', student.fullName),
                  _buildDataChip('Category', student.category ?? 'ST'),
                  if (student.tribeName != null) _buildDataChip('Tribe', student.tribeName!),
                  if (student.state != null) _buildDataChip('State', student.state!),
                  if (student.currentCourse != null) _buildDataChip('Course', student.currentCourse!),
                  if (student.institutionName != null) _buildDataChip('Institute', student.institutionName!),
                  _buildDataChip(
                    'Annual Family Income',
                    (_tempIncomeOverride ?? student.annualFamilyIncome) != null
                        ? '₹${(_tempIncomeOverride ?? student.annualFamilyIncome)!.toInt()}'
                        : 'Missing from profile',
                    isWarning: (_tempIncomeOverride ?? student.annualFamilyIncome) == null,
                  ),
                  _buildDataChip(
                    'Aadhaar / Bank DBT',
                    (student.aadhaarNumber != null && student.bankAccountNumber != null)
                        ? 'Seeded & Active'
                        : 'Action required',
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

  Widget _buildDataChip(String label, String value, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.warning.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning ? AppColors.warning.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isWarning ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isWarning ? AppColors.warning : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBanner(EligibilityResult result) {
    Color bannerColor;
    Color textColor;
    IconData icon;
    String statusTitle;

    switch (result.status) {
      case EligibilityStatus.eligible:
        bannerColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        statusTitle = 'Eligible';
        break;
      case EligibilityStatus.notEligible:
        bannerColor = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
        statusTitle = 'Not Eligible';
        break;
      case EligibilityStatus.indeterminate:
        bannerColor = AppColors.warning.withValues(alpha: 0.12);
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
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5),
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
                        fontSize: 20,
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingInfoPrompt(EligibilityResult result, Student? student) {
    final needsIncome = result.missingFields.any((f) => f.toLowerCase().contains('income'));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.warning, width: 1.2),
      ),
      color: AppColors.warning.withValues(alpha: 0.05),
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
            const Text(
              'Instead of guessing, the app asks only for what is missing to evaluate this scheme accurately.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
                      decoration: const InputDecoration(
                        labelText: 'Enter Annual Family Income (₹)',
                        hintText: 'e.g. 180000',
                        prefixText: '₹ ',
                        isDense: true,
                        border: OutlineInputBorder(),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildCriteriaBreakdownCard(EligibilityResult result) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rule_folder_outlined, size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Why: Criteria Breakdown',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...result.criteria.map((c) => _buildCriterionRow(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionRow(EligibilityCriterion criterion) {
    Widget icon;
    Color statusBgColor;

    switch (criterion.status) {
      case CriterionStatus.satisfied:
        icon = const Text('✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 16));
        statusBgColor = AppColors.success.withValues(alpha: 0.1);
        break;
      case CriterionStatus.notSatisfied:
        icon = const Text('✕', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 16));
        statusBgColor = AppColors.error.withValues(alpha: 0.1);
        break;
      case CriterionStatus.indeterminate:
        icon = const Text('?', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w900, fontSize: 16));
        statusBgColor = AppColors.warning.withValues(alpha: 0.1);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (criterion.reason != null)
                  Text(
                    criterion.reason!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: criterion.status == CriterionStatus.notSatisfied
                          ? AppColors.error
                          : criterion.status == CriterionStatus.indeterminate
                              ? AppColors.warning
                              : AppColors.textSecondary,
                    ),
                  ),
                Text(
                  criterion.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocumentsCard(Scholarship scheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Required Documents',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (scheme.requiredDocuments.isEmpty)
              const Text('No document requirements recorded for this scheme.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
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
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

  Widget _buildDisclaimerBox(String? disclaimer) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.privacy_tip_outlined, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              disclaimer ?? ScholarshipEligibilityService.preliminaryDisclaimer,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
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
                onPressed: () => _showSchemePickerBottomSheet(context, schemes),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Ask JAGO',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  context.go(RouteNames.jago);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSchemePickerBottomSheet(BuildContext context, List<Scholarship> schemes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Select Another Scholarship Scheme',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: schemes.length,
                  itemBuilder: (ctx, index) {
                    final s = schemes[index];
                    final isCurrent = s.id == _selectedScheme?.id;
                    return ListTile(
                      leading: Icon(
                        isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isCurrent ? AppColors.primary : AppColors.textTertiary,
                      ),
                      title: Text(
                        s.name,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        s.duration ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _onSchemeSelected(s);
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
