import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoader extends StatelessWidget {
  final double? size;
  const AppLoader({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottie/mygen_loader2.json',
      width: size,
      height: size,
      repeat: true,
      animate: true,
    );
  }
}
