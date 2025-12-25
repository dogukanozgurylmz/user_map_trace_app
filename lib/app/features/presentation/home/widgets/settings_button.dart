import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black2,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(42, 42),
          ),
          icon: const Icon(Icons.settings_outlined),
        ),
      ),
    );
  }
}
