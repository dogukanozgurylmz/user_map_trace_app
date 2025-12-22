import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

final class DeviceInfoHelper {
  DeviceInfoHelper._();

  static final DeviceInfoHelper instance = DeviceInfoHelper._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _deviceId;

  /// Method to initialize device identity
  Future<void> init() async {
    _deviceId = await _getDeviceId();
    log('Device ID initialized: $_deviceId');
  }

  /// Method returning the device ID
  Future<String?> _getDeviceId() async {
    if (_deviceId != null) return _deviceId; // Recall if already received

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      }
    } catch (e, stackTrace) {
      log('Error getting device ID: $e', stackTrace: stackTrace);
    }

    return _deviceId;
  }

  /// Returns the cached device ID
  String? get deviceId {
    if (_deviceId == null) {
      log('Warning: Device ID is accessed before initialization!');
    }
    return _deviceId;
  }
}
