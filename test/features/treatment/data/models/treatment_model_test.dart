import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/data/models/treatment_model.dart';
import 'package:mobile_owner/features/treatment/domain/entities/treatment.dart';

void main() {
  group('TreatmentModel', () {
    test('should be a subclass of Treatment', () {
      final model = TreatmentModel(
        id: 't-1',
        shopId: 'shop-1',
        name: '젤네일',
        price: 30000,
        duration: 60,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(model, isA<Treatment>());
    });

    test('should parse from JSON correctly', () {
      final json = {
        'id': 't-1',
        'shopId': 'shop-1',
        'name': '젤네일',
        'price': 30000,
        'duration': 60,
        'description': '기본 젤네일',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = TreatmentModel.fromJson(json);

      expect(model.id, 't-1');
      expect(model.shopId, 'shop-1');
      expect(model.name, '젤네일');
      expect(model.price, 30000);
      expect(model.duration, 60);
      expect(model.description, '기본 젤네일');
      expect(model.createdAt, DateTime.utc(2024, 1, 1));
      expect(model.updatedAt, DateTime.utc(2024, 1, 1));
    });

    test('should handle null description', () {
      final json = {
        'id': 't-1',
        'shopId': 'shop-1',
        'name': '젤네일',
        'price': 30000,
        'duration': 60,
        'description': null,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = TreatmentModel.fromJson(json);

      expect(model.description, isNull);
    });
  });
}
