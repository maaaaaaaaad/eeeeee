import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/shared/widgets/app_bottom_sheet.dart';

const _kScreenSize = Size(400, 800);
const _kKeyboardHeight = 300.0;
const _kBottomSafeArea = 34.0;

Widget _appWithKeyboard({
  required Widget child,
  double keyboardBottom = _kKeyboardHeight,
  double bottomSafeArea = _kBottomSafeArea,
}) {
  final effectivePaddingBottom =
      keyboardBottom > 0 ? 0.0 : bottomSafeArea;
  return MaterialApp(
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: _kScreenSize,
        viewInsets: EdgeInsets.only(bottom: keyboardBottom),
        padding: EdgeInsets.only(bottom: effectivePaddingBottom),
        viewPadding: EdgeInsets.only(bottom: bottomSafeArea),
      ),
      child: appChild!,
    ),
    home: Scaffold(body: child),
  );
}

Future<void> _openSheet(
  WidgetTester tester, {
  required WidgetBuilder builder,
}) async {
  await tester.pumpWidget(
    _appWithKeyboard(
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            showAppBottomSheet<void>(
              context: context,
              builder: builder,
            );
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('showAppBottomSheet keyboard handling', () {
    testWidgets(
      'sheet content stays above the keyboard when viewInsets.bottom > 0',
      (tester) async {
        tester.view.physicalSize = _kScreenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _openSheet(
          tester,
          builder: (_) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                TextField(
                  key: Key('sheet_text_field'),
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 400),
                Text('bottom', key: Key('sheet_bottom_marker')),
              ],
            ),
          ),
        );

        final textFieldRect =
            tester.getRect(find.byKey(const Key('sheet_text_field')));
        final keyboardTop = _kScreenSize.height - _kKeyboardHeight;

        expect(
          textFieldRect.bottom,
          lessThanOrEqualTo(keyboardTop),
          reason:
              'TextField bottom (${textFieldRect.bottom}) must be at or above '
              'keyboard top ($keyboardTop). Wrapper failed to pad for viewInsets.',
        );
      },
    );

    testWidgets(
      'sheet content is not double-padded (bottom sits exactly on keyboard top)',
      (tester) async {
        tester.view.physicalSize = _kScreenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _openSheet(
          tester,
          builder: (_) => const SizedBox(
            key: Key('sheet_body'),
            height: 200,
          ),
        );

        final sheetBodyRect =
            tester.getRect(find.byKey(const Key('sheet_body')));
        final keyboardTop = _kScreenSize.height - _kKeyboardHeight;

        expect(
          sheetBodyRect.bottom,
          closeTo(keyboardTop, 1.0),
          reason:
              'Sheet content bottom (${sheetBodyRect.bottom}) should sit '
              'exactly on keyboard top ($keyboardTop). A larger gap indicates '
              'double-padding (wrapper + Flutter both padded for keyboard).',
        );
      },
    );

    testWidgets(
      'without keyboard, sheet honours the bottom safe area',
      (tester) async {
        tester.view.physicalSize = _kScreenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _appWithKeyboard(
            keyboardBottom: 0,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    builder: (_) => const SizedBox(
                      key: Key('sheet_body'),
                      height: 100,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final sheetBodyRect =
            tester.getRect(find.byKey(const Key('sheet_body')));
        expect(
          sheetBodyRect.bottom,
          lessThanOrEqualTo(_kScreenSize.height - _kBottomSafeArea + 1),
          reason:
              'Sheet content bottom (${sheetBodyRect.bottom}) must be at or '
              'above the home indicator area '
              '(${_kScreenSize.height - _kBottomSafeArea}).',
        );
      },
    );

    testWidgets(
      'when keyboard is open, no white gap sits between content and keyboard',
      (tester) async {
        tester.view.physicalSize = _kScreenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _openSheet(
          tester,
          builder: (_) => Container(
            key: const Key('sheet_body'),
            color: const Color(0xFFFFFFFF),
            child: const SizedBox(
              height: 200,
              child: Center(child: TextField()),
            ),
          ),
        );

        final sheetBodyRect =
            tester.getRect(find.byKey(const Key('sheet_body')));
        final keyboardTop = _kScreenSize.height - _kKeyboardHeight;
        final gap = keyboardTop - sheetBodyRect.bottom;

        expect(
          gap,
          lessThanOrEqualTo(1.0),
          reason:
              'A gap of $gap logical pixels between the sheet body bottom '
              '(${sheetBodyRect.bottom}) and the keyboard top ($keyboardTop) '
              'would render as visible empty (potentially white) space above '
              'the keyboard.',
        );
      },
    );
  });
}
