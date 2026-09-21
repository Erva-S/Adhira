import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Profile editing sub-page.
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController(text: 'Rajesh Singh');
  final _mobileController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController(text: 'rajesh.singh@email.com');
  final _fatherController = TextEditingController(text: 'Manoj Singh');

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _fatherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryLight,
                    child: Text('RS', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white)),
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
            Text('Mobile Number', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            AppTextField(controller: _mobileController, hintText: 'Enter mobile number'),
            const SizedBox(height: 16),
            Text('Email Address', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            AppTextField(controller: _emailController, hintText: 'Enter email address'),
            const SizedBox(height: 28),
            AppButton(
              label: 'Save Changes',
              icon: Icons.check,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
