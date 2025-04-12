import 'dart:developer';
import 'dart:io';
import 'package:catcher_2/core/catcher_2.dart';
import 'package:catcher_2/utils/catcher_2_error_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_project/presentation/cubit/general_setting_cubit/general_setting_cubit.dart';
import 'package:flutter_project/presentation/network_connection.dart';
import 'package:flutter_project/presentation/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:flutter_project/presentation/cubit/counter/counter_cubit.dart';
import 'package:flutter_project/presentation/cubit/language/language_cubit.dart';
import 'package:flutter_project/presentation/cubit/loading/loading_cubit.dart';
import 'package:flutter_project/presentation/cubit/notification/selected_notification/selected_notification_cubit.dart';
import 'package:flutter_project/presentation/cubit/theme/theme_cubit.dart';
import 'package:flutter_project/presentation/cubit/toggle_cubit/toggle_cubit.dart';
import 'package:flutter_project/common/constants/languages.dart';
import 'package:flutter_project/common/constants/route_constants.dart';
import 'package:flutter_project/common/constants/theme.dart';
import 'package:flutter_project/di/get_it.dart';
import 'package:flutter_project/presentation/app_localizations.dart';
import 'package:flutter_project/presentation/fade_page_route_builder.dart';
import 'package:flutter_project/presentation/globals.dart';
import 'package:flutter_project/presentation/journeys/loading/loading_screen.dart';
import 'package:flutter_project/presentation/new_notification_service.dart';
import 'package:flutter_project/presentation/routes.dart';
import 'package:flutter_project/presentation/utils/app_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DeviceType { phone, tablet }

class StartApp extends StatefulWidget {
  const StartApp({super.key});

  @override
  State<StartApp> createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {
  late LanguageCubit _languageCubit;
  late LoadingCubit _loadingCubit;
  late ThemeCubit _themeCubit;
  late BottomNavigationCubit _bottomNavigationCubit;
  late ToggleCubit _toggleCubit;
  late GeneralSettingCubit _generalSettingCubit;

  @override
  void initState() {
    appConstants.loadLight();
    super.initState();

    _languageCubit = getItInstance<LanguageCubit>();
    _themeCubit = getItInstance<ThemeCubit>();
    _themeCubit.loadPreferredTheme();
    _loadingCubit = getItInstance<LoadingCubit>();
    _bottomNavigationCubit = getItInstance<BottomNavigationCubit>();
    _toggleCubit = getItInstance<ToggleCubit>();
    _generalSettingCubit = getItInstance<GeneralSettingCubit>();
    badgeCounterCubit = getItInstance<CounterCubit>();
    _configureSelectNotificationSubject();

    loadInitialData();
    initialization();
    logicOfIntroductionScreen();
    getPreviousNotificationCount();
    internetCheck();
  }

  void loadInitialData() {
    // _accountInfoCubit.loadInitialData();
  }

  @override
  void dispose() {
    _languageCubit.close();
    _themeCubit.close();
    _loadingCubit.close();
    _bottomNavigationCubit.close();
    _toggleCubit.close();
    _generalSettingCubit.close();
    badgeCounterCubit?.close();
    super.dispose();
  }

  Future<void> getPreviousNotificationCount() async {
    totalNotificationCounts = await AppFunctions().getNotificationCount();
  }

// splash remove
  void initialization() async {
    await Future.delayed(const Duration(seconds: 3));
  }

  void internetCheck() {
    if (Platform.isAndroid) {
      listenConnection();
    }
  }

  void _configureSelectNotificationSubject() {
    try {
      Future.delayed(
        Duration.zero,
        () {
          if (rootContext != null) {
            listenNotificationStream();

            // listenDeepLinkStream();
          }
        },
      );
    } catch (e) {
      Future.delayed(
        Duration.zero,
        () async {
          if (rootContext != null) {
            if (userToken == null) {
              await AppFunctions().forceLogout();
            } else {
              if (rootContext == null) return;
              Navigator.of(rootContext!).pushReplacementNamed(RouteList.app_home);
            }
          }
        },
      );
    }
  }

  void listenNotificationStream() {
    try {
      notificationCubit.stream.listen(
        (event) async {
          if (event is SelectedNotificationLoadedState) {
            //(userEntity != null);
            // AppFunctions().decrementNotificationCount();
            if (userEntity == null) {
              if (currentRouteName == RouteList.initial) {
                await AppFunctions().forceLogout();
              }
            } else if (userEntity != null &&
                event.payloadModel != null &&
                event.payloadModel!.type == 'Combo Product Offer') {
              // TODO notification Naviagting hendel
              // if (event.payloadModel?.comnoProductId != '') {
              //   await Catcher2.navigatorKey?.currentState?.pushNamed(
              //     RouteList.single_combo_details_screen,
              //     arguments: SingleComboScreenArgs(
              //       comboId: int.tryParse(event.payloadModel?.comnoProductId ?? '0') ?? 0,
              //       isComeInCart: false,
              //     ),
              //   );
              // }
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  DeviceType getDeviceType() {
    final data = MediaQueryData.fromView(View.of(context));
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  int counter = 0;
  logicOfIntroductionScreen() async {
    final prefs = await SharedPreferences.getInstance();
    counter = prefs.getInt('counter') ?? 0;
  }

  BuildContext? rootContext;

  @override
  Widget build(BuildContext context) {
    rootContext = context;

    if (kDebugMode && 1 != 1) {
      debugInvertOversizedImages = true;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageCubit>.value(value: _languageCubit),
        BlocProvider<LoadingCubit>.value(value: _loadingCubit),
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
        BlocProvider<SelectedNotificationCubit>.value(value: notificationCubit),
        BlocProvider<BottomNavigationCubit>.value(value: _bottomNavigationCubit),
        BlocProvider<ToggleCubit>.value(value: _toggleCubit),
        BlocProvider<GeneralSettingCubit>.value(value: _generalSettingCubit),
      ],
      child: BlocBuilder<ThemeCubit, Themes>(
        bloc: _themeCubit,
        builder: (context, theme) {
          if (Platform.isAndroid) {
            // SystemChrome.setSystemUIOverlayStyle(
            //   SystemUiOverlayStyle(
            //     statusBarColor: theme == Themes.dark ? appConstants.theme1Color : appConstants.theme1Color,
            //     statusBarIconBrightness: theme == Themes.dark ? Brightness.dark : Brightness.light,
            //   ),
            // );
          } else if (Platform.isIOS) {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: theme == Themes.dark ? appConstants.primary1Color : appConstants.primary1Color,
              statusBarIconBrightness: theme == Themes.dark ? Brightness.light : Brightness.dark,
              statusBarBrightness: theme == Themes.dark ? Brightness.light : Brightness.dark,
            ));
          }
          return Material(
            child: BlocBuilder<LanguageCubit, LanguageState>(
              bloc: _languageCubit,
              builder: (context, state) {
                if (state is LanguageLoadedState) {
                  return ScreenUtilInit(
                    useInheritedMediaQuery: true,
                    designSize: getDeviceType() == DeviceType.tablet ? const Size(834, 1194) : const Size(360, 800),
                    rebuildFactor: (old, data) => RebuildFactors.orientation(old, data),
                    splitScreenMode: true,
                    minTextAdapt: true,
                    builder: (context, snapshot) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        locale: state.locale,
                        supportedLocales: languages.map((e) => Locale(e.shortCode.toString())).toList(),
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        themeMode: theme == Themes.dark ? ThemeMode.dark : ThemeMode.light,
                        scaffoldMessengerKey: snackbarKey,
                        navigatorKey: Catcher2.navigatorKey,
                        navigatorObservers: <NavigatorObserver>[
                          // AnalyticsService.getAnalyticsObserver(), //Firebase Analytics
                          // MyRouteObserver(), //User Screen Time Coutner and Analytics
                        ],
                        theme: ThemeData(
                          fontFamily: 'Poppins',
                          useMaterial3: true,
                          dialogBackgroundColor: appConstants.grey1,
                          scaffoldBackgroundColor: appConstants.whiteBackgroundColor,
                          primaryColor: appConstants.primary1Color,
                          textSelectionTheme: TextSelectionThemeData(
                            selectionHandleColor: Colors.transparent,
                            selectionColor: appConstants.primary1Color.withValues(alpha: 0.3),
                            cursorColor: appConstants.primary1Color,
                          ),
                          highlightColor: Colors.transparent,
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: Colors.transparent,
                            // background: appConstants.greyBackgroundColor,
                          ),
                        ),
                        builder: (BuildContext context, Widget? child) {
                          ErrorWidget.builder = (details) => Material(
                                child: Catcher2ErrorWidget(
                                  details: details,
                                  showStacktrace: true,
                                  title: "An application error has occurred",
                                  description:
                                      "There was unexpected situation in application. Application has been ' 'able to recover from error state,Please send screenshot to support team",
                                  maxWidthForSmallMode: 150,
                                ),
                              );

                          return LoadingScreen(screen: child ?? Container());
                        },
                        initialRoute: RouteList.initial,
                        onGenerateRoute: (RouteSettings settings) {
                          if (kDebugMode) {
                            log("Routes : ${settings.name}");
                          }
                          final routes = Routes.getRoutes(settings);
                          final WidgetBuilder? builder = routes[settings.name];
                          return FadePageRouteBuilder(builder: builder!, settings: settings);
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
