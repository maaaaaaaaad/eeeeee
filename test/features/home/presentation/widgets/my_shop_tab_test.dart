import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/features/home/presentation/widgets/my_shop_tab.dart';

class FakeHomeNotifier extends HomeNotifier {
  final HomeState _initialState;

  FakeHomeNotifier(this._initialState);

  @override
  HomeState build() {
    return _initialState;
  }

  @override
  Future<void> loadData() async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  const owner = Owner(
    id: 'owner-1',
    businessNumber: '1234567890',
    phoneNumber: '01012345678',
    nickname: '테스트',
    email: 'test@test.com',
  );

  const shop = BeautyShop(
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

  Widget createWidget({List<BeautyShop> shops = const []}) {
    final state = HomeState(
      status: HomeStatus.loaded,
      owner: owner,
      shops: shops,
    );

    return ProviderScope(
      overrides: [
        homeNotifierProvider.overrideWith(() => FakeHomeNotifier(state)),
      ],
      child: const MaterialApp(
        home: Scaffold(body: MyShopTab()),
      ),
    );
  }

  group('MyShopTab', () {
    testWidgets('should show EmptyShopGuide when no shops', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('아직 등록된 샵이 없어요'), findsOneWidget);
      expect(find.text('샵 등록하기'), findsOneWidget);
    });

    testWidgets('should show shop list when shops exist', (tester) async {
      await tester.pumpWidget(createWidget(shops: [shop]));
      await tester.pump();

      expect(find.text('내 뷰티샵'), findsOneWidget);
      expect(find.text('테스트 샵'), findsOneWidget);
    });

    testWidgets('should show FAB when shops exist', (tester) async {
      await tester.pumpWidget(createWidget(shops: [shop]));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should not show FAB when no shops', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
