import 'package:dartz/dartz.dart';
import 'package:oceanmtech_dmt/data/repositories/app_repository.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';
import 'package:oceanmtech_dmt/domain/usecases/usecase.dart';

class UpdateLanguage extends UseCase<void, String> {
  final AppRepository appRepository;

  UpdateLanguage({required this.appRepository});

  @override
  Future<Either<AppError, void>> call(String params) async {
    return await appRepository.updateLanguage(params);
  }
}
