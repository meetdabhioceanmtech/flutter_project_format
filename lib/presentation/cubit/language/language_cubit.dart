// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_project/domain/entities/app_error.dart';
import 'package:flutter_project/domain/params/no_params.dart';
import 'package:flutter_project/domain/usecases/get_preferred_language.dart';
import 'package:flutter_project/domain/usecases/update_language.dart';
import 'package:flutter_project/presentation/globals.dart';

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
