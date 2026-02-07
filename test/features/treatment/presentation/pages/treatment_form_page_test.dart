import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/create_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/delete_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/update_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/presentation/pages/treatment_form_page.dart';
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
    description: '기본 젤네일',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  Widget createWidget({Treatment? treatment}) {
    return ProviderScope(
      overrides: [
        createTreatmentUseCaseProvider.overrideWithValue(mockCreate),
        updateTreatmentUseCaseProvider.overrideWithValue(mockUpdate),
        deleteTreatmentUseCaseProvider.overrideWithValue(mockDelete),
      ],
      child: MaterialApp(
        home: TreatmentFormPage(
          shopId: 'shop-1',
          treatment: treatment,
        ),
      ),
    );
  }

  group('TreatmentFormPage - Create mode', () {
    testWidgets('should display create mode app bar', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('시술 등록'), findsOneWidget);
    });

    testWidgets('should display empty form fields', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.widgetWithText(TextFormField, '시술명'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '가격'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '소요시간 (분)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '설명 (선택)'), findsOneWidget);
    });

    testWidgets('should display register button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('등록하기'), findsOneWidget);
    });

    testWidgets('should not display delete button in create mode',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('삭제하기'), findsNothing);
    });

    testWidgets('should show validation errors on empty submit',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('등록하기'));
      await tester.pumpAndSettle();

      expect(find.textContaining('입력해주세요'), findsWidgets);
    });

    testWidgets('should call create on valid form submit', (tester) async {
      when(() => mockCreate(any()))
          .thenAnswer((_) async => Right(testTreatment));

      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, '시술명'), '젤네일');
      await tester.enterText(
          find.widgetWithText(TextFormField, '가격'), '30000');
      await tester.enterText(
          find.widgetWithText(TextFormField, '소요시간 (분)'), '60');

      await tester.tap(find.text('등록하기'));
      await tester.pumpAndSettle();

      verify(() => mockCreate(any())).called(1);
    });
  });

  group('TreatmentFormPage - Edit mode', () {
    testWidgets('should display edit mode app bar', (tester) async {
      await tester.pumpWidget(createWidget(treatment: testTreatment));

      expect(find.text('시술 수정'), findsOneWidget);
    });

    testWidgets('should pre-fill form fields', (tester) async {
      await tester.pumpWidget(createWidget(treatment: testTreatment));

      final nameField = find.widgetWithText(TextFormField, '시술명');
      final nameWidget = tester.widget<TextFormField>(nameField);
      expect(nameWidget.controller?.text, '젤네일');
    });

    testWidgets('should display update button', (tester) async {
      await tester.pumpWidget(createWidget(treatment: testTreatment));

      expect(find.text('수정하기'), findsOneWidget);
    });

    testWidgets('should display delete button in edit mode', (tester) async {
      await tester.pumpWidget(createWidget(treatment: testTreatment));

      expect(find.text('삭제하기'), findsOneWidget);
    });

    testWidgets('should call update on valid form submit', (tester) async {
      when(() => mockUpdate(any()))
          .thenAnswer((_) async => Right(testTreatment));

      await tester.pumpWidget(createWidget(treatment: testTreatment));

      await tester.tap(find.text('수정하기'));
      await tester.pumpAndSettle();

      verify(() => mockUpdate(any())).called(1);
    });
  });
}
