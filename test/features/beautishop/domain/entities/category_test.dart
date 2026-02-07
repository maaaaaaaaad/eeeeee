import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('should create with required fields', () {
      const category = Category(id: '1', name: '네일');
      expect(category.id, '1');
      expect(category.name, '네일');
    });

    test('should support value equality', () {
      const a = Category(id: '1', name: '네일');
      const b = Category(id: '1', name: '네일');
      expect(a, b);
    });

    test('should not be equal with different ids', () {
      const a = Category(id: '1', name: '네일');
      const b = Category(id: '2', name: '네일');
      expect(a, isNot(b));
    });
  });
}
