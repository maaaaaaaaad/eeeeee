import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    expect(find.text('젤로마크 사장님'), findsOneWidget);
    expect(find.text('사장님 전용 앱에 로그인하세요'), findsOneWidget);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('회원가입'), findsOneWidget);
  });
}
