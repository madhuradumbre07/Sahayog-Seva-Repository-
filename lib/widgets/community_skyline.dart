import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Subtle cityscape illustration anchored to the bottom of the splash.
class CommunitySkyline extends StatelessWidget {
  const CommunitySkyline({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(painter: _CommunitySkylinePainter()),
      ),
    );
  }
}

class _CommunitySkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.background,
          AppColors.illustrationSoft.withValues(alpha: 0.35),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, fade);

    final fill = Paint()
      ..color = AppColors.illustration.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    final midFill = Paint()
      ..color = AppColors.illustrationSoft.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final ground = h;

    _drawCloud(canvas, Offset(w * 0.14, h * 0.22), w * 0.16, fill);
    _drawCloud(canvas, Offset(w * 0.86, h * 0.18), w * 0.14, fill);

    _drawBuilding(canvas, Offset(w * 0.04, ground), w * 0.10, h * 0.42, fill);
    _drawBuilding(canvas, Offset(w * 0.13, ground), w * 0.09, h * 0.58, midFill);
    _drawBuilding(canvas, Offset(w * 0.22, ground), w * 0.12, h * 0.36, fill);
    _drawTree(canvas, Offset(w * 0.36, ground), h * 0.28, fill);
    _drawBuilding(canvas, Offset(w * 0.40, ground), w * 0.11, h * 0.50, midFill);
    _drawBuilding(canvas, Offset(w * 0.50, ground), w * 0.08, h * 0.34, fill);
    _drawBuilding(canvas, Offset(w * 0.58, ground), w * 0.13, h * 0.62, fill);
    _drawTree(canvas, Offset(w * 0.74, ground), h * 0.24, midFill);
    _drawBuilding(canvas, Offset(w * 0.76, ground), w * 0.10, h * 0.40, midFill);
    _drawBuilding(canvas, Offset(w * 0.86, ground), w * 0.12, h * 0.52, fill);
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius * 0.55, paint);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.45, center.dy + radius * 0.08),
      radius * 0.42,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.48, center.dy + radius * 0.1),
      radius * 0.4,
      paint,
    );
  }

  void _drawBuilding(
    Canvas canvas,
    Offset baseLeft,
    double width,
    double height,
    Paint paint,
  ) {
    final body = Rect.fromLTWH(
      baseLeft.dx,
      baseLeft.dy - height,
      width,
      height,
    );
    canvas.drawRect(body, paint);

    final roof = Path()
      ..moveTo(baseLeft.dx, baseLeft.dy - height)
      ..lineTo(baseLeft.dx + width / 2, baseLeft.dy - height - width * 0.22)
      ..lineTo(baseLeft.dx + width, baseLeft.dy - height)
      ..close();
    canvas.drawPath(roof, paint);
  }

  void _drawTree(Canvas canvas, Offset base, double height, Paint paint) {
    final trunkWidth = height * 0.12;
    final trunk = Rect.fromCenter(
      center: Offset(base.dx, base.dy - height * 0.18),
      width: trunkWidth,
      height: height * 0.36,
    );
    canvas.drawRect(trunk, paint);
    canvas.drawCircle(
      Offset(base.dx, base.dy - height * 0.48),
      height * 0.28,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
