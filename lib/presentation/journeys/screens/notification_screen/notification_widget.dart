import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:oceanmtech_dmt/common/extention/theme_extension.dart';
import 'package:oceanmtech_dmt/data/models/my_notification_model.dart';
import 'package:oceanmtech_dmt/di/get_it.dart';
import 'package:oceanmtech_dmt/presentation/cubit/notification/notification_handle/notification_cubit.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/journeys/screens/notification_screen/notification_screen.dart';
import 'package:oceanmtech_dmt/presentation/new_notification_service.dart';
import 'package:oceanmtech_dmt/presentation/utils/app_functions.dart';
import 'package:oceanmtech_dmt/presentation/widgets/common_widget.dart';

abstract class NotificationWidget extends State<NotificationScreen> {
  late NotificationCubit notificationViewCubit;

  @override
  void initState() {
    flutterLocalNotificationsPlugin.cancelAll();
    notificationViewCubit = getItInstance<NotificationCubit>();
    // notificationViewCubit.loadData();
    notificationViewCubit.getNotificationHistory();
    AppFunctions().resetNotificationCount();
    super.initState();
  }

  @override
  void dispose() {
    notificationViewCubit.loadingCubit.hide();
    notificationViewCubit.close();
    super.dispose();
  }

  Widget jobNotificationWidget({required NotificationData notification}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: appConstants.grey1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                notification.notification.title,
                style: Theme.of(context).textTheme.body1MediumHeading.copyWith(
                      color: appConstants.primary1Color,
                    ),
                overflow: TextOverflow.visible,
                maxLines: 3,
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              color: appConstants.grey1.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Text(
                      notification.notification.body,
                      style: Theme.of(context).textTheme.caption1MediumHeading.copyWith(
                            color: appConstants.neutral5Color,
                          ),
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Divider(
                    color: appConstants.neutral9Color,
                    height: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(notification.createdAt),
                          style: Theme.of(context).textTheme.caption2MediumHeading.copyWith(
                                color: appConstants.neutral5Color,
                              ),
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          textAlign: TextAlign.start,
                        ),
                        CommonWidget.commonText(
                          text: DateFormat('hh:mm a').format(notification.createdAt),
                          style: Theme.of(context).textTheme.caption2MediumHeading.copyWith(
                                color: appConstants.neutral5Color,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
