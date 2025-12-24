import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';

part 'route_model.g.dart';

@HiveType(typeId: 1)
class RouteModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  final List<LocationModel> locations;

  const RouteModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.locations,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'locations': locations.map((l) => l.toMap()).toList(),
    };
  }

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      id: map['id'] as String,
      name: map['name'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      locations: (map['locations'] as List)
          .map((l) => LocationModel.fromMap(l as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate, locations];
}
