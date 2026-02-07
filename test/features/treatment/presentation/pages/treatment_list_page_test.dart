import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/list_treatments_usecase.dart';
import 'package:mobile_owner/features/treatment/presentation/pages/treatment_list_page.dart';
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
      name: '속눈썹 연장',
      price: 50000,
      duration: 90,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        listTreatmentsUseCaseProvider.overrideWithValue(mockListUseCase),
      ],
      child: const MaterialApp(
        home: TreatmentListPage(shopId: 'shop-1'),
      ),
    );
  }

  group('TreatmentListPage', () {
    testWidgets('should display app bar title', (tester) async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => Right(treatments));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('시술 관리'), findsOneWidget);
    });

    testWidgets('should display treatment cards when loaded', (tester) async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => Right(treatments));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('젤네일'), findsOneWidget);
      expect(find.text('속눈썹 연장'), findsOneWidget);
    });

    testWidgets('should display empty message when no treatments',
        (tester) async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('등록된 시술이 없습니다'), findsOneWidget);
    });

    testWidgets('should display error message on failure', (tester) async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => const Left(ServerFailure('로드 실패')));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('로드 실패'), findsOneWidget);
    });

    testWidgets('should have FAB button', (tester) async {
      when(() => mockListUseCase('shop-1'))
          .thenAnswer((_) async => Right(treatments));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
