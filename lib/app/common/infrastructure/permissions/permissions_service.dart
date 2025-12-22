import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'i_permissions_service.dart';

final class PermissionsService implements IPermissionsService {
  PermissionsService._();

  static final PermissionsService instance = PermissionsService._();

  @override
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await checkLocationPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  @override
  Future<bool> hasBackgroundLocationPermission() async {
    final permission = await Permission.locationAlways.status;
    return permission.isGranted;
  }

  @override
  Future<bool> requestBackgroundLocationPermission() async {
    final permission = await Permission.locationAlways.request();
    return permission.isGranted;
  }
}
