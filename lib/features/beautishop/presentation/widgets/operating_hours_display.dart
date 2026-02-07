import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/constants/operating_days.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class OperatingHoursDisplay extends StatelessWidget {
  final Map<String, String> operatingTime;

  const OperatingHoursDisplay({super.key, required this.operatingTime});

  @override
  Widget build(BuildContext context) {
    if (operatingTime.isEmpty) {
      return const Text(
        '영업시간 정보 없음',
        style: TextStyle(fontSize: 14, color: AppColors.textHint),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: OperatingDays.orderedKeys.map((day) {
        final label = OperatingDays.toKorean[day] ?? day;
        final hours = operatingTime[day];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hours != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                hours ?? '휴무',
                style: TextStyle(
                  fontSize: 14,
                  color: hours != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
