import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_owner/core/notification/notification_handler.dart';

void main() {
  group('NotificationHandler', () {
    group('parsePayload', () {
      test('returns empty map for null payload', () {
        final result = NotificationHandler.parsePayload(null);
        expect(result, isEmpty);
      });

      test('returns empty map for invalid JSON', () {
        final result = NotificationHandler.parsePayload('not json');
        expect(result, isEmpty);
      });

      test('parses valid JSON payload', () {
        final payload = jsonEncode({
          'type': 'RESERVATION_CREATED',
          'reservationId': 'abc-123',
        });
        final result = NotificationHandler.parsePayload(payload);
        expect(result['type'], 'RESERVATION_CREATED');
        expect(result['reservationId'], 'abc-123');
      });
    });

    group('buildPayload', () {
      test('encodes data map with type and reservationId', () {
        final data = {
          'type': 'RESERVATION_CREATED',
          'reservationId': 'abc',
        };
        final payload = NotificationHandler.buildPayload(data);
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        expect(decoded['type'], 'RESERVATION_CREATED');
        expect(decoded['reservationId'], 'abc');
      });
    });

    group('isReservationNotification', () {
      test('returns true for RESERVATION_CREATED', () {
        expect(
          NotificationHandler.isReservationNotification('RESERVATION_CREATED'),
          isTrue,
        );
      });

      test('returns true for RESERVATION_CANCELLED', () {
        expect(
          NotificationHandler.isReservationNotification('RESERVATION_CANCELLED'),
          isTrue,
        );
      });

      test('returns true for UNPROCESSED_RESERVATION_REMINDER', () {
        expect(
          NotificationHandler.isReservationNotification(
              'UNPROCESSED_RESERVATION_REMINDER'),
          isTrue,
        );
      });

      test('returns false for RESERVATION_CONFIRMED', () {
        expect(
          NotificationHandler.isReservationNotification('RESERVATION_CONFIRMED'),
          isFalse,
        );
      });

      test('returns false for unknown type', () {
        expect(
          NotificationHandler.isReservationNotification('UNKNOWN'),
          isFalse,
        );
      });

      test('returns false for null type', () {
        expect(
          NotificationHandler.isReservationNotification(null),
          isFalse,
        );
      });
    });
  });
}
