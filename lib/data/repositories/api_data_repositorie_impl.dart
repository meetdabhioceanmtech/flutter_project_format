import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_project/data/datasources/common_api_call.dart';
import 'package:flutter_project/data/datasources/api_data_source.dart';
import 'package:flutter_project/data/models/model_response_extend.dart';
import 'package:flutter_project/domain/entities/app_error.dart';
import 'package:flutter_project/domain/repositories/api_repositorie.dart';

class ApiDataRepositoriesImpl extends ApiDataRepositories {
  final ApiDataSource dataSource;

  ApiDataRepositoriesImpl({required this.dataSource});

  @override
  Future<Either<AppError, T>> dataFatch<T extends ModelResponseExtend>({
    required String endpoint,
    required T Function(Map<String, dynamic>json) fromJson,
    required APICallType apiCallType,
    required String screenName,
    Map<String, dynamic>? params,
    Map<String, String>? header,
    List<MapEntry<String, MultipartFile>>? multipleImages,
  }) async {
    try {
      return await dataSource.dataFatchApi(
        endpoint: endpoint,
        fromJson: fromJson,
        apiCallType: apiCallType,
        params: params,
        header: header,
        screenName: screenName,
        multipleImages: multipleImages,
      );
    } on Exception {
      throw Exception('Something goes wrong.');
    }
  }
}
