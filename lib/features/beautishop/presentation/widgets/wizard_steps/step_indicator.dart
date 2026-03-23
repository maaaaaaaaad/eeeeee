import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  static const _stepLabels = [
    '기본 정보',
    '위치',
    '영업 시간',
    '시술',
    '설명',
    '확인',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepBefore < currentStep
                    ? AppColors.pastelPink
                    : AppColors.divider,
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.pastelPink
                      : isCurrent
                          ? AppColors.accentPink
                          : AppColors.divider,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              isCurrent ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                _stepLabels[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  color: isCurrent || isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                  fontWeight:
                      isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
