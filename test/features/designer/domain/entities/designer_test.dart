import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';

void main() {
  group('Designer', () {
    test('should be Equatable by id only', () {
      final designerA = Designer(
        id: 'd-1',
        shopId: 'shop-1',
        name: '김디자이너',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final designerB = Designer(
        id: 'd-1',
        shopId: 'shop-2',
        name: '다른이름',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(designerA, designerB);
    });

    test('should default photoUrls to empty list', () {
      final designer = Designer(
        id: 'd-1',
        shopId: 'shop-1',
        name: '김디자이너',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(designer.photoUrls, isEmpty);
    });
  });
}
