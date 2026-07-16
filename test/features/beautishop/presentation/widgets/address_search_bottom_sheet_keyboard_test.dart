import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/geocode_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/address_search_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/address_search_bottom_sheet.dart';
import 'package:mobile_owner/shared/widgets/app_bottom_sheet.dart';
import 'package:mocktail/mocktail.dart';

class _MockGeocodeRemoteDataSource extends Mock
    implements GeocodeRemoteDataSource {}

const _kScreenSize = Size(400, 800);
const _kKeyboardHeight = 300.0;
const _kBottomSafeArea = 34.0;

Widget _appWithKeyboard({
  required Widget child,
  required GeocodeRemoteDataSource dataSource,
}) {
  return ProviderScope(
    overrides: [
      geocodeRemoteDataSourceProvider.overrideWithValue(dataSource),
    ],
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
  late _MockGeocodeRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = _MockGeocodeRemoteDataSource();
  });

  group('AddressSearchBottomSheet keyboard test', () {
    testWidgets(
      'search TextField stays above keyboard when opened',
      (tester) async {
        tester.view.physicalSize = _kScreenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _appWithKeyboard(
            dataSource: mockDataSource,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => AddressSearchBottomSheet(
                      onSelected: (_) {},
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

        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);

        final rect = tester.getRect(textFieldFinder);
        final keyboardTop = _kScreenSize.height - _kKeyboardHeight;

        expect(
          rect.top,
          lessThan(keyboardTop),
          reason: 'Search TextField (top=${rect.top}) must render above '
              'the keyboard top ($keyboardTop). The sheet uses a fixed '
              'SizedBox(height: 0.7 * screenHeight) which must be reduced '
              'by the wrapper when the keyboard is up.',
        );

        expect(
          rect.bottom,
          lessThanOrEqualTo(keyboardTop),
          reason: 'Search TextField bottom (${rect.bottom}) must not extend '
              'past the keyboard top ($keyboardTop).',
        );
      },
    );
  });
}
