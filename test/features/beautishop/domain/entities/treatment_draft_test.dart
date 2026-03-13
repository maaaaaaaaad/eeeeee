import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/beautishop/domain/entities/treatment_draft.dart';

void main() {
  group('TreatmentDraft', () {
    test('should create with required fields', () {
      const draft = TreatmentDraft(
        name: '커트',
        price: 15000,
        duration: 30,
      );

      expect(draft.name, '커트');
      expect(draft.price, 15000);
      expect(draft.duration, 30);
      expect(draft.description, isNull);
    });

    test('should create with all fields', () {
      const draft = TreatmentDraft(
        name: '염색',
        price: 80000,
        duration: 120,
        description: '전체 염색',
      );

      expect(draft.name, '염색');
      expect(draft.price, 80000);
      expect(draft.duration, 120);
      expect(draft.description, '전체 염색');
    });

    test('should support value equality', () {
      const draft1 = TreatmentDraft(name: '커트', price: 15000, duration: 30);
      const draft2 = TreatmentDraft(name: '커트', price: 15000, duration: 30);
      const draft3 = TreatmentDraft(name: '펌', price: 15000, duration: 30);

      expect(draft1, equals(draft2));
      expect(draft1, isNot(equals(draft3)));
    });

    test('should copyWith correctly', () {
      const original = TreatmentDraft(
        name: '커트',
        price: 15000,
        duration: 30,
        description: '남성 커트',
      );

      final updated = original.copyWith(price: 20000);

      expect(updated.name, '커트');
      expect(updated.price, 20000);
      expect(updated.duration, 30);
      expect(updated.description, '남성 커트');
    });

    test('should copyWith description to null', () {
      const original = TreatmentDraft(
        name: '커트',
        price: 15000,
        duration: 30,
        description: '남성 커트',
      );

      final updated = original.copyWith(description: () => null);

      expect(updated.description, isNull);
    });
  });
}
