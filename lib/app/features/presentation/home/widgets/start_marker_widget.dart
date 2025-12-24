import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_images.dart';

class StartMarkerWidget extends StatelessWidget {
  const StartMarkerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppImages.startMarker, width: 35, height: 35);
  }
}
