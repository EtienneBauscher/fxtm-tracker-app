// 🌎 Project imports:
import 'package:fxtm/enums/http_method.enum.dart';

extension HttpMethodX on HttpMethod {
  String get capitalised {
    return name.toUpperCase();
  }
}
