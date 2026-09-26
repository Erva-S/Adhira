import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../services/authentication/auth_provider.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Profile editing sub-page — updates persistent student profile.
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _fatherController;
  late final TextEditingController _tribeController;
  late final TextEditingController _institutionController;
  late final TextEditingController _courseController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      AuthProvider? authProvider;
      try {
        authProvider = Provider.of<AuthProvider>(context, listen: false);
      } catch (_) {}
      final user = authProvider?.currentUser;
      _nameController = TextEditingController(text: user?.fullName ?? '');
      _mobileController = TextEditingController(text: user?.mobileNumber ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _fatherController = TextEditingController(text: user?.fatherName ?? '');
      _tribeController = TextEditingController(text: user?.tribeName ?? '');
      _institutionController = TextEditingController(text: user?.institutionName ?? '');
      _courseController = TextEditingController(text: user?.currentCourse ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _fatherController.dispose();
    _tribeController.dispose();
    _institutionController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {}

    final student = authProvider?.currentUser;
    final displayName = student?.fullName ?? 'Student';
        final initials = displayName
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();

        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(fallbackRoute: RouteNames.profile),
            title: const Text('Edit Profile'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          initials.isNotEmpty ? initials : 'ST',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Full Name', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                AppTextField(controller: _nameController, hintText: 'Enter full name'),
                const SizedBox(height: 16),
                Text('Father\'s Name', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                AppTextField(controller: _fatherController, hintText: 'Enter father\'s name'),
                const SizedBox(height: 16),
                Text('Tribe / Community Name', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                AppTextField(controller: _tribeController, hintText: 'e.g. Santhal, Gond, Bodo'),
                const SizedBox(height: 16),
                Text('Institution Name', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                AppTextField(controller: _institutionController, hintText: 'e.g. NIT Rourkela'),
                const SizedBox(height: 16),
                Text('Current Course / Degree', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                AppTextField(controller: _courseController, hintText: 'e.g. B.Tech Computer Science'),
                const SizedBox(height: 16),
                Text('Mobile Number (Identity Linked)', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                AppTextField(
                  controller: _mobileController,
                  hintText: 'Mobile number',
                  readOnly: true, // Auth identity field — locked
                ),
                const SizedBox(height: 16),
                Text('Email Address', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                AppTextField(controller: _emailController, hintText: 'Enter email address'),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Save Changes',
                  icon: Icons.check,
                  isLoading: authProvider?.isLoading ?? false,
                  onPressed: () async {
                    if (student == null) return;
                    final updated = student.copyWith(
                      fullName: _nameController.text.trim(),
                      fatherName: _fatherController.text.trim(),
                      tribeName: _tribeController.text.trim(),
                      institutionName: _institutionController.text.trim(),
                      currentCourse: _courseController.text.trim(),
                      email: _emailController.text.trim(),
                      profileCompletionPercent: 0.85,
                    );
                    if (authProvider != null) {
                      await authProvider.updateProfile(updated);
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated and persisted successfully!')),
                      );
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
  }
}
