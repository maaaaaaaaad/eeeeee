import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/wizard_steps/designer_draft_form.dart';

const _kScreenSize = Size(400, 800);
const _kKeyboardHeight = 300.0;
const _kBottomSafeArea = 34.0;

Widget _appWithKeyboard({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          size: _kScreenSize,
          viewInsets: const EdgeInsets.only(bottom: _kKeyboardHeight),
          padding: EdgeInsets.zero,
          viewPadding: const EdgeInsets.only(bottom: _kBottomSafeArea),
        ),
        child: appChild!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('DesignerDraftForm keyboard test', () {
    testWidgets(
      '이름 TextField stays above keyboard when opened',
      (tester) async {
        tester.view.physicalSize = _kScreenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _appWithKeyboard(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  DesignerDraftForm.show(
                    context: context,
                    onSave: (_) {},
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final nameField = find.widgetWithText(TextFormField, '이름 (필수)');
        expect(nameField, findsOneWidget);

        final rect = tester.getRect(nameField);
        final keyboardTop = _kScreenSize.height - _kKeyboardHeight;

        expect(
          rect.top,
          lessThan(keyboardTop),
          reason: '이름 TextFormField (top=${rect.top}) must render '
              'above the keyboard top ($keyboardTop).',
        );
      },
    );
  });
}
