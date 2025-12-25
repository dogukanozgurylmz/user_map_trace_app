import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';

class TopGradientWidget extends StatelessWidget {
  const TopGradientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.black2.withValues(alpha: 0.4),
            AppColors.black2.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
