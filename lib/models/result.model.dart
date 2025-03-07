// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.model.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const Result._();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failed(DioException exception) = Failed<T>;

  V on<V>({
    required V Function(T) success,
    required V Function(Exception) failure,
  }) {
    return when(success: success, failed: failure);
  }
}
