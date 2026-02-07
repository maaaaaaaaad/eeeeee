import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/reservation/presentation/widgets/reject_reservation_dialog.dart';

void main() {
  group('RejectReservationDialog', () {
    testWidgets('should display title and text field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RejectReservationDialog(),
          ),
        ),
      );

      expect(find.text('예약 거절'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should disable confirm button when reason is empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => RejectReservationDialog.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final confirmButton = find.text('거절하기');
      expect(confirmButton, findsOneWidget);
    });

    testWidgets('should return reason when confirmed', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await RejectReservationDialog.show(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '일정이 맞지 않습니다');
      await tester.pumpAndSettle();

      await tester.tap(find.text('거절하기'));
      await tester.pumpAndSettle();

      expect(result, '일정이 맞지 않습니다');
    });

    testWidgets('should return null when cancelled', (tester) async {
      String? result = 'initial';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await RejectReservationDialog.show(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
