import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/core/usecase/usecase.dart';

class TestUseCase extends UseCase<String, TestParams> {
  @override
  Future<String> call(TestParams params) async {
    return 'Result: ${params.value}';
  }
}

class TestParams {
  final String value;
  TestParams(this.value);
}

class NoParamsUseCase extends UseCase<int, NoParams> {
  @override
  Future<int> call(NoParams params) async {
    return 42;
  }
}

void main() {
  group('UseCase', () {
    test('should execute with params and return result', () async {
      final useCase = TestUseCase();
      final result = await useCase(TestParams('test'));

      expect(result, equals('Result: test'));
    });

    test('should execute with NoParams', () async {
      final useCase = NoParamsUseCase();
      final result = await useCase(NoParams());

      expect(result, equals(42));
    });
  });
}
