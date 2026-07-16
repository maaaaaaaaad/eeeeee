import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/designer/domain/entities/create_designer_params.dart';

void main() {
  group('CreateDesignerParams', () {
    test('should be Equatable on all fields', () {
      const paramsA = CreateDesignerParams(
        shopId: 'shop-1',
        name: '김디자이너',
        nickname: '젤리',
        intro: '경력 10년',
        photoUrls: ['https://cdn/1.jpg'],
      );
      const paramsB = CreateDesignerParams(
        shopId: 'shop-1',
        name: '김디자이너',
        nickname: '젤리',
        intro: '경력 10년',
        photoUrls: ['https://cdn/1.jpg'],
      );
      expect(paramsA, paramsB);
    });

    test('should default photoUrls to empty list', () {
      const params = CreateDesignerParams(shopId: 'shop-1', name: '김디자이너');
      expect(params.photoUrls, isEmpty);
    });
  });
}
