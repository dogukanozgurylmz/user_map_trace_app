import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:flutter/material.dart';

final class AppCheckbox extends StatefulWidget {
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const AppCheckbox({
    super.key,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  double _currentSize = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _sizeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 10.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 100,
      ),
    ]).animate(_controller);

    _controller.addListener(() {
      setState(() {
        _currentSize = _sizeAnimation.value;
      });
    });
  }

  @override
  void didUpdateWidget(AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.duration = const Duration(milliseconds: 1000);
      _controller.forward(from: 0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.duration = const Duration(milliseconds: 100);
      _controller.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.isSelected);
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.black, width: 2),
        ),
        child: Center(
          child: Container(
            width: _currentSize,
            height: _currentSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
