import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/repositories/treatment_repository.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/create_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/delete_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/get_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/list_treatments_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/update_treatment_usecase.dart';

class MockTreatmentRepository extends Mock implements TreatmentRepository {}

void main() {
  late MockTreatmentRepository mockRepository;

  setUp(() {
    mockRepository = MockTreatmentRepository();
  });

  final testTreatment = Treatment(
    id: 't-1',
    shopId: 'shop-1',
    name: '젤네일',
    price: 30000,
    duration: 60,
    description: '기본 젤네일',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('CreateTreatmentUseCase', () {
    late CreateTreatmentUseCase useCase;

    setUp(() {
      useCase = CreateTreatmentUseCase(mockRepository);
    });

    const params = CreateTreatmentParams(
      shopId: 'shop-1',
      name: '젤네일',
      price: 30000,
      duration: 60,
      description: '기본 젤네일',
    );

    test('should create a treatment via repository', () async {
      when(() => mockRepository.createTreatment(params))
          .thenAnswer((_) async => Right(testTreatment));

      final result = await useCase(params);

      expect(result, Right(testTreatment));
      verify(() => mockRepository.createTreatment(params)).called(1);
    });

    test('should return failure when creation fails', () async {
      when(() => mockRepository.createTreatment(params))
          .thenAnswer((_) async => const Left(ServerFailure('생성 실패')));

      final result = await useCase(params);

      expect(result, const Left(ServerFailure('생성 실패')));
    });
  });

  group('GetTreatmentUseCase', () {
    late GetTreatmentUseCase useCase;

    setUp(() {
      useCase = GetTreatmentUseCase(mockRepository);
    });

    test('should get a treatment by id', () async {
      when(() => mockRepository.getTreatment('t-1'))
          .thenAnswer((_) async => Right(testTreatment));

      final result = await useCase('t-1');

      expect(result, Right(testTreatment));
      verify(() => mockRepository.getTreatment('t-1')).called(1);
    });

    test('should return failure when not found', () async {
      when(() => mockRepository.getTreatment('invalid'))
          .thenAnswer((_) async => const Left(ServerFailure('시술을 찾을 수 없습니다')));

      final result = await useCase('invalid');

      expect(result.isLeft(), true);
    });
  });

  group('ListTreatmentsUseCase', () {
    late ListTreatmentsUseCase useCase;

    setUp(() {
      useCase = ListTreatmentsUseCase(mockRepository);
    });

    test('should list treatments by shop id', () async {
      when(() => mockRepository.listTreatments('shop-1'))
          .thenAnswer((_) async => Right([testTreatment]));

      final result = await useCase('shop-1');

      result.fold(
        (_) => fail('should be right'),
        (treatments) => expect(treatments.length, 1),
      );
      verify(() => mockRepository.listTreatments('shop-1')).called(1);
    });

    test('should return empty list when no treatments', () async {
      when(() => mockRepository.listTreatments('shop-1'))
          .thenAnswer((_) async => const Right([]));

      final result = await useCase('shop-1');

      result.fold(
        (_) => fail('should be right'),
        (treatments) => expect(treatments, isEmpty),
      );
    });
  });

  group('UpdateTreatmentUseCase', () {
    late UpdateTreatmentUseCase useCase;

    setUp(() {
      useCase = UpdateTreatmentUseCase(mockRepository);
    });

    const params = UpdateTreatmentParams(
      treatmentId: 't-1',
      name: '젤네일 수정',
      price: 35000,
      duration: 90,
    );

    test('should update a treatment via repository', () async {
      when(() => mockRepository.updateTreatment(params))
          .thenAnswer((_) async => Right(testTreatment));

      final result = await useCase(params);

      expect(result, Right(testTreatment));
      verify(() => mockRepository.updateTreatment(params)).called(1);
    });
  });

  group('DeleteTreatmentUseCase', () {
    late DeleteTreatmentUseCase useCase;

    setUp(() {
      useCase = DeleteTreatmentUseCase(mockRepository);
    });

    test('should delete a treatment via repository', () async {
      when(() => mockRepository.deleteTreatment('t-1'))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase('t-1');

      expect(result, const Right(null));
      verify(() => mockRepository.deleteTreatment('t-1')).called(1);
    });
  });
}
