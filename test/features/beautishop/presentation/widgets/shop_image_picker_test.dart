import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/presentation/widgets/shop_image_picker.dart';

void main() {
  group('ShopImagePicker', () {
    testWidgets(
      'keeps its state alive when scrolled out of a lazy list and back',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ShopImagePicker(
                    onChanged: (_) {},
                    onUpload: (File file) async => 'https://example.com/x.jpg',
                  ),
                  const SizedBox(height: 3000),
                ],
              ),
            ),
          ),
        );

        final stateBefore = tester.state(find.byType(ShopImagePicker));
        expect(stateBefore, isA<AutomaticKeepAliveClientMixin>());

        await tester.drag(find.byType(ListView).first, const Offset(0, -2800));
        await tester.pump();
        await tester.drag(find.byType(ListView).first, const Offset(0, 2800));
        await tester.pump();

        final stateAfter = tester.state(find.byType(ShopImagePicker));
        expect(identical(stateBefore, stateAfter), isTrue);
      },
    );

    testWidgets('renders the add button when below the image limit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopImagePicker(
              maxImages: 3,
              onChanged: (_) {},
              onUpload: (File file) async => 'https://example.com/x.jpg',
            ),
          ),
        ),
      );

      expect(find.text('사진 추가'), findsOneWidget);
    });
  });
}
