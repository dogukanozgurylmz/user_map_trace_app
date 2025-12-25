part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final List<RouteModel> routes;
  final bool isLoading;
  final String? errorMessage;
  final RouteModel? selectedRoute;

  const SettingsState({
    this.routes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedRoute,
  });

  SettingsState copyWith({
    List<RouteModel>? routes,
    bool? isLoading,
    String? errorMessage,
    RouteModel? selectedRoute,
  }) {
    return SettingsState(
      routes: routes ?? this.routes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedRoute: selectedRoute ?? this.selectedRoute,
    );
  }

  @override
  List<Object?> get props => [routes, isLoading, errorMessage, selectedRoute];
}
