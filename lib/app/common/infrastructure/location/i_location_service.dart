import 'package:geolocator/geolocator.dart';

abstract class ILocationService {
  Future<bool> isLocationServiceEnabled();
  Future<Position> getCurrentPosition({LocationSettings? locationSettings});
  Stream<Position> watchPosition({LocationSettings? locationSettings});
  Future<Position?> getLastKnownPosition();
}
