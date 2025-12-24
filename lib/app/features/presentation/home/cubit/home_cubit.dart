import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orange_sdk/orange_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/common/infrastructure/location/background_location_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/location/i_location_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/permissions/i_permissions_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/routing/i_routing_service.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:user_map_trace_app/app/features/data/repositories/location_repository.dart';
import 'package:user_map_trace_app/core/logger/app_logger.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required LocationRepository locationRepository,
    required ILocationService locationService,
    required IPermissionsService permissionsService,
    required IRoutingService routingService,
  }) : _locationRepository = locationRepository,
       _locationService = locationService,
       _permissionsService = permissionsService,
       _routingService = routingService,
       super(const HomeState()) {
    _init();
  }

  final LocationRepository _locationRepository;
  final ILocationService _locationService;
  final IPermissionsService _permissionsService;
  final IRoutingService _routingService;

  StreamSubscription? _locationSubscription;

  final MapController mapController = MapController();

  Future<void> _init() async {
    await getCurrentLocation();
    _loadHistory();
    _locationSubscription = BackgroundLocationService.instance.locationStream
        .listen((data) {
          _onNewLocationReceived(data);
        });
  }

  Future<void> _loadHistory() async {
    List<LatLng> history = [];
    List<LocationModel> locationHistory = [];

    final data = await _locationRepository.getAllLocations();
    if (!data.success) {
      AppLogger.instance.error(data.message ?? 'Failed to load history');
      OrangeSnackBar.error(message: data.message ?? 'Failed to load history');
      return;
    }
    final locations = data.data ?? <LocationModel>[];
    for (var item in locations) {
      history.add(LatLng(item.latitude, item.longitude));
      locationHistory.add(item);
    }

    // Geçmiş veriler için marker'lar arası routing yap - her zaman yol bazlı
    List<LatLng> routePolyline = [];
    if (history.length >= 2) {
      for (int i = 0; i < history.length - 1; i++) {
        final start = history[i];
        final end = history[i + 1];

        // Her zaman routing yap (mesafe fark etmeksizin)
        final route = await _routingService.getRouteBetweenPoints(start, end);
        if (route != null && route.isNotEmpty) {
          if (i == 0) {
            // İlk segment için tüm noktaları ekle
            routePolyline.addAll(route);
          } else {
            // Sonraki segmentler için ilk noktayı atla (zaten var)
            routePolyline.addAll(route.skip(1));
          }
        } else {
          // Routing başarısız olursa düz çizgi kullan (fallback)
          if (i == 0) {
            routePolyline.add(start);
          }
          routePolyline.add(end);
        }
      }
    } else if (history.isNotEmpty) {
      // Tek nokta varsa direkt ekle
      routePolyline = history;
    }

    emit(
      state.copyWith(
        routeHistory: history,
        locationHistory: locationHistory,
        routePolyline: routePolyline.isNotEmpty ? routePolyline : history,
        currentLocation: history.isNotEmpty
            ? history.last
            : (state.currentLocation ?? const LatLng(41.0082, 28.9784)),
      ),
    );
  }

  void _onNewLocationReceived(Map<String, dynamic> data) async {
    final newPoint = LatLng(
      (data['lat'] as num).toDouble(),
      (data['lng'] as num).toDouble(),
    );

    // Son marker'dan itibaren yol uzunluğunu kontrol et
    bool shouldSaveMarker = false;
    final currentState = state;

    if (currentState.locationHistory.isEmpty) {
      // İlk marker - direkt kaydet
      shouldSaveMarker = true;
    } else {
      // Son marker'dan itibaren yol uzunluğunu hesapla
      // İkinci marker ve sonrası için mutlaka 100m kontrolü yap
      final lastMarker = currentState.locationHistory.last;
      final routeDistance = await _routingService.getRouteDistance(
        LatLng(lastMarker.latitude, lastMarker.longitude),
        newPoint,
      );

      if (routeDistance != null && routeDistance >= 100) {
        // Yol uzunluğu 100m'yi geçti - marker kaydet
        shouldSaveMarker = true;
      } else if (routeDistance == null) {
        // Routing başarısız oldu - düz mesafe kontrolü yap
        final straightDistance = Geolocator.distanceBetween(
          lastMarker.latitude,
          lastMarker.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );
        if (straightDistance >= 100) {
          shouldSaveMarker = true;
        }
      }
      // Yol uzunluğu 100m'den azsa marker kaydetme
    }

    // Heading bilgisini al
    final heading = data['heading'] != null
        ? (data['heading'] as num).toDouble()
        : null;

    // Sadece marker kaydedilecekse işlem yap
    if (!shouldSaveMarker) {
      // Marker kaydetme ama currentLocation'ı ve heading'i güncelle
      emit(
        currentState.copyWith(
          currentLocation: newPoint,
          currentHeading: heading,
        ),
      );
      return;
    }

    final locationModel = LocationModel(
      latitude: (data['lat'] as num).toDouble(),
      longitude: (data['lng'] as num).toDouble(),
      accuracy: data['accuracy'] != null
          ? (data['accuracy'] as num).toDouble()
          : null,
      altitude: data['altitude'] != null
          ? (data['altitude'] as num).toDouble()
          : null,
      speed: data['speed'] != null ? (data['speed'] as num).toDouble() : null,
      heading: data['heading'] != null
          ? (data['heading'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(data['timestamp'] as String),
    );

    await _locationRepository.saveLocation(locationModel);

    // State'i tekrar oku (race condition önlemek için)
    final latestState = state;
    final updatedList = List<LatLng>.from(latestState.routeHistory)
      ..add(newPoint);
    final updatedLocationHistory = List<LocationModel>.from(
      latestState.locationHistory,
    )..add(locationModel);

    // Marker'lar arası routing yap (background'da, başarısız olursa düz çizgi)
    List<LatLng> updatedPolyline = List<LatLng>.from(latestState.routePolyline);
    if (updatedList.length >= 2) {
      final lastPoint = updatedList[updatedList.length - 2];

      // Önce düz çizgi ekle (hızlı görünsün)
      updatedPolyline.add(newPoint);

      // Background'da routing yap ve güncelle
      _routingService
          .getRouteBetweenPoints(lastPoint, newPoint)
          .then((route) {
            if (route != null && route.isNotEmpty) {
              // Düz çizgiyi kaldır ve routing sonucunu ekle
              final currentStateSnapshot = state;
              final currentPolyline = List<LatLng>.from(
                currentStateSnapshot.routePolyline,
              );
              if (currentPolyline.isNotEmpty &&
                  currentPolyline.last.latitude == newPoint.latitude &&
                  currentPolyline.last.longitude == newPoint.longitude) {
                currentPolyline.removeLast();
                currentPolyline.addAll(route.skip(1));
                emit(
                  currentStateSnapshot.copyWith(routePolyline: currentPolyline),
                );
              }
            }
          })
          .catchError((e) {
            AppLogger.instance.error('Background routing hatası: $e');
          });
    } else {
      // İlk nokta - direkt ekle
      updatedPolyline.add(newPoint);
    }

    emit(
      latestState.copyWith(
        routeHistory: updatedList,
        locationHistory: updatedLocationHistory,
        currentLocation: newPoint,
        routePolyline: updatedPolyline,
        followLocation: true,
        currentHeading: heading,
      ),
    );

    // Haritayı otomatik takip et
    final finalState = state;
    if (finalState.followLocation && finalState.currentLocation != null) {
      moveToLocation(newPoint);
    }
  }

  Future<void> toggleTracking(BuildContext context) async {
    if (state.isTracking) {
      await BackgroundLocationService.instance.stopService();
      emit(state.copyWith(isTracking: false));
    } else {
      final hasPermission = await _permissionsService.hasLocationPermission();
      if (!hasPermission) {
        final permission = await _permissionsService
            .requestLocationPermission();
        if (permission == LocationPermission.deniedForever) {
          AppLogger.instance.error(AppStrings.locationPermissionDeniedForever);
          OrangeSnackBar.error(
            message: AppStrings.locationPermissionDeniedForever,
          );
          await openAppSettings();
          return;
        }
        if (permission == LocationPermission.denied) {
          AppLogger.instance.error(AppStrings.locationPermissionDenied);
          OrangeSnackBar.error(message: AppStrings.locationPermissionDenied);
          return;
        }
      }

      if (Platform.isIOS) {
        final geolocatorPermission = await _permissionsService
            .checkLocationPermission();
        AppLogger.instance.log("iOS konum izni durumu: $geolocatorPermission");

        final hasBackgroundPermission = await _permissionsService
            .hasBackgroundLocationPermission();
        AppLogger.instance.log(
          "iOS arka plan izni var mı: $hasBackgroundPermission",
        );

        if (!hasBackgroundPermission) {
          if (geolocatorPermission == LocationPermission.always) {
            AppLogger.instance.log(
              "Geolocator always izni var ama kontrol başarısız, servis başlatılıyor...",
            );
          } else {
            AppLogger.instance.log("iOS arka plan izni isteniyor...");

            final shouldRequest = await _showBackgroundPermissionDialog(
              context,
            );
            if (!shouldRequest) {
              return;
            }

            final backgroundGranted = await _permissionsService
                .requestBackgroundLocationPermission();
            if (!backgroundGranted) {
              AppLogger.instance.error("iOS arka plan izni reddedildi");
              final finalPermission = await _permissionsService
                  .hasBackgroundLocationPermission();
              if (!finalPermission) {
                OrangeSnackBar.error(
                  message:
                      "Arka planda konum takibi için 'Her Zaman' izni gereklidir",
                );
              }
              return;
            }
          }
        }
      }

      await BackgroundLocationService.instance.startService();
      emit(state.copyWith(isTracking: true, followLocation: true));
    }
  }

  Future<void> resetRoute() async {
    await _locationRepository.clearAllLocations();

    emit(
      state.copyWith(
        routeHistory: [],
        locationHistory: [],
        routePolyline: [],
        currentLocation: null,
        selectedLocationModel: null,
      ),
    );
  }

  Future<void> saveCurrentRoute() async {
    if (state.locationHistory.isEmpty) {
      AppLogger.instance.log("Kaydedilecek yolculuk yok");
      return;
    }

    try {
      final route = RouteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name:
            "Yolculuk ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        startDate: state.locationHistory.first.timestamp,
        endDate: state.locationHistory.last.timestamp,
        locations: List.from(state.locationHistory),
      );

      final result = await _locationRepository.saveRoute(route);
      if (result.success) {
        AppLogger.instance.log("Yolculuk kaydedildi: ${route.id}");
        OrangeSnackBar.success(message: AppStrings.routeSaved);
      } else {
        AppLogger.instance.error("Yolculuk kaydedilemedi: ${result.message}");
        OrangeSnackBar.error(
          message: result.message ?? "Yolculuk kaydedilemedi",
        );
      }
    } catch (e) {
      AppLogger.instance.error("Yolculuk kaydetme hatası: $e");
      OrangeSnackBar.error(message: "Yolculuk kaydedilemedi: $e");
    }
  }

  void toggleFollowLocation() {
    emit(state.copyWith(followLocation: !state.followLocation));
  }

  void selectLocationModel(LocationModel? locationModel) {
    emit(state.copyWith(selectedLocationModel: locationModel));
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";
      }
      return "Adres bulunamadı";
    } catch (e) {
      return "Adres hatası: $e";
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }

  Future<void> startService(BuildContext context) async {
    try {
      final hasPermission = await _permissionsService.hasLocationPermission();
      if (!hasPermission) {
        final permission = await _permissionsService
            .requestLocationPermission();
        if (permission == LocationPermission.deniedForever) {
          AppLogger.instance.error(AppStrings.locationPermissionDeniedForever);
          OrangeSnackBar.error(
            message: AppStrings.locationPermissionDeniedForever,
          );
          await openAppSettings();
          return;
        }
        if (permission == LocationPermission.denied) {
          AppLogger.instance.error(AppStrings.locationPermissionDenied);
          OrangeSnackBar.error(message: AppStrings.locationPermissionDenied);
          return;
        }
      }

      if (Platform.isIOS) {
        final geolocatorPermission = await _permissionsService
            .checkLocationPermission();
        AppLogger.instance.log("iOS konum izni durumu: $geolocatorPermission");

        final hasBackgroundPermission = await _permissionsService
            .hasBackgroundLocationPermission();
        AppLogger.instance.log(
          "iOS arka plan izni var mı: $hasBackgroundPermission",
        );

        if (!hasBackgroundPermission) {
          if (geolocatorPermission == LocationPermission.always) {
            AppLogger.instance.log(
              "Geolocator always izni var ama kontrol başarısız, servis başlatılıyor...",
            );
          } else {
            AppLogger.instance.log("iOS arka plan izni isteniyor...");

            final shouldRequest = await _showBackgroundPermissionDialog(
              context,
            );
            if (!shouldRequest) {
              return;
            }

            final backgroundGranted = await _permissionsService
                .requestBackgroundLocationPermission();
            if (!backgroundGranted) {
              AppLogger.instance.error("iOS arka plan izni reddedildi");
              final finalPermission = await _permissionsService
                  .hasBackgroundLocationPermission();
              if (!finalPermission) {
                OrangeSnackBar.error(
                  message:
                      "Arka planda konum takibi için 'Her Zaman' izni gereklidir",
                );
              }
              return;
            }
          }
        }
      }

      await BackgroundLocationService.instance.startService();
      emit(state.copyWith(isTracking: true, followLocation: true));
    } catch (e) {
      AppLogger.instance.error("Servis başlatma hatası: $e");
      OrangeSnackBar.error(message: "Servis başlatılamadı: $e");
    }
  }

  Future<void> stopService() async {
    await BackgroundLocationService.instance.stopService();
    emit(state.copyWith(isTracking: false));
  }

  Future<void> getCurrentLocation() async {
    try {
      final isLocationEnabled = await _locationService
          .isLocationServiceEnabled();
      if (!isLocationEnabled) {
        AppLogger.instance.error(AppStrings.locationServiceDisabled);
        OrangeSnackBar.error(message: AppStrings.locationServiceDisabled);
        return;
      }

      final hasPermission = await _permissionsService.hasLocationPermission();
      if (!hasPermission) {
        final permission = await _permissionsService
            .requestLocationPermission();

        if (permission == LocationPermission.deniedForever) {
          AppLogger.instance.error(AppStrings.locationPermissionDeniedForever);
          OrangeSnackBar.error(
            message: AppStrings.locationPermissionDeniedForever,
          );
          await openAppSettings();
          return;
        }

        if (permission == LocationPermission.denied) {
          AppLogger.instance.error(AppStrings.locationPermissionDenied);
          OrangeSnackBar.error(message: AppStrings.locationPermissionDenied);
          return;
        }
      }

      final currentPosition = await _locationService.getCurrentPosition();
      emit(
        state.copyWith(
          currentLocation: LatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          ),
          currentHeading: currentPosition.heading,
        ),
      );
      moveToLocation(
        LatLng(currentPosition.latitude, currentPosition.longitude),
      );
    } on PermissionDeniedException catch (e) {
      AppLogger.instance.error("${AppStrings.locationPermissionDenied}: $e");
      OrangeSnackBar.error(message: AppStrings.locationPermissionDeniedForever);
      await openAppSettings();
    } catch (e) {
      AppLogger.instance.error("${AppStrings.locationError}: $e");
      OrangeSnackBar.error(message: "${AppStrings.locationError}: $e");
    }
  }

  void moveToLocation(LatLng location) {
    mapController.moveAndRotate(location, 15, 0);
  }

  Future<bool> _showBackgroundPermissionDialog(BuildContext context) async {
    OrangeDialog.blur(
      context: context,
      title: AppStrings.backgroundLocationPermissionRequired,
      message: AppStrings.backgroundLocationPermissionMessage,
      actions: [
        OrangeDialogAction(
          label: AppStrings.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        OrangeDialogAction(
          label: AppStrings.goToSettings,
          onPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
        ),
      ],
    );
    return false;
  }
}
