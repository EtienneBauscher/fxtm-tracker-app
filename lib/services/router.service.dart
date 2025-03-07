// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:go_router/go_router.dart';

// 🌎 Project imports:
import 'package:fxtm/contracts/router_service.contract.dart';
import 'package:fxtm/enums/named_route.enum.dart';
import 'package:fxtm/extensions/named_route.extension.dart';
import 'package:fxtm/models/navigation_state.model.dart';
import 'package:fxtm/pages/main_page.dart';

class RouterService implements RouterServiceContract {
  late final _router = _buildWebRouter();

  @override
  GoRouter get router => _router;

  @override
  NavigationState get navigationState {
    return NavigationState.fromConfiguration(
      _router.routerDelegate.currentConfiguration,
    );
  }

  @override
  Map<String, String> get queryParams {
    final returnParams = <String, String>{};
    final existingParams =
        navigationState.queryParameters ?? <String, String>{};

    for (final key in existingParams.keys) {
      returnParams.addAll({key: existingParams[key]!});
    }

    return returnParams;
  }

  @override
  void addListener(Function() listen) {
    _router.routerDelegate.addListener(listen);
  }

  @override
  void removeListener(Function() listen) {
    _router.routerDelegate.removeListener(listen);
  }

  @override
  void updateRouterWithParams(Map<String, String> queryParams) {
    final uri = _router.routerDelegate.currentConfiguration.uri;
    final updatedUri = Uri(
      path: uri.path,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (updatedUri.toString() != uri.toString()) {
      _router.go(updatedUri.toString());
    }
  }
}

GoRouter _buildWebRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    initialLocation: NamedRouteX(NamedRoute.home).path,
    navigatorKey: rootNavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        name: NamedRoute.home.name,
        path: NamedRoute.home.path,
        pageBuilder: (context, state) {
          return _buildScaffoldPage(context, state, const MainPage());
        },
      ),
    ],
    debugLogDiagnostics: true,
    redirect: _redirect,
  );
}

Page _buildScaffoldPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: Scaffold(body: Center(child: child)),
    transitionsBuilder: _buildFadeTransition,
  );
}

FadeTransition _buildFadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Future<String?> _redirect(
  BuildContext context,
  GoRouterState routerState,
) async {
  return routerState.uri.toString();
}
