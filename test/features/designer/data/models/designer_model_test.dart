import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/designer/data/models/designer_model.dart';
import 'package:mobile_owner/features/designer/domain/entities/designer.dart';

void main() {
  group('DesignerModel', () {
    test('should be a subclass of Designer', () {
      final model = DesignerModel(
        id: 'd-1',
        shopId: 'shop-1',
        name: '김디자이너',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(model, isA<Designer>());
    });

    test('should parse from JSON correctly', () {
      final json = {
        'id': 'd-1',
        'shopId': 'shop-1',
        'name': '김디자이너',
        'nickname': '젤리',
        'intro': '경력 10년',
        'photoUrls': ['https://cdn/1.jpg', 'https://cdn/2.jpg'],
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = DesignerModel.fromJson(json);

      expect(model.id, 'd-1');
      expect(model.shopId, 'shop-1');
      expect(model.name, '김디자이너');
      expect(model.nickname, '젤리');
      expect(model.intro, '경력 10년');
      expect(model.photoUrls.length, 2);
      expect(model.photoUrls[0], 'https://cdn/1.jpg');
      expect(model.createdAt, DateTime.utc(2024, 1, 1));
    });

    test('should handle null optional fields', () {
      final json = {
        'id': 'd-1',
        'shopId': 'shop-1',
        'name': '김디자이너',
        'nickname': null,
        'intro': null,
        'photoUrls': null,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = DesignerModel.fromJson(json);

      expect(model.nickname, isNull);
      expect(model.intro, isNull);
      expect(model.photoUrls, isEmpty);
    });

    test('should serialize to JSON', () {
      final model = DesignerModel(
        id: 'd-1',
        shopId: 'shop-1',
        name: '김디자이너',
        nickname: '젤리',
        intro: '경력 10년',
        photoUrls: const ['https://cdn/1.jpg'],
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      final json = model.toJson();

      expect(json['id'], 'd-1');
      expect(json['shopId'], 'shop-1');
      expect(json['name'], '김디자이너');
      expect(json['nickname'], '젤리');
      expect(json['intro'], '경력 10년');
      expect(json['photoUrls'], ['https://cdn/1.jpg']);
    });
  });
}
