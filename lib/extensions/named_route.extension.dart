// 🌎 Project imports:
import 'package:fxtm/enums/named_route.enum.dart';

extension NamedRouteX on NamedRoute {
  String get path {
    switch (this) {
      case NamedRoute.home:
        return '/';
    }
  }
}
