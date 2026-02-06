import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/core/error/failure.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';
import 'package:mobile_owner/features/home/domain/entities/beauty_shop.dart';
import 'package:mobile_owner/features/home/domain/repositories/home_repository.dart';
import 'package:mobile_owner/features/home/domain/usecases/get_my_shops_usecase.dart';

class MockHomeRepository implements HomeRepository {
  Either<Failure, List<BeautyShop>>? shopsResult;

  @override
  Future<Either<Failure, List<BeautyShop>>> getMyShops() async {
    return shopsResult!;
  }

  @override
  Future<Either<Failure, Owner>> getMyProfile() async {
    throw UnimplementedError();
  }
}

void main() {
  late GetMyShopsUseCase useCase;
  late MockHomeRepository repository;

  setUp(() {
    repository = MockHomeRepository();
    useCase = GetMyShopsUseCase(repository);
  });

  test('should return list of beauty shops on success', () async {
    const shops = [
      BeautyShop(
        id: '1',
        name: 'Shop A',
        regNum: '111-11-11111',
        phoneNumber: '010-1111-1111',
        address: 'Seoul',
        latitude: 37.0,
        longitude: 127.0,
        operatingTime: {},
        images: [],
        averageRating: 4.0,
        reviewCount: 10,
        categories: [],
      ),
    ];
    repository.shopsResult = const Right(shops);

    final result = await useCase(NoParams());

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (data) {
        expect(data.length, 1);
        expect(data[0].name, 'Shop A');
      },
    );
  });

  test('should return failure when repository fails', () async {
    repository.shopsResult = const Left(ServerFailure('서버 오류'));

    final result = await useCase(NoParams());

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, '서버 오류'),
      (_) => fail('Expected Left'),
    );
  });
}
