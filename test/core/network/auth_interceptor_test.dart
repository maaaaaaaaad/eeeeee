import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/core/network/auth_interceptor.dart';

void main() {
  group('AuthInterceptor.prepareRetryData', () {
    test('clones already-consumed FormData so the retry body is re-readable',
        () {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes([1, 2, 3, 4], filename: 'menu.jpg'),
      });
      formData.finalize();

      final options = RequestOptions(path: '/api/images/upload', data: formData);

      AuthInterceptor.prepareRetryData(options);

      expect(options.data, isNot(same(formData)));
      expect(() => (options.data as FormData).finalize(), returnsNormally);
    });

    test('leaves non-FormData payloads untouched', () {
      final body = {'refreshToken': 'abc'};
      final options = RequestOptions(path: '/api/auth/refresh', data: body);

      AuthInterceptor.prepareRetryData(options);

      expect(options.data, same(body));
    });

    test('tolerates null payloads', () {
      final options = RequestOptions(path: '/api/members/me');

      expect(() => AuthInterceptor.prepareRetryData(options), returnsNormally);
      expect(options.data, isNull);
    });
  });
}
