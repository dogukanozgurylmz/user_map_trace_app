import 'package:user_map_trace_app/app/features/data/datasources/local/location_local_datasource.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:user_map_trace_app/core/result/result.dart';

abstract class LocationRepository {
  Future<Result> saveLocation(LocationModel location);
  Future<DataResult<List<LocationModel>>> getAllLocations();
  Future<DataResult<List<LocationModel>>> getLocationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Result> clearAllLocations();
  Future<Result> saveRoute(RouteModel route);
  Future<DataResult<List<RouteModel>>> getAllRoutes();
}

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDatasource _locationLocalDatasource;

  LocationRepositoryImpl({
    required LocationLocalDatasource locationLocalDatasource,
  }) : _locationLocalDatasource = locationLocalDatasource;

  @override
  Future<Result> clearAllLocations() async {
    try {
      await _locationLocalDatasource.clearAllLocations();
      return SuccessResult(message: "All locations cleared successfully");
    } catch (e) {
      return ErrorResult(message: "Failed to clear all locations: $e");
    }
  }

  @override
  Future<DataResult<List<LocationModel>>> getAllLocations() async {
    try {
      final locations = await _locationLocalDatasource.getAllLocations();
      return SuccessDataResult(
        data: locations,
        message: "All locations fetched successfully",
      );
    } catch (e) {
      return ErrorDataResult(message: "Failed to fetch all locations: $e");
    }
  }

  @override
  Future<DataResult<List<LocationModel>>> getLocationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final locations = await _locationLocalDatasource.getLocationsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      return SuccessDataResult(
        data: locations,
        message: "Locations fetched successfully",
      );
    } catch (e) {
      return ErrorDataResult(message: "Failed to fetch locations: $e");
    }
  }

  @override
  Future<Result> saveLocation(LocationModel location) async {
    try {
      await _locationLocalDatasource.saveLocation(location);
      return SuccessResult(message: "Location saved successfully");
    } catch (e) {
      return ErrorResult(message: "Failed to save location: $e");
    }
  }

  @override
  Future<Result> saveRoute(RouteModel route) async {
    try {
      await _locationLocalDatasource.saveRoute(route);
      return SuccessResult(message: "Route saved successfully");
    } catch (e) {
      return ErrorResult(message: "Failed to save route: $e");
    }
  }

  @override
  Future<DataResult<List<RouteModel>>> getAllRoutes() async {
    try {
      final routes = await _locationLocalDatasource.getAllRoutes();
      return SuccessDataResult(
        data: routes,
        message: "All routes fetched successfully",
      );
    } catch (e) {
      return ErrorDataResult(message: "Failed to fetch all routes: $e");
    }
  }
}
