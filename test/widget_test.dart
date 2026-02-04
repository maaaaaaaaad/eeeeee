import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/app.dart';

void main() {
  testWidgets('OwnerApp renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OwnerApp()),
    );

    expect(find.text('젤로마크 사장님 앱'), findsOneWidget);
  });
}
