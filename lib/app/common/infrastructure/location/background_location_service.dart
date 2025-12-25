import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

LocationSettings get _createLocationSettings {
  return Platform.isIOS
      ? AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          activityType: ActivityType.fitness,
          distanceFilter: 10,
          allowBackgroundLocationUpdates: true,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        )
      : const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          timeLimit: null,
        );
}

Future<bool> _checkLocationPermissions(ServiceInstance service) async {
  try {
    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Konum Servisi Kapalı",
          content: "Lütfen konum servislerini açın",
        );
      }
      return false;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
        service.setForegroundNotificationInfo(
          title: "Konum İzni Gerekli",
          content: "Lütfen konum izni verin",
        );
      }
      return false;
    }
    return true;
  } catch (e) {
    return false;
  }
}

void _setupAndroidService(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "Martı Takip Aktif",
      content: "Konum takibi başlatılıyor...",
    );

    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
}

bool _shouldSavePosition(Position? lastPosition, Position currentPosition) {
  if (lastPosition == null) {
    return true;
  }
  final distance = Geolocator.distanceBetween(
    lastPosition.latitude,
    lastPosition.longitude,
    currentPosition.latitude,
    currentPosition.longitude,
  );
  return distance >= 100;
}

Map<String, dynamic> _createPositionData(Position position) {
  return {
    'lat': position.latitude,
    'lng': position.longitude,
    'timestamp': position.timestamp.toIso8601String(),
    'speed': position.speed,
    'accuracy': position.accuracy,
    'altitude': position.altitude,
    'heading': position.heading,
  };
}

void Function(Position) _createPositionHandler(
  ServiceInstance service,
  bool Function() isStopped,
  Position? Function() getLastPosition,
  void Function(Position) setLastPosition,
) {
  return (Position position) {
    if (isStopped()) {
      return;
    }

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Martı Takip Aktif",
        content: "Hız: ${position.speed.toStringAsFixed(1)} m/s",
      );
    }

    if (_shouldSavePosition(getLastPosition(), position)) {
      setLastPosition(position);
    }

    service.invoke('update', _createPositionData(position));
  };
}

void Function(Object) _createErrorHandler(
  ServiceInstance service,
  bool Function() isStopped,
) {
  return (Object error) {
    if (isStopped()) {
      return;
    }
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Konum Hatası",
        content: "Konum alınamıyor: ${error.toString()}",
      );
    }
    service.invoke('error', {'error': error.toString()});
  };
}

StreamSubscription<Position> _startLocationStream(
  ServiceInstance service,
  LocationSettings settings,
  bool Function() isStopped,
  Position? Function() getLastPosition,
  void Function(Position) setLastPosition,
) {
  return Geolocator.getPositionStream(locationSettings: settings).listen(
    _createPositionHandler(
      service,
      isStopped,
      getLastPosition,
      setLastPosition,
    ),
    onError: _createErrorHandler(service, isStopped),
    cancelOnError: false,
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final locationSettings = _createLocationSettings;
  StreamSubscription<Position>? locationSubscription;
  bool isStopped = false;
  Position? lastPosition;

  _setupAndroidService(service);

  service.on('stopService').listen((event) async {
    isStopped = true;
    await locationSubscription?.cancel();
    locationSubscription = null;
    if (service is AndroidServiceInstance) {
      service.stopSelf();
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  });

  service.on('restartService').listen((event) async {
    await locationSubscription?.cancel();
    locationSubscription = null;
    isStopped = false;
    lastPosition = null;

    final hasPermission = await _checkLocationPermissions(service);
    if (!hasPermission) {
      return;
    }

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    locationSubscription = _startLocationStream(
      service,
      _createLocationSettings,
      () => isStopped,
      () => lastPosition,
      (position) => lastPosition = position,
    );
  });

  final hasPermission = await _checkLocationPermissions(service);
  if (!hasPermission) {
    return;
  }

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  locationSubscription = _startLocationStream(
    service,
    locationSettings,
    () => isStopped,
    () => lastPosition,
    (position) => lastPosition = position,
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  onStart(service);
  return true;
}

class BackgroundLocationService {
  BackgroundLocationService._();
  static final BackgroundLocationService instance =
      BackgroundLocationService._();

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    service.on('update').listen((event) {
      if (event != null) {
        _controller.add(event);
      }
    });

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'marti_location_channel',
        initialNotificationTitle: 'Martı Takip',
        initialNotificationContent: 'Konum takibi aktif',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<bool> startService() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (isRunning) {
      service.invoke('restartService');
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    final result = await service.startService();
    return result;
  }

  Future<bool> stopService() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (!isRunning) {
      return true;
    }

    service.invoke('stopService');
    await Future.delayed(const Duration(milliseconds: 1000));

    final stillRunning = await service.isRunning();

    return !stillRunning;
  }

  Stream<Map<String, dynamic>> get locationStream => _controller.stream;

  Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}
