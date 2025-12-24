import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/map_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/settings_button.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/status_info_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/top_gradient_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/tracking_toggle_button.dart';
import 'package:user_map_trace_app/core/extensions/build_context_extensions.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartTracking();
    });
  }

  Future<void> _checkAndStartTracking() async {
    final cubit = context.read<HomeCubit>();
    final state = cubit.state;

    // Eğer zaten takip ediliyorsa başlatma
    if (state.isTracking) {
      return;
    }

    // Konum izni kontrolü ve otomatik başlatma
    await cubit.startService(context);
  }

  @override
  void dispose() {
    context.read<HomeCubit>().mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Haritayı tüm ekrana yaymak için
      body: Stack(
        children: [
          MapWidget(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: context.height * 0.1,
            child: TopGradientWidget(),
          ),
          Positioned(top: 12, right: 20, child: SettingsButton()),
          Positioned(top: 12, left: 20, child: const TrackingToggleButton()),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: StatusInfoWidget(),
          ),
        ],
      ),
    );
  }
}
