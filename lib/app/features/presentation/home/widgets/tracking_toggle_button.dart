import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';

class TrackingToggleButton extends StatelessWidget {
  const TrackingToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: () => cubit.toggleTracking(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      state.isTracking
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                      color: state.isTracking ? AppColors.red : AppColors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.isTracking
                          ? AppStrings.stopTracking
                          : AppStrings.startTracking,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: state.isTracking
                            ? AppColors.red
                            : AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
