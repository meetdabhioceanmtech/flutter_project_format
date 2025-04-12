import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_project/presentation/cubit/loading/loading_cubit.dart';
import 'package:flutter_project/presentation/globals.dart';

class LoadingScreen extends StatelessWidget {
  final Widget screen;

  const LoadingScreen({
    super.key,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        1 == 1
            ? screen
            : Container(
                color: appConstants.primary1Color,
                child: SafeArea(top: true, left: true, right: true, bottom: false, child: screen),
              ),
        BlocBuilder<LoadingCubit, bool>(
          builder: (context, shouldShow) {
            if (shouldShow) {
              return Container(
                color: Colors.black.withValues(alpha: 0.6),
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight,
                child: Center(
                  child: SizedBox(
                    height: 30.h,
                    width: 30.w,
                    child: CircularProgressIndicator(
                      color: appConstants.primary1Color,
                    ),
                    // child: const FlareActor(
                    //   'assets/animation/loading_circle.flr',
                    //   animation: 'load',
                    //   snapToEnd: true,
                    // ),
                  ),
                ),
                //  child: Center(child: Image.asset('assets/animation/ios.gif', height: 36.h, width: 36.w)),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
