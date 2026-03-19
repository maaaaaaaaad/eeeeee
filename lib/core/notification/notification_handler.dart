import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_owner/core/notification/local_notification_service.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_detail_by_id_page.dart';

class NotificationHandler {
  final GlobalKey<NavigatorState> navigatorKey;
  final LocalNotificationService? _localNotificationService;
  final VoidCallback? _onReservationNotification;

  NotificationHandler({
    required this.navigatorKey,
    LocalNotificationService? localNotificationService,
    VoidCallback? onReservationNotification,
  })  : _localNotificationService = localNotificationService,
        _onReservationNotification = onReservationNotification;

  static const _reservationTypes = {
    'RESERVATION_CREATED',
    'RESERVATION_CANCELLED',
    'UNPROCESSED_RESERVATION_REMINDER',
  };

  void handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}, type=${message.data['type']}');
    final notification = message.notification;
    if (notification == null) {
      debugPrint('Notification payload is null, skipping');
      return;
    }

    final payload = buildPayload(message.data);
    _localNotificationService?.show(
      id: message.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: payload,
    );

    final type = message.data['type'] as String?;
    if (isReservationNotification(type)) {
      _onReservationNotification?.call();
    }
  }

  void handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (isReservationNotification(type)) {
      _onReservationNotification?.call();

      final reservationId = data['reservationId'] as String?;
      if (reservationId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReservationDetailByIdPage(reservationId: reservationId),
          ),
        );
      }
    }
  }

  void handleNotificationResponsePayload(String? payload) {
    final data = parsePayload(payload);
    if (data.isNotEmpty) {
      handleNotificationTap(data);
    }
  }

  Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      handleNotificationTap(message.data);
    }
  }

  static bool isReservationNotification(String? type) {
    return type != null && _reservationTypes.contains(type);
  }

  static String buildPayload(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> parsePayload(String? payload) {
    if (payload == null) return {};
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }
}
