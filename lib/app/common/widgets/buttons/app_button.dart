import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';

final class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.green,
    this.textColor = AppColors.white,
    this.icon,
    this.height = 56,
    this.textStyle,
    this.width,
    this.borderRadius = 16,
    this.shrinkWrap = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final double height;
  final TextStyle? textStyle;
  final double? width;
  final double borderRadius;
  final bool shrinkWrap;

  factory AppButton.fill({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Color backgroundColor = AppColors.green,
    Color textColor = AppColors.white,
    Widget? icon,
    double height = 56,
    TextStyle? textStyle,
    double? width,
    double borderRadius = 16,
    bool shrinkWrap = false,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      height: height,
      textStyle: textStyle,
      width: width,
      borderRadius: borderRadius,
      shrinkWrap: shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(
          shrinkWrap ? width ?? 0 : width ?? double.infinity,
          height,
        ),
        shadowColor: AppColors.transparent,
      ),
      child: icon == null
          ? Text(
              text,
              style:
                  textStyle ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style:
                      textStyle ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                icon!,
              ],
            ),
    );
  }
}
