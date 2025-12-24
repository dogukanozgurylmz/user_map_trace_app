import 'package:get_it/get_it.dart';
import 'package:user_map_trace_app/app/common/router/app_router.dart';
import 'package:user_map_trace_app/app/features/data/datasources/local/location_local_datasource.dart';
import 'package:user_map_trace_app/app/common/infrastructure/location/i_location_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/location/location_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/permissions/i_permissions_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/permissions/permissions_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/routing/i_routing_service.dart';
import 'package:user_map_trace_app/app/common/infrastructure/routing/routing_service.dart';
import 'package:user_map_trace_app/app/features/data/repositories/location_repository.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';

final getIt = GetIt.instance;

/// **Service provider class managing all dependencies**
final class ServiceLocator {
  /// **Main method to call to set up dependencies**
  void setup() {
    _setupServices();
    _setupRouter();
    _setupDataSource();
    _setupRepository();
    _setupCubit();
  }

  /// **Core Services Dependency**
  void _setupServices() {
    getIt
      ..registerLazySingleton<IPermissionsService>(PermissionsService.new)
      ..registerLazySingleton<ILocationService>(LocationService.new)
      ..registerLazySingleton<IRoutingService>(RoutingService.new);
  }

  /// **Router Dependency**
  void _setupRouter() {
    getIt.registerLazySingleton<AppRouter>(AppRouter.new);
  }

  /// **DataSource Dependency**
  void _setupDataSource() {
    getIt.registerFactory<LocationLocalDatasource>(
      () => LocationLocalDatasourceImpl(),
    );
  }

  /// **Repository Dependency**
  void _setupRepository() {
    getIt.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(locationLocalDatasource: getIt()),
    );
  }

  /// **BLoC, Cubit and ViewModel Dependency**
  void _setupCubit() {
    getIt.registerLazySingleton<HomeCubit>(
      () => HomeCubit(
        locationRepository: getIt(),
        locationService: getIt(),
        permissionsService: getIt(),
        routingService: getIt(),
      ),
    );
  }

  /// **Resets dependencies for Test and Debug**
  Future<void> reset() async {
    await getIt.reset();
    setup();
  }
}
