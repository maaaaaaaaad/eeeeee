import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/core/notification/fcm_service.dart';
import 'package:mobile_owner/core/notification/local_notification_service.dart';
import 'package:mobile_owner/core/notification/navigator_key.dart';
import 'package:mobile_owner/core/notification/notification_handler.dart';
import 'package:mobile_owner/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile_owner/features/notification/data/datasources/device_token_remote_datasource.dart';
import 'package:mobile_owner/features/notification/data/repositories/device_token_repository_impl.dart';
import 'package:mobile_owner/features/notification/domain/repositories/device_token_repository.dart';

final deviceTokenRemoteDataSourceProvider =
    Provider<DeviceTokenRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DeviceTokenRemoteDataSourceImpl(apiClient: apiClient);
});

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>((ref) {
  final remoteDataSource = ref.watch(deviceTokenRemoteDataSourceProvider);
  return DeviceTokenRepositoryImpl(remoteDataSource: remoteDataSource);
});

final reservationRefreshCallbackProvider =
    StateProvider<VoidCallback?>((ref) => null);

final localNotificationServiceProvider =
    Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  final repository = ref.watch(deviceTokenRepositoryProvider);
  final localNotificationService =
      ref.read(localNotificationServiceProvider);
  final refreshCallback = ref.read(reservationRefreshCallbackProvider);

  final handler = NotificationHandler(
    navigatorKey: navigatorKey,
    localNotificationService: localNotificationService,
    onReservationNotification: refreshCallback,
  );

  localNotificationService.setOnNotificationTap(
    handler.handleNotificationResponsePayload,
  );

  return FcmService(
    messaging: FirebaseMessaging.instance,
    deviceTokenRepository: repository,
    notificationHandler: handler,
  );
});

final notificationInitProvider = FutureProvider<void>((ref) async {
  final fcmService = ref.read(fcmServiceProvider);
  await fcmService.initialize();
});
