import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/geocode_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/data/models/geocode_result_model.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/create_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_registration_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/address_search_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/map_preview.dart';

class MockCreateBeautishopUseCase extends Mock
    implements CreateBeautishopUseCase {}

class MockGeocodeRemoteDataSource extends Mock
    implements GeocodeRemoteDataSource {}

void main() {
  late MockCreateBeautishopUseCase mockUseCase;
  late MockGeocodeRemoteDataSource mockGeocodeDataSource;

  setUp(() {
    mockUseCase = MockCreateBeautishopUseCase();
    mockGeocodeDataSource = MockGeocodeRemoteDataSource();
  });

  setUpAll(() {
    registerFallbackValue(CreateShopParams(
      name: '',
      regNum: '',
      phoneNumber: '',
      address: '',
      latitude: 0,
      longitude: 0,
      operatingTime: const {},
    ));
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        createBeautishopUseCaseProvider.overrideWithValue(mockUseCase),
        geocodeRemoteDataSourceProvider
            .overrideWithValue(mockGeocodeDataSource),
        mapWidgetBuilderProvider.overrideWithValue(
          (lat, lng) => Container(
            key: const Key('map_placeholder'),
            color: Colors.grey,
            child: Center(child: Text('$lat, $lng')),
          ),
        ),
      ],
      child: const MaterialApp(
        home: ShopRegistrationPage(),
      ),
    );
  }

  group('ShopRegistrationPage', () {
    testWidgets('should display app bar and first form section', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('샵 등록'), findsOneWidget);
      expect(find.text('기본 정보'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '샵 이름'), findsOneWidget);
    });

    testWidgets('should display location section with search icon',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.scrollUntilVisible(
        find.text('위치 정보'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('위치 정보'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should open address search bottom sheet when address tapped',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.scrollUntilVisible(
        find.widgetWithText(TextFormField, '주소'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(TextFormField, '주소'));
      await tester.pumpAndSettle();

      expect(find.textContaining('도로명 + 건물번호'), findsOneWidget);
    });

    testWidgets(
        'should fill address and coordinates when search result selected',
        (tester) async {
      const testResults = [
        GeocodeResultModel(
          roadAddress: '서울특별시 강남구 테헤란로 123',
          jibunAddress: '서울특별시 강남구 역삼동 456',
          latitude: 37.5665,
          longitude: 126.978,
        ),
      ];

      when(() => mockGeocodeDataSource.searchAddress(any()))
          .thenAnswer((_) async => testResults);

      await tester.pumpWidget(createWidget());

      await tester.scrollUntilVisible(
        find.widgetWithText(TextFormField, '주소'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(TextFormField, '주소'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, '도로명 + 건물번호 (예: 테헤란로 123)'),
          '강남구');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      await tester.tap(find.text('서울특별시 강남구 테헤란로 123'));
      await tester.pumpAndSettle();

      final addressField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, '서울특별시 강남구 테헤란로 123'),
      );
      expect(addressField.controller?.text, '서울특별시 강남구 테헤란로 123');
    });

    testWidgets('should show validation errors when tapping register button',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.scrollUntilVisible(
        find.text('등록하기'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('등록하기'));
      await tester.pumpAndSettle();

      expect(find.textContaining('입력해주세요'), findsWidgets);
    });
  });
}
