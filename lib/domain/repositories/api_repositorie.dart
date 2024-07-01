import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:oceanmtech_dmt/data/datasources/common_api_call.dart';
import 'package:oceanmtech_dmt/data/models/model_response_extend.dart';
import 'package:oceanmtech_dmt/domain/entities/app_error.dart';

abstract class ApiDataRepositories {
  Future<Either<AppError, T>> dataFatch<T extends ModelResponseExtend>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJson,
    required APICallType apiCallType,
    required String screenName,
    Map<String, dynamic>? params,
    Map<String, String>? header,
    List<MapEntry<String, MultipartFile>>? multipleImages,
  });
}
