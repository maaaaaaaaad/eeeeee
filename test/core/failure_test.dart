import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/core/error/failure.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should contain message', () {
      const failure = ServerFailure('Server error occurred');

      expect(failure.message, equals('Server error occurred'));
    });

    test('NetworkFailure should contain message', () {
      const failure = NetworkFailure('No internet connection');

      expect(failure.message, equals('No internet connection'));
    });

    test('AuthFailure should contain message', () {
      const failure = AuthFailure('Unauthorized');

      expect(failure.message, equals('Unauthorized'));
    });

    test('CacheFailure should contain message', () {
      const failure = CacheFailure('Cache read failed');

      expect(failure.message, equals('Cache read failed'));
    });

    test('NoTokenFailure should have default message', () {
      const failure = NoTokenFailure();

      expect(failure.message, equals('저장된 토큰이 없습니다'));
    });

    test('ValidationFailure should contain message', () {
      const failure = ValidationFailure('Invalid input');

      expect(failure.message, equals('Invalid input'));
    });
  });
}
