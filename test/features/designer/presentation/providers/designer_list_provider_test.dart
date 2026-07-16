import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer_id_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/usecases/create_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/delete_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/list_designers_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/update_designer_usecase.dart';
import 'package:mobile_owner/features/designer/presentation/providers/designer_list_provider.dart';
import 'package:mobile_owner/features/designer/presentation/providers/designer_provider.dart';

class MockListUseCase extends Mock implements ListDesignersUseCase {}

class MockCreateUseCase extends Mock implements CreateDesignerUseCase {}

class MockUpdateUseCase extends Mock implements UpdateDesignerUseCase {}

class MockDeleteUseCase extends Mock implements DeleteDesignerUseCase {}

void main() {
  late MockListUseCase mockList;
  late MockCreateUseCase mockCreate;
  late MockUpdateUseCase mockUpdate;
  late MockDeleteUseCase mockDelete;

  setUp(() {
    mockList = MockListUseCase();
    mockCreate = MockCreateUseCase();
    mockUpdate = MockUpdateUseCase();
    mockDelete = MockDeleteUseCase();
  });

  setUpAll(() {
    registerFallbackValue(
        const CreateDesignerParams(shopId: 'shop-1', name: 'x'));
    registerFallbackValue(
        const UpdateDesignerParams(designerId: 'd-1', shopId: 'shop-1'));
    registerFallbackValue(
        const DesignerIdParams(shopId: 'shop-1', designerId: 'd-1'));
  });

  final designer = Designer(
    id: 'd-1',
    shopId: 'shop-1',
    name: '김디자이너',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final designer2 = Designer(
    id: 'd-2',
    shopId: 'shop-1',
    name: '박디자이너',
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        listDesignersUseCaseProvider.overrideWithValue(mockList),
        createDesignerUseCaseProvider.overrideWithValue(mockCreate),
        updateDesignerUseCaseProvider.overrideWithValue(mockUpdate),
        deleteDesignerUseCaseProvider.overrideWithValue(mockDelete),
      ],
    );
  }

  group('DesignerListNotifier', () {
    test('should load designers on build', () async {
      when(() => mockList('shop-1'))
          .thenAnswer((_) async => Right([designer]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(designerListNotifierProvider('shop-1').notifier);
      await notifier.loadDesigners();

      final state = container.read(designerListNotifierProvider('shop-1'));
      expect(state.status, DesignerListStatus.loaded);
      expect(state.designers.length, 1);
    });

    test('should handle load failure', () async {
      when(() => mockList('shop-1'))
          .thenAnswer((_) async => const Left(ServerFailure('로드 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(designerListNotifierProvider('shop-1').notifier);
      await notifier.loadDesigners();

      final state = container.read(designerListNotifierProvider('shop-1'));
      expect(state.status, DesignerListStatus.error);
      expect(state.errorMessage, '로드 실패');
    });

    test('createDesigner should append on success', () async {
      when(() => mockList('shop-1'))
          .thenAnswer((_) async => Right([designer]));
      when(() => mockCreate(any()))
          .thenAnswer((_) async => Right(designer2));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(designerListNotifierProvider('shop-1').notifier);
      await notifier.loadDesigners();

      final error = await notifier.createDesigner(
        const CreateDesignerParams(shopId: 'shop-1', name: '박디자이너'),
      );

      expect(error, isNull);
      final state = container.read(designerListNotifierProvider('shop-1'));
      expect(state.designers.length, 2);
    });

    test('createDesigner should return error message on failure', () async {
      when(() => mockList('shop-1'))
          .thenAnswer((_) async => const Right([]));
      when(() => mockCreate(any()))
          .thenAnswer((_) async => const Left(ServerFailure('생성 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(designerListNotifierProvider('shop-1').notifier);
      await notifier.loadDesigners();

      final error = await notifier.createDesigner(
        const CreateDesignerParams(shopId: 'shop-1', name: '박디자이너'),
      );

      expect(error, '생성 실패');
    });

    test('updateDesigner should replace the matching designer', () async {
      final updated = Designer(
        id: 'd-1',
        shopId: 'shop-1',
        name: '수정된이름',
        createdAt: designer.createdAt,
        updatedAt: DateTime(2024, 2, 1),
      );
      when(() => mockList('shop-1'))
          .thenAnswer((_) async => Right([designer]));
      when(() => mockUpdate(any())).thenAnswer((_) async => Right(updated));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(designerListNotifierProvider('shop-1').notifier);
      await notifier.loadDesigners();

      final error = await notifier.updateDesigner(
        const UpdateDesignerParams(
          designerId: 'd-1',
          shopId: 'shop-1',
          name: '수정된이름',
        ),
      );

      expect(error, isNull);
      final state = container.read(designerListNotifierProvider('shop-1'));
      expect(state.designers.first.name, '수정된이름');
    });

    test('deleteDesigner should remove the matching designer', () async {
      when(() => mockList('shop-1'))
          .thenAnswer((_) async => Right([designer, designer2]));
      when(() => mockDelete(any()))
          .thenAnswer((_) async => const Right(null));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(designerListNotifierProvider('shop-1').notifier);
      await notifier.loadDesigners();

      final error = await notifier.deleteDesigner('d-1');

      expect(error, isNull);
      final state = container.read(designerListNotifierProvider('shop-1'));
      expect(state.designers.length, 1);
      expect(state.designers.first.id, 'd-2');
    });
  });
}
