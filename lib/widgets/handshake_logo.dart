import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular handshake mark: two interlocking hands, tilted ~45°.
class HandshakeLogo extends StatelessWidget {
  const HandshakeLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SahayogSeva logo',
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.17),
            child: const CustomPaint(painter: _HandshakePainter()),
          ),
        ),
      ),
    );
  }
}

class _HandshakePainter extends CustomPainter {
  const _HandshakePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide;
    final stroke = u * 0.115;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    // Horizontal clasp, then tilt so it reads as a rounded diamond.
    canvas.rotate(-math.pi / 4);

    // Left hand: rounded U opening to the right (wrist on the left).
    final leftHand = Path()
      ..moveTo(u * 0.22, -u * 0.05)
      ..lineTo(-u * 0.16, -u * 0.05)
      ..arcToPoint(
        Offset(-u * 0.16, u * 0.23),
        radius: Radius.circular(u * 0.14),
        clockwise: false,
      )
      ..lineTo(u * 0.10, u * 0.23);

    // Left thumb curling up into the clasp.
    final leftThumb = Path()
      ..moveTo(-u * 0.02, u * 0.23)
      ..quadraticBezierTo(u * 0.12, u * 0.34, u * 0.20, u * 0.14);

    // Right hand: rounded U opening to the left (wrist on the right).
    final rightHand = Path()
      ..moveTo(-u * 0.22, u * 0.05)
      ..lineTo(u * 0.16, u * 0.05)
      ..arcToPoint(
        Offset(u * 0.16, -u * 0.23),
        radius: Radius.circular(u * 0.14),
        clockwise: false,
      )
      ..lineTo(-u * 0.10, -u * 0.23);

    // Right thumb curling down into the clasp.
    final rightThumb = Path()
      ..moveTo(u * 0.02, -u * 0.23)
      ..quadraticBezierTo(-u * 0.12, -u * 0.34, -u * 0.20, -u * 0.14);

    canvas.drawPath(leftHand, paint);
    canvas.drawPath(leftThumb, paint);
    canvas.drawPath(rightHand, paint);
    canvas.drawPath(rightThumb, paint);

    // Four parallel finger strokes across the interlocking palms.
    final fingerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.72
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final x = -u * 0.06 + i * u * 0.055;
      canvas.drawLine(
        Offset(x, -u * 0.09),
        Offset(x + u * 0.02, u * 0.09),
        fingerPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
