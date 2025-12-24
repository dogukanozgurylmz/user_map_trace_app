import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';
import 'package:user_map_trace_app/app/features/data/models/route_model.dart';

class HiveHelper {
  HiveHelper._();
  static final HiveHelper instance = HiveHelper._();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LocationModelAdapter());
    Hive.registerAdapter(RouteModelAdapter());
    await HiveHelper.instance.openBox<LocationModel>('locations_box');
    await HiveHelper.instance.openBox<RouteModel>('routes_box');
  }

  Future<Box<T>> openBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }

  Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

  Future<void> closeBox<T>(Box<T> box) async {
    await box.close();
  }

  Future<void> clearBox<T>(Box<T> box) async {
    await box.clear();
  }

  Future<void> deleteBox<T>(String name) async {
    await Hive.deleteBoxFromDisk(name);
  }

  Future<void> deleteAllBoxes() async {
    await Hive.deleteFromDisk();
  }
}
