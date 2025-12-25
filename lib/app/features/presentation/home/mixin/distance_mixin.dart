import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/common/helpers/distance/distance_helper.dart';

mixin DistanceMixin {
  double calculateTotalDistance(List<LatLng> routePolyline) {
    if (routePolyline.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < routePolyline.length - 1; i++) {
      totalDistance += DistanceHelper.instance
          .calculateDistanceBetweenPositions(
            position1: LatLng(
              routePolyline[i].latitude,
              routePolyline[i].longitude,
            ),
            position2: LatLng(
              routePolyline[i + 1].latitude,
              routePolyline[i + 1].longitude,
            ),
          );
    }
    return totalDistance;
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return distanceInMeters.toStringAsFixed(0);
    } else {
      return (distanceInMeters / 1000).toStringAsFixed(2);
    }
  }

  String getDistanceUnit(double distanceInMeters) {
    return distanceInMeters < 1000 ? 'm' : 'km';
  }
}
