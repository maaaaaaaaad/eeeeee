import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/delete_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/get_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_detail_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/list_treatments_usecase.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';

class MockGetBeautishopUseCase extends Mock implements GetBeautishopUseCase {}

class MockDeleteBeautishopUseCase extends Mock
    implements DeleteBeautishopUseCase {}

class MockListTreatmentsUseCase extends Mock
    implements ListTreatmentsUseCase {}

void main() {
  late MockGetBeautishopUseCase mockGetShop;
  late MockDeleteBeautishopUseCase mockDeleteShop;
  late MockListTreatmentsUseCase mockListTreatments;

  setUp(() {
    mockGetShop = MockGetBeautishopUseCase();
    mockDeleteShop = MockDeleteBeautishopUseCase();
    mockListTreatments = MockListTreatmentsUseCase();
  });

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
    averageRating: 4.5,
    reviewCount: 10,
    categories: [],
  );

  final treatments = [
    Treatment(
      id: 't-1',
      shopId: 'shop-1',
      name: '젤네일',
      price: 30000,
      duration: 60,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        getBeautishopUseCaseProvider.overrideWithValue(mockGetShop),
        deleteBeautishopUseCaseProvider.overrideWithValue(mockDeleteShop),
        listTreatmentsUseCaseProvider.overrideWithValue(mockListTreatments),
      ],
      child: const MaterialApp(
        home: ShopDetailPage(shopId: 'shop-1'),
      ),
    );
  }

  group('ShopDetailPage - Treatment section', () {
    testWidgets('should display treatment section title and manage button',
        (tester) async {
      when(() => mockGetShop('shop-1'))
          .thenAnswer((_) async => const Right(testShop));
      when(() => mockListTreatments('shop-1'))
          .thenAnswer((_) async => Right(treatments));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('시술 관리'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('시술 관리'), findsOneWidget);
      expect(find.text('관리하기'), findsWidgets);
    });

    testWidgets('should display 0 count when no treatments', (tester) async {
      when(() => mockGetShop('shop-1'))
          .thenAnswer((_) async => const Right(testShop));
      when(() => mockListTreatments('shop-1'))
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('등록된 시술 0개'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('등록된 시술 0개'), findsOneWidget);
    });
  });
}
