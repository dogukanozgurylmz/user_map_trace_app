import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';

mixin RouteMapMixin {
  List<LatLng> getRoutePoints(RouteModel route) {
    return route.locations
        .map((location) => LatLng(location.latitude, location.longitude))
        .toList();
  }

  LatLng getRouteCenterPoint(RouteModel route) {
    if (route.locations.isEmpty) {
      return const LatLng(41.0082, 28.9784);
    }
    final points = getRoutePoints(route);
    final avgLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final avgLng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(avgLat, avgLng);
  }

  LatLngBounds getRouteBounds(RouteModel route) {
    if (route.locations.isEmpty) {
      return LatLngBounds(
        const LatLng(41.0082, 28.9784),
        const LatLng(41.0082, 28.9784),
      );
    }
    final points = getRoutePoints(route);
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }
}
