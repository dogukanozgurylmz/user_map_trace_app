import 'package:latlong2/latlong.dart';

abstract class IRoutingService {
  Future<List<LatLng>?> getRouteBetweenPoints(LatLng start, LatLng end);
  Future<double?> getRouteDistance(LatLng start, LatLng end);
}
