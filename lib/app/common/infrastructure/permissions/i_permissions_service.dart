import 'package:geolocator/geolocator.dart';

abstract class IPermissionsService {
  Future<LocationPermission> checkLocationPermission();
  Future<LocationPermission> requestLocationPermission();
  Future<bool> hasLocationPermission();
  Future<bool> hasBackgroundLocationPermission();
  Future<bool> requestBackgroundLocationPermission();
}
