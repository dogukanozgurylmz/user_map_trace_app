import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/home/mixin/distance_mixin.dart';

class StatisticItemWidget extends StatelessWidget with DistanceMixin {
  const StatisticItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final totalDistance = calculateTotalDistance(state.routePolyline);
        final formattedDistance = formatDistance(totalDistance);
        final unit = getDistanceUnit(totalDistance);
        final isZeroDistance = totalDistance < 1.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.black2,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
                children: isZeroDistance
                    ? [
                        const TextSpan(
                          text: AppStrings.startJourneyMessage,
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.black2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                    : [
                        const TextSpan(text: AppStrings.great),
                        TextSpan(
                          text: formattedDistance,
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: "$unit ",
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: AppStrings.youHaveTraveled),
                      ],
              ),
            ),
          ],
        );
      },
    );
  }
}
