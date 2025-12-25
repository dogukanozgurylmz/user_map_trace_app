import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:user_map_trace_app/app/features/data/repositories/route_repository.dart';
import 'package:user_map_trace_app/core/logger/app_logger.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required RouteRepository routeRepository})
    : _routeRepository = routeRepository,
      super(const SettingsState()) {
    loadRoutes();
  }

  final RouteRepository _routeRepository;
  final MapController mapController = MapController();

  Future<void> loadRoutes() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _routeRepository.getAllRoutes();
      if (result.success) {
        emit(state.copyWith(routes: result.data ?? [], isLoading: false));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: result.message ?? 'Rotalar yüklenemedi',
          ),
        );
        AppLogger.instance.error(result.message ?? 'Rotalar yüklenemedi');
      }
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Bir hata oluştu: $e'),
      );
      AppLogger.instance.error('Rotalar yüklenirken hata: $e');
    }
  }

  void selectRoute(RouteModel route) {
    emit(state.copyWith(selectedRoute: route));
    _initializeMapForRoute(route);
  }

  void _initializeMapForRoute(RouteModel route) {
    final routePoints = _getRoutePoints(route);
    final centerPoint = _getRouteCenterPoint(route);
    final bounds = _getRouteBounds(route);

    Future.microtask(() {
      if (routePoints.length > 1) {
        mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      } else {
        mapController.move(centerPoint, 15);
      }
    });
  }

  List<LatLng> _getRoutePoints(RouteModel route) {
    return route.locations
        .map((location) => LatLng(location.latitude, location.longitude))
        .toList();
  }

  LatLng _getRouteCenterPoint(RouteModel route) {
    if (route.locations.isEmpty) {
      return const LatLng(41.0082, 28.9784);
    }
    final points = _getRoutePoints(route);
    final avgLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final avgLng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(avgLat, avgLng);
  }

  LatLngBounds _getRouteBounds(RouteModel route) {
    if (route.locations.isEmpty) {
      return LatLngBounds(
        const LatLng(41.0082, 28.9784),
        const LatLng(41.0082, 28.9784),
      );
    }
    final points = _getRoutePoints(route);
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  List<LatLng> getRoutePoints(RouteModel route) => _getRoutePoints(route);

  LatLng getRouteCenterPoint(RouteModel route) => _getRouteCenterPoint(route);

  LatLngBounds getRouteBounds(RouteModel route) => _getRouteBounds(route);

  @override
  Future<void> close() {
    mapController.dispose();
    return super.close();
  }
}
