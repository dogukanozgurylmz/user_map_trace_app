import 'package:get_it/get_it.dart';
import 'package:user_map_trace_app/app/common/router/app_router.dart';
import 'package:user_map_trace_app/app/features/data/datasources/local/test_local_datasource.dart';
import 'package:user_map_trace_app/app/features/data/datasources/remote/test_remote_datasource.dart';
import 'package:user_map_trace_app/app/features/data/repositories/test_repository.dart';
import 'package:user_map_trace_app/app/features/presentation/test/cubit/test_cubit.dart';

final getIt = GetIt.instance;

/// **Service provider class managing all dependencies**
final class ServiceLocator {
  /// **Main method to call to set up dependencies**
  void setup() {
    _setupRouter();
    _setupDataSource();
    _setupRepository();
    _setupCubit();
  }

  /// **Router Dependency**
  void _setupRouter() {
    getIt.registerLazySingleton<AppRouter>(AppRouter.new);
  }

  /// **DataSource Dependency**
  void _setupDataSource() {
    getIt
      ..registerLazySingleton<TestLocalDatasource>(TestLocalDatasourceImpl.new)
      ..registerLazySingleton<TestRemoteDatasource>(
        TestRemoteDatasourceImpl.new,
      );
  }

  /// **Repository Dependency**
  void _setupRepository() {
    getIt.registerLazySingleton<TestRepository>(
      () => TestRepositoryImpl(
        remoteDatasource: getIt(),
        localDatasource: getIt(),
      ),
    );
  }

  /// **BLoC, Cubit and ViewModel Dependency**
  void _setupCubit() {
    getIt.registerLazySingleton<TestCubit>(
      () => TestCubit(testRepository: getIt()),
    );
  }

  /// **Resets dependencies for Test and Debug**
  Future<void> reset() async {
    await getIt.reset();
    setup();
  }
}
