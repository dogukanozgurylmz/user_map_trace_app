import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';

class CurrentLocationButton extends StatelessWidget {
  const CurrentLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<HomeCubit>().getCurrentLocation();
      },
      style: IconButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(56, 56),
      ),
      icon: const Icon(
        Icons.my_location_rounded,
        color: AppColors.green,
        size: 30,
      ),
    );
  }
}
