import 'package:flutter/material.dart';

class DashedBorder extends BoxBorder {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;
  final BorderRadius borderRadius;

  const DashedBorder({
    this.color = Colors.black,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.strokeWidth = 1.0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final rrect =
        borderRadius?.toRRect(rect) ?? this.borderRadius.toRRect(rect);
    _drawDashedRRect(canvas, rrect, paint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  ShapeBorder scale(double t) {
    return DashedBorder(
      color: color,
      dashWidth: dashWidth * t,
      dashSpace: dashSpace * t,
      strokeWidth: strokeWidth * t,
      borderRadius: borderRadius * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius.toRRect(rect).deflate(strokeWidth / 2));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  BorderSide get top => BorderSide(color: color, width: strokeWidth);

  @override
  BorderSide get bottom => BorderSide(color: color, width: strokeWidth);

  @override
  bool get isUniform => true;
}
