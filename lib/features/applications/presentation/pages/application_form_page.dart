import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/step_progress_bar.dart';

/// Multi-step scholarship application form for MoTA schemes.
class ApplicationFormPage extends StatefulWidget {
  final Scholarship? initialScholarship;

  const ApplicationFormPage({super.key, this.initialScholarship});

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  int _currentStep = 0;
  static const int _totalSteps = 5;

  static const List<String> _stepLabels = [
    'Scheme',
    'Tribal',
    'Academic',
    'Bank & Docs',
    'Review',
  ];

  // Form state
  late ScholarshipType _selectedType;
  late String _schemeName;
  late String _schemeId;
  double? _requestedAmount;

  // Controllers - Step 1: Scheme & Personal
  final _nameController = TextEditingController(text: 'Rajesh Soren');
  final _dobController = TextEditingController(text: '14/08/2004');
  String _gender = 'Male';
  final _aadhaarController = TextEditingController(text: 'XXXX-XXXX-4892');
  final _mobileController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController(text: 'rajesh.soren@nitrkl.ac.in');

  // Controllers - Step 2: Tribal & Domicile
  String _state = 'Odisha';
  String _district = 'Mayurbhanj';
  final _tribeController = TextEditingController(text: 'Santhal');
  final _stCertController = TextEditingController(text: 'ST/OD/2023/88921');
  bool _isPVTG = false;

  // Controllers - Step 3: Academic Details
  final _instituteController = TextEditingController(text: 'NIT Rourkela');
  final _courseController = TextEditingController(text: 'B.Tech (Computer Science)');
  final _yearController = TextEditingController(text: 'Year 2');
  final _marksController = TextEditingController(text: '84.5%');
  String _academicYear = '2025-26';

  // Controllers - Step 4: Bank & Documents
  final _bankNameController = TextEditingController(text: 'State Bank of India');
  final _accountNoController = TextEditingController(text: '987654321012');
  final _ifscController = TextEditingController(text: 'SBIN0001234');

  // Document checklist
  bool _docAadhaar = true;
  bool _docSTCert = true;
  bool _docIncome = true;
  bool _docMarksheet = true;
  bool _docBonafide = true;

  // Step 5: Review declaration
  bool _declarationChecked = false;

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initialScholarship;
    _selectedType = init?.type ?? ScholarshipType.postMatric;
    _schemeName = init?.name ?? 'Post-Matric Scholarship for ST Students';
    _schemeId = init?.id ?? 'sch-post-matric';
    _requestedAmount = init?.maxAmount ?? 70000;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_prefilled) {
      AuthProvider? authProvider;
      try {
        authProvider = Provider.of<AuthProvider>(context, listen: false);
      } catch (_) {}
      final user = authProvider?.currentUser;
      if (user != null) {
        if (user.fullName.isNotEmpty) _nameController.text = user.fullName;
        if (user.mobileNumber != null && user.mobileNumber!.isNotEmpty) {
          _mobileController.text = '+91 ${user.mobileNumber}';
        }
        if (user.email != null && user.email!.isNotEmpty) {
          _emailController.text = user.email!;
        }
        if (user.aadhaarNumber != null && user.aadhaarNumber!.isNotEmpty) {
          _aadhaarController.text = user.aadhaarNumber!;
        }
        if (user.tribeName != null && user.tribeName!.isNotEmpty) {
          _tribeController.text = user.tribeName!;
        }
        if (user.stCertificateNumber != null && user.stCertificateNumber!.isNotEmpty) {
          _stCertController.text = user.stCertificateNumber!;
        }
        if (user.state != null && user.state!.isNotEmpty) _state = user.state!;
        if (user.district != null && user.district!.isNotEmpty) _district = user.district!;
        if (user.institutionName != null && user.institutionName!.isNotEmpty) {
          _instituteController.text = user.institutionName!;
        }
        if (user.currentCourse != null && user.currentCourse!.isNotEmpty) {
          _courseController.text = user.currentCourse!;
        }
        if (user.currentYear != null && user.currentYear!.isNotEmpty) {
          _yearController.text = user.currentYear!;
        }
        if (user.bankName != null && user.bankName!.isNotEmpty) {
          _bankNameController.text = user.bankName!;
        }
        if (user.bankAccountNumber != null && user.bankAccountNumber!.isNotEmpty) {
          _accountNoController.text = user.bankAccountNumber!;
        }
        if (user.ifscCode != null && user.ifscCode!.isNotEmpty) {
          _ifscController.text = user.ifscCode!;
        }
        _isPVTG = user.isPVTG;
      }
      _prefilled = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _aadhaarController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _tribeController.dispose();
    _stCertController.dispose();
    _instituteController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _marksController.dispose();
    _bankNameController.dispose();
    _accountNoController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.scholarshipDashboard),
        title: const Text('Scholarship Application'),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: StepProgressBar(
              totalSteps: _totalSteps,
              currentStep: _currentStep,
              stepLabels: _stepLabels,
            ),
          ),
          const Divider(height: 1),

          // Step Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(),
            ),
          ),

          // Bottom Navigation Buttons
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1SchemeAndPersonal();
      case 1:
        return _buildStep2TribalAndDomicile();
      case 2:
        return _buildStep3AcademicDetails();
      case 3:
        return _buildStep4BankAndDocuments();
      case 4:
        return _buildStep5ReviewAndSubmit();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Scheme & Personal Info ─────────────────────────────────
  Widget _buildStep1SchemeAndPersonal() {
    final schemes = context.read<ScholarshipDataService>().schemes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Scholarship Scheme', 'Choose the MoTA scheme you wish to apply for.'),
        const SizedBox(height: 12),
        DropdownButtonFormField<ScholarshipType>(
          value: _selectedType,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'MoTA Scheme *',
            prefixIcon: Icon(Icons.school_outlined),
          ),
          items: ScholarshipType.values.map((type) {
            final scheme = schemes.firstWhere(
              (s) => s.type == type,
              orElse: () => schemes.first,
            );
            return DropdownMenuItem(
              value: type,
              child: Text(
                scheme.name,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedType = val;
                final scheme = schemes.firstWhere((s) => s.type == val);
                _schemeName = scheme.name;
                _schemeId = scheme.id;
                _requestedAmount = scheme.maxAmount;
              });
            }
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Personal Information', 'Details verified from Aadhaar & DigiLocker.'),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Full Name (as per Aadhaar) *',
          controller: _nameController,
          prefixIcon: const Icon(Icons.person_outline),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Date of Birth *',
                controller: _dobController,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v ?? _gender),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Aadhaar Number * (UIDAI Verified)',
          controller: _aadhaarController,
          prefixIcon: const Icon(Icons.fingerprint),
          readOnly: true,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Mobile Number *',
          controller: _mobileController,
          prefixIcon: const Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Email Address',
          controller: _emailController,
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // ── Step 2: Tribal & Domicile ──────────────────────────────────────
  Widget _buildStep2TribalAndDomicile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tribal Identity & Domicile', 'Official tribal community verification.'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _state,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'State *'),
                items: ['Odisha', 'Jharkhand', 'Madhya Pradesh', 'Chhattisgarh', 'Rajasthan', 'Gujarat']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _state = v ?? _state),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _district,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'District *'),
                items: ['Mayurbhanj', 'Sundargarh', 'Koraput', 'Rayagada', 'Ranchi', 'Bastar']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _district = v ?? _district),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Notified Scheduled Tribe (ST) Name *',
          controller: _tribeController,
          prefixIcon: const Icon(Icons.people_outline),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'ST Certificate Number *',
          controller: _stCertController,
          prefixIcon: const Icon(Icons.badge_outlined),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: CheckboxListTile(
            value: _isPVTG,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: const Text(
              'Particularly Vulnerable Tribal Group (PVTG)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Check if you belong to any 75 notified PVTG communities for priority assistance.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            onChanged: (val) => setState(() => _isPVTG = val ?? false),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Academic Details ───────────────────────────────────────
  Widget _buildStep3AcademicDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Academic & Institution Details', 'Current course and institution credentials.'),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Name of Institution *',
          controller: _instituteController,
          prefixIcon: const Icon(Icons.account_balance_outlined),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Course / Degree *',
          controller: _courseController,
          prefixIcon: const Icon(Icons.school_outlined),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Current Year / Sem *',
                controller: _yearController,
                prefixIcon: const Icon(Icons.calendar_view_day_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Previous Marks % *',
                controller: _marksController,
                prefixIcon: const Icon(Icons.grade_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _academicYear,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Academic Year *'),
          items: ['2025-26', '2024-25']
              .map((y) => DropdownMenuItem(value: y, child: Text(y)))
              .toList(),
          onChanged: (v) => setState(() => _academicYear = v ?? _academicYear),
        ),
      ],
    );
  }

  // ── Step 4: Bank & Documents ───────────────────────────────────────
  Widget _buildStep4BankAndDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Aadhaar-Seeded Bank Account', 'DBT funds are disbursed directly to this account.'),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Bank Name *',
          controller: _bankNameController,
          prefixIcon: const Icon(Icons.account_balance),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Account Number *',
          controller: _accountNoController,
          prefixIcon: const Icon(Icons.credit_card),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'IFSC Code *',
          controller: _ifscController,
          prefixIcon: const Icon(Icons.tag),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aadhaar-DBT mapping active via NPCI mapper',
                  style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Reusable Verified Documents (Part 9)
        Builder(
          builder: (context) {
            final reusable = context.watch<ScholarshipDataService>().reusableDocuments;
            if (reusable.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.recycling, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Use Existing Verified Documents',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E8449), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${reusable.length} verified document(s) found in your wallet. They will be automatically linked:',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      ...reusable.map((d) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                                const SizedBox(width: 6),
                                Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                const SizedBox(width: 6),
                                const Text('(Verified)', style: TextStyle(color: AppColors.success, fontSize: 11)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),

        _buildSectionTitle('Document Checklist', 'Tick verified documents ready for submission.'),
        const SizedBox(height: 8),
        _buildDocCheckItem('Aadhaar Card (UIDAI verified)', _docAadhaar, (v) => setState(() => _docAadhaar = v)),
        _buildDocCheckItem('ST/Caste Certificate (e-District)', _docSTCert, (v) => setState(() => _docSTCert = v)),
        _buildDocCheckItem('Income Certificate (< ₹2.50 Lakh)', _docIncome, (v) => setState(() => _docIncome = v)),
        _buildDocCheckItem('Previous Year Marksheet', _docMarksheet, (v) => setState(() => _docMarksheet = v)),
        _buildDocCheckItem('Institution Bonafide / Enrollment', _docBonafide, (v) => setState(() => _docBonafide = v)),
      ],
    );
  }

  // ── Step 5: Review & Submit ────────────────────────────────────────
  Widget _buildStep5ReviewAndSubmit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Application Summary', 'Please review your details before final submission.'),
        const SizedBox(height: 16),
        _buildReviewCard('Selected Scheme', [
          _buildReviewRow('Scheme', _schemeName),
          _buildReviewRow('Academic Year', _academicYear),
          _buildReviewRow('Requested Amount', '₹${_requestedAmount?.toInt() ?? 70000}'),
        ]),
        const SizedBox(height: 12),
        _buildReviewCard('Personal & Tribal', [
          _buildReviewRow('Student Name', _nameController.text),
          _buildReviewRow('DOB & Gender', '${_dobController.text} • $_gender'),
          _buildReviewRow('Tribe & District', '${_tribeController.text} • $_district, $_state'),
          _buildReviewRow('ST Certificate No', _stCertController.text),
          _buildReviewRow('PVTG Status', _isPVTG ? 'Yes' : 'No'),
        ]),
        const SizedBox(height: 12),
        _buildReviewCard('Academic Details', [
          _buildReviewRow('Institution', _instituteController.text),
          _buildReviewRow('Course & Year', '${_courseController.text} • ${_yearController.text}'),
          _buildReviewRow('Marks', _marksController.text),
        ]),
        const SizedBox(height: 12),
        _buildReviewCard('Bank Account (DBT)', [
          _buildReviewRow('Bank', _bankNameController.text),
          _buildReviewRow('Account No', _accountNoController.text),
          _buildReviewRow('IFSC', _ifscController.text),
        ]),
        const SizedBox(height: 20),
        Card(
          margin: EdgeInsets.zero,
          child: CheckboxListTile(
            value: _declarationChecked,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: const Text(
              'Declaration of Authenticity *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: const Text(
              'I hereby declare that all the information provided above is true and correct to the best of my knowledge. Any false statement will result in cancellation.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            onChanged: (val) => setState(() => _declarationChecked = val ?? false),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildDocCheckItem(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      value: value,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      secondary: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
      onChanged: (v) => onChanged(v ?? false),
    );
  }

  Widget _buildReviewCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          const Divider(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: isLastStep ? (_declarationChecked ? _submitApplication : null) : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(isLastStep ? 'Submit Application' : 'Next Step'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _saveDraft() {
    context.read<ScholarshipDataService>().saveDraft(
      scholarshipId: _schemeId,
      scholarshipName: _schemeName,
      scholarshipType: _selectedType,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Draft saved for $_schemeName'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.push(RouteNames.applicationsList),
        ),
      ),
    );
  }

  void _submitApplication() {
    final service = context.read<ScholarshipDataService>();
    final reusableIds = service.reusableDocuments.map((d) => d.id).toList();

    service.submitApplication(
      scholarshipId: _schemeId,
      scholarshipName: _schemeName,
      scholarshipType: _selectedType,
      academicYear: _academicYear,
      requestedAmount: _requestedAmount,
      remarks: 'Certified submission with linked documents.',
      reusedDocumentIds: reusableIds,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.successLight,
              child: Icon(Icons.check, color: AppColors.success),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text('Application Submitted!', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your application for $_schemeName has been submitted to the Ministry of Tribal Affairs.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedType.shortCode}-${DateTime.now().year}-00004',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Keep this number for tracking and verification purposes.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(RouteNames.scholarshipDashboard);
            },
            child: const Text('Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pushReplacement(RouteNames.applicationTracking);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Track Application'),
          ),
        ],
      ),
    );
  }
}
