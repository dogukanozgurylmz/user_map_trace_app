import 'package:flutter/material.dart';

/// A custom `BoxBorder` implementation that draws a gradient border.
/// Supports rectangular and circular shapes with optional rounded corners.
class GradientBorder extends BoxBorder {
  /// The thickness of the border.
  final double width;

  /// The gradient used to paint the border.
  final Gradient gradient;

  /// Creates a `GradientBorder` with the specified width and gradient.
  const GradientBorder({
    this.width = 1,
    required this.gradient,
  });

  /// Paints the gradient border on the given `Canvas` within the specified `Rect`.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    BoxShape shape =
        BoxShape.rectangle, // The shape of the border (circle or rectangle).
    BorderRadius? borderRadius, // Optional border radius for rectangles.
    TextDirection? textDirection,
  }) {
    // Check if the shape is a circle or rectangle and paint accordingly.
    if (shape == BoxShape.circle) {
      _paintCircle(canvas, rect);
    } else {
      _paintRect(canvas, rect, borderRadius);
    }
  }

  /// Paints a gradient border for a circular shape.
  void _paintCircle(Canvas canvas, Rect rect) {
    // Configure the paint object with the gradient and style.
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect) // Apply the gradient as a shader.
      ..style = PaintingStyle.stroke // Set the paint style to stroke.
      ..strokeWidth = width; // Set the stroke width.

    // Draw a circle at the center of the rectangle with the border width.
    canvas.drawCircle(rect.center, rect.width / 2, paint);
  }

  /// Paints a gradient border for a rectangular shape, optionally with rounded corners.
  void _paintRect(Canvas canvas, Rect rect, BorderRadius? borderRadius) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    if (borderRadius != null) {
      final RRect rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
      canvas.drawRRect(rrect, paint);
    } else {
      canvas.drawRect(rect.deflate(width / 2), paint);
    }
  }

  /// Defines the dimensions of the border as an `EdgeInsetsGeometry`.
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  /// Scales the border by a factor `t`, which is useful for animations or transformations.
  @override
  ShapeBorder scale(double t) {
    return GradientBorder(
      width: width * t,
      gradient: gradient,
    );
  }

  /// Returns the inner path of the border, adjusted for the border thickness.
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect.deflate(width / 2));
  }

  /// Returns the outer path of the border.
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  /// Defines the bottom side of the border with no visible color (for compatibility).
  @override
  BorderSide get bottom => BorderSide(
        color: Colors.transparent,
        width: width,
      );

  /// Indicates whether the border is uniform on all sides.
  @override
  bool get isUniform => true;

  /// Defines the top side of the border with no visible color (for compatibility).
  @override
  BorderSide get top => BorderSide(
        color: Colors.transparent,
        width: width,
      );
}
