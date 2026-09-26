import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/india_location_data.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import '../../../documents/presentation/pages/digilocker_consent_page.dart';
import '../../../../shared/widgets/digilocker_preview_sheet.dart';
import '../../../../core/localization/app_localizations_extension.dart';

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

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    _totalSteps,
    (_) => GlobalKey<FormState>(),
  );

  List<String> get _stepLabels => [
    context.l10n.stepPersonal,
    context.l10n.stepAddress,
    context.l10n.stepAcademic,
    context.l10n.stepBankDocs,
    context.l10n.stepReview,
  ];

  // Form state
  ScholarshipType _selectedType = ScholarshipType.postMatric;
  String _schemeName = 'Post-Matric Scholarship for ST Students';
  String _schemeId = 'sch-post-matric';
  double? _requestedAmount = 70000;

  // Controllers - Step 1: Scheme & Personal
  final _nameController = TextEditingController(text: 'Rajesh Soren');
  final _dobController = TextEditingController(text: '14/08/2004');
  String _gender = 'Male';
  final _aadhaarController = TextEditingController(text: 'XXXX-XXXX-4892');
  final _mobileController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController(text: 'rajesh.soren@nitrkl.ac.in');

  // Controllers - Step 2: Tribal & Domicile
  String? _state = 'Odisha';
  String? _district = 'Mayurbhanj';
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

  // DigiLocker demo link state
  bool _digiLockerLinked = false;

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initialScholarship;
    if (init != null) {
      _selectedType = init.type;
      _schemeName = init.name;
      _schemeId = init.id;
      _requestedAmount = init.maxAmount;
    }
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
        if (user.state != null &&
            user.state!.isNotEmpty &&
            IndiaLocationData.states.contains(user.state)) {
          _state = user.state!;
          final validDistricts = IndiaLocationData.getDistricts(_state!);
          if (user.district != null && validDistricts.contains(user.district)) {
            _district = user.district!;
          } else {
            _district = null;
          }
        }
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
        if (user.dateOfBirth != null) {
          final dob = user.dateOfBirth!;
          _dobController.text = '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}';
        }
        if (user.gender != null && user.gender!.isNotEmpty) {
          _gender = user.gender!;
        }
        if (user.isDigiLockerLinked) {
          _digiLockerLinked = true;
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.scholarshipDashboard),
        title: Text(l10n.applicationFormTitle),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.saveDraft),
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
              key: ValueKey('step_scroll_view_$_currentStep'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionButtons(),
    );
  }

  Widget _buildCurrentStep() {
    try {
      Widget stepWidget;
      switch (_currentStep) {
        case 0:
          stepWidget = _buildStep1SchemeAndPersonal();
          break;
        case 1:
          stepWidget = _buildStep2TribalAndDomicile();
          break;
        case 2:
          stepWidget = _buildStep3AcademicDetails();
          break;
        case 3:
          stepWidget = _buildStep4BankAndDocuments();
          break;
        case 4:
          stepWidget = _buildStep5ReviewAndSubmit();
          break;
        default:
          stepWidget = _buildStep5ReviewAndSubmit();
      }

      if (_currentStep == 4) {
        return stepWidget;
      }

      return Form(
        key: _formKeys[_currentStep],
        child: stepWidget,
      );
    } catch (e, stack) {
      debugPrint('Error building step $_currentStep: $e\n$stack');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 36),
            const SizedBox(height: 12),
            const Text(
              'Application Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please review your details and confirm submission.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Refresh Details'),
            ),
          ],
        ),
      );
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
          initialValue: _selectedType,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'MoTA Scheme *',
            prefixIcon: Icon(Icons.school_outlined),
          ),
          validator: (val) => val == null ? 'Please select a scheme' : null,
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
          validator: (v) => AppValidators.required(v, 'Full Name'),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'Date of Birth *',
                controller: _dobController,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                validator: (v) => AppValidators.required(v, 'Date of Birth'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gender *',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.wc_outlined),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Select gender' : null,
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v ?? _gender),
                  ),
                ],
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
          validator: (v) => AppValidators.required(v, 'Aadhaar Number'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Mobile Number *',
          controller: _mobileController,
          prefixIcon: const Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Mobile number is required';
            final digits = v.replaceAll(RegExp(r'\D'), '');
            if (digits.length < 10) return 'Enter a valid 10-digit mobile number';
            return null;
          },
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Email Address',
          controller: _emailController,
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v != null && v.trim().isNotEmpty) {
              return AppValidators.email(v);
            }
            return null;
          },
        ),
      ],
    );
  }

  // ── Step 2: Tribal & Domicile ──────────────────────────────────────
  Widget _buildStep2TribalAndDomicile() {
    final districts = _state != null ? IndiaLocationData.getDistricts(_state!) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tribal Identity & Domicile', 'Official tribal community verification.'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'State *',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _state,
                    isExpanded: true,
                    items: IndiaLocationData.states
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    validator: (v) => (v == null || v.isEmpty) ? 'Select state' : null,
                    onChanged: (v) {
                      setState(() {
                        _state = v;
                        _district = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'District *',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey('district_dropdown_$_state'),
                    initialValue: (_district != null && districts.contains(_district)) ? _district : null,
                    isExpanded: true,
                    hint: Text(
                      _state == null ? 'Select state first' : 'Select district',
                      style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    ),
                    items: districts
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    validator: (v) => (v == null || v.isEmpty) ? 'Select district' : null,
                    onChanged: _state == null
                        ? null
                        : (v) => setState(() => _district = v),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Notified Scheduled Tribe (ST) Name *',
          controller: _tribeController,
          prefixIcon: const Icon(Icons.people_outline),
          validator: (v) => AppValidators.required(v, 'Tribe Name'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'ST Certificate Number *',
          controller: _stCertController,
          prefixIcon: const Icon(Icons.badge_outlined),
          validator: (v) => AppValidators.required(v, 'ST Certificate Number'),
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
          validator: (v) => AppValidators.required(v, 'Institution Name'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Course / Degree *',
          controller: _courseController,
          prefixIcon: const Icon(Icons.school_outlined),
          validator: (v) => AppValidators.required(v, 'Course / Degree'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Current Year / Sem *',
                controller: _yearController,
                prefixIcon: const Icon(Icons.calendar_view_day_outlined),
                validator: (v) => AppValidators.required(v, 'Current Year'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Previous Marks % *',
                controller: _marksController,
                prefixIcon: const Icon(Icons.grade_outlined),
                validator: (v) => AppValidators.required(v, 'Previous Marks'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Academic Year *',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _academicYear,
              isExpanded: true,
              items: ['2025-26', '2024-25']
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              validator: (v) => (v == null || v.isEmpty) ? 'Select academic year' : null,
              onChanged: (v) => setState(() => _academicYear = v ?? _academicYear),
            ),
          ],
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
          validator: (v) => AppValidators.required(v, 'Bank Name'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Account Number *',
          controller: _accountNoController,
          prefixIcon: const Icon(Icons.credit_card),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Account Number is required';
            if (v.trim().length < 8) return 'Enter a valid Account Number';
            return null;
          },
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'IFSC Code *',
          controller: _ifscController,
          prefixIcon: const Icon(Icons.tag),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'IFSC Code is required';
            if (v.trim().length < 4) return 'Enter a valid IFSC Code';
            return null;
          },
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

        // ── DigiLocker Document Linking (Demo) ────────────────
        _buildSectionTitle(
          'Link Documents via DigiLocker',
          'Attach government-issued documents from your DigiLocker — Demo',
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _digiLockerLinked
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: _buildDigiLockerLinkCard(),
          secondChild: _buildDigiLockerLinkedCard(),
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
                    color: AppColors.successLight.withValues(alpha: 0.3),
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
                          Expanded(
                            child: Text(
                              'Use Existing Verified Documents',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E8449), fontSize: 13),
                            ),
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
                                Expanded(
                                  child: Text(
                                    d.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
        _buildDocCheckItem('Aadhaar Card (UIDAI verified) *', _docAadhaar, (v) => setState(() => _docAadhaar = v)),
        _buildDocCheckItem('ST/Caste Certificate (e-District) *', _docSTCert, (v) => setState(() => _docSTCert = v)),
        _buildDocCheckItem('Income Certificate (< ₹2.50 Lakh)', _docIncome, (v) => setState(() => _docIncome = v)),
        _buildDocCheckItem('Previous Year Marksheet', _docMarksheet, (v) => setState(() => _docMarksheet = v)),
        _buildDocCheckItem('Institution Bonafide / Enrollment', _docBonafide, (v) => setState(() => _docBonafide = v)),
      ],
    );
  }

  Widget _buildDigiLockerLinkCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B57D0).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0B57D0).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B57D0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF0B57D0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DigiLocker Integration — Demo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0B57D0),
                      ),
                    ),
                    Text(
                      'Attach documents issued by Govt. of India',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Required for this scheme:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          _buildRequiredDocChip('Aadhaar Card', Icons.fingerprint),
          _buildRequiredDocChip('ST Community Certificate', Icons.badge_outlined),
          _buildRequiredDocChip('Income Certificate', Icons.receipt_long_outlined),
          _buildRequiredDocChip('Class 12 Marksheet', Icons.school_outlined),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const DigiLockerConsentPage(
                      autoImportToWallet: true,
                    ),
                  ),
                );
                if (result == true && mounted) {
                  setState(() {
                    _digiLockerLinked = true;
                    _docAadhaar = true;
                    _docSTCert = true;
                    _docMarksheet = true;
                    _docIncome = true;
                    _docBonafide = true;
                    if (_currentStep == 3) {
                      _currentStep = 4;
                    }
                  });
                }
              },
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text(
                'Link from DigiLocker (Demo)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B57D0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigiLockerLinkedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: AppColors.success, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DigiLocker Linked — Demo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.successDark,
                      ),
                    ),
                    Text(
                      'Documents from DigiLocker added to your wallet',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _digiLockerLinked = false),
                child: const Text('Change',
                    style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLinkedDocCard(
            name: 'Aadhaar Card',
            category: 'Identity Document',
            issuer: 'UIDAI',
            maskedId: 'XXXX XXXX 4401',
            icon: Icons.fingerprint,
            assetPath: 'assets/images/aadhaar_card.png',
          ),
          const SizedBox(height: 8),
          _buildLinkedDocCard(
            name: 'Caste Certificate (SEBC / ST)',
            category: 'Caste / Community',
            issuer: 'Govt. of Gujarat',
            maskedId: 'Certificate No. 809/XXXX',
            icon: Icons.badge_outlined,
            assetPath: 'assets/images/caste_certificate.jpg',
          ),
          const SizedBox(height: 8),
          _buildLinkedDocCard(
            name: 'Class 12 Marksheet',
            category: 'Academic Qualification',
            issuer: 'CBSE',
            maskedId: 'Roll No. 1163XXXX',
            icon: Icons.school_outlined,
            assetPath: 'assets/images/class12_marksheet.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedDocCard({
    required String name,
    required String category,
    required String issuer,
    required String maskedId,
    required IconData icon,
    required String assetPath,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.success),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified, size: 13, color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$issuer • $maskedId',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              showDigiLockerDocumentPreview(
                context,
                name: name,
                category: category,
                issuer: issuer,
                maskedNumber: maskedId,
                isVerified: true,
                assetImagePath: assetPath,
              );
            },
            icon: const Icon(Icons.visibility_outlined, size: 14, color: AppColors.primary),
            label: const Text(
              'View',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocChip(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0B57D0)),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
          _buildReviewRow('Scheme', _schemeName.isNotEmpty ? _schemeName : 'Post-Matric Scholarship for ST Students'),
          _buildReviewRow('Academic Year', _academicYear.isNotEmpty ? _academicYear : '2025-26'),
          _buildReviewRow('Requested Amount', '₹${(_requestedAmount ?? 70000).toInt()}'),
        ]),
        const SizedBox(height: 12),
        _buildReviewCard('Personal & Tribal', [
          _buildReviewRow('Student Name', _nameController.text.isNotEmpty ? _nameController.text : 'Rajesh Soren'),
          _buildReviewRow('DOB & Gender', '${_dobController.text.isNotEmpty ? _dobController.text : "14/08/2004"} • $_gender'),
          _buildReviewRow('Tribe & District', '${_tribeController.text.isNotEmpty ? _tribeController.text : "Santhal"} • ${_district ?? "Mayurbhanj"}, ${_state ?? "Odisha"}'),
          _buildReviewRow('ST Certificate No', _stCertController.text.isNotEmpty ? _stCertController.text : 'ST/OD/2023/88921'),
          _buildReviewRow('PVTG Status', _isPVTG ? 'Yes' : 'No'),
        ]),
        const SizedBox(height: 12),
        _buildReviewCard('Academic Details', [
          _buildReviewRow('Institution', _instituteController.text.isNotEmpty ? _instituteController.text : 'NIT Rourkela'),
          _buildReviewRow('Course & Year', '${_courseController.text.isNotEmpty ? _courseController.text : "B.Tech"} • ${_yearController.text.isNotEmpty ? _yearController.text : "Year 2"}'),
          _buildReviewRow('Marks', _marksController.text.isNotEmpty ? _marksController.text : '84.5%'),
        ]),
        const SizedBox(height: 12),
        _buildReviewCard('Bank Account (DBT)', [
          _buildReviewRow('Bank', _bankNameController.text.isNotEmpty ? _bankNameController.text : 'State Bank of India'),
          _buildReviewRow('Account No', _accountNoController.text.isNotEmpty ? _accountNoController.text : '987654321012'),
          _buildReviewRow('IFSC', _ifscController.text.isNotEmpty ? _ifscController.text : 'SBIN0001234'),
        ]),
        if (_digiLockerLinked) ...[
          const SizedBox(height: 12),
          _buildReviewCard('Attached Documents (DigiLocker Verified)', [
            _buildReviewRow('Aadhaar Card', 'Govt. Verified (UIDAI • XXXX XXXX 4401)'),
            _buildReviewRow('Caste Certificate', 'Govt. Verified (Govt. of Gujarat • 809/XXXX)'),
            _buildReviewRow('Class 12 Marksheet', 'Govt. Verified (CBSE • Roll 1163XXXX)'),
          ]),
        ],
        const SizedBox(height: 20),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
          child: CheckboxListTile(
            value: _declarationChecked,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            activeColor: AppColors.primary,
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
        const SizedBox(height: 32),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (_currentStep > 0) ...[
                OutlinedButton.icon(
                  onPressed: () => setState(() => _currentStep--),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: Text(context.l10n.back),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isLastStep) {
                      if (!_declarationChecked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please check the Declaration of Authenticity before submitting.'),
                            backgroundColor: AppColors.error,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      _submitApplication();
                    } else {
                      _nextStep();
                    }
                  },
                  icon: Icon(
                    isLastStep ? Icons.check_circle_outline : Icons.arrow_forward,
                    size: 20,
                  ),
                  label: Text(
                    isLastStep ? 'Submit Application' : context.l10n.nextStep,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastStep
                        ? (_declarationChecked ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5))
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    final formState = _formKeys[_currentStep].currentState;
    if (formState != null && !formState.validate()) {
      return;
    }

    // Step 2 specific check: ensure state and district are selected
    if (_currentStep == 1) {
      if (_state == null || _state!.isEmpty || _district == null || _district!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both State and District to proceed.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // Step 4 specific check: ensure essential documents are checked
    if (_currentStep == 3) {
      if (!_docAadhaar || !_docSTCert) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify required documents (Aadhaar & ST Certificate) before proceeding.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

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

    final l10n = context.l10n;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.successLight,
              child: Icon(Icons.check, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.applicationSubmittedTitle, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.applicationSubmittedMsg,
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
                  Expanded(
                    child: Text(
                      '${_selectedType.shortCode}-${DateTime.now().year}-00004',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.keepApplicationNumber,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(RouteNames.scholarshipDashboard);
            },
            child: Text(l10n.goToDashboard),
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
            child: Text(l10n.trackApplication),
          ),
        ],
      ),
    );
  }
}
