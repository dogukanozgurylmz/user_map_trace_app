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

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<HomeCubit>().mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //final cubit = context.read<HomeCubit>();

    if (state == AppLifecycleState.resumed) {
      // Uygulama foreground'a geldiğinde state'i senkronize et
      //cubit.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MapWidget(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: context.height * 0.1,
            child: const TopGradientWidget(),
          ),
          const Positioned(top: 12, right: 20, child: SettingsButton()),
          const Positioned(top: 12, left: 20, child: TrackingToggleButton()),
          const Positioned(
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
