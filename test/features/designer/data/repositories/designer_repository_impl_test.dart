import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/designer/data/datasources/designer_remote_datasource.dart';
import 'package:mobile_owner/features/designer/data/models/create_designer_request.dart';
import 'package:mobile_owner/features/designer/data/models/designer_model.dart';
import 'package:mobile_owner/features/designer/data/models/update_designer_request.dart';
import 'package:mobile_owner/features/designer/data/repositories/designer_repository_impl.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';

class MockDesignerRemoteDataSource extends Mock
    implements DesignerRemoteDataSource {}

void main() {
  late MockDesignerRemoteDataSource mockDataSource;
  late DesignerRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockDesignerRemoteDataSource();
    repository = DesignerRepositoryImpl(remoteDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(const CreateDesignerRequest(name: 'x'));
    registerFallbackValue(const UpdateDesignerRequest());
  });

  final testModel = DesignerModel(
    id: 'd-1',
    shopId: 'shop-1',
    name: '김디자이너',
    nickname: '젤리',
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  group('createDesigner', () {
    const params = CreateDesignerParams(
      shopId: 'shop-1',
      name: '김디자이너',
    );

    test('should return Designer on success', () async {
      when(() => mockDataSource.createDesigner('shop-1', any()))
          .thenAnswer((_) async => testModel);

      final result = await repository.createDesigner(params);

      expect(result, Right(testModel));
    });

    test('should return ValidationFailure on 400', () async {
      when(() => mockDataSource.createDesigner('shop-1', any()))
          .thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
          data: {'code': 'INVALID_DESIGNER_NAME'},
        ),
      ));

      final result = await repository.createDesigner(params);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('should return ServerFailure on generic DioException', () async {
      when(() => mockDataSource.createDesigner('shop-1', any()))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      final result = await repository.createDesigner(params);

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('getDesigner', () {
    test('should return Designer on success', () async {
      when(() => mockDataSource.getDesigner('shop-1', 'd-1'))
          .thenAnswer((_) async => testModel);

      final result = await repository.getDesigner('shop-1', 'd-1');

      expect(result, Right(testModel));
    });

    test('should return Failure on error', () async {
      when(() => mockDataSource.getDesigner('shop-1', 'd-1'))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await repository.getDesigner('shop-1', 'd-1');

      expect(result.isLeft(), true);
    });
  });

  group('listDesigners', () {
    test('should return list on success', () async {
      when(() => mockDataSource.listDesigners('shop-1'))
          .thenAnswer((_) async => [testModel]);

      final result = await repository.listDesigners('shop-1');

      result.fold(
        (_) => fail('should be right'),
        (designers) {
          expect(designers.length, 1);
          expect(designers[0].name, '김디자이너');
        },
      );
    });

    test('should return Failure on error', () async {
      when(() => mockDataSource.listDesigners('shop-1'))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await repository.listDesigners('shop-1');

      expect(result.isLeft(), true);
    });
  });

  group('updateDesigner', () {
    const params = UpdateDesignerParams(
      designerId: 'd-1',
      shopId: 'shop-1',
      name: '수정',
    );

    test('should return Designer on success', () async {
      when(() => mockDataSource.updateDesigner('shop-1', 'd-1', any()))
          .thenAnswer((_) async => testModel);

      final result = await repository.updateDesigner(params);

      expect(result, Right(testModel));
    });

    test('should return ValidationFailure on 400', () async {
      when(() => mockDataSource.updateDesigner('shop-1', 'd-1', any()))
          .thenThrow(DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
          data: {'code': 'INVALID_DESIGNER_NAME'},
        ),
      ));

      final result = await repository.updateDesigner(params);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('deleteDesigner', () {
    test('should return void on success', () async {
      when(() => mockDataSource.deleteDesigner('shop-1', 'd-1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteDesigner('shop-1', 'd-1');

      expect(result, const Right(null));
    });

    test('should return Failure on error', () async {
      when(() => mockDataSource.deleteDesigner('shop-1', 'd-1'))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await repository.deleteDesigner('shop-1', 'd-1');

      expect(result.isLeft(), true);
    });
  });
}
