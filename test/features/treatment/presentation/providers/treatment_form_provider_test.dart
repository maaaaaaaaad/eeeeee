import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/create_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/delete_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/update_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_form_provider.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';

class MockCreateTreatmentUseCase extends Mock
    implements CreateTreatmentUseCase {}

class MockUpdateTreatmentUseCase extends Mock
    implements UpdateTreatmentUseCase {}

class MockDeleteTreatmentUseCase extends Mock
    implements DeleteTreatmentUseCase {}

void main() {
  late MockCreateTreatmentUseCase mockCreate;
  late MockUpdateTreatmentUseCase mockUpdate;
  late MockDeleteTreatmentUseCase mockDelete;

  setUp(() {
    mockCreate = MockCreateTreatmentUseCase();
    mockUpdate = MockUpdateTreatmentUseCase();
    mockDelete = MockDeleteTreatmentUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const CreateTreatmentParams(
      shopId: '',
      name: '',
      price: 0,
      duration: 10,
    ));
    registerFallbackValue(const UpdateTreatmentParams(
      treatmentId: '',
      name: '',
      price: 0,
      duration: 10,
    ));
  });

  final testTreatment = Treatment(
    id: 't-1',
    shopId: 'shop-1',
    name: '젤네일',
    price: 30000,
    duration: 60,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        createTreatmentUseCaseProvider.overrideWithValue(mockCreate),
        updateTreatmentUseCaseProvider.overrideWithValue(mockUpdate),
        deleteTreatmentUseCaseProvider.overrideWithValue(mockDelete),
      ],
    );
  }

  group('TreatmentFormNotifier', () {
    test('initial state should be initial status', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(treatmentFormNotifierProvider);
      expect(state.status, TreatmentFormStatus.initial);
    });

    test('should create treatment successfully', () async {
      when(() => mockCreate(any()))
          .thenAnswer((_) async => Right(testTreatment));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentFormNotifierProvider.notifier);

      await notifier.create(const CreateTreatmentParams(
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      ));

      final state = container.read(treatmentFormNotifierProvider);
      expect(state.status, TreatmentFormStatus.success);
    });

    test('should handle create failure', () async {
      when(() => mockCreate(any()))
          .thenAnswer((_) async => const Left(ServerFailure('등록 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentFormNotifierProvider.notifier);

      await notifier.create(const CreateTreatmentParams(
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
      ));

      final state = container.read(treatmentFormNotifierProvider);
      expect(state.status, TreatmentFormStatus.error);
      expect(state.errorMessage, '등록 실패');
    });

    test('should update treatment successfully', () async {
      when(() => mockUpdate(any()))
          .thenAnswer((_) async => Right(testTreatment));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentFormNotifierProvider.notifier);

      await notifier.update(const UpdateTreatmentParams(
        treatmentId: 't-1',
        name: '젤네일 수정',
        price: 35000,
        duration: 90,
      ));

      final state = container.read(treatmentFormNotifierProvider);
      expect(state.status, TreatmentFormStatus.success);
    });

    test('should handle update failure', () async {
      when(() => mockUpdate(any()))
          .thenAnswer((_) async => const Left(ServerFailure('수정 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentFormNotifierProvider.notifier);

      await notifier.update(const UpdateTreatmentParams(
        treatmentId: 't-1',
        name: '젤네일 수정',
        price: 35000,
        duration: 90,
      ));

      final state = container.read(treatmentFormNotifierProvider);
      expect(state.status, TreatmentFormStatus.error);
      expect(state.errorMessage, '수정 실패');
    });

    test('should delete treatment successfully', () async {
      when(() => mockDelete('t-1'))
          .thenAnswer((_) async => const Right(null));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentFormNotifierProvider.notifier);

      final result = await notifier.delete('t-1');

      expect(result, true);
      final state = container.read(treatmentFormNotifierProvider);
      expect(state.status, TreatmentFormStatus.deleted);
    });

    test('should handle delete failure', () async {
      when(() => mockDelete('t-1'))
          .thenAnswer((_) async => const Left(ServerFailure('삭제 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentFormNotifierProvider.notifier);

      final result = await notifier.delete('t-1');

      expect(result, false);
      final state = container.read(treatmentFormNotifierProvider);
      expect(state.errorMessage, '삭제 실패');
    });
  });
}
