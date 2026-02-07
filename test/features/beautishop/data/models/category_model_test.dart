import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/data/models/category_model.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    test('should be a subclass of Category', () {
      const model = CategoryModel(id: '1', name: '네일');
      expect(model, isA<Category>());
    });

    test('should parse from JSON correctly', () {
      final json = {'id': '1', 'name': '네일'};
      final model = CategoryModel.fromJson(json);

      expect(model.id, '1');
      expect(model.name, '네일');
    });

    test('should convert to JSON correctly', () {
      const model = CategoryModel(id: '1', name: '네일');
      final json = model.toJson();

      expect(json['id'], '1');
      expect(json['name'], '네일');
    });
  });
}
