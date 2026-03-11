import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/geocode_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/data/models/geocode_result_model.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/geocode_result.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/address_search_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/address_search_bottom_sheet.dart';

class MockGeocodeRemoteDataSource extends Mock
    implements GeocodeRemoteDataSource {}

void main() {
  late MockGeocodeRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockGeocodeRemoteDataSource();
  });

  const testResults = [
    GeocodeResultModel(
      roadAddress: '서울특별시 강남구 테헤란로 123',
      jibunAddress: '서울특별시 강남구 역삼동 456',
      latitude: 37.5665,
      longitude: 126.978,
    ),
    GeocodeResultModel(
      roadAddress: '서울특별시 서초구 서초대로 789',
      jibunAddress: '서울특별시 서초구 서초동 100',
      latitude: 37.4837,
      longitude: 127.0324,
    ),
  ];

  Widget createWidget({
    void Function(GeocodeResult)? onSelected,
  }) {
    return ProviderScope(
      overrides: [
        geocodeRemoteDataSourceProvider.overrideWithValue(mockDataSource),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddressSearchBottomSheet(
                    onSelected: onSelected ?? (_) {},
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('AddressSearchBottomSheet', () {
    testWidgets('should display search text field with format hint',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('도로명 + 건물번호'), findsOneWidget);
    });

    testWidgets('should show results after search', (tester) async {
      when(() => mockDataSource.searchAddress(any()))
          .thenAnswer((_) async => testResults);

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '강남구');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('서울특별시 강남구 테헤란로 123'), findsOneWidget);
      expect(find.text('서울특별시 서초구 서초대로 789'), findsOneWidget);
    });

    testWidgets('should show empty state with format guidance when no results',
        (tester) async {
      when(() => mockDataSource.searchAddress(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '존재하지않는주소');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('검색 결과가 없습니다'), findsOneWidget);
      expect(find.textContaining('도로명+건물번호'), findsOneWidget);
    });

    testWidgets('should call onSelected when result is tapped',
        (tester) async {
      when(() => mockDataSource.searchAddress(any()))
          .thenAnswer((_) async => testResults);

      GeocodeResult? selectedResult;

      await tester.pumpWidget(createWidget(
        onSelected: (result) => selectedResult = result,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '강남구');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      await tester.tap(find.text('서울특별시 강남구 테헤란로 123'));
      await tester.pumpAndSettle();

      expect(selectedResult, isNotNull);
      expect(selectedResult!.roadAddress, '서울특별시 강남구 테헤란로 123');
      expect(selectedResult!.latitude, 37.5665);
    });

    testWidgets('should display jibun address as subtitle', (tester) async {
      when(() => mockDataSource.searchAddress(any()))
          .thenAnswer((_) async => testResults);

      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '강남구');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('서울특별시 강남구 역삼동 456'), findsOneWidget);
    });
  });
}
