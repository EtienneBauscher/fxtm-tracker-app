// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';

// 🌎 Project imports:
import 'package:fxtm/enums/named_route.enum.dart';

part 'navigation_state.model.freezed.dart';

@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    String? fullPath,
    NamedRoute? namedRoute,
    String? subRoute,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
  }) = _NavigationState;

  factory NavigationState.fromConfiguration(RouteMatchList configuration) {
    final fullPath = configuration.fullPath;
    final segments = configuration.uri.pathSegments;
    final pathPrameters = configuration.pathParameters;
    final queryParameters = configuration.uri.queryParameters;
    final namedRoute =
        segments.isEmpty
            ? null
            : NamedRoute.values.singleWhere((route) {
              return route.name.toLowerCase() == segments.first.toLowerCase();
            });

    switch (namedRoute) {
      case NamedRoute.home:
        return NavigationState(
          fullPath: fullPath,
          namedRoute: NamedRoute.home,
          pathParameters: pathPrameters,
          queryParameters: queryParameters,
        );
      default:
        return NavigationState(
          fullPath: fullPath,
          namedRoute: NamedRoute.home,
          pathParameters: pathPrameters,
          queryParameters: queryParameters,
        );
    }
  }
}
