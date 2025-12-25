import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/common/config/config.dart';
import 'package:user_map_trace_app/core/dio_manager/api_error_model.dart';
import 'package:user_map_trace_app/core/dio_manager/api_response_model.dart';
import 'package:user_map_trace_app/core/dio_manager/dio_manager.dart';
import 'package:user_map_trace_app/core/logger/app_logger.dart';

abstract class RouteRemoteDatasource {
  Future<ApiResponseModel<List<LatLng>>> getRouteBetweenPoints(
    LatLng start,
    LatLng end,
  );
  Future<ApiResponseModel<double>> getRouteDistance(LatLng start, LatLng end);
}

class RouteRemoteDatasourceImpl implements RouteRemoteDatasource {
  RouteRemoteDatasourceImpl()
    : _dioManager = DioApiManager(baseUrl: Config.apiBaseUrl);

  final DioApiManager _dioManager;
  // Profile: driving, cycling, walking
  static const String _profile = 'walking';

  // Cache: Aynı noktalar arası rotaları cache'le
  final Map<String, List<LatLng>> _routeCache = {};
  static const double _cachePrecision = 0.0001; // ~11 metre hassasiyet

  @override
  Future<ApiResponseModel<List<LatLng>>> getRouteBetweenPoints(
    LatLng start,
    LatLng end,
  ) async {
    try {
      // Cache key oluştur (yuvarlanmış koordinatlar)
      final cacheKey = _getCacheKey(start, end);

      // Cache'de varsa direkt döndür
      if (_routeCache.containsKey(cacheKey)) {
        AppLogger.instance.log('Routing cache hit: $cacheKey');
        return ApiResponseModel.success(_routeCache[cacheKey]!);
      }

      // OSRM API format: {longitude},{latitude};{longitude},{latitude}
      final coordinates =
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

      final response = await _dioManager.get<Map<String, dynamic>>(
        '/route/v1/$_profile/$coordinates',
        queryParams: {'geometries': 'geojson', 'overview': 'full'},
      );

      if (response.isSuccess && response.data != null) {
        final code = response.data!['code'] as String?;
        if (code == 'Ok') {
          final routes = response.data!['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final geometry = route['geometry'] as Map<String, dynamic>?;
            if (geometry != null) {
              final coordinates = geometry['coordinates'] as List?;
              if (coordinates != null && coordinates.isNotEmpty) {
                // GeoJSON format: [longitude, latitude]
                final routePoints = coordinates.map((coord) {
                  final coordList = coord as List;
                  return LatLng(coordList[1] as double, coordList[0] as double);
                }).toList();

                // Cache'e kaydet
                _routeCache[cacheKey] = routePoints;

                // Cache boyutunu sınırla (max 100 rota)
                if (_routeCache.length > 100) {
                  final firstKey = _routeCache.keys.first;
                  _routeCache.remove(firstKey);
                }

                return ApiResponseModel.success(routePoints);
              }
            }
          }
        } else {
          AppLogger.instance.error(
            'OSRM routing hatası: ${response.data!['message'] ?? code}',
          );
        }
      }

      return ApiResponseModel.error(
        response.error ?? ApiErrorModel(message: 'Route bulunamadı'),
      );
    } catch (e) {
      AppLogger.instance.error('Routing hatası: $e');
      return ApiResponseModel.error(
        ApiErrorModel(message: 'Routing hatası: $e'),
      );
    }
  }

  String _getCacheKey(LatLng start, LatLng end) {
    final startLat =
        (start.latitude / _cachePrecision).round() * _cachePrecision;
    final startLng =
        (start.longitude / _cachePrecision).round() * _cachePrecision;
    final endLat = (end.latitude / _cachePrecision).round() * _cachePrecision;
    final endLng = (end.longitude / _cachePrecision).round() * _cachePrecision;

    return '${startLat.toStringAsFixed(4)},${startLng.toStringAsFixed(4)};${endLat.toStringAsFixed(4)},${endLng.toStringAsFixed(4)}';
  }

  @override
  Future<ApiResponseModel<double>> getRouteDistance(
    LatLng start,
    LatLng end,
  ) async {
    try {
      // Önce cache'de var mı kontrol et
      final cacheKey = _getCacheKey(start, end);
      if (_routeCache.containsKey(cacheKey)) {
        // Cache'deki rotanın uzunluğunu hesapla
        final route = _routeCache[cacheKey]!;
        final distance = _calculateRouteDistance(route);
        return ApiResponseModel.success(distance);
      }

      // OSRM API format: {longitude},{latitude};{longitude},{latitude}
      final coordinates =
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

      final response = await _dioManager.get<Map<String, dynamic>>(
        '/route/v1/$_profile/$coordinates',
        queryParams: {
          'geometries': 'geojson',
          'overview': 'simplified', // Sadece uzunluk için simplified yeterli
        },
      );

      if (response.isSuccess && response.data != null) {
        final code = response.data!['code'] as String?;
        if (code == 'Ok') {
          final routes = response.data!['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final distance = route['distance'] as num?;
            if (distance != null) {
              return ApiResponseModel.success(distance.toDouble());
            }
          }
        }
      }

      return ApiResponseModel.error(
        response.error ?? ApiErrorModel(message: 'Route distance bulunamadı'),
      );
    } catch (e) {
      AppLogger.instance.error('Route distance hatası: $e');
      return ApiResponseModel.error(
        ApiErrorModel(message: 'Route distance hatası: $e'),
      );
    }
  }

  double _calculateRouteDistance(List<LatLng> routePoints) {
    if (routePoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        routePoints[i].latitude,
        routePoints[i].longitude,
        routePoints[i + 1].latitude,
        routePoints[i + 1].longitude,
      );
    }
    return totalDistance;
  }
}
