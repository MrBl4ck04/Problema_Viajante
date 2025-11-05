import 'package:flutter/material.dart';

class Dibujo extends CustomPainter{
  final double x,y,w,h;
  Dibujo({super.repaint, required this.x, required this.y, required this.w, required this.h});
  @override
  void paint(Canvas canvas, Size size){
    Paint paint = Paint()
    ..color = Colors.purple
    ..style = PaintingStyle.fill;

    Path m = Path();
    m.moveTo(x, y+h/2);
    m.quadraticBezierTo(x+w/2, y+h/2, x+w/2, y);
    m.quadraticBezierTo(x+w/2, y+h/2, x+w, y+h/2);
    m.lineTo(x+4*w/6, y+h/2);
    m.lineTo(x+4*w/6, y+5*h/6);
    m.lineTo(x+w, y+h);
    m.lineTo(x+4*w/6, y+h);
    m.lineTo(x+w/2, y+5*h/6);
    m.lineTo(x+2*w/6, y+h);
    m.lineTo(x, y+h);
    m.lineTo(x+2*w/6, y+5*h/6);
    m.lineTo(x+2*w/6, y+h/2);
    m.lineTo(x, y+h/2);

    canvas.drawPath(m, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
    return true;
  }
}