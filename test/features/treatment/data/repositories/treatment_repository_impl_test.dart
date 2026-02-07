import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:mobile_owner/features/treatment/data/models/create_treatment_request.dart';
import 'package:mobile_owner/features/treatment/data/models/treatment_model.dart';
import 'package:mobile_owner/features/treatment/data/models/update_treatment_request.dart';
import 'package:mobile_owner/features/treatment/data/repositories/treatment_repository_impl.dart';
import 'package:mobile_owner/features/treatment/domain/entities/create_treatment_params.dart';
import 'package:mobile_owner/features/treatment/domain/entities/update_treatment_params.dart';

class MockTreatmentRemoteDataSource extends Mock
    implements TreatmentRemoteDataSource {}

void main() {
  late MockTreatmentRemoteDataSource mockDataSource;
  late TreatmentRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockTreatmentRemoteDataSource();
    repository = TreatmentRepositoryImpl(remoteDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(const CreateTreatmentRequest(
      name: '',
      price: 0,
      duration: 10,
    ));
    registerFallbackValue(const UpdateTreatmentRequest(
      name: '',
      price: 0,
      duration: 10,
    ));
  });

  final testModel = TreatmentModel(
    id: 't-1',
    shopId: 'shop-1',
    name: '젤네일',
    price: 30000,
    duration: 60,
    description: '기본 젤네일',
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  group('createTreatment', () {
    const params = CreateTreatmentParams(
      shopId: 'shop-1',
      name: '젤네일',
      price: 30000,
      duration: 60,
      description: '기본 젤네일',
    );

    test('should return Treatment on success', () async {
      when(() => mockDataSource.createTreatment('shop-1', any()))
          .thenAnswer((_) async => testModel);

      final result = await repository.createTreatment(params);

      expect(result, Right(testModel));
    });

    test('should return ValidationFailure on 400', () async {
      when(() => mockDataSource.createTreatment('shop-1', any()))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      final result = await repository.createTreatment(params);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('should return ServerFailure on DioException', () async {
      when(() => mockDataSource.createTreatment('shop-1', any()))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
          data: {'message': '서버 오류'},
        ),
      ));

      final result = await repository.createTreatment(params);

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('getTreatment', () {
    test('should return Treatment on success', () async {
      when(() => mockDataSource.getTreatment('t-1'))
          .thenAnswer((_) async => testModel);

      final result = await repository.getTreatment('t-1');

      expect(result, Right(testModel));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.getTreatment('t-1')).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await repository.getTreatment('t-1');

      expect(result.isLeft(), true);
    });
  });

  group('listTreatments', () {
    test('should return list on success', () async {
      when(() => mockDataSource.listTreatments('shop-1'))
          .thenAnswer((_) async => [testModel]);

      final result = await repository.listTreatments('shop-1');

      result.fold(
        (_) => fail('should be right'),
        (treatments) {
          expect(treatments.length, 1);
          expect(treatments[0].name, '젤네일');
        },
      );
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.listTreatments('shop-1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await repository.listTreatments('shop-1');

      expect(result.isLeft(), true);
    });
  });

  group('updateTreatment', () {
    const params = UpdateTreatmentParams(
      treatmentId: 't-1',
      name: '젤네일 수정',
      price: 35000,
      duration: 90,
    );

    test('should return Treatment on success', () async {
      when(() => mockDataSource.updateTreatment('t-1', any()))
          .thenAnswer((_) async => testModel);

      final result = await repository.updateTreatment(params);

      expect(result, Right(testModel));
    });

    test('should return ValidationFailure on 400', () async {
      when(() => mockDataSource.updateTreatment('t-1', any()))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      final result = await repository.updateTreatment(params);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('deleteTreatment', () {
    test('should return void on success', () async {
      when(() => mockDataSource.deleteTreatment('t-1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteTreatment('t-1');

      expect(result, const Right(null));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.deleteTreatment('t-1')).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await repository.deleteTreatment('t-1');

      expect(result.isLeft(), true);
    });
  });
}
