import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import 'retry_signal_service.dart';

class ResilientInterceptor extends Interceptor {
  ResilientInterceptor(this._dio, this._retrySignalService);

  final Dio _dio;
  final RetrySignalService _retrySignalService;
  final Random _random = Random();

  static const String _retryCountKey = 'retry_count';
  static const String _skipRandomFailureKey = 'skip_random_failure';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final isGet = options.method.toUpperCase() == 'GET';
    final retryCount = options.extra[_retryCountKey] as int? ?? 0;
    final skipRandomFailure = options.extra[_skipRandomFailureKey] == true;
    final shouldFail =
        isGet && retryCount == 0 && !skipRandomFailure && _random.nextDouble() < 0.3;

    if (shouldFail) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const SocketException('Simulated unstable network'),
        ),
      );
      return;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isGet = options.method.toUpperCase() == 'GET';
    final retryCount = options.extra[_retryCountKey] as int? ?? 0;

    if (!isGet || retryCount >= 3) {
      handler.next(err);
      return;
    }

    _retrySignalService.show();

    final backoff = Duration(milliseconds: 400 * (1 << retryCount));
    await Future<void>.delayed(backoff);

    final requestOptions = options.copyWith();
    requestOptions.extra = Map<String, dynamic>.from(options.extra)
      ..[_retryCountKey] = retryCount + 1
      ..[_skipRandomFailureKey] = true;

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      _retrySignalService.hide();
      handler.resolve(response);
    } on DioException catch (retryError) {
      _retrySignalService.hide();
      handler.next(retryError);
    }
  }
}
