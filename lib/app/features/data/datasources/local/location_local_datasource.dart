import 'package:hive_ce/hive.dart';
import 'package:user_map_trace_app/app/common/helpers/hive/hive_helper.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';

abstract class LocationLocalDatasource {
  Future<void> saveLocation(LocationModel location);
  Future<List<LocationModel>> getAllLocations();
  Future<List<LocationModel>> getLocationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<void> clearAllLocations();
  Future<void> saveRoute(RouteModel route);
  Future<List<RouteModel>> getAllRoutes();
}

class LocationLocalDatasourceImpl implements LocationLocalDatasource {
  LocationLocalDatasourceImpl();
  final Box<LocationModel> _box = HiveHelper.instance.getBox<LocationModel>(
    'locations_box',
  );
  final Box<RouteModel> _routesBox = HiveHelper.instance.getBox<RouteModel>(
    'routes_box',
  );

  @override
  Future<void> saveLocation(LocationModel location) async {
    await _box.add(location);
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    return _box.values.toList();
  }

  @override
  Future<List<LocationModel>> getLocationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allLocations = await getAllLocations();
    return allLocations
        .where(
          (location) =>
              location.timestamp.isAfter(startDate) &&
              location.timestamp.isBefore(endDate),
        )
        .toList();
  }

  @override
  Future<void> clearAllLocations() async {
    await _box.clear();
  }

  @override
  Future<void> saveRoute(RouteModel route) async {
    await _routesBox.put(route.id, route);
  }

  @override
  Future<List<RouteModel>> getAllRoutes() async {
    return _routesBox.values.toList();
  }
}
