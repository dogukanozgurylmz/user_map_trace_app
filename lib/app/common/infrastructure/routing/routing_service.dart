import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/common/infrastructure/routing/i_routing_service.dart';
import 'package:user_map_trace_app/core/logger/app_logger.dart';

final class RoutingService implements IRoutingService {
  RoutingService() : _dio = Dio();

  final Dio _dio;
  // OSRM public server - ücretsiz ve API key gerektirmiyor
  static const String _baseUrl = 'http://router.project-osrm.org';
  // Profile: driving, cycling, walking
  static const String _profile = 'walking';

  // Cache: Aynı noktalar arası rotaları cache'le
  final Map<String, List<LatLng>> _routeCache = {};
  static const double _cachePrecision = 0.0001; // ~11 metre hassasiyet

  @override
  Future<List<LatLng>?> getRouteBetweenPoints(LatLng start, LatLng end) async {
    try {
      // Cache key oluştur (yuvarlanmış koordinatlar)
      final cacheKey = _getCacheKey(start, end);

      // Cache'de varsa direkt döndür
      if (_routeCache.containsKey(cacheKey)) {
        AppLogger.instance.log('Routing cache hit: $cacheKey');
        return _routeCache[cacheKey];
      }

      // OSRM API format: {longitude},{latitude};{longitude},{latitude}
      final coordinates =
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

      final response = await _dio.get(
        '$_baseUrl/route/v1/$_profile/$coordinates',
        queryParameters: {
          'geometries':
              'geojson', // GeoJSON format kullanarak direkt koordinatları al
          'overview': 'full', // Tüm detaylı geometriyi al
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final code = response.data['code'] as String?;
        if (code == 'Ok') {
          final routes = response.data['routes'] as List?;
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

                return routePoints;
              }
            }
          }
        } else {
          AppLogger.instance.error(
            'OSRM routing hatası: ${response.data['message'] ?? code}',
          );
        }
      }
      return null;
    } catch (e) {
      AppLogger.instance.error('Routing hatası: $e');
      return null;
    }
  }

  String _getCacheKey(LatLng start, LatLng end) {
    // Koordinatları yuvarla ve cache key oluştur
    final startLat =
        (start.latitude / _cachePrecision).round() * _cachePrecision;
    final startLng =
        (start.longitude / _cachePrecision).round() * _cachePrecision;
    final endLat = (end.latitude / _cachePrecision).round() * _cachePrecision;
    final endLng = (end.longitude / _cachePrecision).round() * _cachePrecision;

    return '${startLat.toStringAsFixed(4)},${startLng.toStringAsFixed(4)};${endLat.toStringAsFixed(4)},${endLng.toStringAsFixed(4)}';
  }

  @override
  Future<double?> getRouteDistance(LatLng start, LatLng end) async {
    try {
      // Önce cache'de var mı kontrol et
      final cacheKey = _getCacheKey(start, end);
      if (_routeCache.containsKey(cacheKey)) {
        // Cache'deki rotanın uzunluğunu hesapla
        final route = _routeCache[cacheKey]!;
        return _calculateRouteDistance(route);
      }

      // OSRM API format: {longitude},{latitude};{longitude},{latitude}
      final coordinates =
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

      final response = await _dio.get(
        '$_baseUrl/route/v1/$_profile/$coordinates',
        queryParameters: {
          'geometries': 'geojson',
          'overview': 'simplified', // Sadece uzunluk için simplified yeterli
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final code = response.data['code'] as String?;
        if (code == 'Ok') {
          final routes = response.data['routes'] as List?;
          if (routes != null && routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final distance = route['distance'] as num?;
            if (distance != null) {
              return distance.toDouble();
            }
          }
        }
      }
      return null;
    } catch (e) {
      AppLogger.instance.error('Route distance hatası: $e');
      return null;
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
