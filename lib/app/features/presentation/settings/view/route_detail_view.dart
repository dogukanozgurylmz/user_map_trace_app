import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/common/get_it/get_it.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/marker_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/start_marker_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/settings/cubit/settings_cubit.dart';

@RoutePage()
class RouteDetailView extends StatelessWidget {
  const RouteDetailView({super.key, required this.route});

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt.get<SettingsCubit>()..selectRoute(route),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          final routePoints = cubit.getRoutePoints(route);
          final centerPoint = cubit.getRouteCenterPoint(route);

          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black2),
                onPressed: () => context.router.pop(),
              ),
              title: Text(
                route.name,
                style: const TextStyle(
                  color: AppColors.black2,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: routePoints.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.noData,
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                  )
                : FlutterMap(
                    mapController: cubit.mapController,
                    options: MapOptions(
                      initialCenter: centerPoint,
                      initialZoom: 15,
                      minZoom: 5,
                      maxZoom: 18,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.user_map_trace_app',
                      ),
                      if (routePoints.length > 1)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              strokeWidth: 6,
                              color: AppColors.green,
                              strokeCap: StrokeCap.round,
                              strokeJoin: StrokeJoin.round,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        alignment: Alignment.topCenter,
                        markers: [
                          if (routePoints.isNotEmpty)
                            Marker(
                              point: routePoints.first,
                              width: 40,
                              height: 40,
                              child: const StartMarkerWidget(),
                              rotate: true,
                            ),
                          ...route.locations
                              .skip(1)
                              .map(
                                (location) => Marker(
                                  point: LatLng(
                                    location.latitude,
                                    location.longitude,
                                  ),
                                  width: 35,
                                  height: 35,
                                  child: MarkerWidget(location: location),
                                  rotate: true,
                                ),
                              ),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
