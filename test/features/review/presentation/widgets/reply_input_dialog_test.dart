import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/review/presentation/widgets/reply_input_dialog.dart';

void main() {
  group('ReplyInputDialog', () {
    testWidgets('should show "답글 작성" title when no initial content',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReplyInputDialog()),
        ),
      );

      expect(find.text('답글 작성'), findsOneWidget);
      expect(find.text('등록'), findsOneWidget);
    });

    testWidgets('should show "답글 수정" title when initial content provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReplyInputDialog(initialContent: '기존 답글')),
        ),
      );

      expect(find.text('답글 수정'), findsOneWidget);
      expect(find.text('수정'), findsOneWidget);
    });

    testWidgets('should pre-fill text field with initial content',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReplyInputDialog(initialContent: '기존 답글')),
        ),
      );

      expect(find.text('기존 답글'), findsOneWidget);
    });

    testWidgets('should disable submit button when text is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReplyInputDialog()),
        ),
      );

      final submitButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '등록'),
      );
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('should enable submit button when text is entered',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReplyInputDialog()),
        ),
      );

      await tester.enterText(find.byType(TextField), '감사합니다!');
      await tester.pump();

      final submitButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '등록'),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets('should show max length counter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReplyInputDialog()),
        ),
      );

      expect(find.text('0/500'), findsOneWidget);
    });

    testWidgets('should close on cancel', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (_) => const ReplyInputDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('should return trimmed content on submit', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (_) => const ReplyInputDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  감사합니다!  ');
      await tester.pump();

      await tester.tap(find.text('등록'));
      await tester.pumpAndSettle();

      expect(result, '감사합니다!');
    });
  });
}
