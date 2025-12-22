import 'package:flutter/material.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String label;
  final String? emoji;
  final bool isEnabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? labelColor;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  // Multi-select support
  final bool isMultiSelect;
  final List<T> selectedValues;
  final void Function(T value, bool selected)? onChangedMulti;

  const AppRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.emoji,
    this.isEnabled = true,
    this.activeColor,
    this.inactiveColor,
    this.labelColor,
    this.spacing = 8,
    this.padding,
    this.isMultiSelect = false,
    this.selectedValues = const [],
    this.onChangedMulti,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = isMultiSelect
        ? selectedValues.contains(value)
        : value == groupValue;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              if (isMultiSelect) {
                final bool next = !isSelected;
                onChangedMulti?.call(value, next);
              } else {
                onChanged(value);
              }
            }
          : null,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (activeColor ?? AppColors.black)
                : AppColors.black,
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (activeColor ?? AppColors.black)
                      : (inactiveColor ?? AppColors.black),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor ?? AppColors.black,
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(width: spacing),

            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              SizedBox(width: spacing),
            ],

            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: labelColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
