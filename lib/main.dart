import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:catcher_2/core/catcher_2.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/catcher_manage.dart';
import 'package:flutter_project/setup_hive.dart';
import 'package:flutter_project/app_links_service.dart';
import 'package:flutter_project/presentation/cubit/counter/counter_cubit.dart';
import 'package:flutter_project/firebase_options.dart';
import 'package:flutter_project/http_overrides.dart';
import 'package:flutter_project/presentation/globals.dart';
import 'package:flutter_project/start_app.dart';
import 'package:flutter_project/presentation/new_notification_service.dart';
import 'package:flutter_project/presentation/utils/app_constants.dart';
import 'package:flutter_project/presentation/utils/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'di/get_it.dart' as get_it;

enum DeviceType { phone, tablet }

final StreamController<int> controller = StreamController<int>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  debugPrint('>> _firebaseMessagingBackgroundHandler');

  try {
    badgeCounterCubit = CounterCubit();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await PushNotificationService().registerNotificationListeners();
    if (message?.data.containsKey("af-uinstall-tracking") ?? false) {
      return;
    } else {
      if (Platform.isAndroid) {
        setNotificationData(data: message);
      } else {
        PushNotificationService().sendLocalNotification(message: message);
      }

      // Restart.restartApp();
    }
  } catch (error) {
    debugPrint("== Error == $error");
  }
}

@pragma('vm:entry-point')
void computeIsolate(Message message) {
  final StreamController controller = StreamController.broadcast();

  Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      controller.add([message.oldDuration + timer.tick, message.message]);
    },
  );

  controller.stream.listen((event) {
    message.sendPort.send(event);
  });
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await mainFunction();
}

Future<void> mainFunction() async {
  WidgetsFlutterBinding.ensureInitialized();
  appConstants = AppConstants();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await AppLinksService.init();
  await SharedPref.instance.getInstance();
  prefs = await SharedPreferences.getInstance();

  if (kReleaseMode) {
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await _setupSSLCert();
  await _setupNotifications();
  await SetupHive().setupHiveBoxes();
  await SetupHive().loadLanguages();
  unawaited(get_it.init());

  HttpOverrides.global = MyHttpOverrides();
  _initializeCatcher();
}

Future<void> _setupSSLCert() async {
  final data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
}

Future<void> _setupNotifications() async {
  await PushNotificationService().setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  firebaseAnalytics = FirebaseAnalytics.instance;
  firebaseAnalytics?.setAnalyticsCollectionEnabled(!kDebugMode);
}

void _initializeCatcher() {
  final catcherManage = CatcherManage();

  debugPrint('>> DebugOptions : ${catcherManage.debugOptions.customParameters}');
  log('>> ReleaseOptions : ${catcherManage.releaseOptions.onFlutterError}');

  Catcher2(
    rootWidget: const StartApp(),
    ensureInitialized: true,
    enableLogger: true,
    // debugConfig: catcherManage.debugOptions, // Error Handle
    // releaseConfig: catcherManage.releaseOptions, // Error Handle
  );

  // FlutterNativeSplash.remove();
}
