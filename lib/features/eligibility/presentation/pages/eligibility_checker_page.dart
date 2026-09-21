import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';

/// Multi-step eligibility checker page.
class EligibilityCheckerPage extends StatefulWidget {
  const EligibilityCheckerPage({super.key});

  @override
  State<EligibilityCheckerPage> createState() => _EligibilityCheckerPageState();
}

class _EligibilityCheckerPageState extends State<EligibilityCheckerPage> {
  int _currentStep = 0;
  final Map<int, int> _answers = {};

  final List<_EligibilityQuestion> _questions = [
    _EligibilityQuestion(
      question: 'Do you belong to a Scheduled Tribe (ST)?',
      options: ['Yes', 'No', 'Applied for certificate'],
    ),
    _EligibilityQuestion(
      question: 'What is your current education level?',
      options: ['Class 9-10', 'Class 11-12', 'Undergraduate', 'Postgraduate', 'M.Phil/Ph.D'],
    ),
    _EligibilityQuestion(
      question: 'What is your family annual income?',
      options: ['Below ₹2 Lakh', '₹2-3.5 Lakh', '₹3.5-6 Lakh', 'Above ₹6 Lakh'],
    ),
    _EligibilityQuestion(
      question: 'Where do you wish to study?',
      options: ['India — Government', 'India — Private (Top)', 'India — Other', 'Abroad'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentStep];
    return Scaffold(
      appBar: AppBar(title: const Text('Eligibility Checker')),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(_questions.length, (i) {
                final isActive = i == _currentStep;
                final isDone = i < _currentStep;
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Step ${_currentStep + 1} of ${_questions.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          // Question
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              question.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Options
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final isSelected = _answers[_currentStep] == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => setState(() => _answers[_currentStep] = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: AppButton(
                      label: 'Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => setState(() => _currentStep--),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: _currentStep == _questions.length - 1 ? 'Check Eligibility' : 'Next',
                    onPressed: _answers.containsKey(_currentStep)
                        ? () {
                            if (_currentStep < _questions.length - 1) {
                              setState(() => _currentStep++);
                            } else {
                              // TODO: Show eligibility result
                              _showResult(context);
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResult(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            Text('You may be eligible!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Based on your answers, you may qualify for Post-Matric Scholarship and Top Class Education.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('⚠️ Final eligibility is subject to official verification.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            AppButton(label: 'View Eligible Schemes', onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _EligibilityQuestion {
  final String question;
  final List<String> options;
  const _EligibilityQuestion({required this.question, required this.options});
}
