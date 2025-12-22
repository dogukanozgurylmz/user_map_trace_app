import 'package:flutter/material.dart';

extension SingleChildScrollViewExtensions on Widget {
  Widget scroll(bool isScroll) {
    return SingleChildScrollView(
      physics: !isScroll ? const NeverScrollableScrollPhysics() : null,
      child: this,
    );
  }
}
