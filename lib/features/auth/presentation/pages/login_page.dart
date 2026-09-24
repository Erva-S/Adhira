import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/widgets/language_selector_sheet.dart';

/// Login / Registration page with Indian mobile number validation and OTP trigger.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLogin = true;
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _cleanPhone(String input) {
    var cleaned = input.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  bool _validatePhone() {
    final cleaned = _cleanPhone(_phoneController.text);
    if (cleaned.isEmpty) {
      setState(() => _phoneError = 'Mobile number is required.');
      return false;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      setState(() => _phoneError = 'Please enter a valid 10-digit Indian mobile number starting with 6, 7, 8, or 9.');
      return false;
    }
    setState(() => _phoneError = null);
    return true;
  }

  Future<void> _handleSendOtp() async {
    FocusScope.of(context).unfocus();

    if (!_validatePhone()) return;

    final cleanedPhone = _cleanPhone(_phoneController.text);
    final authProvider = context.read<AuthProvider>();

    final result = await authProvider.sendOtp(cleanedPhone);

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.push(
        RouteNames.otpVerification,
        extra: {'phoneNumber': cleanedPhone},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authProvider = context.watch<AuthProvider>();
    LocaleProvider? localeProvider;
    try {
      localeProvider = Provider.of<LocaleProvider>(context, listen: true);
    } catch (_) {}
    final currentLang = localeProvider?.currentLanguage ?? LocaleProvider.supportedLanguages.first;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header with logo and language button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school, color: AppColors.primary, size: 28),
                    ),
                    TextButton.icon(
                      onPressed: () => showLanguageSelectorSheet(context),
                      icon: const Icon(Icons.language, size: 16),
                      label: Text(
                        currentLang.nativeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceVariant,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? l10n.welcomeBack : l10n.createAccount,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? l10n.signInSubtitle : l10n.registerSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 36),

                // Phone field
                AppTextField(
                  label: l10n.mobileNumber,
                  hintText: l10n.enterMobileNumber,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.fromLTRB(14, 14, 6, 14),
                    child: Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  maxLength: 10,
                  errorText: _phoneError,
                  onChanged: (_) {
                    if (_phoneError != null) _validatePhone();
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                AppButton(
                  label: _isLogin ? l10n.sendOtp : '${l10n.createAccount} & ${l10n.sendOtp}',
                  isLoading: authProvider.isLoading,
                  onPressed: authProvider.isLoading ? null : _handleSendOtp,
                ),
                const SizedBox(height: 16),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Social login
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('DigiLocker OAuth redirect...')),
                          );
                        },
                        icon: const Icon(Icons.lock_open, size: 18),
                        label: const Text('DigiLocker'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aadhaar e-KYC authentication...')),
                          );
                        },
                        icon: const Icon(Icons.fingerprint, size: 18),
                        label: const Text('Aadhaar'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Toggle login/register
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _phoneError = null;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Register"
                          : 'Already have an account? Login',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
