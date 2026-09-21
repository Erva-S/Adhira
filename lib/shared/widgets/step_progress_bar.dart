import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Reusable multi-step progress bar with step labels.
class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 0-indexed
  final List<String>? stepLabels;

  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        Row(
          children: List.generate(totalSteps, (i) {
            final isActive = i == currentStep;
            final isDone = i < currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.success
                      : isActive
                          ? AppColors.primary
                          : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (stepLabels != null && stepLabels!.length == totalSteps) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(totalSteps, (i) {
              final isActive = i == currentStep;
              final isDone = i < currentStep;
              return Expanded(
                child: Text(
                  stepLabels![i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isDone
                        ? AppColors.success
                        : isActive
                            ? AppColors.primary
                            : AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
