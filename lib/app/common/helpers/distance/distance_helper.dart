import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final class DistanceHelper {
  DistanceHelper._();

  static final DistanceHelper instance = DistanceHelper._();

  static const double defaultThreshold = 100.0;

  double calculateDistance({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    const distance = Distance();
    return distance.as(
      LengthUnit.Meter,
      LatLng(latitude1, longitude1),
      LatLng(latitude2, longitude2),
    );
  }

  double calculateDistanceBetweenPositions({
    required Position position1,
    required Position position2,
  }) {
    return calculateDistance(
      latitude1: position1.latitude,
      longitude1: position1.longitude,
      latitude2: position2.latitude,
      longitude2: position2.longitude,
    );
  }

  bool isDistanceThresholdExceeded({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
    double threshold = defaultThreshold,
  }) {
    final distance = calculateDistance(
      latitude1: latitude1,
      longitude1: longitude1,
      latitude2: latitude2,
      longitude2: longitude2,
    );
    return distance >= threshold;
  }

  bool isDistanceThresholdExceededBetweenPositions({
    required Position position1,
    required Position position2,
    double threshold = defaultThreshold,
  }) {
    return isDistanceThresholdExceeded(
      latitude1: position1.latitude,
      longitude1: position1.longitude,
      latitude2: position2.latitude,
      longitude2: position2.longitude,
      threshold: threshold,
    );
  }
}
