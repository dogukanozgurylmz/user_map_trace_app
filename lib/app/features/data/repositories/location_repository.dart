import 'package:user_map_trace_app/app/features/data/datasources/local/location_local_datasource.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';
import 'package:user_map_trace_app/core/result/result.dart';

abstract class LocationRepository {
  Future<Result> saveLocation(LocationModel location);
  Future<DataResult<List<LocationModel>>> getAllLocations();
  Future<DataResult<List<LocationModel>>> getLocationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Result> clearAllLocations();
}

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDatasource _localDatasource;

  LocationRepositoryImpl({required LocationLocalDatasource localDatasource})
    : _localDatasource = localDatasource;

  @override
  Future<Result> clearAllLocations() async {
    try {
      await _localDatasource.clearAllLocations();
      return SuccessResult(message: "All locations cleared successfully");
    } catch (e) {
      return ErrorResult(message: "Failed to clear all locations: $e");
    }
  }

  @override
  Future<DataResult<List<LocationModel>>> getAllLocations() async {
    try {
      final locations = await _localDatasource.getAllLocations();
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
      final locations = await _localDatasource.getLocationsByDateRange(
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
      await _localDatasource.saveLocation(location);
      return SuccessResult(message: "Location saved successfully");
    } catch (e) {
      return ErrorResult(message: "Failed to save location: $e");
    }
  }
}
