import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        backgroundColor: Color(0xFFfcfcfc),
        foregroundColor: Color(0xFF34D100),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: Size(56, 56),
      ),
      icon: const Icon(
        Icons.my_location_rounded,
        color: Color(0xFF34D100),
        size: 30,
      ),
    );
  }
}
