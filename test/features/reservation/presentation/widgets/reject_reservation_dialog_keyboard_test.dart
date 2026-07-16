import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/reservation/presentation/widgets/reject_reservation_dialog.dart';

const _kScreenSize = Size(400, 800);
const _kKeyboardHeight = 300.0;
const _kBottomSafeArea = 34.0;

Widget _appWithKeyboard({required Widget child}) {
  return MaterialApp(
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
  );
}

void main() {
  group('RejectReservationDialog keyboard test', () {
    testWidgets(
      '거절 사유 TextField stays above keyboard when opened',
      (tester) async {
        tester.view.physicalSize = _kScreenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _appWithKeyboard(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => RejectReservationDialog.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);

        final rect = tester.getRect(textFieldFinder);
        final keyboardTop = _kScreenSize.height - _kKeyboardHeight;

        expect(
          rect.top,
          lessThan(keyboardTop),
          reason: 'TextField (top=${rect.top}) must render above the '
              'keyboard top ($keyboardTop).',
        );

        expect(
          rect.bottom,
          lessThanOrEqualTo(keyboardTop + 1),
          reason: 'TextField bottom (${rect.bottom}) must not extend past '
              'the keyboard top ($keyboardTop).',
        );
      },
    );
  });
}
