import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reject_reservation_params.dart';

void main() {
  group('RejectReservationParams', () {
    test('should create with required fields', () {
      const params = RejectReservationParams(
        reservationId: 'r-1',
        rejectionReason: '일정이 맞지 않습니다',
      );

      expect(params.reservationId, 'r-1');
      expect(params.rejectionReason, '일정이 맞지 않습니다');
    });

    test('should support value equality', () {
      const a = RejectReservationParams(
        reservationId: 'r-1',
        rejectionReason: '사유',
      );
      const b = RejectReservationParams(
        reservationId: 'r-1',
        rejectionReason: '사유',
      );
      expect(a, b);
    });

    test('should not be equal with different values', () {
      const a = RejectReservationParams(
        reservationId: 'r-1',
        rejectionReason: '사유1',
      );
      const b = RejectReservationParams(
        reservationId: 'r-1',
        rejectionReason: '사유2',
      );
      expect(a, isNot(b));
    });
  });
}
