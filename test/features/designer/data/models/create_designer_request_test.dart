import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/designer/data/models/create_designer_request.dart';

void main() {
  group('CreateDesignerRequest', () {
    test('should convert to JSON with all fields', () {
      const request = CreateDesignerRequest(
        name: '김디자이너',
        nickname: '젤리',
        intro: '경력 10년',
        photoUrls: ['https://cdn/1.jpg'],
      );

      final json = request.toJson();

      expect(json['name'], '김디자이너');
      expect(json['nickname'], '젤리');
      expect(json['intro'], '경력 10년');
      expect(json['photoUrls'], ['https://cdn/1.jpg']);
    });

    test('should keep optional fields null in JSON', () {
      const request = CreateDesignerRequest(name: '김디자이너');

      final json = request.toJson();

      expect(json['name'], '김디자이너');
      expect(json['nickname'], isNull);
      expect(json['intro'], isNull);
      expect(json['photoUrls'], isNull);
    });
  });
}
