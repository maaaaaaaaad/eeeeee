import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/operating_hours_display.dart';

void main() {
  group('OperatingHoursDisplay', () {
    testWidgets('should show "영업시간 정보 없음" when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperatingHoursDisplay(operatingTime: {}),
          ),
        ),
      );

      expect(find.text('영업시간 정보 없음'), findsOneWidget);
    });

    testWidgets('should display days with hours', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OperatingHoursDisplay(
              operatingTime: {
                'MONDAY': '09:00-18:00',
                'FRIDAY': '10:00-20:00',
              },
            ),
          ),
        ),
      );

      expect(find.text('09:00-18:00'), findsOneWidget);
      expect(find.text('10:00-20:00'), findsOneWidget);
      expect(find.text('휴무'), findsNWidgets(5));
    });
  });
}
