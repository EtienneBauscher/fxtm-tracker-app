// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.model.freezed.dart';

@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const ApiResponse._();

  factory ApiResponse.success(T? data) = _ApiSuccess;
  factory ApiResponse.failed(DioException? error) = _ApiFailed;
}
