import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/common/helpers/distance/distance_helper.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/current_marker_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/location_detail_bottom_sheet.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/marker_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/start_marker_widget.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        final points = state.routeHistory;
        final routePolyline = state.routePolyline.isNotEmpty
            ? state.routePolyline
            : points;
        final defaultLocation =
            state.currentLocation ?? const LatLng(41.0082, 28.9784);
        return FlutterMap(
          mapController: cubit.mapController,
          options: MapOptions(
            initialCenter: LatLng(
              defaultLocation.latitude,
              defaultLocation.longitude,
            ),
            initialZoom: 15,
            minZoom: 5,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
              doubleTapZoomCurve: Curves.easeInOut,
              doubleTapZoomDuration: Duration(milliseconds: 300),
            ),
            onTap: (tapPosition, point) {
              // Marker'lara tıklama kontrolü
              for (final location in state.locationHistory) {
                final distance = DistanceHelper.instance
                    .calculateDistanceBetweenPositions(
                      position1: LatLng(point.latitude, point.longitude),
                      position2: LatLng(location.latitude, location.longitude),
                    );
                // 50 metre içindeyse marker'a tıklanmış say
                if (distance < 50) {
                  LocationDetailBottomSheet.show(context, location);
                  return;
                }
              }
            },
          ),
          children: [
            // Harita sağlayıcısı
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.user_map_trace_app',
            ),

            // Rota Çizgisi (Yol bazlı)
            if (routePolyline.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePolyline,
                    strokeWidth: 6,
                    color: const Color(0xFF4F46E5),
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),
            MarkerLayer(
              alignment: Alignment.topCenter,
              markers: [
                // Başlangıç Noktası (İlk marker)
                if (points.isNotEmpty)
                  Marker(
                    point: points.first,
                    width: 40,
                    height: 40,
                    child: const StartMarkerWidget(),
                    rotate: true,
                  ),
                // Her 100m Marker'ları (İkinci marker'dan itibaren)
                ...state.locationHistory
                    .skip(1) // İlk marker'ı atla (start marker)
                    .map(
                      (location) => Marker(
                        point: LatLng(location.latitude, location.longitude),
                        width: 35,
                        height: 35,
                        child: MarkerWidget(location: location),
                        alignment: Alignment.topRight,
                        rotate: true,
                      ),
                    ),
                // Anlık Konum Marker'ı (Her zaman göster)
                if (state.currentLocation != null)
                  Marker(
                    point: state.currentLocation!,
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    child: const CurrentMarkerWidget(),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
