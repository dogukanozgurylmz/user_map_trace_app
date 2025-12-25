import 'package:auto_route/auto_route.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/features/presentation/home/view/home_view.dart';
import 'package:user_map_trace_app/app/features/presentation/settings/view/route_detail_view.dart';
import 'package:user_map_trace_app/app/features/presentation/settings/view/saved_routes_view.dart';
import 'package:user_map_trace_app/app/features/presentation/settings/view/settings_view.dart';
import 'package:user_map_trace_app/app/features/presentation/splash/view/splash_view.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: SavedRoutesRoute.page),
    AutoRoute(page: RouteDetailRoute.page),
  ];
}
