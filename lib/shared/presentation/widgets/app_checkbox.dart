import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppCheckbox extends StatefulWidget {
  final double? size;
  final bool isActive;
  final Color? activeColor;
  final Color? borderColor;
  final void Function(bool value)? onTap;
  const AppCheckbox({
    super.key,
    this.size,
    required this.isActive,
    this.onTap,
    this.activeColor,
    this.borderColor,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  bool isActive = false;
  @override
  void initState() {
    setState(() => isActive = widget.isActive);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor.withValues(alpha: 0.1);
    return InkWell(
      splashColor: Theme.of(context).scaffoldBackgroundColor,
      onTap: () {
        widget.onTap?.call(!isActive);
        setState(() => isActive = !isActive);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: widget.size ?? 24.w,
        width: widget.size ?? 24.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isActive ? widget.activeColor ?? primaryColor : Colors.transparent,
          border: Border.all(
            color: widget.isActive
                ? widget.activeColor ?? primaryColor
                : widget.borderColor ?? Theme.of(context).primaryColor,
          ),
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 500),
          scale: widget.isActive ? 0.7 : 0,
          // child: const AppIcon(icon: AppIcons.check),
          child: CircleAvatar(),
        ),
      ),
    );
  }
}
