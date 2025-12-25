// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [HomeView]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeView();
    },
  );
}

/// generated route for
/// [RouteDetailView]
class RouteDetailRoute extends PageRouteInfo<RouteDetailRouteArgs> {
  RouteDetailRoute({
    Key? key,
    required RouteModel route,
    List<PageRouteInfo>? children,
  }) : super(
         RouteDetailRoute.name,
         args: RouteDetailRouteArgs(key: key, route: route),
         initialChildren: children,
       );

  static const String name = 'RouteDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RouteDetailRouteArgs>();
      return RouteDetailView(key: args.key, route: args.route);
    },
  );
}

class RouteDetailRouteArgs {
  const RouteDetailRouteArgs({this.key, required this.route});

  final Key? key;

  final RouteModel route;

  @override
  String toString() {
    return 'RouteDetailRouteArgs{key: $key, route: $route}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RouteDetailRouteArgs) return false;
    return key == other.key && route == other.route;
  }

  @override
  int get hashCode => key.hashCode ^ route.hashCode;
}

/// generated route for
/// [SavedRoutesView]
class SavedRoutesRoute extends PageRouteInfo<void> {
  const SavedRoutesRoute({List<PageRouteInfo>? children})
    : super(SavedRoutesRoute.name, initialChildren: children);

  static const String name = 'SavedRoutesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SavedRoutesView();
    },
  );
}

/// generated route for
/// [SettingsView]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsView();
    },
  );
}

/// generated route for
/// [SplashView]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashView();
    },
  );
}
