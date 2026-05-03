import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/constants/operating_days.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class OperatingTimeForm extends StatefulWidget {
  final Map<String, String> initialValue;
  final ValueChanged<Map<String, String>> onChanged;

  const OperatingTimeForm({
    super.key,
    this.initialValue = const {},
    required this.onChanged,
  });

  @override
  State<OperatingTimeForm> createState() => _OperatingTimeFormState();
}

class _DayState {
  bool enabled;
  TimeOfDay startTime;
  TimeOfDay endTime;

  _DayState({
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });
}

class _OperatingTimeFormState extends State<OperatingTimeForm> {
  late final Map<String, _DayState> _states;

  static const _defaultStart = TimeOfDay(hour: 9, minute: 0);
  static const _defaultEnd = TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _states = {};
    for (final day in OperatingDays.orderedKeys) {
      final raw = widget.initialValue[day];
      if (raw != null && raw.isNotEmpty && raw.contains('-')) {
        final parts = raw.split('-');
        _states[day] = _DayState(
          enabled: true,
          startTime: _parseTime(parts[0]) ?? _defaultStart,
          endTime: _parseTime(parts[1]) ?? _defaultEnd,
        );
      } else {
        _states[day] = _DayState(
          enabled: false,
          startTime: _defaultStart,
          endTime: _defaultEnd,
        );
      }
    }
  }

  TimeOfDay? _parseTime(String input) {
    final parts = input.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _notifyChanged() {
    final result = <String, String>{};
    for (final day in OperatingDays.orderedKeys) {
      final s = _states[day]!;
      if (s.enabled) {
        result[day] = '${_formatTime(s.startTime)}-${_formatTime(s.endTime)}';
      }
    }
    widget.onChanged(result);
  }

  Future<void> _pickTime(String day, bool isStart) async {
    final state = _states[day]!;
    final initial = isStart ? state.startTime : state.endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? '시작 시간' : '종료 시간',
      cancelText: '취소',
      confirmText: '확인',
      hourLabelText: '시',
      minuteLabelText: '분',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        state.startTime = picked;
      } else {
        state.endTime = picked;
      }
    });
    _notifyChanged();
  }

  void _applyToAll() {
    final monday = OperatingDays.orderedKeys.first;
    final source = _states[monday]!;
    if (!source.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('월요일을 영업 상태로 먼저 설정해주세요')),
      );
      return;
    }
    setState(() {
      for (final day in OperatingDays.orderedKeys.skip(1)) {
        _states[day] = _DayState(
          enabled: true,
          startTime: source.startTime,
          endTime: source.endTime,
        );
      }
    });
    _notifyChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('월요일 시간을 모든 요일에 적용했습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _applyToAll,
            icon: const Icon(Icons.copy_all_outlined, size: 18),
            label: const Text('월요일 기준 전체 적용'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentPink,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...OperatingDays.orderedKeys.map((day) {
          final label = OperatingDays.toKorean[day] ?? day;
          final state = _states[day]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: state.enabled
                    ? Colors.white
                    : AppColors.divider.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: state.enabled
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: state.enabled,
                    activeThumbColor: AppColors.pastelPink,
                    onChanged: (val) {
                      setState(() => state.enabled = val);
                      _notifyChanged();
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: state.enabled
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _TimeChip(
                                time: _formatTime(state.startTime),
                                onTap: () => _pickTime(day, true),
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '~',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              _TimeChip(
                                time: _formatTime(state.endTime),
                                onTap: () => _pickTime(day, false),
                              ),
                            ],
                          )
                        : const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '휴무',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final VoidCallback onTap;

  const _TimeChip({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pastelPink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.pastelPink.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: AppColors.accentPink,
            ),
            const SizedBox(width: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accentPink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
