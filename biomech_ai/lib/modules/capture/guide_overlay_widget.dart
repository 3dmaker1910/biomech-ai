import 'package:flutter/material.dart';

class GuideOverlayWidget extends StatelessWidget {
  final bool isBody;

  const GuideOverlayWidget({super.key, required this.isBody});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 120),
      painter: isBody ? _BodySilhouettePainter() : _FootSilhouettePainter(),
    );
  }
}

class _BodySilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withOpacity(0.15)..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    canvas.drawCircle(Offset(centerX, size.height * 0.1), size.width * 0.1, paint);
    final bodyPath = Path();
    bodyPath.moveTo(centerX - size.width * 0.15, size.height * 0.2);
    bodyPath.lineTo(centerX + size.width * 0.15, size.height * 0.2);
    bodyPath.lineTo(centerX + size.width * 0.12, size.height * 0.55);
    bodyPath.lineTo(centerX - size.width * 0.12, size.height * 0.55);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);
    final leftLeg = Path();
    leftLeg.moveTo(centerX - size.width * 0.12, size.height * 0.55);
    leftLeg.lineTo(centerX - size.width * 0.02, size.height * 0.55);
    leftLeg.lineTo(centerX - size.width * 0.04, size.height * 0.95);
    leftLeg.lineTo(centerX - size.width * 0.14, size.height * 0.95);
    leftLeg.close();
    canvas.drawPath(leftLeg, paint);
    final rightLeg = Path();
    rightLeg.moveTo(centerX + size.width * 0.02, size.height * 0.55);
    rightLeg.lineTo(centerX + size.width * 0.12, size.height * 0.55);
    rightLeg.lineTo(centerX + size.width * 0.14, size.height * 0.95);
    rightLeg.lineTo(centerX + size.width * 0.04, size.height * 0.95);
    rightLeg.close();
    canvas.drawPath(rightLeg, paint);
    final leftArm = Path();
    leftArm.moveTo(centerX - size.width * 0.15, size.height * 0.22);
    leftArm.lineTo(centerX - size.width * 0.35, size.height * 0.5);
    leftArm.lineTo(centerX - size.width * 0.30, size.height * 0.52);
    leftArm.lineTo(centerX - size.width * 0.12, size.height * 0.28);
    leftArm.close();
    canvas.drawPath(leftArm, paint);
    final rightArm = Path();
    rightArm.moveTo(centerX + size.width * 0.15, size.height * 0.22);
    rightArm.lineTo(centerX + size.width * 0.35, size.height * 0.5);
    rightArm.lineTo(centerX + size.width * 0.30, size.height * 0.52);
    rightArm.lineTo(centerX + size.width * 0.12, size.height * 0.28);
    rightArm.close();
    canvas.drawPath(rightArm, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FootSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withOpacity(0.15)..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final footPath = Path();
    footPath.moveTo(centerX - size.width * 0.15, centerY - size.height * 0.35);
    footPath.quadraticBezierTo(centerX - size.width * 0.25, centerY - size.height * 0.1, centerX - size.width * 0.2, centerY + size.height * 0.2);
    footPath.quadraticBezierTo(centerX - size.width * 0.15, centerY + size.height * 0.35, centerX, centerY + size.height * 0.38);
    footPath.quadraticBezierTo(centerX + size.width * 0.2, centerY + size.height * 0.35, centerX + size.width * 0.2, centerY + size.height * 0.2);
    footPath.quadraticBezierTo(centerX + size.width * 0.25, centerY - size.height * 0.1, centerX + size.width * 0.15, centerY - size.height * 0.3);
    footPath.quadraticBezierTo(centerX + size.width * 0.1, centerY - size.height * 0.4, centerX, centerY - size.height * 0.38);
    footPath.quadraticBezierTo(centerX - size.width * 0.1, centerY - size.height * 0.4, centerX - size.width * 0.15, centerY - size.height * 0.35);
    footPath.close();
    canvas.drawPath(footPath, paint);
    final toePaint = Paint()..color = Colors.grey.withOpacity(0.12)..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final x = centerX - size.width * 0.12 + (i * size.width * 0.06);
      final y = centerY - size.height * 0.42 - (i == 0 ? 4 : (i == 4 ? 4 : 0));
      final radius = i == 0 ? 5.0 : 4.0;
      canvas.drawCircle(Offset(x, y), radius, toePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
