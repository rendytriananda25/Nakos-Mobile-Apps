import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'back_card_widget.dart';
import 'front_card_widget.dart';
import 'hero_ambient_bloom.dart';

class FloatingCardsHero extends StatefulWidget {
  final bool enableAnimation;
  final Animation<double>? exitAnimation;

  const FloatingCardsHero({
    super.key,
    this.enableAnimation = true,
    this.exitAnimation,
  });

  @override
  State<FloatingCardsHero> createState() => _FloatingCardsHeroState();
}

class _FloatingCardsHeroState extends State<FloatingCardsHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  double _touchX = 0.0;
  double _touchY = 0.0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    if (widget.enableAnimation) {
      _floatController.repeat();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Listenable animationListenable = widget.exitAnimation != null
        ? Listenable.merge([_floatController, widget.exitAnimation!])
        : _floatController;

    return SizedBox(
      height: 270.0,
      child: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            if (!widget.enableAnimation) return;
            setState(() {
              _touchX = (details.localPosition.dx / 320.0 - 0.5).clamp(-0.5, 0.5);
              _touchY = (details.localPosition.dy / 250.0 - 0.5).clamp(-0.5, 0.5);
            });
          },
          onPanEnd: (_) {
            if (!widget.enableAnimation) return;
            setState(() {
              _touchX = 0.0;
              _touchY = 0.0;
            });
          },
          onPanCancel: () {
            if (!widget.enableAnimation) return;
            setState(() {
              _touchX = 0.0;
              _touchY = 0.0;
            });
          },
          child: SizedBox(
            width: 320.0,
            height: 250.0,
            child: AnimatedBuilder(
              animation: animationListenable,
              builder: (context, _) {
                final val = widget.enableAnimation
                    ? _floatController.value
                    : 0.0;
                final exitVal = widget.exitAnimation?.value ?? 0.0;
                final idleAngle = val * 2 * math.pi;

                double slingshotX = 0.0;
                double slingshotY = 0.0;
                double deckSpinZ = 0.0;
                double deckTiltX = 0.0;
                double deckRollY = 0.0;
                double deckScale = 1.0;
                double deckOpacity = 1.0;

                double orbitRadiusX = 0.0;
                double orbitRadiusY = 0.0;
                double cardOrbitAngle = 0.0;

                if (exitVal > 0.0) {
                  if (exitVal < 0.22) {
                    final p = exitVal / 0.22;
                    final ease = 1.0 - (1.0 - p) * (1.0 - p);
                    slingshotX = -85.0 * ease;
                    slingshotY = 95.0 * ease;
                    deckSpinZ = -0.38 * ease;
                    deckTiltX = 0.12 * ease;
                    deckRollY = -0.20 * ease;
                    deckScale = 1.0 + (0.05 * ease);
                  } else {
                    final p = (exitVal - 0.22) / 0.78;
                    final ease = p * p * (1.15 + 0.35 * p);
                    slingshotX = -85.0 + 525.0 * ease;
                    slingshotY = 95.0 - 745.0 * ease;
                    deckSpinZ = -0.38 + (p * 1.50);
                    deckTiltX = 0.12 + (math.sin(p * math.pi) * -0.55);
                    deckRollY = -0.20 + (p * 2.40);
                    deckScale = (1.05 - (p * 0.65)).clamp(0.2, 1.2);
                    deckOpacity = (1.0 - (p > 0.72 ? (p - 0.72) / 0.28 : 0.0)).clamp(0.0, 1.0);
                  }

                  orbitRadiusX = 28.0 + (exitVal * 75.0);
                  orbitRadiusY = 16.0 + (exitVal * 42.0);
                  cardOrbitAngle = exitVal * 2.2 * math.pi;
                }

                final idleBackOffsetY = math.sin(idleAngle + (math.pi * 0.85)) * 7.0;
                final idleBackOffsetX = -math.cos(idleAngle + (math.pi * 0.85)) * 2.8;
                final idleBackTiltZ = -0.25 + (math.cos(idleAngle + (math.pi * 0.85)) * 0.015);
                final idleBackTiltX = 0.08 + (math.sin(idleAngle + (math.pi * 0.85)) * 0.02) + (-_touchY * 0.15);
                final idleBackTiltY = 0.06 - (math.cos(idleAngle + (math.pi * 0.85)) * 0.02) + (_touchX * 0.15);

                final idleFrontOffsetY = math.sin(idleAngle) * 8.5;
                final idleFrontOffsetX = math.cos(idleAngle) * 3.5;
                final idleFrontTiltZ = 0.14 + (math.sin(idleAngle) * 0.016);
                final idleFrontTiltX = 0.05 + (math.cos(idleAngle) * 0.02) + (-_touchY * 0.25);
                final idleFrontTiltY = -0.06 + (math.sin(idleAngle) * 0.025) + (_touchX * 0.25);

                final frontOrbitalDx = exitVal > 0.0
                    ? math.cos(cardOrbitAngle) * orbitRadiusX
                    : 0.0;
                final frontOrbitalDy = exitVal > 0.0
                    ? math.sin(cardOrbitAngle) * orbitRadiusY
                    : 0.0;
                final frontDepthFactor = exitVal > 0.0
                    ? 1.0 + (math.sin(cardOrbitAngle) * 0.08)
                    : 1.0;

                final backOrbitalDx = exitVal > 0.0
                    ? -math.cos(cardOrbitAngle) * orbitRadiusX
                    : 0.0;
                final backOrbitalDy = exitVal > 0.0
                    ? -math.sin(cardOrbitAngle) * orbitRadiusY
                    : 0.0;
                final backDepthFactor = exitVal > 0.0
                    ? 1.0 - (math.sin(cardOrbitAngle) * 0.08)
                    : 1.0;

                final frontElevation = math.sin(idleAngle);
                final frontShadowBlur = 24.0 + (frontElevation * 6.0);
                final frontShadowOffset = 12.0 + (frontElevation * 3.0);
                final frontShadowAlpha = 0.38 + (frontElevation * 0.08);

                final sheenProgress = (val * 1.4) % 1.0;

                final bool frontIsOnTop = exitVal > 0.0
                    ? frontOrbitalDy >= backOrbitalDy
                    : true;

                final backCardWidget = Positioned(
                  top: 38.0,
                  left: 12.0,
                  child: Transform.translate(
                    offset: Offset(idleBackOffsetX + backOrbitalDx, idleBackOffsetY + backOrbitalDy),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateZ(idleBackTiltZ)
                        ..rotateX(idleBackTiltX)
                        ..rotateY(idleBackTiltY),
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: backDepthFactor,
                        child: const BackCardWidget(),
                      ),
                    ),
                  ),
                );

                final frontCardWidget = Positioned(
                  top: 68.0,
                  right: 12.0,
                  child: Transform.translate(
                    offset: Offset(idleFrontOffsetX + frontOrbitalDx, idleFrontOffsetY + frontOrbitalDy),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateZ(idleFrontTiltZ)
                        ..rotateX(idleFrontTiltX)
                        ..rotateY(idleFrontTiltY),
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: frontDepthFactor,
                        child: FrontCardWidget(
                          sheenProgress: sheenProgress,
                          shadowBlur: frontShadowBlur,
                          shadowOffset: frontShadowOffset,
                          shadowAlpha: frontShadowAlpha,
                          enableAnimation: widget.enableAnimation,
                        ),
                      ),
                    ),
                  ),
                );

                return Transform.translate(
                  offset: Offset(slingshotX, slingshotY),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateZ(deckSpinZ)
                      ..rotateX(deckTiltX)
                      ..rotateY(deckRollY),
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: deckScale,
                      child: Opacity(
                        opacity: deckOpacity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            HeroAmbientBloom(
                              floatAnimation: _floatController,
                              exitAnimation: widget.exitAnimation,
                              enableAnimation: widget.enableAnimation,
                            ),
                            if (frontIsOnTop) ...[
                              backCardWidget,
                              frontCardWidget,
                            ] else ...[
                              frontCardWidget,
                              backCardWidget,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
