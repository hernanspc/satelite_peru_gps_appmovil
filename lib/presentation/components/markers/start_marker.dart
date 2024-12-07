import 'package:flutter/material.dart';

class StartMarkerPainter extends CustomPainter {
  final String minutes;
  final String destination;

  StartMarkerPainter({
    required this.minutes,
    required this.destination,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()..color = Colors.black;

    final whitePaint = Paint()..color = Colors.white;

    const double circleBlackRadius = 20;
    const double circleWhiteRadius = 7;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height - circleBlackRadius),
      circleBlackRadius,
      blackPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height - circleBlackRadius),
      circleWhiteRadius,
      whitePaint,
    );

    // Dibujar caja blanca
    final path = Path();
    path.moveTo(10, 20);
    path.lineTo(size.width - 10, 20);
    path.lineTo(size.width - 10, 100);
    path.lineTo(10, 100);

    canvas.drawShadow(path, Colors.black, 8, false);
    canvas.drawPath(path, whitePaint);

    //Dibujar Caja negra
    const blackBoxRec = Rect.fromLTWH(10, 20, 70, 80);
    canvas.drawRect(blackBoxRec, blackPaint);

    //Textos
    //Minutos
    final textSpan = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.w400,
      ),
      text: minutes,
    );

    final minutesPointer = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(
        minWidth: 70,
        maxWidth: 70,
      );

    minutesPointer.paint(
      canvas,
      const Offset(10, 35),
    );

    //PALABRA
    //MIN
    final minutesText = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w300,
      ),
      text: 'MIN',
    );

    final minutesMinPainter = TextPainter(
      text: minutesText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(
        minWidth: 70,
        maxWidth: 70,
      );

    minutesMinPainter.paint(
      canvas,
      const Offset(10, 68),
    );

    //Description
    final temDestino = destination;

    final locationText = TextSpan(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w300,
      ),
      text: temDestino,
    );

    final locationPainter = TextPainter(
      maxLines: 2,
      ellipsis: '..',
      text: locationText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(
        minWidth: size.width - 135,
        maxWidth: size.width - 135,
      );

    final double offsetY = (temDestino.length > 20) ? 35 : 38;

    locationPainter.paint(
      canvas,
      Offset(90, offsetY),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
