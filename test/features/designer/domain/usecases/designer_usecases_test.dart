import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer_id_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/repositories/designer_repository.dart';
import 'package:mobile_owner/features/designer/domain/usecases/create_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/delete_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/get_designer_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/list_designers_usecase.dart';
import 'package:mobile_owner/features/designer/domain/usecases/update_designer_usecase.dart';

class MockDesignerRepository extends Mock implements DesignerRepository {}

void main() {
  late MockDesignerRepository mockRepository;

  setUp(() {
    mockRepository = MockDesignerRepository();
  });

  final testDesigner = Designer(
    id: 'd-1',
    shopId: 'shop-1',
    name: '김디자이너',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('CreateDesignerUseCase', () {
    const params = CreateDesignerParams(shopId: 'shop-1', name: '김디자이너');

    test('should create a designer via repository', () async {
      final useCase = CreateDesignerUseCase(mockRepository);
      when(() => mockRepository.createDesigner(params))
          .thenAnswer((_) async => Right(testDesigner));

      final result = await useCase(params);

      expect(result, Right(testDesigner));
      verify(() => mockRepository.createDesigner(params)).called(1);
    });

    test('should return failure when creation fails', () async {
      final useCase = CreateDesignerUseCase(mockRepository);
      when(() => mockRepository.createDesigner(params))
          .thenAnswer((_) async => const Left(ServerFailure('생성 실패')));

      final result = await useCase(params);

      expect(result, const Left(ServerFailure('생성 실패')));
    });
  });

  group('GetDesignerUseCase', () {
    const params = DesignerIdParams(shopId: 'shop-1', designerId: 'd-1');

    test('should get a designer by id params', () async {
      final useCase = GetDesignerUseCase(mockRepository);
      when(() => mockRepository.getDesigner('shop-1', 'd-1'))
          .thenAnswer((_) async => Right(testDesigner));

      final result = await useCase(params);

      expect(result, Right(testDesigner));
      verify(() => mockRepository.getDesigner('shop-1', 'd-1')).called(1);
    });
  });

  group('ListDesignersUseCase', () {
    test('should list designers by shop id', () async {
      final useCase = ListDesignersUseCase(mockRepository);
      when(() => mockRepository.listDesigners('shop-1'))
          .thenAnswer((_) async => Right([testDesigner]));

      final result = await useCase('shop-1');

      result.fold(
        (_) => fail('should be right'),
        (designers) => expect(designers.length, 1),
      );
    });
  });

  group('UpdateDesignerUseCase', () {
    const params = UpdateDesignerParams(
      designerId: 'd-1',
      shopId: 'shop-1',
      name: '수정',
    );

    test('should update a designer via repository', () async {
      final useCase = UpdateDesignerUseCase(mockRepository);
      when(() => mockRepository.updateDesigner(params))
          .thenAnswer((_) async => Right(testDesigner));

      final result = await useCase(params);

      expect(result, Right(testDesigner));
      verify(() => mockRepository.updateDesigner(params)).called(1);
    });
  });

  group('DeleteDesignerUseCase', () {
    const params = DesignerIdParams(shopId: 'shop-1', designerId: 'd-1');

    test('should delete a designer via repository', () async {
      final useCase = DeleteDesignerUseCase(mockRepository);
      when(() => mockRepository.deleteDesigner('shop-1', 'd-1'))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result, const Right(null));
      verify(() => mockRepository.deleteDesigner('shop-1', 'd-1')).called(1);
    });
  });
}
