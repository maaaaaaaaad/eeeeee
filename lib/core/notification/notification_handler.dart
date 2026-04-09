import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_owner/core/notification/local_notification_service.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_detail_by_id_page.dart';
import 'package:mobile_owner/features/review/presentation/pages/review_list_page.dart';

class NotificationHandler {
  final GlobalKey<NavigatorState> navigatorKey;
  final LocalNotificationService? _localNotificationService;
  final VoidCallback? _onReservationNotification;
  final VoidCallback? _onReviewNotification;

  NotificationHandler({
    required this.navigatorKey,
    LocalNotificationService? localNotificationService,
    VoidCallback? onReservationNotification,
    VoidCallback? onReviewNotification,
  })  : _localNotificationService = localNotificationService,
        _onReservationNotification = onReservationNotification,
        _onReviewNotification = onReviewNotification;

  static const _reservationTypes = {
    'RESERVATION_CREATED',
    'RESERVATION_CANCELLED',
    'UNPROCESSED_RESERVATION_REMINDER',
  };

  static const _reviewTypes = {
    'NEW_REVIEW',
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
    if (isReviewNotification(type)) {
      _onReviewNotification?.call();
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
    if (isReviewNotification(type)) {
      _onReviewNotification?.call();

      final shopId = data['shopId'] as String?;
      if (shopId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReviewListPage(
              shopId: shopId,
              averageRating: 0,
              reviewCount: 0,
            ),
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

  static bool isReviewNotification(String? type) {
    return type != null && _reviewTypes.contains(type);
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
