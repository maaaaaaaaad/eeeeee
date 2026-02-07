import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';

void main() {
  group('Reservation', () {
    test('should create with all required fields', () {
      final reservation = Reservation(
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

      expect(reservation.id, 'r-1');
      expect(reservation.shopId, 'shop-1');
      expect(reservation.memberId, 'member-1');
      expect(reservation.treatmentId, 'treatment-1');
      expect(reservation.reservationDate, '2024-06-15');
      expect(reservation.startTime, '10:00');
      expect(reservation.endTime, '11:00');
      expect(reservation.status, ReservationStatus.pending);
    });

    test('should allow optional fields to be null', () {
      final reservation = Reservation(
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

      expect(reservation.shopName, isNull);
      expect(reservation.treatmentName, isNull);
      expect(reservation.treatmentPrice, isNull);
      expect(reservation.treatmentDuration, isNull);
      expect(reservation.memberNickname, isNull);
      expect(reservation.memo, isNull);
      expect(reservation.rejectionReason, isNull);
    });

    test('should create with all optional fields', () {
      final reservation = Reservation(
        id: 'r-1',
        shopId: 'shop-1',
        memberId: 'member-1',
        treatmentId: 'treatment-1',
        shopName: '뷰티샵',
        treatmentName: '젤네일',
        treatmentPrice: 30000,
        treatmentDuration: 60,
        memberNickname: '홍길동',
        reservationDate: '2024-06-15',
        startTime: '10:00',
        endTime: '11:00',
        status: ReservationStatus.confirmed,
        memo: '메모입니다',
        rejectionReason: null,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(reservation.shopName, '뷰티샵');
      expect(reservation.treatmentName, '젤네일');
      expect(reservation.treatmentPrice, 30000);
      expect(reservation.treatmentDuration, 60);
      expect(reservation.memberNickname, '홍길동');
      expect(reservation.memo, '메모입니다');
    });

    test('should support value equality by id', () {
      final a = Reservation(
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
      final b = Reservation(
        id: 'r-1',
        shopId: 'shop-2',
        memberId: 'member-2',
        treatmentId: 'treatment-2',
        reservationDate: '2024-07-15',
        startTime: '14:00',
        endTime: '15:00',
        status: ReservationStatus.confirmed,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      );
      expect(a, b);
    });

    test('should not be equal with different ids', () {
      final a = Reservation(
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
      final b = Reservation(
        id: 'r-2',
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
      expect(a, isNot(b));
    });
  });
}
