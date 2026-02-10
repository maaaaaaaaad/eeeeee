import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/update_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/schedule_management_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_time_form.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateBeautishopUseCase extends Mock
    implements UpdateBeautishopUseCase {}

class FakeUpdateShopParams extends Fake implements UpdateShopParams {}

void main() {
  late MockUpdateBeautishopUseCase mockUpdateUseCase;

  setUpAll(() {
    registerFallbackValue(FakeUpdateShopParams());
  });

  setUp(() {
    mockUpdateUseCase = MockUpdateBeautishopUseCase();
  });

  const tShop = BeautyShop(
    id: 'shop-1',
    name: '테스트 샵',
    regNum: '1234567890',
    phoneNumber: '01012345678',
    address: '서울시 강남구',
    latitude: 37.5665,
    longitude: 126.978,
    operatingTime: {
      'MONDAY': '09:00-18:00',
      'TUESDAY': '09:00-18:00',
      'WEDNESDAY': '09:00-18:00',
    },
    description: '테스트 설명',
    images: ['img1.jpg'],
    averageRating: 4.5,
    reviewCount: 10,
    categories: [],
  );

  Widget createWidget({BeautyShop shop = tShop}) {
    return ProviderScope(
      overrides: [
        updateBeautishopUseCaseProvider.overrideWithValue(mockUpdateUseCase),
      ],
      child: MaterialApp(
        home: ScheduleManagementPage(shop: shop),
      ),
    );
  }

  group('ScheduleManagementPage', () {
    testWidgets('should display app bar title', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('스케줄 관리'), findsOneWidget);
    });

    testWidgets('should display OperatingTimeForm', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(OperatingTimeForm), findsOneWidget);
    });

    testWidgets('should display save button', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.scrollUntilVisible(
        find.text('저장'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('should display day labels from operating time form',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('월'), findsOneWidget);
      expect(find.text('화'), findsOneWidget);
      expect(find.text('수'), findsOneWidget);
      expect(find.text('목'), findsOneWidget);
      expect(find.text('금'), findsOneWidget);
      expect(find.text('토'), findsOneWidget);
      expect(find.text('일'), findsOneWidget);
    });

    testWidgets('should show switches for each day', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Switch), findsNWidgets(7));
    });

    testWidgets('should have enabled switches for days with operating time',
        (tester) async {
      await tester.pumpWidget(createWidget());

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();

      expect(switches[0].value, true);
      expect(switches[1].value, true);
      expect(switches[2].value, true);
      expect(switches[3].value, false);
      expect(switches[4].value, false);
      expect(switches[5].value, false);
      expect(switches[6].value, false);
    });

    testWidgets('should call update when save is tapped', (tester) async {
      when(() => mockUpdateUseCase(any()))
          .thenAnswer((_) async => const Right(tShop));

      await tester.pumpWidget(createWidget());

      await tester.scrollUntilVisible(
        find.text('저장'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      verify(() => mockUpdateUseCase(any())).called(1);
    });

    testWidgets('should show snackbar on error', (tester) async {
      when(() => mockUpdateUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('저장 실패')),
      );

      await tester.pumpWidget(createWidget());

      await tester.scrollUntilVisible(
        find.text('저장'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(find.text('저장 실패'), findsOneWidget);
    });
  });
}
