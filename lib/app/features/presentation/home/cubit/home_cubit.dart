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
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:user_map_trace_app/app/features/data/repositories/location_repository.dart';
import 'package:user_map_trace_app/app/features/data/repositories/route_repository.dart';
import 'package:user_map_trace_app/core/logger/app_logger.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required LocationRepository locationRepository,
    required RouteRepository routeRepository,
    required ILocationService locationService,
    required IPermissionsService permissionsService,
  }) : _locationRepository = locationRepository,
       _routeRepository = routeRepository,
       _locationService = locationService,
       _permissionsService = permissionsService,
       super(const HomeState()) {
    _init();
  }

  final LocationRepository _locationRepository;
  final RouteRepository _routeRepository;
  final ILocationService _locationService;
  final IPermissionsService _permissionsService;

  StreamSubscription<Map<String, dynamic>>? _locationSubscription;

  final MapController mapController = MapController();

  final double _minDistanceForMarker = 100.0;
  final double _maxAccuracyForSave = 50.0;
  final double _maxAccuracyForRouting = 30.0;

  Future<bool> _requestLocationPermissionIfNeeded() async {
    final hasPermission = await _permissionsService.hasLocationPermission();
    if (hasPermission) {
      return true;
    }

    final permission = await _permissionsService.requestLocationPermission();
    if (permission == LocationPermission.deniedForever) {
      AppLogger.instance.error(AppStrings.locationPermissionDeniedForever);
      OrangeSnackBar.error(message: AppStrings.locationPermissionDeniedForever);
      await openAppSettings();
      return false;
    }
    if (permission == LocationPermission.denied) {
      AppLogger.instance.error(AppStrings.locationPermissionDenied);
      OrangeSnackBar.error(message: AppStrings.locationPermissionDenied);
      return false;
    }
    return true;
  }

  Future<bool> _handleIosBackgroundPermission(BuildContext context) async {
    if (!Platform.isIOS) {
      return true;
    }

    final geolocatorPermission = await _permissionsService
        .checkLocationPermission();
    AppLogger.instance.log("iOS konum izni durumu: $geolocatorPermission");

    final hasBackgroundPermission = await _permissionsService
        .hasBackgroundLocationPermission();
    AppLogger.instance.log(
      "iOS arka plan izni var mı: $hasBackgroundPermission",
    );

    if (hasBackgroundPermission) {
      return true;
    }

    if (geolocatorPermission == LocationPermission.always) {
      AppLogger.instance.log(
        "Geolocator always izni var ama kontrol başarısız, servis başlatılıyor...",
      );
      return true;
    }

    AppLogger.instance.log("iOS arka plan izni isteniyor...");

    if (context.mounted) {
      final shouldRequest = await _showBackgroundPermissionDialog(context);
      if (!shouldRequest) {
        return false;
      }
    }

    final backgroundGranted = await _permissionsService
        .requestBackgroundLocationPermission();
    if (!backgroundGranted) {
      AppLogger.instance.error("iOS arka plan izni reddedildi");
      final finalPermission = await _permissionsService
          .hasBackgroundLocationPermission();
      if (!finalPermission) {
        OrangeSnackBar.error(
          message: "Arka planda konum takibi için 'Her Zaman' izni gereklidir",
        );
      }
      return false;
    }

    return true;
  }

  LocationModel _createLocationModelFromData(Map<String, dynamic> data) {
    return LocationModel(
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
  }

  Map<String, dynamic> _extractLocationData(Map<String, dynamic> data) {
    return {
      'point': LatLng(
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      ),
      'accuracy': data['accuracy'] != null
          ? (data['accuracy'] as num).toDouble()
          : null,
      'heading': data['heading'] != null
          ? (data['heading'] as num).toDouble()
          : null,
    };
  }

  Future<bool> _shouldSaveMarker(LatLng newPoint) async {
    final currentState = state;
    if (currentState.locationHistory.isEmpty) {
      return true;
    }

    final lastMarker = currentState.locationHistory.last;
    final straightDistance = Geolocator.distanceBetween(
      lastMarker.latitude,
      lastMarker.longitude,
      newPoint.latitude,
      newPoint.longitude,
    );

    if (straightDistance < _minDistanceForMarker) {
      return false;
    }

    final routeDistance = await _routeRepository.getRouteDistance(
      LatLng(lastMarker.latitude, lastMarker.longitude),
      newPoint,
    );

    if (!routeDistance.success) {
      AppLogger.instance.error(
        routeDistance.message ?? 'Failed to fetch route distance',
      );
      OrangeSnackBar.error(
        message: routeDistance.message ?? 'Failed to fetch route distance',
      );
      return false;
    }

    final routeDistanceData = routeDistance.data ?? 0;
    return routeDistanceData >= _minDistanceForMarker ||
        straightDistance >= _minDistanceForMarker;
  }

  Future<List<LatLng>> _buildRoutePolylineForHistory(
    List<LatLng> history,
  ) async {
    if (history.length < 2) {
      return history;
    }

    final List<LatLng> routePolyline = [];
    for (int i = 0; i < history.length - 1; i++) {
      final start = history[i];
      final end = history[i + 1];

      final route = await _routeRepository.getRouteBetweenPoints(start, end);
      if (!route.success) {
        AppLogger.instance.error(route.message ?? 'Failed to fetch route');
        OrangeSnackBar.error(message: route.message ?? 'Failed to fetch route');
        return [];
      }

      final routeData = route.data ?? [];
      if (routeData.isNotEmpty) {
        if (i == 0) {
          routePolyline.addAll(routeData);
        } else {
          routePolyline.addAll(routeData.skip(1));
        }
      } else {
        if (i == 0) {
          routePolyline.add(start);
        }
        routePolyline.add(end);
      }
    }

    return routePolyline;
  }

  void _updatePolylineWithRoute(
    List<LatLng> currentPolyline,
    LatLng lastPoint,
    LatLng newPoint,
    LocationModel lastLocation,
    LocationModel currentLocation,
  ) {
    final lastAccuracy = lastLocation.accuracy ?? double.infinity;
    final currentAccuracy = currentLocation.accuracy ?? double.infinity;

    currentPolyline.add(newPoint);

    if (lastAccuracy > _maxAccuracyForRouting ||
        currentAccuracy > _maxAccuracyForRouting) {
      return;
    }

    _routeRepository
        .getRouteBetweenPoints(lastPoint, newPoint)
        .then((route) {
          if (!route.success) {
            AppLogger.instance.error(route.message ?? 'Failed to fetch route');
            OrangeSnackBar.error(
              message: route.message ?? 'Failed to fetch route',
            );
            return;
          }

          final routeData = route.data ?? [];
          if (routeData.isEmpty) {
            return;
          }

          final stateSnapshot = state;
          final polyline = List<LatLng>.from(stateSnapshot.routePolyline);
          if (polyline.isNotEmpty &&
              polyline.last.latitude == newPoint.latitude &&
              polyline.last.longitude == newPoint.longitude) {
            polyline.removeLast();
            polyline.addAll(routeData.skip(1));
            emit(stateSnapshot.copyWith(routePolyline: polyline));
          }
        })
        .catchError((e) {
          AppLogger.instance.error('Background routing hatası: $e');
        });
  }

  Future<void> _init() async {
    await getCurrentLocation();
    await _loadHistory();
    await _syncServiceState();

    _locationSubscription = BackgroundLocationService.instance.locationStream
        .listen(_onNewLocationReceived);
  }

  Future<void> _syncServiceState() async {
    final isRunning = await BackgroundLocationService.instance
        .isServiceRunning();
    if (isRunning) {
      emit(state.copyWith(isTracking: true));
    }
  }

  Future<void> onAppResumed() async {
    await _syncServiceState();

    if (state.isTracking) {
      await _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final data = await _locationRepository.getAllLocations();
    if (!data.success) {
      AppLogger.instance.error(data.message ?? 'Failed to load history');
      OrangeSnackBar.error(message: data.message ?? 'Failed to load history');
      return;
    }

    final locations = data.data ?? <LocationModel>[];
    final history = locations
        .map((item) => LatLng(item.latitude, item.longitude))
        .toList();
    final routePolyline = await _buildRoutePolylineForHistory(history);

    emit(
      state.copyWith(
        routeHistory: history,
        locationHistory: locations,
        routePolyline: routePolyline.isNotEmpty ? routePolyline : history,
        currentLocation: history.isNotEmpty
            ? history.last
            : (state.currentLocation ?? const LatLng(41.0082, 28.9784)),
      ),
    );
  }

  Future<void> _onNewLocationReceived(Map<String, dynamic> data) async {
    final locationData = _extractLocationData(data);
    final newPoint = locationData['point'] as LatLng;
    final accuracy = locationData['accuracy'] as double?;
    final heading = locationData['heading'] as double?;

    if (accuracy != null && accuracy > _maxAccuracyForSave) {
      AppLogger.instance.log(
        "Konum accuracy çok kötü ($accuracy m), atlanıyor",
      );
      return;
    }

    final currentState = state;
    final shouldSaveMarker = await _shouldSaveMarker(newPoint);

    if (!shouldSaveMarker) {
      emit(
        currentState.copyWith(
          currentLocation: newPoint,
          currentHeading: heading,
        ),
      );
      return;
    }

    final locationModel = _createLocationModelFromData(data);
    await _locationRepository.saveLocation(locationModel);

    final latestState = state;
    final updatedList = List<LatLng>.from(latestState.routeHistory)
      ..add(newPoint);
    final updatedLocationHistory = List<LocationModel>.from(
      latestState.locationHistory,
    )..add(locationModel);

    final updatedPolyline = List<LatLng>.from(latestState.routePolyline);
    if (updatedList.length >= 2) {
      final lastPoint = updatedList[updatedList.length - 2];
      final lastLocation =
          latestState.locationHistory[latestState.locationHistory.length - 2];
      _updatePolylineWithRoute(
        updatedPolyline,
        lastPoint,
        newPoint,
        lastLocation,
        locationModel,
      );
    } else {
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

    if (state.followLocation && state.currentLocation != null) {
      moveToLocation(newPoint);
    }
  }

  Future<void> toggleTracking(BuildContext context) async {
    if (state.isTracking) {
      await BackgroundLocationService.instance.stopService();
      emit(state.copyWith(isTracking: false));
      return;
    }

    final hasPermission = await _requestLocationPermissionIfNeeded();
    if (!hasPermission) {
      return;
    }

    if (context.mounted) {
      final hasBackgroundPermission = await _handleIosBackgroundPermission(
        context,
      );
      if (!hasBackgroundPermission) {
        return;
      }
    }

    await BackgroundLocationService.instance.startService();
    emit(state.copyWith(isTracking: true, followLocation: true));
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

      final result = await _routeRepository.saveRoute(route);
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
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      );
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
      final hasPermission = await _requestLocationPermissionIfNeeded();
      if (!hasPermission) {
        return;
      }

      if (context.mounted) {
        final hasBackgroundPermission = await _handleIosBackgroundPermission(
          context,
        );
        if (!hasBackgroundPermission) {
          return;
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

      final hasPermission = await _requestLocationPermissionIfNeeded();
      if (!hasPermission) {
        return;
      }

      final currentPosition = await _locationService.getCurrentPosition();
      final location = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      emit(
        state.copyWith(
          currentLocation: location,
          currentHeading: currentPosition.heading,
        ),
      );
      moveToLocation(location);
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
    mapController.moveAndRotate(location, 15, 12);
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
