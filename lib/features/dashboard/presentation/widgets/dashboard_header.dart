import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final String greeting;
  final VoidCallback? onQuickExpenseTap;
  final VoidCallback? onProfileTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.greeting = 'Selamat datang,',
    this.onQuickExpenseTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCanvas,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46.0,
                    height: 46.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF222228),
                          Color(0xFF141418),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.borderHairline,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: avatarUrl != null && avatarUrl!.isNotEmpty
                          ? (avatarUrl!.startsWith('http')
                              ? Image.network(
                                  avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const AvatarFallbackIcon(),
                                )
                              : (File(avatarUrl!).existsSync()
                                  ? Image.file(
                                      File(avatarUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const AvatarFallbackIcon(),
                                    )
                                  : const AvatarFallbackIcon()))
                          : const AvatarFallbackIcon(),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          greeting,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          userName,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textHighContrast,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onQuickExpenseTap?.call();
            },
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: 46.0,
              height: 46.0,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.32),
                    blurRadius: 14.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.textHighContrast,
                  size: 28.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarFallbackIcon extends StatelessWidget {
  const AvatarFallbackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        size: 26.0,
        color: AppColors.brandPrimary,
      ),
    );
  }
}
