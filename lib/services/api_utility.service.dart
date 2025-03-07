// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:logger/web.dart';

// 🌎 Project imports:
import 'package:fxtm/config.dart';
import 'package:fxtm/contracts/api_request_utility_service.contract.dart';
import 'package:fxtm/contracts/logger_service.contract.dart';
import 'package:fxtm/enums/http_method.enum.dart';
import 'package:fxtm/enums/query_params.enum.dart';
import 'package:fxtm/extensions/http_method.extension.dart';
import 'package:fxtm/models/query.model.dart';

class ApiRequestUtilityService implements ApiRequestUtilityServiceContract {
  ApiRequestUtilityService(this._dio);

  final Dio _dio;

  @override
  Future<Response<T>> request<T>({
    required HttpMethod method,
    required Query<String> query,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    final Options requestOptions = options ?? Options();

    if (!const bool.fromEnvironment('development')) {
      _dio.interceptors.add(
        LogInterceptor(
          logPrint: (o) => debugPrint(o.toString()),
          request: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: false,
        ),
      );
    }

    final key = Config.apiKey;

    queryParameters = <String, dynamic>{QueryParams.token.name: key}
      ..addAll(queryParameters ?? {});

    requestOptions.contentType = 'application/json';
    requestOptions.responseType = ResponseType.json;
    requestOptions.headers = {
      'accept': 'application/json',
      if (requestOptions.headers != null) ...requestOptions.headers!,
    };

    switch (method) {
      case HttpMethod.get:
        requestOptions.method = HttpMethod.get.capitalised;
        break;
      case HttpMethod.post:
        requestOptions.method = HttpMethod.post.capitalised;
        break;
      case HttpMethod.put:
        requestOptions.method = HttpMethod.put.capitalised;
        break;
      case HttpMethod.patch:
        requestOptions.method = HttpMethod.patch.capitalised;
        break;
      case HttpMethod.delete:
        requestOptions.method = HttpMethod.delete.capitalised;
        break;
    }

    return _dio.request<T>(
      '${_dio.options.baseUrl}${query.path}',
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: requestOptions,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

class DioInterceptor extends Interceptor {
  DioInterceptor(this._loggerService);

  final LoggerServiceContract _loggerService;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final type = err.type;
    final requestOptions = err.requestOptions;
    final message = err.response?.data['message'];

    const env = String.fromEnvironment('development');

    if (env == 'development') {
      _loggerService.log(
        message,
        error: err.response,
        stackTrace: err.stackTrace,
        level: Level.error,
      );
    }

    switch (type) {
      case DioExceptionType.connectionTimeout:
        throw ConnectionTimeout(requestOptions: requestOptions, type: type);
      case DioExceptionType.connectionError:
        throw ConnectionTimeout(requestOptions: requestOptions, type: type);
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;

        switch (code) {
          case 400:
            throw BadRequest(
              requestOptions: requestOptions,
              type: type,
              message: message,
            );
          case 401:
            throw Unauthorized(requestOptions: requestOptions, type: type);
          case 404:
            throw NotFound(requestOptions: requestOptions, type: type);
          case 409:
            throw Conflict(
              requestOptions: requestOptions,
              type: type,
              message: message,
            );
        }
      case DioExceptionType.unknown:
        throw UnKnown(
          requestOptions: requestOptions,
          type: type,
          error: err.error,
        );

      case DioExceptionType.sendTimeout:
      // TODO: Handle this case.
      case DioExceptionType.receiveTimeout:
      // TODO: Handle this case.
      case DioExceptionType.badCertificate:
      // TODO: Handle this case.
      case DioExceptionType.cancel:
      // TODO: Handle this case.
    }
  }
}

class ConnectionTimeout extends DioException {
  ConnectionTimeout({required super.requestOptions, super.type});
}

class BadRequest extends DioException {
  BadRequest({required super.requestOptions, super.type, super.message});
}

class NotFound extends DioException {
  NotFound({required super.requestOptions, super.type});
}

class Unauthorized extends DioException {
  Unauthorized({required super.requestOptions, super.type});
}

class Conflict extends DioException {
  Conflict({
    required super.requestOptions,
    super.type = DioExceptionType.badResponse,
    super.message,
  });
}

class UnKnown extends DioException {
  UnKnown({required super.requestOptions, super.type, super.error});
}
