import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/geocode_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/check_reg_num_usecase.dart';
import 'package:mobile_owner/features/beautishop/domain/usecases/create_beautishop_usecase.dart';
import 'package:mobile_owner/features/beautishop/presentation/pages/shop_registration_page.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/address_search_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/providers/beautishop_provider.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/map_preview.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/usecases/create_treatment_usecase.dart';
import 'package:mobile_owner/features/treatment/presentation/providers/treatment_provider.dart';

class MockCreateBeautishopUseCase extends Mock
    implements CreateBeautishopUseCase {}

class MockCheckRegNumUseCase extends Mock implements CheckRegNumUseCase {}

class MockCreateTreatmentUseCase extends Mock
    implements CreateTreatmentUseCase {}

class MockGeocodeRemoteDataSource extends Mock
    implements GeocodeRemoteDataSource {}

void main() {
  late MockCreateBeautishopUseCase mockUseCase;
  late MockCheckRegNumUseCase mockCheckRegNum;
  late MockCreateTreatmentUseCase mockCreateTreatment;
  late MockGeocodeRemoteDataSource mockGeocodeDataSource;

  setUp(() {
    mockUseCase = MockCreateBeautishopUseCase();
    mockCheckRegNum = MockCheckRegNumUseCase();
    mockCreateTreatment = MockCreateTreatmentUseCase();
    mockGeocodeDataSource = MockGeocodeRemoteDataSource();
  });

  setUpAll(() {
    registerFallbackValue(CreateShopParams(
      name: '',
      regNum: '',
      phoneNumber: '',
      address: '',
      latitude: 0,
      longitude: 0,
      operatingTime: const {},
    ));
    registerFallbackValue(const CreateTreatmentParams(
      shopId: '',
      name: '',
      price: 0,
      duration: 0,
    ));
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        createBeautishopUseCaseProvider.overrideWithValue(mockUseCase),
        checkRegNumUseCaseProvider.overrideWithValue(mockCheckRegNum),
        createTreatmentUseCaseProvider.overrideWithValue(mockCreateTreatment),
        geocodeRemoteDataSourceProvider
            .overrideWithValue(mockGeocodeDataSource),
        mapWidgetBuilderProvider.overrideWithValue(
          (lat, lng) => Container(
            key: const Key('map_placeholder'),
            color: Colors.grey,
            child: Center(child: Text('$lat, $lng')),
          ),
        ),
      ],
      child: const MaterialApp(
        home: ShopRegistrationPage(),
      ),
    );
  }

  group('ShopRegistrationPage (Wizard)', () {
    testWidgets('should display app bar and step indicator', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('샵 등록'), findsOneWidget);
      expect(find.text('기본 정보를 입력해주세요'), findsOneWidget);
    });

    testWidgets('should display basic info step with form fields',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.widgetWithText(TextFormField, '샵 이름'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '사업자등록번호'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '전화번호'), findsOneWidget);
      expect(find.text('중복확인'), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('다음'), findsOneWidget);
    });

    testWidgets('should show snackbar when next pressed with empty fields',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('입력 정보를 확인해주세요'), findsOneWidget);
    });

    testWidgets('should navigate to step 2 with valid basic info',
        (tester) async {
      when(() => mockCheckRegNum('1234567890'))
          .thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, '샵 이름'), '뷰티샵');
      await tester.enterText(
          find.widgetWithText(TextFormField, '사업자등록번호'), '1234567890');
      await tester.enterText(
          find.widgetWithText(TextFormField, '전화번호'), '010-1234-5678');

      await tester.tap(find.text('중복확인'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('위치 정보를 입력해주세요'), findsOneWidget);
    });

    testWidgets('should show duplicate message for existing reg num',
        (tester) async {
      when(() => mockCheckRegNum('1234567890')).thenAnswer((_) async =>
          const Left(
              ValidationFailure('이미 등록된 사업자등록번호입니다')));

      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, '사업자등록번호'), '1234567890');
      await tester.tap(find.text('중복확인'));
      await tester.pumpAndSettle();

      expect(find.text('이미 등록된 사업자등록번호입니다'), findsOneWidget);
    });
  });
}
