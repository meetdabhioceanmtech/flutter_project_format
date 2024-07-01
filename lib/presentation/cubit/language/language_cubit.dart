// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';
import 'package:oceanmtech_dmt/domain/params/no_params.dart';
import 'package:oceanmtech_dmt/domain/usecases/get_preferred_language.dart';
import 'package:oceanmtech_dmt/domain/usecases/update_language.dart';
import 'package:oceanmtech_dmt/presentation/globals.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final GetPreferredLanguage getPreferredLanguage;
  final UpdateLanguage updateLanguage;
  bool isMounted = true;

  LanguageCubit({
    required this.getPreferredLanguage,
    required this.updateLanguage,
  }) : super(LanguageLoadedState(Locale(currentLangCode)));

  void toggleLanguage({required String shortCode}) async {
    await updateLanguage(shortCode);
    loadPreferredLanguage();
  }

  Future<void> loadPreferredLanguage() async {
    final response = await getPreferredLanguage(NoParams());
    if (!isMounted) return;
    emit(
      response.fold(
        (error) => LanguageErrorState(
          errorMessage: error.errorMessage,
          appErrorType: error.errorType,
        ),
        (r) => LanguageLoadedState(
          Locale(r),
        ),
      ),
    );
  }

  void changeLanguage(int index) {
    emit(LanguageInitialState(index: index));
  }
}
