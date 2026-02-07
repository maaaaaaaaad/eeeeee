import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/features/beautishop/data/datasources/beautishop_remote_datasource.dart';
import 'package:mobile_owner/features/beautishop/data/models/category_model.dart';
import 'package:mobile_owner/features/beautishop/data/models/create_beautishop_request.dart';
import 'package:mobile_owner/features/beautishop/data/models/update_beautishop_request.dart';
import 'package:mobile_owner/features/beautishop/data/repositories/beautishop_repository_impl.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/create_shop_params.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/update_shop_params.dart';
import 'package:mobile_owner/features/home/data/models/beauty_shop_model.dart';

class MockBeautishopRemoteDataSource extends Mock
    implements BeautishopRemoteDataSource {}

void main() {
  late MockBeautishopRemoteDataSource mockDataSource;
  late BeautishopRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockBeautishopRemoteDataSource();
    repository = BeautishopRepositoryImpl(remoteDataSource: mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(const CreateBeautishopRequest(
      name: '',
      regNum: '',
      phoneNumber: '',
      address: '',
      latitude: 0,
      longitude: 0,
      operatingTime: {},
      shopImages: [],
    ));
    registerFallbackValue(const UpdateBeautishopRequest(
      operatingTime: {},
      shopImages: [],
    ));
  });

  const testShopModel = BeautyShopModel(
    id: 'shop-1',
    name: '테스트 샵',
    regNum: '1234567890',
    phoneNumber: '01012345678',
    address: '서울시 강남구',
    latitude: 37.5665,
    longitude: 126.978,
    operatingTime: {'MONDAY': '09:00-18:00'},
    images: [],
    averageRating: 0.0,
    reviewCount: 0,
    categories: [],
  );

  group('createShop', () {
    final params = CreateShopParams(
      name: '테스트 샵',
      regNum: '1234567890',
      phoneNumber: '01012345678',
      address: '서울시 강남구',
      latitude: 37.5665,
      longitude: 126.978,
      operatingTime: const {'MONDAY': '09:00-18:00'},
    );

    test('should return BeautyShop on success', () async {
      when(() => mockDataSource.createShop(any()))
          .thenAnswer((_) async => testShopModel);

      final result = await repository.createShop(params);

      expect(result, const Right(testShopModel));
    });

    test('should return ServerFailure on DioException', () async {
      when(() => mockDataSource.createShop(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
          data: {'message': '서버 오류'},
        ),
      ));

      final result = await repository.createShop(params);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be left'),
      );
    });

    test('should return ValidationFailure on 400', () async {
      when(() => mockDataSource.createShop(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      final result = await repository.createShop(params);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('getShop', () {
    test('should return BeautyShop on success', () async {
      when(() => mockDataSource.getShop('shop-1'))
          .thenAnswer((_) async => testShopModel);

      final result = await repository.getShop('shop-1');

      expect(result, const Right(testShopModel));
    });

    test('should return ServerFailure on error', () async {
      when(() => mockDataSource.getShop('shop-1')).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await repository.getShop('shop-1');

      expect(result.isLeft(), true);
    });
  });

  group('updateShop', () {
    final params = UpdateShopParams(
      shopId: 'shop-1',
      operatingTime: const {'MONDAY': '10:00-20:00'},
      shopImages: const [],
    );

    test('should return BeautyShop on success', () async {
      when(() => mockDataSource.updateShop('shop-1', any()))
          .thenAnswer((_) async => testShopModel);

      final result = await repository.updateShop(params);

      expect(result, const Right(testShopModel));
    });
  });

  group('deleteShop', () {
    test('should return void on success', () async {
      when(() => mockDataSource.deleteShop('shop-1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteShop('shop-1');

      expect(result, const Right(null));
    });
  });

  group('getCategories', () {
    test('should return list of categories on success', () async {
      const categories = [
        CategoryModel(id: '1', name: '네일'),
        CategoryModel(id: '2', name: '헤어'),
      ];
      when(() => mockDataSource.getCategories())
          .thenAnswer((_) async => categories);

      final result = await repository.getCategories();

      result.fold(
        (_) => fail('should be right'),
        (data) {
          expect(data.length, 2);
          expect(data[0].name, '네일');
        },
      );
    });
  });

  group('setShopCategories', () {
    test('should return void on success', () async {
      when(() => mockDataSource.setShopCategories('shop-1', ['1', '2']))
          .thenAnswer((_) async {});

      final result = await repository.setShopCategories('shop-1', ['1', '2']);

      expect(result, const Right(null));
    });
  });
}
