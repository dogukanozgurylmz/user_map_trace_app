import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/features/data/models/location_model.dart';

class MarkerWidget extends StatelessWidget {
  final LocationModel location;
  const MarkerWidget({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.flag, color: AppColors.black2, size: 35);
  }
}
