import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    required this.child,
    this.color,
    this.bgcolor,
    this.disableColor,
    this.elevation,
    this.side = BorderSide.none,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color? color;
  final Color? bgcolor;
  final Color? disableColor;
  final double? elevation;
  final BorderSide side;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: bgcolor,
          shape: const StadiumBorder(),
          disabledBackgroundColor: disableColor ?? Colors.grey,
          elevation: elevation,
          fixedSize: Size.fromHeight(20)),
      onPressed: onTap,
      child: child,
    );
  }
}
