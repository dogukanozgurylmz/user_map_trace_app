import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/common/widgets/buttons/app_button.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';
import 'package:user_map_trace_app/app/features/presentation/home/mixin/journey_mixin.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/current_lcoation_widget.dart';
import 'package:user_map_trace_app/app/features/presentation/home/widgets/statistic_item_widget.dart';

class StatusInfoWidget extends StatelessWidget with JourneyMixin {
  const StatusInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatisticItemWidget(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: state.isTracking
                              ? AppStrings.stopJourney
                              : (state.locationHistory.isEmpty
                                    ? AppStrings.startNewJourney
                                    : AppStrings.newJourney),
                          onPressed: state.isTracking
                              ? () => stopJourney(context, cubit)
                              : (state.locationHistory.isEmpty
                                    ? () => startNewJourney(context, cubit)
                                    : () =>
                                          showNewJourneyDialog(context, cubit)),
                          backgroundColor: state.isTracking
                              ? AppColors.red
                              : AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const CurrentLocationButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
