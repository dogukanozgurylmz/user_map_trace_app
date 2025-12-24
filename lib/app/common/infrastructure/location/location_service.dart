import 'package:geolocator/geolocator.dart';

import 'i_location_service.dart';

final class LocationService implements ILocationService {
  const LocationService();

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return await Geolocator.getCurrentPosition(
      locationSettings:
          locationSettings ??
          const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  @override
  Stream<Position> watchPosition({LocationSettings? locationSettings}) {
    return Geolocator.getPositionStream(
      locationSettings:
          locationSettings ??
          const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
    );
  }

  @override
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }
}
