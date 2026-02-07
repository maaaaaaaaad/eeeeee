import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/reservation/data/models/reject_reservation_request.dart';

void main() {
  group('RejectReservationRequest', () {
    test('should create with rejectionReason', () {
      const request = RejectReservationRequest(
        rejectionReason: '일정이 맞지 않습니다',
      );

      expect(request.rejectionReason, '일정이 맞지 않습니다');
    });

    test('should convert to JSON correctly', () {
      const request = RejectReservationRequest(
        rejectionReason: '일정이 맞지 않습니다',
      );

      final json = request.toJson();

      expect(json, {'rejectionReason': '일정이 맞지 않습니다'});
    });
  });
}
