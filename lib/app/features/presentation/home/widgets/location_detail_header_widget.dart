import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';

class LocationDetailHeaderWidget extends StatelessWidget {
  const LocationDetailHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Konum Detayları',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.router.pop,
          color: AppColors.grey,
        ),
      ],
    );
  }
}
