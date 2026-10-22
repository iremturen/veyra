import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:veyra/app/app.dart';
import 'package:veyra/firebase_options.dart';
import 'package:veyra/data/services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return true;
  };

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  runApp(const VeyraApp());
  unawaited(_initializeFirebaseMessaging());
}

Future<void> _initializeFirebaseMessaging() async {
  try {
    await FirebaseMessagingService.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint('FCM initialization failed: $error');
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'FCM initialization failed',
    );
  }
}
