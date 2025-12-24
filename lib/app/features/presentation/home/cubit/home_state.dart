part of 'home_cubit.dart';

class HomeState extends Equatable {
  final List<LatLng> routeHistory;
  final List<LocationModel> locationHistory;
  final bool isTracking;
  final LatLng? currentLocation;
  final List<LatLng> routePolyline;
  final bool followLocation;
  final LocationModel? selectedLocationModel;
  final double? currentHeading;

  const HomeState({
    this.routeHistory = const [],
    this.locationHistory = const [],
    this.isTracking = false,
    this.currentLocation,
    this.routePolyline = const [],
    this.followLocation = false,
    this.selectedLocationModel,
    this.currentHeading,
  });

  HomeState copyWith({
    List<LatLng>? routeHistory,
    List<LocationModel>? locationHistory,
    bool? isTracking,
    LatLng? currentLocation,
    List<LatLng>? routePolyline,
    bool? followLocation,
    LocationModel? selectedLocationModel,
    double? currentHeading,
  }) {
    return HomeState(
      routeHistory: routeHistory ?? this.routeHistory,
      locationHistory: locationHistory ?? this.locationHistory,
      isTracking: isTracking ?? this.isTracking,
      currentLocation: currentLocation ?? this.currentLocation,
      routePolyline: routePolyline ?? this.routePolyline,
      followLocation: followLocation ?? this.followLocation,
      selectedLocationModel:
          selectedLocationModel ?? this.selectedLocationModel,
      currentHeading: currentHeading ?? this.currentHeading,
    );
  }

  @override
  List<Object?> get props => [
    routeHistory,
    locationHistory,
    isTracking,
    currentLocation,
    routePolyline,
    followLocation,
    selectedLocationModel,
    currentHeading,
  ];
}
