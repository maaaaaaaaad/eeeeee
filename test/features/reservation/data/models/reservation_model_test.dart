import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/reservation/data/models/reservation_model.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';

void main() {
  group('ReservationModel', () {
    test('should be a subclass of Reservation', () {
      final model = ReservationModel(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        reservationDate: '2024-06-15',
        startTime: '10:00',
        endTime: '11:00',
        status: ReservationStatus.pending,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(model, isA<Reservation>());
    });

    test('should parse from JSON with all fields', () {
      final json = {
        'id': 'r-1',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'treatmentId': 'treatment-1',
        'shopName': '뷰티샵',
        'treatmentName': '젤네일',
        'treatmentPrice': 30000,
        'treatmentDuration': 60,
        'memberNickname': '홍길동',
        'reservationDate': '2024-06-15',
        'startTime': '10:00',
        'endTime': '11:00',
        'status': 'PENDING',
        'memo': '메모입니다',
        'rejectionReason': null,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = ReservationModel.fromJson(json);

      expect(model.id, 'r-1');
      expect(model.shopId, 'shop-1');
      expect(model.memberId, 'member-1');
      expect(model.treatmentId, 'treatment-1');
      expect(model.shopName, '뷰티샵');
      expect(model.treatmentName, '젤네일');
      expect(model.treatmentPrice, 30000);
      expect(model.treatmentDuration, 60);
      expect(model.memberNickname, '홍길동');
      expect(model.reservationDate, '2024-06-15');
      expect(model.startTime, '10:00');
      expect(model.endTime, '11:00');
      expect(model.status, ReservationStatus.pending);
      expect(model.memo, '메모입니다');
      expect(model.rejectionReason, isNull);
      expect(model.createdAt, DateTime.utc(2024, 1, 1));
      expect(model.updatedAt, DateTime.utc(2024, 1, 1));
    });

    test('should handle null optional fields', () {
      final json = {
        'id': 'r-1',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'treatmentId': 'treatment-1',
        'shopName': null,
        'treatmentName': null,
        'treatmentPrice': null,
        'treatmentDuration': null,
        'memberNickname': null,
        'reservationDate': '2024-06-15',
        'startTime': '10:00',
        'endTime': '11:00',
        'status': 'CONFIRMED',
        'memo': null,
        'rejectionReason': null,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = ReservationModel.fromJson(json);

      expect(model.shopName, isNull);
      expect(model.treatmentName, isNull);
      expect(model.treatmentPrice, isNull);
      expect(model.treatmentDuration, isNull);
      expect(model.memberNickname, isNull);
      expect(model.memo, isNull);
      expect(model.rejectionReason, isNull);
      expect(model.status, ReservationStatus.confirmed);
    });

    test('should parse NO_SHOW status', () {
      final json = {
        'id': 'r-1',
        'shopId': 'shop-1',
        'memberId': 'member-1',
        'treatmentId': 'treatment-1',
        'reservationDate': '2024-06-15',
        'startTime': '10:00',
        'endTime': '11:00',
        'status': 'NO_SHOW',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final model = ReservationModel.fromJson(json);

      expect(model.status, ReservationStatus.noShow);
    });
  });
}
