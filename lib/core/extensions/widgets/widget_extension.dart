import 'package:flutter/material.dart';

extension TextExtension on Widget {
  GestureDetector onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: this,
    );
  }
}
