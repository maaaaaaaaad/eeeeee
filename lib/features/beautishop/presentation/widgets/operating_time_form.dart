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

class _OperatingTimeFormState extends State<OperatingTimeForm> {
  late final Map<String, bool> _enabled;
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _enabled = {};
    _controllers = {};
    for (final day in OperatingDays.orderedKeys) {
      final value = widget.initialValue[day];
      _enabled[day] = value != null && value.isNotEmpty;
      _controllers[day] = TextEditingController(text: value ?? '09:00-18:00');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanged() {
    final result = <String, String>{};
    for (final day in OperatingDays.orderedKeys) {
      if (_enabled[day] == true && _controllers[day]!.text.isNotEmpty) {
        result[day] = _controllers[day]!.text;
      }
    }
    widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: OperatingDays.orderedKeys.map((day) {
        final label = OperatingDays.toKorean[day] ?? day;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: _enabled[day] ?? false,
                activeThumbColor: AppColors.pastelPink,
                onChanged: (val) {
                  setState(() => _enabled[day] = val);
                  _notifyChanged();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _enabled[day] == true
                    ? TextField(
                        controller: _controllers[day],
                        decoration: const InputDecoration(
                          hintText: '09:00-18:00',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: (_) => _notifyChanged(),
                      )
                    : const Text(
                        '휴무',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
