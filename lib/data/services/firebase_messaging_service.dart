import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/firebase_options.dart';

const String _importantChannelId = 'veyra_important_alerts';

const AndroidNotificationChannel _importantChannel = AndroidNotificationChannel(
  _importantChannelId,
  AppStrings.notificationChannelName,
  description: AppStrings.notificationChannelDescription,
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    'FCM background message received: ${message.messageId ?? 'no message id'}',
  );
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _registrationSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return;
    }
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_importantChannel);

    // Foreground notifications are displayed by flutter_local_notifications.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _messageSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
      onError: (Object error) =>
          debugPrint('FCM foreground stream error: $error'),
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteNotificationTap,
      onError: (Object error) => debugPrint('FCM tap stream error: $error'),
    );

    await _requestPermission();
    await _registerForDevelopment();

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleRemoteNotificationTap(initialMessage);

    final localLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (localLaunchDetails?.didNotificationLaunchApp == true) {
      _handleLocalNotificationPayload(
        localLaunchDetails?.notificationResponse?.payload,
      );
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint(
        'FCM notification permission: ${settings.authorizationStatus}',
      );
    } on FirebaseException catch (error) {
      debugPrint(
        'FCM permission request failed (${error.code}): ${error.message}',
      );
    } catch (error) {
      debugPrint('FCM permission request failed: $error');
    }
  }

  Future<void> _registerForDevelopment() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint(
            'FCM registration skipped because the APNs token is unavailable. '
            'Enable Push Notifications and configure APNs for iOS delivery.',
          );
          return;
        }
      }

      // Subscribe before registering so the initial Firebase Installation ID
      // event is not missed. Firebase Console accepts this ID for test sends.
      _registrationSubscription = _messaging.onRegistered.listen((
        installationId,
      ) {
        if (kDebugMode) {
          debugPrint(
            'Firebase Installation ID (debug/testing only): $installationId',
          );
        }
      });
      await _messaging.register();
    } on FirebaseException catch (error) {
      debugPrint('FCM registration failed (${error.code}): ${error.message}');
    } catch (error) {
      debugPrint('FCM registration failed: $error');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? _messageText(message.data['title']);
    final body =
        message.notification?.body ?? _messageText(message.data['body']);
    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      return;
    }

    try {
      await _localNotifications.show(
        id:
            (message.messageId?.hashCode ??
                DateTime.now().millisecondsSinceEpoch) &
            0x7fffffff,
        title: title ?? AppStrings.appName,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _importantChannelId,
            AppStrings.notificationChannelName,
            channelDescription: AppStrings.notificationChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.messageId,
      );
    } catch (error) {
      debugPrint('Foreground local notification failed: $error');
    }
  }

  String? _messageText(Object? value) => value is String ? value : null;

  void _handleRemoteNotificationTap(RemoteMessage message) {
    debugPrint(
      'FCM notification opened: ${message.messageId ?? 'no message id'}; '
      'data keys: ${message.data.keys.join(', ')}',
    );
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    _handleLocalNotificationPayload(response.payload);
  }

  void _handleLocalNotificationPayload(String? payload) {
    debugPrint('Local notification opened: ${payload ?? 'no payload'}');
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _registrationSubscription?.cancel();
    _initialized = false;
  }
}
