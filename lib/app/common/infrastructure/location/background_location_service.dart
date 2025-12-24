import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user_map_trace_app/core/logger/app_logger.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  AppLogger.instance.log("Konum servisi başlatılıyor...");
  DartPluginRegistrant.ensureInitialized();

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );

  StreamSubscription<Position>? locationSubscription;
  bool isStopped = false;
  Position? lastPosition;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      AppLogger.instance.log("Konum servisi foreground moduna geçiliyor...");
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      AppLogger.instance.log("Konum servisi background moduna geçiliyor...");
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) async {
    AppLogger.instance.log("Konum servisi durduruluyor...");
    isStopped = true;
    if (locationSubscription != null) {
      AppLogger.instance.log("Konum stream iptal ediliyor...");
      await locationSubscription!.cancel();
      locationSubscription = null;
    }
    if (service is AndroidServiceInstance) {
      service.stopSelf();
    } else {
      AppLogger.instance.log("iOS servisi durduruluyor...");
      await Future.delayed(const Duration(milliseconds: 100));
    }
  });

  service.on('restartService').listen((event) async {
    AppLogger.instance.log("Konum servisi yeniden başlatılıyor...");
    if (locationSubscription != null) {
      AppLogger.instance.log("Eski stream iptal ediliyor...");
      await locationSubscription!.cancel();
      locationSubscription = null;
    }
    isStopped = false;
    lastPosition = null;

    try {
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        AppLogger.instance.log("Konum servisi etkin değil...");
        return;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        AppLogger.instance.log("Konum izni yok...");
        return;
      }

      locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              if (isStopped) {
                AppLogger.instance.log(
                  "Konum servisi durduruldu, konum alınmayacak",
                );
                return;
              }

              if (service is AndroidServiceInstance) {
                service.setForegroundNotificationInfo(
                  title: "Martı Takip Aktif",
                  content: "Hız: ${position.speed.toStringAsFixed(1)} m/s",
                );
              }

              bool shouldSave = false;

              if (lastPosition == null) {
                AppLogger.instance.log("Konum servisi ilk konum...");
                shouldSave = true;
              } else {
                AppLogger.instance.log("Konum servisi sonraki konum...");
                final distance = Geolocator.distanceBetween(
                  lastPosition!.latitude,
                  lastPosition!.longitude,
                  position.latitude,
                  position.longitude,
                );

                // Daha sık konum gönder (yol uzunluğu kontrolü için)
                // HomeCubit'te yol uzunluğuna göre 100m kontrolü yapılacak
                if (distance >= 20) {
                  AppLogger.instance.log("Konum servisi 20 metre fark var...");
                  shouldSave = true;
                }
              }

              if (shouldSave) {
                AppLogger.instance.log("Konum servisi kaydediliyor...");
                final newData = <String, dynamic>{
                  'lat': position.latitude,
                  'lng': position.longitude,
                  'timestamp': position.timestamp.toIso8601String(),
                  'speed': position.speed,
                  'accuracy': position.accuracy,
                  'altitude': position.altitude,
                  'heading': position.heading,
                };

                AppLogger.instance.log("Konum servisi güncellendi: $newData");
                service.invoke('update', newData);

                lastPosition = position;
              }
            },
            onError: (error) {
              if (isStopped) {
                AppLogger.instance.log(
                  "Konum servisi durduruldu, hata yok sayılıyor",
                );
                return;
              }
              AppLogger.instance.error("Konum stream hatası: $error");
              if (service is AndroidServiceInstance) {
                service.setForegroundNotificationInfo(
                  title: "Konum Hatası",
                  content: "Konum alınamıyor: ${error.toString()}",
                );
              }
              service.invoke('error', {'error': error.toString()});
            },
            cancelOnError: false,
          );
      AppLogger.instance.log("Konum servisi yeniden başlatıldı");
    } catch (e) {
      AppLogger.instance.error("Konum servisi yeniden başlatma hatası: $e");
    }
  });

  try {
    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
    AppLogger.instance.log("Konum servisi etkin mi: $isLocationServiceEnabled");
    if (!isLocationServiceEnabled) {
      AppLogger.instance.log("Konum servisi etkin değil...");
      if (service is AndroidServiceInstance) {
        AppLogger.instance.log("Konum servisi foreground moduna geçiliyor...");
        service.setForegroundNotificationInfo(
          title: "Konum Servisi Kapalı",
          content: "Lütfen konum servislerini açın",
        );
      }
      return;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (service is AndroidServiceInstance) {
        AppLogger.instance.log("Konum servisi foreground moduna geçiliyor...");
        service.setForegroundNotificationInfo(
          title: "Konum İzni Gerekli",
          content: "Lütfen konum izni verin",
        );
      }
      return;
    }
  } catch (e) {
    AppLogger.instance.error("Konum izni kontrolü hatası: $e");
    return;
  }

  locationSubscription =
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          if (isStopped) {
            AppLogger.instance.log(
              "Konum servisi durduruldu, konum alınmayacak",
            );
            return;
          }

          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "Martı Takip Aktif",
              content: "Hız: ${position.speed.toStringAsFixed(1)} m/s",
            );
          }

          bool shouldSave = false;

          if (lastPosition == null) {
            AppLogger.instance.log("Konum servisi ilk konum...");
            shouldSave = true;
          } else {
            AppLogger.instance.log("Konum servisi sonraki konum...");
            final distance = Geolocator.distanceBetween(
              lastPosition!.latitude,
              lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            if (distance >= 100) {
              AppLogger.instance.log("Konum servisi 100 metre fark var...");
              shouldSave = true;
            }
          }

          if (shouldSave) {
            AppLogger.instance.log("Konum servisi kaydediliyor...");
            final newData = <String, dynamic>{
              'lat': position.latitude,
              'lng': position.longitude,
              'timestamp': position.timestamp.toIso8601String(),
              'speed': position.speed,
              'accuracy': position.accuracy,
              'altitude': position.altitude,
              'heading': position.heading,
            };

            AppLogger.instance.log("Konum servisi güncellendi: $newData");
            service.invoke('update', newData);

            lastPosition = position;
          }
        },
        onError: (error) {
          if (isStopped) {
            AppLogger.instance.log(
              "Konum servisi durduruldu, hata yok sayılıyor",
            );
            return;
          }
          AppLogger.instance.error("Konum stream hatası: $error");
          if (service is AndroidServiceInstance) {
            AppLogger.instance.log("Konum hatası: ${error.toString()}");
            service.setForegroundNotificationInfo(
              title: "Konum Hatası",
              content: "Konum alınamıyor: ${error.toString()}",
            );
          }
          AppLogger.instance.log("Konum hatası: ${error.toString()}");
          service.invoke('error', {'error': error.toString()});
        },
        cancelOnError: false,
      );
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  AppLogger.instance.log("IOS servis başlatılıyor...");
  service.invoke('update', {'message': 'IOS servis başlatılıyor...'});
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
        AppLogger.instance.log("IOS servis güncellendi: $event");
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
        initialNotificationContent: 'Servis başlatılıyor...',
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
    AppLogger.instance.log("Servis başlatılıyor...");
    final isRunning = await service.isRunning();
    AppLogger.instance.log("Servis çalışıyor mu: $isRunning");

    if (isRunning) {
      AppLogger.instance.log(
        "Servis zaten çalışıyor, restart event gönderiliyor...",
      );
      service.invoke('restartService');
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    final result = await service.startService();
    AppLogger.instance.log("Servis başlatma sonucu: $result");
    return result;
  }

  Future<bool> stopService() async {
    final service = FlutterBackgroundService();
    AppLogger.instance.log("Servis durduruluyor...");
    final isRunning = await service.isRunning();
    AppLogger.instance.log("Servis çalışıyor mu: $isRunning");

    if (!isRunning) {
      AppLogger.instance.log("Servis zaten çalışmıyor");
      return true;
    }

    service.invoke('stopService');
    await Future.delayed(const Duration(milliseconds: 1000));

    final stillRunning = await service.isRunning();
    AppLogger.instance.log(
      "Servis durdurulduktan sonra çalışıyor mu: $stillRunning",
    );

    return !stillRunning;
  }

  Stream<Map<String, dynamic>> get locationStream => _controller.stream;
}
