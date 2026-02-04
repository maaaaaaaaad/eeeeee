import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/auth/domain/entities/owner.dart';

void main() {
  group('Owner', () {
    test('should create Owner with all properties', () {
      final owner = Owner(
        id: '123e4567-e89b-12d3-a456-426614174000',
        businessNumber: '123-45-67890',
        phoneNumber: '010-1234-5678',
        nickname: '테스트사장님',
        email: 'owner@test.com',
      );

      expect(owner.id, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(owner.businessNumber, equals('123-45-67890'));
      expect(owner.phoneNumber, equals('010-1234-5678'));
      expect(owner.nickname, equals('테스트사장님'));
      expect(owner.email, equals('owner@test.com'));
    });

    test('should be equal when id is same', () {
      final owner1 = Owner(
        id: '123e4567-e89b-12d3-a456-426614174000',
        businessNumber: '123-45-67890',
        phoneNumber: '010-1234-5678',
        nickname: '사장님1',
        email: 'owner1@test.com',
      );

      final owner2 = Owner(
        id: '123e4567-e89b-12d3-a456-426614174000',
        businessNumber: '123-45-67890',
        phoneNumber: '010-1234-5678',
        nickname: '사장님1',
        email: 'owner1@test.com',
      );

      expect(owner1, equals(owner2));
    });

    test('should not be equal when id is different', () {
      final owner1 = Owner(
        id: '123e4567-e89b-12d3-a456-426614174000',
        businessNumber: '123-45-67890',
        phoneNumber: '010-1234-5678',
        nickname: '사장님1',
        email: 'owner1@test.com',
      );

      final owner2 = Owner(
        id: '123e4567-e89b-12d3-a456-426614174001',
        businessNumber: '123-45-67890',
        phoneNumber: '010-1234-5678',
        nickname: '사장님1',
        email: 'owner1@test.com',
      );

      expect(owner1, isNot(equals(owner2)));
    });
  });
}
