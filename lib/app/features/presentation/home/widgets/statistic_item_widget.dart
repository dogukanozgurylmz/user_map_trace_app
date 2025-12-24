import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';

class StatisticItemWidget extends StatelessWidget {
  const StatisticItemWidget({super.key});

  double _calculateTotalDistance(List<LatLng> routePolyline) {
    if (routePolyline.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < routePolyline.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        routePolyline[i].latitude,
        routePolyline[i].longitude,
        routePolyline[i + 1].latitude,
        routePolyline[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return distanceInMeters.toStringAsFixed(0);
    } else {
      return (distanceInMeters / 1000).toStringAsFixed(2);
    }
  }

  String _getDistanceUnit(double distanceInMeters) {
    return distanceInMeters < 1000 ? 'm' : 'km';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final totalDistance = _calculateTotalDistance(state.routePolyline);
        final formattedDistance = _formatDistance(totalDistance);
        final unit = _getDistanceUnit(totalDistance);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
                children: [
                  const TextSpan(text: "Harika, "),
                  TextSpan(
                    text: formattedDistance,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF34D100),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: "$unit ",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF34D100),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: "ilerledin"),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
