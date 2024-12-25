import 'dart:developer';
import 'dart:io';

import 'package:catcher_2/core/catcher_2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_project/common/constants/hive_constants.dart';
import 'package:flutter_project/presentation/cubit/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:flutter_project/presentation/cubit/counter/counter_cubit.dart';
import 'package:flutter_project/common/extention/string_extension.dart';
import 'package:flutter_project/common/extention/theme_extension.dart';
import 'package:flutter_project/presentation/globals.dart';
import 'package:flutter_project/presentation/journeys/app_home/app_home_screen.dart';
import 'package:flutter_project/presentation/journeys/screens/bottom_navbar/bottom_nav_constants.dart';
import 'package:flutter_project/presentation/journeys/screens/bottom_navbar/nav_title_widget.dart';
import 'package:flutter_project/presentation/widgets/common_widget.dart';
import 'package:flutter_project/presentation/utils/app_functions.dart';

abstract class AppHomeWidget extends State<AppHome> {
  late BottomNavigationCubit bottomNavigationCubit;

  BuildContext? buildContext;

  @override
  void initState() {
    bottomNavigationCubit = BlocProvider.of<BottomNavigationCubit>(context);
    super.initState();
    AppFunctions().getUserToken();
    Future.delayed(Duration.zero, () => installDataLoad());
  }

  Future<void> setupToken() async {
    try {
      if (((await messaging.requestPermission(provisional: true)).authorizationStatus ==
              AuthorizationStatus.authorized) ||
          ((await messaging.requestPermission(provisional: true)).authorizationStatus ==
              AuthorizationStatus.provisional)) {
        if (Platform.isIOS) {
          await messaging.getAPNSToken();
        }
        String? token = await messaging.getToken();

        if (token != null && token.toString().isNotEmpty) {
          // await saveTokenToDatabase(token);
        }
        // FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
      } else {
        if (kDebugMode) {
          print('User declined or has not accepted permission');
        }
      }
    } on Exception catch (e, stackTrace) {
      Catcher2.reportCheckedError(e, stackTrace);
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void installDataLoad() async {
    if (userToken != null) {
      await getFirebaseFcmToken();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getFirebaseFcmToken() async {
    try {
      userFcmToken = await userDataBox.get(HiveConstants.USER_FCM_TOKEN, defaultValue: "notfound");
      // ignore: avoid_print
      print("FCM Token: $userFcmToken");
      log("FCM Token: $userFcmToken");
      String? fcmTokon = await FirebaseMessaging.instance.getToken() ?? "notfound";

      if (fcmTokon != userFcmToken) {
        // deviceInfoCubit.updateDeviceInfo(fcmTokon: fcmTokon);
      }
    } catch (e) {
      log('getFirebaseFcmToken Error ==> $e');
    }
  }

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: appConstants.whiteBackgroundColor,
      backgroundColor: appConstants.whiteBackgroundColor,
      iconTheme: IconThemeData(color: appConstants.secondary1Color),
      titleSpacing: 0,
      leading: Builder(
        builder: (context) {
          return IconButton(
            highlightColor: Colors.transparent,
            onPressed: () => Scaffold.of(context).openDrawer(), // And this!
            icon: CommonWidget.imageBuilder(
              image: "assets/svgs/common/drawer_icon.svg",
              fit: BoxFit.cover,
              height: 15.h,
            ),
          );
        },
      ),
      title: CommonWidget.commonText(
        text: "Job Search Company App",
        style: Theme.of(context).textTheme.subTitle2MediumHeading.copyWith(color: appConstants.secondary1Color),
      ),
      actions: [
        InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () async {
            // CommonRouter.pushNamed(RouteList.notification_screen);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<CounterCubit, int>(
              bloc: badgeCounterCubit,
              builder: (_, state) {
                return Badge(
                  backgroundColor: totalNotificationCounts != 0 ? Colors.red : Colors.transparent,
                  isLabelVisible: totalNotificationCounts == 0 ? false : true,
                  largeSize: 13,
                  offset: const Offset(1, -3),
                  label: Text(
                    totalNotificationCounts.toString(),
                    style: Theme.of(context).textTheme.h4BoldHeading.copyWith(
                          color: appConstants.whiteBackgroundColor,
                          fontSize: 10.sp,
                          height: 1,
                        ),
                  ),
                  child: CommonWidget.imageBuilder(
                    image: '',
                    height: 20.h,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomBar() {
    return BlocBuilder<BottomNavigationCubit, int>(
      bloc: bottomNavigationCubit,
      builder: (BuildContext context, int state) {
        bool isNeedSafeArea = View.of(context).viewPadding.bottom > 0;
        return Container(
          height: isNeedSafeArea ? 76.h : 64.h,
          alignment: Alignment.topCenter,
          padding: Platform.isAndroid ? EdgeInsets.symmetric(vertical: isNeedSafeArea ? 8.h : 0) : null,
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: appConstants.primary4Color, blurRadius: 3, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < bottomBarItems.length; i++)
                      Expanded(
                        child: NavTitleWidget(
                          title: bottomBarItems[i].title.translate(context),
                          onTap: () {
                            bottomNavigationCubit.changedBottomNavigation(i);
                          },
                          iconPath: bottomBarItems[i].icon,
                          isSelected: bottomBarItems[i].index == state,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
