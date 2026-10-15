import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeroAmbientBloom extends StatelessWidget {
  final Animation<double> floatAnimation;
  final Animation<double>? exitAnimation;
  final bool enableAnimation;

  const HeroAmbientBloom({
    super.key,
    required this.floatAnimation,
    this.exitAnimation,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final Listenable animationListenable = exitAnimation != null
        ? Listenable.merge([floatAnimation, exitAnimation!])
        : floatAnimation;

    return AnimatedBuilder(
      animation: animationListenable,
      builder: (context, _) {
        final val = enableAnimation ? floatAnimation.value : 0.0;
        final exitVal = exitAnimation?.value ?? 0.0;
        final angle = val * 2 * math.pi;

        final glowScale = (enableAnimation
            ? 1.0 + (math.sin(angle) * 0.05)
            : 1.0) * (1.0 + exitVal * 0.7);
        final glowOpacity = enableAnimation
            ? 0.32 + (math.sin(angle) * 0.08)
            : 0.30;
        final innerGlowScale = enableAnimation
            ? 1.0 - (math.sin(angle) * 0.04)
            : 1.0;

        return RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: glowScale,
                child: Container(
                  width: 260.0,
                  height: 260.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF653F).withValues(alpha: glowOpacity),
                        const Color(0xFFFF653F).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: innerGlowScale,
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFC85C).withValues(alpha: glowOpacity * 0.65),
                        const Color(0xFFFFC85C).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
