import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/treatment/presentation/widgets/delete_treatment_dialog.dart';

void main() {
  group('DeleteTreatmentDialog', () {
    testWidgets('should display treatment name and warning', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteTreatmentDialog(treatmentName: '젤네일'),
          ),
        ),
      );

      expect(find.text('시술 삭제'), findsOneWidget);
      expect(find.textContaining('젤네일'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('삭제'), findsOneWidget);
    });

    testWidgets('should return false when cancel tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await DeleteTreatmentDialog.show(
                    context,
                    treatmentName: '젤네일',
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('should return true when delete tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await DeleteTreatmentDialog.show(
                    context,
                    treatmentName: '젤네일',
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(result, true);
    });
  });
}
