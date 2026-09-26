import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../services/integrations/digilocker/digilocker_service.dart';
import '../../../../services/scholarship/scholarship_data_service.dart';
import '../../../../shared/widgets/app_button.dart';

enum _ConnectionState {
  idle,
  connecting,
  fetching,
  success,
  error,
}

/// Dedicated DigiLocker connection screen in the post-login authentication flow.
///
/// Securely retrieves verified citizen details from DigiLocker, automatically
/// populates the student profile, and pre-seeds scholarship application data.
class DigiLockerConnectionPage extends StatefulWidget {
  const DigiLockerConnectionPage({super.key});

  @override
  State<DigiLockerConnectionPage> createState() => _DigiLockerConnectionPageState();
}

class _DigiLockerConnectionPageState extends State<DigiLockerConnectionPage>
    with SingleTickerProviderStateMixin {
  final DigiLockerService _digiLockerService = MockDigiLockerService();
  _ConnectionState _state = _ConnectionState.idle;
  String? _errorMessage;
  DigiLockerUserProfile? _fetchedProfile;
  Timer? _autoNavigateTimer;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _startConnection() async {
    final authProvider = context.read<AuthProvider>();
    final scholarshipService = context.read<ScholarshipDataService>();

    setState(() {
      _state = _ConnectionState.connecting;
      _errorMessage = null;
    });

    try {
      // Step 1: Connect to DigiLocker OAuth Gateway
      final connected = await _digiLockerService.connect();
      if (!connected) {
        throw Exception('Gateway handshake failed.');
      }

      if (!mounted) return;

      // Step 2: Fetch verified user details
      setState(() {
        _state = _ConnectionState.fetching;
      });

      final user = authProvider.currentUser;
      final userId = user?.id ?? 'TSS-2025-45678';
      final phone = user?.mobileNumber ?? authProvider.currentPhoneNumber;
      final profile = await _digiLockerService.fetchUserProfile(userId, phoneNumber: phone);

      if (!mounted) return;

      // Step 3: Automatically populate user profile
      await authProvider.populateProfileFromDigiLocker(profile);

      // Pre-refresh scholarship data service with user ID
      try {
        if (authProvider.currentUser != null) {
          await scholarshipService.loadUserData(authProvider.currentUser!.id);
        }
      } catch (_) {
        // Safe fallback if service isn't active
      }

      if (!mounted) return;

      // Step 4: Show success state
      setState(() {
        _state = _ConnectionState.success;
        _fetchedProfile = profile;
      });

      // Automatically proceed to dashboard after a short preview
      _autoNavigateTimer = Timer(const Duration(milliseconds: 2800), () {
        if (mounted && _state == _ConnectionState.success) {
          context.go(RouteNames.dashboard);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ConnectionState.error;
        _errorMessage = "Couldn't connect to DigiLocker. Please try again.";
      });
    }
  }

  void _skipForNow() {
    _autoNavigateTimer?.cancel();
    context.go(RouteNames.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DigiLocker Verification'),
        automaticallyImplyLeading: false,
        actions: [
          if (_state == _ConnectionState.idle || _state == _ConnectionState.error)
            TextButton(
              onPressed: _skipForNow,
              child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStateView(),
        ),
      ),
    );
  }

  Widget _buildCurrentStateView() {
    switch (_state) {
      case _ConnectionState.idle:
        return _buildIdleView();
      case _ConnectionState.connecting:
        return _buildProgressView(
          title: 'Connecting to DigiLocker...',
          subtitle: 'Establishing secure SSL handshake with National DigiLocker Gateway.',
          stepIndex: 1,
        );
      case _ConnectionState.fetching:
        return _buildProgressView(
          title: 'Fetching your details...',
          subtitle: 'Retrieving your certified identity, tribal records, and academic enrollment data.',
          stepIndex: 2,
        );
      case _ConnectionState.success:
        return _buildSuccessView();
      case _ConnectionState.error:
        return _buildErrorView();
    }
  }

  // ── 1. Idle View ──────────────────────────────────────────────────────────
  Widget _buildIdleView() {
    return SingleChildScrollView(
      key: const ValueKey('idle_view'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // DigiLocker Gov emblem / Icon badge
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.lock_person_outlined,
                size: 46,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Connect DigiLocker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Connect your DigiLocker account to securely fetch your verified details and automatically complete your profile.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Feature Highlights
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildBenefitRow(
                  icon: Icons.flash_on_rounded,
                  iconColor: Colors.amber.shade700,
                  title: 'Instant Profile Auto-Fill',
                  description:
                      'No repetitive typing. Full name, father\'s name, DOB, state, and institute are auto-populated.',
                ),
                const Divider(height: 24),
                _buildBenefitRow(
                  icon: Icons.verified_rounded,
                  iconColor: AppColors.primary,
                  title: 'Authentic Government Verification',
                  description:
                      'Caste certificate and academic credentials retrieved directly from official state issuers.',
                ),
                const Divider(height: 24),
                _buildBenefitRow(
                  icon: Icons.security_rounded,
                  iconColor: AppColors.success,
                  title: '100% Private & Masked',
                  description:
                      'Aadhaar numbers remain strictly masked (XXXX-XXXX-4892). Tokens are securely encrypted.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Integration disclosure badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'MoTA Secure Verification Gateway — Authorized Citizen Consent',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Button
          AppButton(
            label: 'Connect DigiLocker',
            onPressed: _startConnection,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _skipForNow,
            child: const Text(
              'Skip for now (I will fill manually)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. Progress View (Connecting / Fetching) ───────────────────────────────
  Widget _buildProgressView({
    required String title,
    required String subtitle,
    required int stepIndex,
  }) {
    return Center(
      key: ValueKey('progress_view_$stepIndex'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            // Visual Step Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildStepRow(
                    label: 'Connecting to DigiLocker',
                    isComplete: stepIndex >= 2,
                    isActive: stepIndex == 1,
                  ),
                  const SizedBox(height: 14),
                  _buildStepRow(
                    label: 'Fetching verified profile details',
                    isComplete: false,
                    isActive: stepIndex == 2,
                  ),
                  const SizedBox(height: 14),
                  _buildStepRow(
                    label: 'Auto-populating student profile',
                    isComplete: false,
                    isActive: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required String label,
    required bool isComplete,
    required bool isActive,
  }) {
    return Row(
      children: [
        if (isComplete)
          const Icon(Icons.check_circle, size: 20, color: AppColors.success)
        else if (isActive)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
          )
        else
          const Icon(Icons.radio_button_unchecked, size: 20, color: AppColors.border),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive
                  ? AppColors.primary
                  : isComplete
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── 3. Success View ───────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    final profile = _fetchedProfile;

    return SingleChildScrollView(
      key: const ValueKey('success_view'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 52,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'DigiLocker Connected',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Your verified details have been successfully fetched.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Auto-populated Profile Preview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Retrieved Profile Data',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 14, color: AppColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildDataRow('Full Name', profile?.fullName ?? 'Rajesh Soren'),
                _buildDataRow('Father\'s Name', profile?.fatherName ?? 'Manoj Soren'),
                _buildDataRow(
                  'Date of Birth',
                  profile?.dateOfBirth != null
                      ? '${profile!.dateOfBirth!.day} Aug ${profile.dateOfBirth!.year}'
                      : '14 Aug 2004',
                ),
                _buildDataRow('Gender', profile?.gender ?? 'Male'),
                _buildDataRow('Category / Tribe', '${profile?.category ?? "ST"} (${profile?.tribeName ?? "Santal"})'),
                _buildDataRow('State & District', '${profile?.district ?? "Mayurbhanj"}, ${profile?.state ?? "Odisha"}'),
                _buildDataRow('Institution', profile?.institutionName ?? 'NIT Rourkela'),
                _buildDataRow('Course', profile?.currentCourse ?? 'B.Tech Computer Science'),
                _buildDataRow('Aadhaar', profile?.maskedAadhaar ?? 'XXXX-XXXX-4892'),
                _buildDataRow('ST Certificate No.', profile?.stCertificateNumber ?? 'ST/OD/2023/88921'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Reusable notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Profile auto-completed. These verified details will be automatically prefilled in your scholarship applications.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Action Button
          AppButton(
            label: 'Continue to Dashboard',
            onPressed: () {
              _autoNavigateTimer?.cancel();
              context.go(RouteNames.dashboard);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Error View ─────────────────────────────────────────────────────────
  Widget _buildErrorView() {
    return Center(
      key: const ValueKey('error_view'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 46,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Couldn\'t connect to DigiLocker',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Please check your connection and try again.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Try Again',
              onPressed: _startConnection,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _skipForNow,
              child: const Text(
                'Continue to Dashboard without DigiLocker',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
