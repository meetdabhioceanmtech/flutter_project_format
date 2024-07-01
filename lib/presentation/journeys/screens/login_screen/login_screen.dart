import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oceanmtech_dmt/common/constants/translation_constants.dart';
import 'package:oceanmtech_dmt/common/extention/size_box_extension.dart';
import 'package:oceanmtech_dmt/common/extention/string_extension.dart';
import 'package:oceanmtech_dmt/common/extention/theme_extension.dart';
import 'package:oceanmtech_dmt/di/get_it.dart';
import 'package:oceanmtech_dmt/presentation/cubit/toggle_cubit/toggle_cubit.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';
import 'package:oceanmtech_dmt/presentation/widgets/common_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ToggleCubit toggleCubit;
  GlobalKey<FormState> loginKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    toggleCubit = getItInstance<ToggleCubit>();
    toggleCubit.setValue(value: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: CommonWidget.padding(
          horizontal: 15,
          vertical: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CommonWidget.imageBuilder(
                  image: "assets/svgs/common/login_image.svg",
                  height: 170.h,
                ),
              ),
              30.sHeight,
              CommonWidget.commonText(
                text: TranslationConstants.login.translate(context),
                style: Theme.of(context).textTheme.h6BoldHeading.copyWith(
                      color: appConstants.primary1Color,
                    ),
              ),
              8.sHeight,
              CommonWidget.commonText(
                text: TranslationConstants.job_search_helps_you_hire_staff_in_2_days.translate(context),
                maxLines: 2,
                style: Theme.of(context).textTheme.body2MediumHeading.copyWith(
                      color: appConstants.primary1Color,
                    ),
              ),
              30.sHeight,
              Form(
                key: loginKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonWidget.field(
                      context: context,
                      controller: emailController,
                      fieldTitle: TranslationConstants.email_address.translate(context),
                      textInputType: TextInputType.emailAddress,
                      hintText: TranslationConstants.enter_email_address.translate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return TranslationConstants.please_enter_your_email_id.translate(context);
                        } else if (!value.trim().isValidEmail()) {
                          return TranslationConstants.please_enter_valid_email_id.translate(context);
                        }
                        return null;
                      },
                    ),
                    BlocBuilder<ToggleCubit, bool>(
                      bloc: toggleCubit,
                      builder: (context, state) {
                        return CommonWidget.field(
                          context: context,
                          controller: passwordController,
                          fieldTitle: TranslationConstants.password.translate(context),
                          textInputType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.send,
                          obscureText: state,
                          hintText: TranslationConstants.enter_your_password.translate(context),
                          suffixWidget: IconButton(
                            highlightColor: Colors.transparent,
                            onPressed: () => toggleCubit.setValue(value: !state),
                            icon: Icon(
                              state ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return TranslationConstants.please_enter_your_password.translate(context);
                            } else if (value.length < 6) {
                              return TranslationConstants.password_must_be_at_least_6_characters_long
                                  .translate(context);
                            }

                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              10.sHeight,
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  // onTap: () async => await CommonRouter.pushNamed(RouteList.forgot_screen),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: CommonWidget.commonText(
                    textAlign: TextAlign.center,
                    text: TranslationConstants.forgot_password_question.translate(context),
                    color: appConstants.primary1Color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              25.sHeight,
              CommonWidget.commonButton(
                text: TranslationConstants.login.translate(context),
                context: context,
                onTap: () async {
                  // if (loginKey.currentState!.validate()) {
                  //   await loginCubit.login(
                  //     context: context,
                  //     email: emailController.text.toString().toLowerCase().trim(),
                  //     password: passwordController.text.toString(),
                  //   );
                  // }
                },
              ),
              15.sHeight,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonWidget.commonText(
                    text: TranslationConstants.you_dont_have_an_account.translate(context),
                    style: Theme.of(context).textTheme.caption1MediumHeading.copyWith(
                          color: appConstants.neutral1Color,
                        ),
                  ),
                  4.sWidth,
                  InkWell(
                    // onTap: () async => await CommonRouter.pushNamed(
                    //   RouteList.register_Screen,
                    //   arguments: const RegisterCompanyParams(
                    //     registerOrEditEnum: RegisterOrEdit.register,
                    //     userEntity: null,
                    //   ),
                    // ),
                    child: CommonWidget.commonText(
                      text: TranslationConstants.sign_up.translate(context),
                      style: Theme.of(context).textTheme.body2SemiboldHeading.copyWith(
                            color: appConstants.primary1Color,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
