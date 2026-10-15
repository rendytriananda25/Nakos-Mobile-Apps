import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BentoNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final bool isCenterAction;

  const BentoNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.isCenterAction = false,
  });
}

typedef FloatingBentoNav = LiquidGlassNavBar;

class FluidPillMetrics {
  final double centerX;
  final double width;
  final double height;
  final double cornerRadius;
  final double glowSpread;
  final Color borderColor;
  final Color fillColor;

  const FluidPillMetrics({
    required this.centerX,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.glowSpread,
    required this.borderColor,
    required this.fillColor,
  });

  FluidPillMetrics copyWith({
    double? centerX,
    double? width,
    double? height,
    double? cornerRadius,
    double? glowSpread,
    Color? borderColor,
    Color? fillColor,
  }) {
    return FluidPillMetrics(
      centerX: centerX ?? this.centerX,
      width: width ?? this.width,
      height: height ?? this.height,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      glowSpread: glowSpread ?? this.glowSpread,
      borderColor: borderColor ?? this.borderColor,
      fillColor: fillColor ?? this.fillColor,
    );
  }
}

class LiquidGlassNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback? onAddPressed;
  final List<BentoNavItem>? items;

  const LiquidGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    this.onAddPressed,
    this.items,
  });

  static const List<BentoNavItem> defaultItems = [
    BentoNavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    BentoNavItem(
      label: 'Alokasi',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    BentoNavItem(
      label: 'Dompet',
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card_rounded,
    ),
    BentoNavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  static const double _w0 = 54.0;
  static const double _h0 = 54.0;
  static const double _wMax = 110.0;
  static const double _kd = 0.35;
  static const double _kv = 0.08;
  static const double _gamma = 0.30;
  static const double _lambda = 0.45;

  late final AnimationController _snapController;
  late final ValueNotifier<FluidPillMetrics> _pillMetricsNotifier;

  Timer? _chargeTimer;
  bool _isDragging = false;
  double _dockWidth = 360.0;
  double _lastTouchX = 0.0;
  double _dragVelocityX = 0.0;
  int _lastVelocityTime = 0;
  int _lastHapticTime = 0;
  int _lastHapticTab = 0;

  FluidPillMetrics _animStartMetrics = const FluidPillMetrics(
    centerX: 27.0,
    width: _w0,
    height: _h0,
    cornerRadius: 26.0,
    glowSpread: 16.0,
    borderColor: Color(0x99FF653F),
    fillColor: Color(0x33FF653F),
  );

  FluidPillMetrics _animTargetMetrics = const FluidPillMetrics(
    centerX: 27.0,
    width: _w0,
    height: _h0,
    cornerRadius: 26.0,
    glowSpread: 16.0,
    borderColor: Color(0x99FF653F),
    fillColor: Color(0x33FF653F),
  );

  @override
  void initState() {
    super.initState();
    _lastHapticTab = widget.selectedIndex;

    final initialCenter = _getTabCenterX(widget.selectedIndex, _dockWidth);
    _pillMetricsNotifier = ValueNotifier<FluidPillMetrics>(
      FluidPillMetrics(
        centerX: initialCenter,
        width: _w0,
        height: _h0,
        cornerRadius: 26.0,
        glowSpread: 16.0,
        borderColor: const Color(0x99FF653F),
        fillColor: const Color(0x33FF653F),
      ),
    );

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _snapController.addListener(_onSnapTick);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex && !_isDragging) {
      _animateToTab(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _chargeTimer?.cancel();
    _snapController.dispose();
    _pillMetricsNotifier.dispose();
    super.dispose();
  }

  List<BentoNavItem> get _navItems =>
      widget.items ?? LiquidGlassNavBar.defaultItems;

  double _getTabCenterX(int index, double dockWidth) {
    final count = _navItems.length;
    if (count == 0) return _w0 / 2;
    final slotWidth = dockWidth / count;
    return (index + 0.5) * slotWidth;
  }

  int _getTabFromCenterX(double centerX, double dockWidth) {
    final count = _navItems.length;
    if (count <= 1) return 0;
    final slotWidth = dockWidth / count;
    final index = (centerX / slotWidth).floor();
    return index.clamp(0, count - 1);
  }

  void _onSnapTick() {
    final t = CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutBack,
    ).value;

    final overshootBounce = math.sin(t * math.pi) * 6.0;
    final undershootDip = math.sin(t * math.pi) * 2.0;

    final cx = lerpDouble(_animStartMetrics.centerX, _animTargetMetrics.centerX, t)!;
    final w = (lerpDouble(_animStartMetrics.width, _animTargetMetrics.width, t)! + overshootBounce)
        .clamp(_w0, _wMax);
    final h = (lerpDouble(_animStartMetrics.height, _animTargetMetrics.height, t)! - undershootDip)
        .clamp(40.0, _h0);
    final spread = lerpDouble(_animStartMetrics.glowSpread, 16.0, t)!;
    final border = Color.lerp(_animStartMetrics.borderColor, const Color(0x99FF653F), t)!;
    final fill = Color.lerp(_animStartMetrics.fillColor, const Color(0x33FF653F), t)!;

    _pillMetricsNotifier.value = FluidPillMetrics(
      centerX: cx,
      width: w,
      height: h,
      cornerRadius: (h / 2.0).clamp(20.0, 26.0),
      glowSpread: spread,
      borderColor: border,
      fillColor: fill,
    );
  }

  void _animateToTab(int targetIndex) {
    _chargeTimer?.cancel();
    _snapController.stop();

    _animStartMetrics = _pillMetricsNotifier.value;
    final targetCenter = _getTabCenterX(targetIndex, _dockWidth);

    _animTargetMetrics = FluidPillMetrics(
      centerX: targetCenter,
      width: _w0,
      height: _h0,
      cornerRadius: 26.0,
      glowSpread: 16.0,
      borderColor: const Color(0x99FF653F),
      fillColor: const Color(0x33FF653F),
    );

    _snapController.forward(from: 0.0);
  }

  void _startChargeTimer(double localX) {
    if (_isDragging) return;
    _chargeTimer?.cancel();
    _chargeTimer = Timer(const Duration(milliseconds: 80), () {
      if (!mounted || _isDragging) return;
      _pillMetricsNotifier.value = _pillMetricsNotifier.value.copyWith(
        width: _w0 - 4.0,
        height: _h0 - 4.0,
        glowSpread: 22.0,
        borderColor: const Color(0xCCFFC85C),
      );
      HapticFeedback.selectionClick();
    });
  }

  void _cancelCharge() {
    _chargeTimer?.cancel();
    if (!_isDragging && !_snapController.isAnimating) {
      final current = _pillMetricsNotifier.value;
      _pillMetricsNotifier.value = current.copyWith(
        width: _w0,
        height: _h0,
        glowSpread: 16.0,
        borderColor: const Color(0x99FF653F),
      );
    }
  }

  void _onDragStart(DragStartDetails details) {
    _chargeTimer?.cancel();
    _snapController.stop();
    _isDragging = true;
    _lastTouchX = details.localPosition.dx;
    _dragVelocityX = 0.0;
    _lastVelocityTime = DateTime.now().millisecondsSinceEpoch;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final dt = (now - _lastVelocityTime).clamp(1, 100);
    final touchX = details.localPosition.dx.clamp(0.0, _dockWidth);
    final dx = touchX - _lastTouchX;

    final instantVelocity = (dx / dt) * 1000.0;
    _dragVelocityX = (_dragVelocityX * 0.7) + (instantVelocity * 0.3);
    _lastTouchX = touchX;
    _lastVelocityTime = now;

    final elongation = math.min(
      _wMax - _w0,
      (dx.abs() * _kd) + (_dragVelocityX.abs() * _kv),
    );
    final wActive = (_w0 + elongation).clamp(_w0, _wMax);

    final hActive = (_h0 * math.pow(_w0 / wActive, _gamma)).toDouble().clamp(38.0, _h0);

    final sgn = _dragVelocityX > 20.0 ? 1.0 : (_dragVelocityX < -20.0 ? -1.0 : 0.0);
    final lagOffset = sgn * ((wActive - _w0) / 2.0) * _lambda;
    final renderCenterX = (touchX - lagOffset).clamp(wActive / 2.0, _dockWidth - (wActive / 2.0));

    final currentHoverTab = _getTabFromCenterX(renderCenterX, _dockWidth);
    if (currentHoverTab != _lastHapticTab && (now - _lastHapticTime >= 45)) {
      _lastHapticTab = currentHoverTab;
      _lastHapticTime = now;
      HapticFeedback.selectionClick();
    }

    final tStretch = ((wActive - _w0) / (_wMax - _w0)).clamp(0.0, 1.0);
    final glowSpread = lerpDouble(16.0, 28.0, tStretch)!;
    final borderColor = Color.lerp(
      const Color(0x99FF653F),
      const Color(0xE6FFC85C),
      tStretch,
    )!;

    _pillMetricsNotifier.value = FluidPillMetrics(
      centerX: renderCenterX,
      width: wActive,
      height: hActive,
      cornerRadius: (hActive / 2.0).clamp(20.0, 26.0),
      glowSpread: glowSpread,
      borderColor: borderColor,
      fillColor: const Color(0x33FF653F),
    );
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final currentCenterX = _pillMetricsNotifier.value.centerX;
    final targetIndex = _getTabFromCenterX(currentCenterX, _dockWidth);

    _animStartMetrics = _pillMetricsNotifier.value;
    final targetCenter = _getTabCenterX(targetIndex, _dockWidth);

    _animTargetMetrics = FluidPillMetrics(
      centerX: targetCenter,
      width: _w0,
      height: _h0,
      cornerRadius: 26.0,
      glowSpread: 18.0,
      borderColor: const Color(0x99FF653F),
      fillColor: const Color(0x33FF653F),
    );

    _snapController.forward(from: 0.0).then((_) {
      HapticFeedback.lightImpact();
    });

    if (targetIndex != widget.selectedIndex) {
      widget.onIndexChanged(targetIndex);
    }
  }

  void _onDragCancel() {
    _isDragging = false;
    _animateToTab(widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _navItems;
    final totalCount = navItems.length;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              _dockWidth = constraints.maxWidth;

              if (!_isDragging && !_snapController.isAnimating) {
                final targetCenter = _getTabCenterX(widget.selectedIndex, _dockWidth);
                if ((_pillMetricsNotifier.value.centerX - targetCenter).abs() > 0.5) {
                  _pillMetricsNotifier.value = _pillMetricsNotifier.value.copyWith(
                    centerX: targetCenter,
                  );
                }
              }

              return Container(
                height: 68.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 24.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                    child: Container(
                      height: 68.0,
                      decoration: BoxDecoration(
                        color: const Color(0xF208080A),
                        borderRadius: BorderRadius.circular(34.0),
                        border: Border.all(
                          color: const Color(0x2EFFFFFF),
                          width: 1.2,
                        ),
                      ),
                      child: Listener(
                        onPointerDown: (e) => _startChargeTimer(e.localPosition.dx),
                        onPointerUp: (_) => _cancelCharge(),
                        onPointerCancel: (_) => _cancelCharge(),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragStart: _onDragStart,
                          onHorizontalDragUpdate: _onDragUpdate,
                          onHorizontalDragEnd: _onDragEnd,
                          onHorizontalDragCancel: _onDragCancel,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              RepaintBoundary(
                                child: CustomPaint(
                                  size: Size(_dockWidth, 68.0),
                                  painter: _FluidPillPainter(
                                    metricsNotifier: _pillMetricsNotifier,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  for (int i = 0; i < totalCount; i++)
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          if (widget.selectedIndex != i) {
                                            widget.onIndexChanged(i);
                                          }
                                        },
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedScale(
                                                scale: (widget.selectedIndex == i) ? 1.15 : 1.0,
                                                duration: const Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                child: Icon(
                                                  (widget.selectedIndex == i && navItems[i].activeIcon != null)
                                                      ? navItems[i].activeIcon!
                                                      : navItems[i].icon,
                                                  size: 22.0,
                                                  color: (widget.selectedIndex == i)
                                                      ? const Color(0xFFFFC85C)
                                                      : const Color(0xFF71717A),
                                                ),
                                              ),
                                              const SizedBox(height: 3.0),
                                              Text(
                                                navItems[i].label,
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: (widget.selectedIndex == i)
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: (widget.selectedIndex == i)
                                                      ? const Color(0xFFFFC85C)
                                                      : const Color(0xFF71717A),
                                                  letterSpacing: 0.1,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FluidPillPainter extends CustomPainter {
  final ValueNotifier<FluidPillMetrics> metricsNotifier;

  _FluidPillPainter({required this.metricsNotifier}) : super(repaint: metricsNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    final m = metricsNotifier.value;
    final rect = Rect.fromCenter(
      center: Offset(m.centerX, size.height / 2.0),
      width: m.width,
      height: m.height,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(m.cornerRadius),
    );

    final glowPaint = Paint()
      ..color = const Color(0x40FF653F)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, m.glowSpread);
    canvas.drawRRect(rrect, glowPaint);

    final fillPaint = Paint()
      ..color = m.fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    final specularHeight = rect.height * 0.45;
    final specularRect = Rect.fromLTWH(rect.left, rect.top, rect.width, specularHeight);
    final specularRRect = RRect.fromRectAndCorners(
      specularRect,
      topLeft: Radius.circular(m.cornerRadius),
      topRight: Radius.circular(m.cornerRadius),
    );
    final specularPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(specularRect);
    canvas.drawRRect(specularRRect, specularPaint);

    final borderPaint = Paint()
      ..color = m.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _FluidPillPainter oldDelegate) => false;
}
