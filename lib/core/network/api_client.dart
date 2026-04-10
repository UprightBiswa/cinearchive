import 'package:dio/dio.dart';

import '../config/app_env.dart';
import '../constants/app_constants.dart';
import 'resilient_interceptor.dart';
import 'retry_signal_service.dart';

class ApiClientFactory {
  ApiClientFactory(this._retrySignalService);

  final RetrySignalService _retrySignalService;

  Dio createReqResClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.reqResBaseUrl,
        headers: <String, dynamic>{
          if (AppEnv.hasReqResKey) 'x-api-key': AppEnv.reqResApiKey,
        },
      ),
    );
    dio.interceptors.add(ResilientInterceptor(dio, _retrySignalService));
    return dio;
  }

  Dio createOmdbClient() {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.omdbBaseUrl));
    dio.interceptors.add(ResilientInterceptor(dio, _retrySignalService));
    return dio;
  }
}
