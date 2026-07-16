import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _kAllowedShowModalBottomSheet = {
  'lib/shared/widgets/app_bottom_sheet.dart',
};

const _kAllowedShowDialog = {
  'lib/shared/widgets/app_bottom_sheet.dart',
};

const _kAllowedScaffold = {
  'lib/shared/widgets/app_scaffold.dart',
};

const _kAllowedViewInsetsBottom = {
  'lib/shared/widgets/app_bottom_sheet.dart',
  'lib/shared/widgets/app_bottom_inset.dart',
  'lib/shared/widgets/app_bottom_action_bar.dart',
};

const _kAllowedRawAlertDialog = {
  'lib/shared/widgets/app_bottom_sheet.dart',
  'lib/features/beautishop/presentation/widgets/delete_confirmation_dialog.dart',
  'lib/features/treatment/presentation/widgets/delete_treatment_dialog.dart',
};

void main() {
  group('Safe overlay architecture', () {
    test('lib/ must not call showModalBottomSheet directly', () {
      final violations = _findViolations(
        pattern: RegExp(r'(?<!\w)showModalBottomSheet\s*[<(]'),
        allowed: _kAllowedShowModalBottomSheet,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Use showAppBottomSheet (lib/shared/widgets/app_bottom_sheet.dart) instead.\n'
            'showAppBottomSheet wraps the sheet with SafeArea(top:false) and viewInsets.bottom '
            'so the content never hides behind the Android navigation/gesture bar or the keyboard.\n'
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('lib/ must not call showDialog directly', () {
      final violations = _findViolations(
        pattern: RegExp(r'(?<!\w)showDialog\s*[<(]'),
        allowed: _kAllowedShowDialog,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Use showAppDialog (lib/shared/widgets/app_bottom_sheet.dart) instead.\n'
            'showAppDialog wraps the dialog body with SafeArea so it never hides behind system UI.\n'
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('lib/ must not instantiate raw Scaffold directly', () {
      final violations = _findViolations(
        pattern: RegExp(r'(?<!\w)Scaffold\s*\('),
        allowed: _kAllowedScaffold,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Use AppScaffold (lib/shared/widgets/app_scaffold.dart) instead of raw Scaffold.\n'
            'AppScaffold auto-handles SafeArea(top:auto,bottom:false) around body and provides '
            '`bottomAction` (AppBottomActionBar), `bottomNavigationBar`, and `backgroundGradient` slots '
            'so no screen leaks under system UI (status bar, gesture bar, home indicator).\n'
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('lib/ must not reference MediaQuery viewInsets.bottom directly', () {
      final violations = _findViolations(
        pattern: RegExp(r'viewInsets(Of\([^)]*\))?\s*\.\s*bottom'),
        allowed: _kAllowedViewInsetsBottom,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Do not read `viewInsets.bottom` (keyboard height) manually.\n'
            'showAppBottomSheet, AppBottomActionBar, and Scaffold(resizeToAvoidBottomInset:true) '
            'already pad for the keyboard. Adding another Padding(bottom: viewInsets.bottom) inside '
            'a sheet double-pads and pushes the content above the keyboard by 2× its height.\n'
            'If you truly need custom keyboard handling for a full-screen overlay, add the file to '
            '_kAllowedViewInsetsBottom in test/architecture/safe_overlay_test.dart with a comment.\n'
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('lib/ must not instantiate raw AlertDialog directly', () {
      final violations = _findViolations(
        pattern: RegExp(r'(?<!\w)AlertDialog\s*\('),
        allowed: _kAllowedRawAlertDialog,
      );
      expect(
        violations,
        isEmpty,
        reason:
            'Use showAppConfirmDialog (lib/shared/widgets/app_bottom_sheet.dart) for confirmation dialogs.\n'
            'It applies the correct insetPadding.bottom (24 + viewPadding.bottom) so the dialog is not '
            'clipped by the Android system nav bar. For non-confirmation dialogs, use showAppDialog '
            'with a Dialog widget and provide your own insetPadding that accounts for viewPadding.bottom.\n'
            'Violations:\n${violations.join('\n')}',
      );
    });
  });
}

List<String> _findViolations({
  required RegExp pattern,
  required Set<String> allowed,
}) {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return const [];

  final violations = <String>[];
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final relative = entity.path.replaceAll(r'\', '/');
    if (allowed.contains(relative)) continue;

    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('//')) continue;
      if (pattern.hasMatch(line)) {
        violations.add('  $relative:${i + 1}  ${line.trim()}');
      }
    }
  }
  return violations;
}
