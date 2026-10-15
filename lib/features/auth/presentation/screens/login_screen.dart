import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../dashboard/presentation/screens/dashboard_home_screen.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/floating_cards_hero.dart';
import '../widgets/onboarding_cta_button.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_welcome_text.dart';

class LoginScreen extends StatefulWidget {
  final bool enableAnimation;

  const LoginScreen({super.key, this.enableAnimation = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final OnboardingController _controller;
  late final AnimationController _entranceController;
  late final AnimationController _exitController;
  late final Animation<double> _headerAnim;
  late final Animation<double> _cardsAnim;
  late final Animation<double> _textAnim;
  late final Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );

    _headerAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _cardsAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.65, curve: Curves.easeOutCubic),
    );
    _textAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic),
    );
    _buttonAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    );

    if (widget.enableAnimation) {
      _entranceController.forward();
    } else {
      _entranceController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _handleStartNow() async {
    await _controller.completeOnboarding(context);

    if (!mounted) return;

    if (widget.enableAnimation) {
      _exitController.forward();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(
          milliseconds: widget.enableAnimation ? 400 : 0,
        ),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: Transform.scale(
              scale: 0.95 + (curvedAnimation.value * 0.05),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFF000000),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.4),
              radius: 1.2,
              colors: [Color(0xFF18181C), Color(0xFF0E0E12), Color(0xFF000000)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: AnimatedBuilder(
                          animation: _exitController,
                          builder: (context, _) {
                            final exitVal = _exitController.value;
                            final uiFade = (1.0 - (exitVal * 2.8)).clamp(0.0, 1.0);
                            final uiSlideY = exitVal * 28.0;

                            return Column(
                              children: [
                                const SizedBox(height: 20.0),
                                Opacity(
                                  opacity: uiFade,
                                  child: AnimatedBuilder(
                                    animation: _headerAnim,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _headerAnim.value,
                                        child: Transform.translate(
                                          offset: Offset(0, (1.0 - _headerAnim.value) * -12.0),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: const OnboardingHeader(),
                                  ),
                                ),
                                const Spacer(),
                                AnimatedBuilder(
                                  animation: _cardsAnim,
                                  builder: (context, child) {
                                    final val = _cardsAnim.value;
                                    return Opacity(
                                      opacity: val.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 0.88 + (val * 0.12),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: FloatingCardsHero(
                                    enableAnimation: widget.enableAnimation,
                                    exitAnimation: _exitController,
                                  ),
                                ),
                                const Spacer(),
                                Opacity(
                                  opacity: uiFade,
                                  child: Transform.translate(
                                    offset: Offset(0, uiSlideY),
                                    child: AnimatedBuilder(
                                      animation: _textAnim,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: _textAnim.value,
                                          child: Transform.translate(
                                            offset: Offset(0, (1.0 - _textAnim.value) * 16.0),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: const OnboardingWelcomeText(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28.0),
                                Opacity(
                                  opacity: uiFade,
                                  child: Transform.translate(
                                    offset: Offset(0, uiSlideY),
                                    child: AnimatedBuilder(
                                      animation: _buttonAnim,
                                      builder: (context, child) {
                                        final val = _buttonAnim.value;
                                        return Opacity(
                                          opacity: val.clamp(0.0, 1.0),
                                          child: Transform.scale(
                                            scale: 0.90 + (val * 0.10),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: OnboardingCtaButton(
                                        onTap: _handleStartNow,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            );
                          },
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
