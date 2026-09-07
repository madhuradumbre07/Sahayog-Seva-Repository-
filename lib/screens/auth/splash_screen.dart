import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../widgets/community_skyline.dart';
import '../../widgets/handshake_logo.dart';

/// Brand introduction, then auto-advance into language selection.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.useLinearProgress = false});

  static const Duration delay = Duration(milliseconds: 2500);
  static const String nextRoute = '/language-selection';

  final bool useLinearProgress;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(SplashScreen.delay, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, SplashScreen.nextRoute);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomIllustrationHeight = MediaQuery.sizeOf(context).height * 0.32;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: CommunitySkyline(height: bottomIllustrationHeight),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HandshakeLogo(size: 112),
                      const SizedBox(height: 32),
                      Text(
                        context.tr('appName'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${context.tr('taglineLine1')}\n${context.tr('taglineLine2')}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.tagline,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _SplashProgress(useLinear: widget.useLinearProgress),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.useLinear});

  final bool useLinear;

  @override
  Widget build(BuildContext context) {
    if (useLinear) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          child: LinearProgressIndicator(
            minHeight: 4,
            color: AppColors.primary,
            backgroundColor: Color(0x1A0D47A1),
          ),
        ),
      );
    }

    return const SizedBox.square(
      dimension: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2.6,
        color: AppColors.primary,
      ),
    );
  }
}
