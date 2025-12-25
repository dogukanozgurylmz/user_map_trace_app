import 'package:hive_ce/hive.dart';
import 'package:user_map_trace_app/app/common/helpers/hive/hive_helper.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';

abstract class RouteLocalDatasource {
  Future<void> saveRoute(RouteModel route);
  Future<List<RouteModel>> getAllRoutes();
}

class RouteLocalDatasourceImpl implements RouteLocalDatasource {
  RouteLocalDatasourceImpl();
  final Box<RouteModel> _box = HiveHelper.instance.getBox<RouteModel>(
    'routes_box',
  );
  @override
  Future<void> saveRoute(RouteModel route) async {
    await _box.put(route.id, route);
  }

  @override
  Future<List<RouteModel>> getAllRoutes() async {
    return _box.values.toList();
  }
}
