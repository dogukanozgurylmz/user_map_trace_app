import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'i_permissions_service.dart';
import 'package:user_map_trace_app/core/logger/app_logger.dart';

final class PermissionsService implements IPermissionsService {
  const PermissionsService();

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
    if (Platform.isIOS) {
      final geolocatorPermission = await Geolocator.checkPermission();
      AppLogger.instance.log(
        "iOS arka plan izni kontrolü: $geolocatorPermission",
      );
      return geolocatorPermission == LocationPermission.always;
    }
    final permission = await Permission.locationAlways.status;
    return permission.isGranted;
  }

  @override
  Future<bool> requestBackgroundLocationPermission() async {
    if (Platform.isIOS) {
      final geolocatorPermission = await Geolocator.checkPermission();
      if (geolocatorPermission == LocationPermission.denied ||
          geolocatorPermission == LocationPermission.deniedForever) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission != LocationPermission.whileInUse &&
            requestedPermission != LocationPermission.always) {
          return false;
        }
      }
      final permission = await Permission.locationAlways.request();
      if (permission.isPermanentlyDenied) {
        return false;
      }
      final finalPermission = await Geolocator.checkPermission();
      return finalPermission == LocationPermission.always;
    }
    final permission = await Permission.locationAlways.request();
    return permission.isGranted;
  }
}
