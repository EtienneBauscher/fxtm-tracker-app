// 🌎 Project imports:
import 'package:fxtm/models/api_response.model.dart';

abstract class FinnhubApiContract {
  Future<ApiResponse<List<String>>> fetchSymbols();
}
