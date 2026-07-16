import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/designer/domain/entities/update_designer_params.dart';

void main() {
  group('UpdateDesignerParams', () {
    test('should be Equatable', () {
      const paramsA = UpdateDesignerParams(
        designerId: 'd-1',
        shopId: 'shop-1',
        name: '김디자이너',
      );
      const paramsB = UpdateDesignerParams(
        designerId: 'd-1',
        shopId: 'shop-1',
        name: '김디자이너',
      );
      expect(paramsA, paramsB);
    });

    test('should allow all optional fields to be null', () {
      const params = UpdateDesignerParams(
        designerId: 'd-1',
        shopId: 'shop-1',
      );
      expect(params.name, isNull);
      expect(params.nickname, isNull);
      expect(params.intro, isNull);
      expect(params.photoUrls, isNull);
    });
  });
}
