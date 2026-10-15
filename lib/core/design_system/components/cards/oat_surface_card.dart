import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_radii.dart';

class OatSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final bool withElevation;
  final Border? customBorder;

  const OatSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = AppColors.surface,
    this.borderRadius,
    this.withElevation = true,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? AppRadii.borderMd,
        border: customBorder ?? Border.all(color: AppColors.border, width: 1.0),
        boxShadow: withElevation ? const [AppRadii.subtleElevation] : null,
      ),
      child: child,
    );
  }
}
