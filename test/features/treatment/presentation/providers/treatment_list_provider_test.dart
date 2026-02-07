import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/list_treatments_usecase.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_list_provider.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';

class MockListTreatmentsUseCase extends Mock
    implements ListTreatmentsUseCase {}

void main() {
  late MockListTreatmentsUseCase mockListUseCase;

  setUp(() {
    mockListUseCase = MockListTreatmentsUseCase();
  });

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
    Treatment(
      id: 't-2',
      shopId: 'shop-1',
      name: '속눈썹',
      price: 50000,
      duration: 90,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        listTreatmentsUseCaseProvider.overrideWithValue(mockListUseCase),
      ],
    );
  }

  group('TreatmentListNotifier', () {
    test('initial state should be initial status', () {
      when(() => mockListUseCase(any()))
          .thenAnswer((_) async => const Right([]));

      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(treatmentListNotifierProvider('shop-1'));
      expect(state.status, TreatmentListStatus.initial);
    });

    test('should load treatments successfully', () async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => Right(treatments));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentListNotifierProvider('shop-1').notifier);
      await notifier.loadTreatments();

      final state = container.read(treatmentListNotifierProvider('shop-1'));
      expect(state.status, TreatmentListStatus.loaded);
      expect(state.treatments.length, 2);
    });

    test('should handle load failure', () async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => const Left(ServerFailure('로드 실패')));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentListNotifierProvider('shop-1').notifier);
      await notifier.loadTreatments();

      final state = container.read(treatmentListNotifierProvider('shop-1'));
      expect(state.status, TreatmentListStatus.error);
      expect(state.errorMessage, '로드 실패');
    });

    test('should refresh treatments', () async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => Right(treatments));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(treatmentListNotifierProvider('shop-1').notifier);
      await notifier.loadTreatments();
      await notifier.refresh();

      final state = container.read(treatmentListNotifierProvider('shop-1'));
      expect(state.status, TreatmentListStatus.loaded);
      verify(() => mockListUseCase('shop-1')).called(2);
    });
  });
}
