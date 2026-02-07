import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/create_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_registration_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class MockCreateBeautishopUseCase extends Mock
    implements CreateBeautishopUseCase {}

void main() {
  late MockCreateBeautishopUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockCreateBeautishopUseCase();
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

    testWidgets('should call register on valid form submit', (tester) async {
      const testShop = BeautyShop(
        id: 'shop-1',
        name: '테스트 샵',
        regNum: '1234567890',
        phoneNumber: '01012345678',
        address: '서울시 강남구',
        latitude: 37.5665,
        longitude: 126.978,
        operatingTime: {},
        images: [],
        averageRating: 0.0,
        reviewCount: 0,
        categories: [],
      );

      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Right(testShop));

      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, '샵 이름'), '테스트 샵');
      await tester.enterText(
          find.widgetWithText(TextFormField, '사업자등록번호'), '1234567890');
      await tester.enterText(
          find.widgetWithText(TextFormField, '전화번호'), '01012345678');

      await tester.scrollUntilVisible(
        find.widgetWithText(TextFormField, '주소'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
          find.widgetWithText(TextFormField, '주소'), '서울시 강남구');

      await tester.scrollUntilVisible(
        find.widgetWithText(TextFormField, '위도'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
          find.widgetWithText(TextFormField, '위도'), '37.5665');
      await tester.enterText(
          find.widgetWithText(TextFormField, '경도'), '126.978');

      await tester.scrollUntilVisible(
        find.text('등록하기'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('등록하기'));
      await tester.pumpAndSettle();

      verify(() => mockUseCase(any())).called(1);
    });
  });
}
