// ignore_for_file: avoid_renaming_method_parameters

import 'package:dartz/dartz.dart';
import 'package:oceanmtech_dmt/data/datasources/language_local_data_source.dart';
import 'package:oceanmtech_dmt/data/repositories/app_repository.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';

class AppRepositoryImpl extends AppRepository {
  final LanguageLocalDataSource languageLocalDataSource;

  AppRepositoryImpl({required this.languageLocalDataSource});

  @override
  Future<Either<AppError, String>> getPreferredLanguage() async {
    try {
      final response = await languageLocalDataSource.getPreferredLanguage();
      return Right(response);
    } on Exception {
      return const Left(AppError(errorType: AppErrorType.database, errorMessage: ''));
    }
  }

  @override
  Future<Either<AppError, void>> updateLanguage(String language) async {
    try {
      final response = await languageLocalDataSource.updateLanguage(language);
      return Right(response);
    } on Exception {
      return const Left(AppError(errorType: AppErrorType.database, errorMessage: ''));
    }
  }
}
