import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/widgets/buttons/app_button.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/home/mixin/date_time_format_mixin.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/location_detail_header_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/location_detail_row_widget.dart';

class LocationDetailBottomSheet extends StatelessWidget
    with DateTimeFormatMixin {
  final LocationModel location;

  const LocationDetailBottomSheet({super.key, required this.location});

  static void show(BuildContext context, LocationModel location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => LocationDetailBottomSheet(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return FutureBuilder<String>(
      future: cubit.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      ),
      builder: (context, snapshot) {
        final address = snapshot.data ?? 'Adres yükleniyor...';
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        const LocationDetailHeaderWidget(),
                        const SizedBox(height: 20),
                        LocationDetailRowWidget(
                          icon: Icons.location_on_rounded,
                          label: 'Adres',
                          value: address,
                          iconColor: AppColors.blue,
                        ),
                        const SizedBox(height: 16),
                        LocationDetailRowWidget(
                          icon: Icons.access_time_rounded,
                          label: 'Zaman',
                          value: formatDateTime(location.timestamp),
                          iconColor: AppColors.blue,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: LocationDetailRowWidget(
                                icon: Icons.north_rounded,
                                label: 'Enlem',
                                value:
                                    '${location.latitude.toStringAsFixed(6)}°',
                                iconColor: AppColors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: LocationDetailRowWidget(
                                icon: Icons.east_rounded,
                                label: 'Boylam',
                                value:
                                    '${location.longitude.toStringAsFixed(6)}°',
                                iconColor: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        if (location.speed != null ||
                            location.accuracy != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (location.speed != null)
                                Expanded(
                                  child: LocationDetailRowWidget(
                                    icon: Icons.speed_rounded,
                                    label: 'Hız',
                                    value:
                                        '${(location.speed! * 3.6).toStringAsFixed(1)} km/h',
                                    iconColor: AppColors.red,
                                  ),
                                ),
                              if (location.speed != null &&
                                  location.accuracy != null)
                                const SizedBox(width: 16),
                              if (location.accuracy != null)
                                Expanded(
                                  child: LocationDetailRowWidget(
                                    icon: Icons.gps_fixed_rounded,
                                    label: 'Doğruluk',
                                    value:
                                        '${location.accuracy!.toStringAsFixed(1)} m',
                                    iconColor: AppColors.purple,
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (location.altitude != null) ...[
                          const SizedBox(height: 16),
                          LocationDetailRowWidget(
                            icon: Icons.height_rounded,
                            label: 'Yükseklik',
                            value: '${location.altitude!.toStringAsFixed(1)} m',
                            iconColor: AppColors.teal,
                          ),
                        ],
                        if (location.heading != null) ...[
                          const SizedBox(height: 16),
                          LocationDetailRowWidget(
                            icon: Icons.explore_rounded,
                            label: 'Yön',
                            value: '${location.heading!.toStringAsFixed(1)}°',
                            iconColor: AppColors.indigo,
                          ),
                        ],
                        const SizedBox(height: 20),
                        AppButton.fill(
                          onPressed: () {
                            cubit.moveToLocation(
                              LatLng(location.latitude, location.longitude),
                            );
                            context.router.pop();
                          },
                          icon: const Icon(Icons.map_rounded),
                          text: 'Haritada Göster',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
