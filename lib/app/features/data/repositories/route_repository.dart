import 'package:latlong2/latlong.dart';
import 'package:user_map_trace_app/app/features/data/datasources/local/route_local_datasource.dart';
import 'package:user_map_trace_app/app/features/data/datasources/remote/route_remote_datasource.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';
import 'package:user_map_trace_app/core/result/result.dart';

abstract class RouteRepository {
  Future<Result> saveRoute(RouteModel route);
  Future<DataResult<List<RouteModel>>> getAllRoutes();
  Future<DataResult<List<LatLng>>> getRouteBetweenPoints(
    LatLng start,
    LatLng end,
  );
  Future<DataResult<double>> getRouteDistance(LatLng start, LatLng end);
}

class RouteRepositoryImpl implements RouteRepository {
  final RouteLocalDatasource _localDatasource;
  final RouteRemoteDatasource _remoteDatasource;
  RouteRepositoryImpl({
    required RouteLocalDatasource localDatasource,
    required RouteRemoteDatasource remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;

  @override
  Future<Result> saveRoute(RouteModel route) async {
    try {
      await _localDatasource.saveRoute(route);
      return SuccessResult(message: "Route saved successfully");
    } catch (e) {
      return ErrorResult(message: "Failed to save route: $e");
    }
  }

  @override
  Future<DataResult<List<RouteModel>>> getAllRoutes() async {
    try {
      final routes = await _localDatasource.getAllRoutes();
      return SuccessDataResult(
        data: routes,
        message: "Routes fetched successfully",
      );
    } catch (e) {
      return ErrorDataResult(message: "Failed to fetch routes: $e");
    }
  }

  @override
  Future<DataResult<List<LatLng>>> getRouteBetweenPoints(
    LatLng start,
    LatLng end,
  ) async {
    final route = await _remoteDatasource.getRouteBetweenPoints(start, end);
    if (!route.isSuccess) {
      return ErrorDataResult(
        message: "Failed to fetch route: ${route.error?.message}",
      );
    }
    return SuccessDataResult(
      data: route.data!,
      message: "Route fetched successfully",
    );
  }

  @override
  Future<DataResult<double>> getRouteDistance(LatLng start, LatLng end) async {
    final distance = await _remoteDatasource.getRouteDistance(start, end);
    if (!distance.isSuccess) {
      return ErrorDataResult(
        message: "Failed to fetch route distance: ${distance.error?.message}",
      );
    }
    return SuccessDataResult(
      data: distance.data!,
      message: "Route distance fetched successfully",
    );
  }
}
