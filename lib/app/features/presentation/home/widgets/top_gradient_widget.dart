import 'package:flutter/material.dart';

class TopGradientWidget extends StatelessWidget {
  const TopGradientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
        ),
      ),
    );
  }
}
