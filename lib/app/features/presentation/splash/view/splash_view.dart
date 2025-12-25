import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/constants/app_images.dart';
import 'package:user_map_trace_app/app/common/infrastructure/location/background_location_service.dart';
import 'package:user_map_trace_app/app/common/router/app_router.dart';
import 'package:user_map_trace_app/core/extensions/build_context_extensions.dart';

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
  }

  Future<void> _initializeBackgroundService() async {
    await Future.delayed(const Duration(seconds: 1));
    await BackgroundLocationService.instance.initialize();
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    context.router.replaceAll([const HomeRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: Center(
        child: Image.asset(
          AppImages.appIconBg,
          width: context.width * 0.6,
          height: context.width * 0.6,
        ),
      ),
    );
  }
}
