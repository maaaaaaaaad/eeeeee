import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/designer/data/models/update_designer_request.dart';

void main() {
  group('UpdateDesignerRequest', () {
    test('should convert to JSON with all fields', () {
      const request = UpdateDesignerRequest(
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

    test('should keep all fields null when omitted', () {
      const request = UpdateDesignerRequest();
      final json = request.toJson();
      expect(json['name'], isNull);
      expect(json['nickname'], isNull);
      expect(json['intro'], isNull);
      expect(json['photoUrls'], isNull);
    });
  });
}
