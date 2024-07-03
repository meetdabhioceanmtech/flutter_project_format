// ignore_for_file: empty_catches, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:catcher_2/core/catcher_2.dart';
import 'package:catcher_2/handlers/console_handler.dart';
import 'package:catcher_2/handlers/http_handler.dart';
import 'package:catcher_2/mode/silent_report_mode.dart';
import 'package:catcher_2/model/catcher_2_options.dart';
import 'package:catcher_2/model/http_request_type.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:oceanmtech_dmt/app_links_service.dart';
import 'package:oceanmtech_dmt/common/constants/hive_constants.dart';
import 'package:oceanmtech_dmt/common/constants/languages.dart';
import 'package:oceanmtech_dmt/data/models/general_setting_model.dart';
import 'package:oceanmtech_dmt/domain/entities/general_setting/general_setting_entity.dart';
import 'package:oceanmtech_dmt/domain/entities/user/user_entity.dart';
import 'package:oceanmtech_dmt/presentation/cubit/counter/counter_cubit.dart';
import 'package:oceanmtech_dmt/domain/entities/language/app_language/app_language_entity.dart';
import 'package:oceanmtech_dmt/firebase_options.dart';
import 'package:oceanmtech_dmt/http_overrides.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/job_search_app.dart';
import 'package:oceanmtech_dmt/presentation/new_notification_service.dart';
import 'package:oceanmtech_dmt/presentation/utils/app_constants.dart';
import 'package:oceanmtech_dmt/presentation/utils/app_functions.dart';
import 'package:oceanmtech_dmt/presentation/utils/shared_preference.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'di/get_it.dart' as get_it;

enum DeviceType { phone, tablet }

final StreamController<int> controller = StreamController<int>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
  print('>>>>>>>>>>>>>>>>>>> _firebaseMessagingBackgroundHandler');

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
    print("============Error ======= $error");
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

  await AppLinksService.init();
  await SharedPref.instance.getInstance();
  prefs = await SharedPreferences.getInstance();

  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // if (Platform.isIOS) {
  //   DartPingIOS.register();
  //   await AppFunctions().initTrackingDialog();
  // }

  // if (Platform.isAndroid) {
  //   await AndroidAlarmManager.initialize();
  // }

  // if (Platform.isAndroid) {
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  // }

  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  await PushNotificationService().setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  firebaseAnalytics = FirebaseAnalytics.instance;
  firebaseAnalytics?.setAnalyticsCollectionEnabled(true);
  if (kDebugMode) {
    firebaseAnalytics?.setAnalyticsCollectionEnabled(false);
  }

  await path_provider.getApplicationDocumentsDirectory().then(
    (dir) async {
      Hive.init(dir.path);
      Hive.registerAdapter<AppLanguageEntity>(AppLanguageEntityAdapter());
      Hive.registerAdapter<GeneralSettingEntity>(GeneralSettingEntityAdapter());
      Hive.registerAdapter<Sector>(SectorAdapter());
      Hive.registerAdapter<UserLanguage>(UserLanguageAdapter());
      Hive.registerAdapter<UserEntity>(UserEntityAdapter());
      Hive.registerAdapter<StateData>(StateDataAdapter());
      Hive.registerAdapter<CityData>(CityDataAdapter());

      jobSearchBox = await Hive.openBox(HiveBoxConstants.JOB_SEARCH_BOX).then((value) {
        isJobSearchBox = true;
        return value;
      });
      appLanBox = await Hive.openBox(HiveBoxConstants.APP_LAN_BOX).then((value) {
        isAppLanBox = true;
        return value;
      });
      currentLanBox = await Hive.openBox(HiveBoxConstants.CURRENT_LANG_BOX).then((value) {
        isCurrentLanBox = true;
        return value;
      });
      userDataBox = await Hive.openBox(HiveBoxConstants.USER_DATA_BOX).then((value) {
        isUserDataBox = true;
        return value;
      });
      generalSettingBox = await Hive.openBox(HiveBoxConstants.GENERAL_SETTING_BOX).then((value) {
        isGeneralSettingBox = true;
        return value;
      });
      appActivityAnaltics = await Hive.openBox(HiveBoxConstants.APP_ACTIVITY_ANALYTICS).then((value) {
        isAppActivityAnaltics = true;
        return value;
      });
      isFirst = await jobSearchBox.get(HiveConstants.IS_FIRST_LOAD, defaultValue: true);
      currentLangCode = await currentLanBox.get(HiveConstants.PREFERRED_LANGUAGE, defaultValue: 'en');
      userToken = await userDataBox.get(HiveConstants.USER_TOKEN, defaultValue: null);
      userFcmToken = await userDataBox.get(HiveConstants.USER_FCM_TOKEN, defaultValue: "notfound");
      deviceData = Map<String, String>.from(await jobSearchBox.get(HiveConstants.DEVICE_DATA, defaultValue: {}));
      generalSettingEntity = await generalSettingBox.get(HiveConstants.GENERAL_SETTING_DATA, defaultValue: null);
      userEntity = await userDataBox.get(HiveConstants.USER_ENTITY_DATA, defaultValue: null);
      appNotification = await appLanBox.get(HiveConstants.APP_NOTIFICATION, defaultValue: true);

      deviceData = await AppFunctions().initPlatformState();
      await saveAssetsLangToDevice();

      if (isFirst) {
        jobSearchBox.put(HiveConstants.SHARE_NUMBER, 0);
        jobSearchBox.put(HiveConstants.NAV_NUMBER, 0);
        jobSearchBox.put(HiveConstants.IS_FIRST_LOAD, false);
        languages = [AppLanguageEntity(id: 1, shortCode: 'en', title: 'English', isDefault: 1)];
        appLanBox.put(HiveConstants.APP_LANGUAGE_LIST, languages);
        currentLanBox.put(HiveConstants.PREFERRED_LANGUAGE, 'en');
      } else {
        languages = List<AppLanguageEntity>.from(
          await appLanBox.get(
            HiveConstants.APP_LANGUAGE_LIST,
            defaultValue: <AppLanguageEntity>[
              AppLanguageEntity(id: 1, shortCode: 'en', title: 'English', isDefault: 1),
            ],
          ),
        );

        if (languages.isEmpty) {
          languages = [AppLanguageEntity(id: 1, shortCode: 'en', title: 'English', isDefault: 1)];
          await appLanBox.put(HiveConstants.APP_LANGUAGE_LIST, languages);
        }

        var filterList = languages.where((element) => (element.isDefault == 1)).toList();
        String currentLang = filterList.isNotEmpty ? filterList[0].shortCode : 'en';

        currentLangCode = currentLang;

        currentLanBox.put(HiveConstants.PREFERRED_LANGUAGE, currentLangCode);
      }

      navigationCount = await jobSearchBox.get(HiveConstants.NAV_NUMBER, defaultValue: 0);
      unawaited(get_it.init());

      HttpOverrides.global = MyHttpOverrides();

      Catcher2Options releaseOptions = Catcher2Options(
        SilentReportMode(),
        [
          HttpHandler(
            HttpRequestType.post,
            Uri.parse("https://dmt.oceanmtechdmt.in/api/v7/error-log/save"),
            headers: {'Content-Type': 'application/json', "Accept": 'application/json'},
            enableCustomParameters: true,
            enableApplicationParameters: true,
            enableDeviceParameters: true,
            enableStackTrace: true,
            requestTimeout: const Duration(seconds: 3),
            responseTimeout: const Duration(seconds: 3),
          ),
        ],
        customParameters: {
          "user_id": userEntity?.id ?? "",
          'mobile_no': userEntity?.mobile.toString() ?? "",
          'token': userFcmToken ?? "",
          'datetime': DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now()).toString(),
          "error_type": "app",
          "freeDiskSpace": "",
          "totalDiskSpace": "",
          "freeRam": "",
          "totalRam": "",
          "issue_type": "App Handled Exception",
          "model_name": deviceData?["device_model"] ?? "",
          "screen_name": currentRouteName,
          "api_endpoint": "",
        },
      );

      Catcher2Options debugOptions = Catcher2Options(
        SilentReportMode(),
        [
          ConsoleHandler(
            enableStackTrace: true,
            enableApplicationParameters: false,
            enableCustomParameters: false,
            enableDeviceParameters: false,
            handleWhenRejected: false,
          )
        ],
        customParameters: {
          "user_id": userEntity?.id ?? "",
          'mobile_no': userEntity?.mobile ?? "",
          'token': userFcmToken ?? "",
          'datetime': DateFormat("dd-MM-yyyy HH:mm:ss").format(DateTime.now()).toString(),
          "error_type": "app",
          "freeDiskSpace": "",
          "totalDiskSpace": "",
          "freeRam": "",
          "totalRam": "",
          "issue_type": "App Handled Exception",
          "model_name": deviceData?["device_model"] ?? "",
          "screen_name": currentRouteName,
          "api_endpoint": "",
        },
      );

      /// Release configuration. Same as above, but once user accepts dialog, user will be prompted to send email with crash to support.5

      var catcher = Catcher2(
        rootWidget: const JobSearchApp(),
        ensureInitialized: true,
        enableLogger: true,
        debugConfig: debugOptions,
        releaseConfig: releaseOptions,
      );

      catcher.updateConfig(debugConfig: debugOptions, releaseConfig: releaseOptions);
    },
  );
}

Future<void> saveAssetsLangToDevice() async {
  languageLocalPath =
      '${(await path_provider.getApplicationDocumentsDirectory()).path}${Platform.pathSeparator}languages';

  ByteData byteData = await rootBundle.load("assets/languages/en.json");

  if (!await Directory(languageLocalPath).exists()) {
    await Directory(languageLocalPath).create();
  }
  File file = await File('$languageLocalPath/en.json').create(recursive: true);
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
}
