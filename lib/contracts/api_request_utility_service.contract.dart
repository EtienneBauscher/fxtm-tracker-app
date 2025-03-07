// 📦 Package imports:
import 'package:dio/dio.dart';

// 🌎 Project imports:
import 'package:fxtm/enums/http_method.enum.dart';
import 'package:fxtm/models/query.model.dart';

abstract class ApiRequestUtilityServiceContract {
  Future<Response<T>> request<T>({
    required HttpMethod method,
    required Query<String> query,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });
}
