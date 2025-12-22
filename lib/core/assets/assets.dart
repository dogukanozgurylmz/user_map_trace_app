import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Assets {
  Assets._();
  final Assets instance = Assets._();

  static Image image(
    String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(assetPath, width: width, height: height, fit: fit);
  }

  static Widget svgIcon(String assetPath, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color ?? Colors.black, BlendMode.dstIn),
    );
  }

  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('JSON yüklenirken hata oluştu: $e');
      return {};
    }
  }
}
