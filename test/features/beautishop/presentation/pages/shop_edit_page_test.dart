import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_edit_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_picker.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/usecases/list_designers_usecase.dart';
import 'package:mobile_owner/features/designer/presentation/providers/designer_provider.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';

class _MockListDesignersUseCase extends Mock implements ListDesignersUseCase {}

BeautyShop _shop() => const BeautyShop(
  id: '1',
  name: '젤로샵',
  regNum: '123-45',
  phoneNumber: '010',
  address: '서울',
  latitude: 37.5,
  longitude: 127.0,
  operatingTime: {},
  images: [],
  menuImages: [],
  averageRating: 0,
  reviewCount: 0,
  categories: [],
);

void main() {
  late _MockListDesignersUseCase mockListDesigners;

  setUp(() {
    mockListDesigners = _MockListDesignersUseCase();
    when(() => mockListDesigners(any())).thenAnswer(
        (_) async => const Right<Failure, List<Designer>>(<Designer>[]));
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listDesignersUseCaseProvider.overrideWithValue(mockListDesigners),
        ],
        child: MaterialApp(home: ShopEditPage(shop: _shop())),
      ),
    );
    await tester.pump();
  }

  Finder submitButton() => find.widgetWithText(FilledButton, '수정하기');

  group('ShopEditPage submit button', () {
    testWidgets('is enabled when no image is uploading', (tester) async {
      await pumpPage(tester);

      expect(tester.widget<FilledButton>(submitButton()).onPressed, isNotNull);
    });

    testWidgets('is disabled while an image is uploading', (tester) async {
      await pumpPage(tester);

      final pickers = tester
          .widgetList<ShopImagePicker>(find.byType(ShopImagePicker))
          .toList();
      pickers.last.onUploadingChanged!(true);
      await tester.pump();

      expect(tester.widget<FilledButton>(submitButton()).onPressed, isNull);
    });

    testWidgets('re-enables once the upload finishes', (tester) async {
      await pumpPage(tester);

      final picker = tester
          .widgetList<ShopImagePicker>(find.byType(ShopImagePicker))
          .last;
      picker.onUploadingChanged!(true);
      await tester.pump();
      picker.onUploadingChanged!(false);
      await tester.pump();

      expect(tester.widget<FilledButton>(submitButton()).onPressed, isNotNull);
    });
  });
}
