import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/infrastructure/location/background_location_service.dart';
import 'package:user_map_trace_app/app/common/router/app_router.dart';

@RoutePage()
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeBackgroundService();
    if (context.mounted) {
      context.router.replaceAll([const HomeRoute()]);
    }
  }

  Future<void> _initializeBackgroundService() async {
    await BackgroundLocationService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Placeholder());
  }
}
