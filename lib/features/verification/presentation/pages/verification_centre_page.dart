import 'package:flutter/material.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/verification_card.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';

/// Verification centre showing all verification checks.
class VerificationCentrePage extends StatelessWidget {
  const VerificationCentrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackRoute: RouteNames.dashboard),
        title: const Text('Verification Centre'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress summary
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Verification Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 4 / 7,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('4 of 7 verifications complete', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Text('57%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                ],
              ),
            ),

            // Verification cards
            const VerificationCard(
              title: 'Identity Verification',
              subtitle: 'Aadhaar verified via UIDAI',
              status: VerificationStatus.verified,
              sourceSystem: 'UIDAI',
              isAutomatic: true,
            ),
            const VerificationCard(
              title: 'ST/PVTG Certificate',
              subtitle: 'Under review by district office',
              status: VerificationStatus.inProgress,
              sourceSystem: 'e-District',
            ),
            const VerificationCard(
              title: 'Income Certificate',
              subtitle: 'Pending verification',
              status: VerificationStatus.pending,
              sourceSystem: 'e-District',
            ),
            const VerificationCard(
              title: 'Academic Records',
              subtitle: 'Verified by institution',
              status: VerificationStatus.verified,
              sourceSystem: 'AISHE',
              isAutomatic: true,
            ),
            const VerificationCard(
              title: 'Institution Verification',
              subtitle: 'Confirmed by NIT Rourkela',
              status: VerificationStatus.verified,
              sourceSystem: 'AISHE',
              isAutomatic: true,
            ),
            const VerificationCard(
              title: 'Domicile Certificate',
              subtitle: 'Verified via state portal',
              status: VerificationStatus.verified,
              sourceSystem: 'State Portal',
            ),
            const VerificationCard(
              title: 'Bank Account',
              subtitle: 'Pending NPCI verification',
              status: VerificationStatus.pending,
              sourceSystem: 'NPCI',
              isAutomatic: true,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
