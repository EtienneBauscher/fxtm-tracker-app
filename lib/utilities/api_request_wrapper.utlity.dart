// 📦 Package imports:
import 'package:dio/dio.dart';

// 🌎 Project imports:
import 'package:fxtm/models/api_response.model.dart';

Future<ApiResponse<T>> apiRequestWrapper<T>({
  required Future<Response<dynamic>> Function() request,
  required T Function(dynamic data) fromJson,
}) async {
  try {
    final response = await request();

    return ApiResponse.success(fromJson(response.data));
  } on DioException catch (exception) {
    return ApiResponse.failed(exception);
  }
}
