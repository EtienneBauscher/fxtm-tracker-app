// 📦 Package imports:
import 'package:go_router/go_router.dart';

// 🌎 Project imports:
import 'package:fxtm/models/navigation_state.model.dart';

abstract class RouterServiceContract {
  GoRouter get router;
  NavigationState get navigationState;
  Map<String, String> get queryParams;
  void addListener(Function() listen);
  void removeListener(Function() listen);
  void updateRouterWithParams(Map<String, String> queryParams);
}
