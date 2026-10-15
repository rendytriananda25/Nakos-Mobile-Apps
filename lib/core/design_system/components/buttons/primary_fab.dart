import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_radii.dart';

class PrimaryFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  final IconData icon;

  const PrimaryFAB({
    super.key,
    required this.onPressed,
    this.tooltip = 'Catat Pengeluaran',
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Material(
        color: AppColors.primary,
        borderRadius: AppRadii.borderFab,
        elevation: 2.0,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.borderFab,
          splashColor: AppColors.primaryDark.withValues(alpha: 0.3),
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
