import 'package:flutter/material.dart';
import 'package:grafito/modelos/modelo_nodo.dart';
import 'package:grafito/modelos/modelo_enlace.dart';
import 'dart:math';

class DibujoNodo extends CustomPainter {
  final List<ModeloNodo> vNodo;
  final List<ModeloEnlace> enlaces;
  final List<int>? rutaOptima;
  final double animacionProgreso;
  final int? nodoSeleccionado;
  final Offset? puntoControlTemp;

  DibujoNodo({
    required this.vNodo,
    this.enlaces = const [],
    this.rutaOptima,
    this.animacionProgreso = 0.0,
    this.nodoSeleccionado,
    this.puntoControlTemp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar enlaces primero (debajo de los nodos)
    _dibujarEnlaces(canvas);
    
    // Dibujar ruta óptima si existe
    if (rutaOptima != null && rutaOptima!.isNotEmpty) {
      _dibujarRutaOptima(canvas);
    }
    
    // Dibujar nodos
    _dibujarNodos(canvas);
    
    // Dibujar punto de control temporal si existe
    if (puntoControlTemp != null && nodoSeleccionado != null) {
      _dibujarPuntoControl(canvas, puntoControlTemp!);
    }
  }

  void _dibujarEnlaces(Canvas canvas) {
    Paint paintLinea = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Paint paintFlecha = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    for (var enlace in enlaces) {
      if (enlace.origen >= vNodo.length || enlace.destino >= vNodo.length) continue;

      Offset inicio = Offset(vNodo[enlace.origen].x, vNodo[enlace.origen].y);
      Offset fin = Offset(vNodo[enlace.destino].x, vNodo[enlace.destino].y);

      if (enlace.puntoControl != null) {
        // Dibujar curva de Bezier
        Path path = Path();
        path.moveTo(inicio.dx, inicio.dy);
        path.quadraticBezierTo(
          enlace.puntoControl!.dx,
          enlace.puntoControl!.dy,
          fin.dx,
          fin.dy,
        );
        canvas.drawPath(path, paintLinea);

        // Dibujar punto de control
        _dibujarPuntoControl(canvas, enlace.puntoControl!);

        // Dibujar flecha en el punto medio de la curva
        Offset puntoMedio = _calcularPuntoBezier(inicio, enlace.puntoControl!, fin, 0.5);
        Offset tangente = _calcularTangenteBezier(inicio, enlace.puntoControl!, fin, 0.5);
        _dibujarFlecha(canvas, puntoMedio, tangente, paintFlecha);

        // Dibujar peso cerca del punto de control
        _dibujarPeso(canvas, enlace.puntoControl!, enlace.peso);
      } else {
        // Dibujar línea recta
        canvas.drawLine(inicio, fin, paintLinea);

        // Dibujar flecha
        Offset direccion = fin - inicio;
        Offset puntoMedio = inicio + direccion * 0.5;
        _dibujarFlecha(canvas, puntoMedio, direccion, paintFlecha);

        // Dibujar peso en el punto medio
        _dibujarPeso(canvas, puntoMedio, enlace.peso);
      }
    }
  }

  void _dibujarPuntoControl(Canvas canvas, Offset punto) {
    Paint paintControl = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(punto, 6, paintControl);
    
    Paint paintBorde = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(punto, 6, paintBorde);
  }

  Offset _calcularPuntoBezier(Offset p0, Offset p1, Offset p2, double t) {
    double x = pow(1 - t, 2) * p0.dx + 2 * (1 - t) * t * p1.dx + pow(t, 2) * p2.dx;
    double y = pow(1 - t, 2) * p0.dy + 2 * (1 - t) * t * p1.dy + pow(t, 2) * p2.dy;
    return Offset(x, y);
  }

  Offset _calcularTangenteBezier(Offset p0, Offset p1, Offset p2, double t) {
    double dx = 2 * (1 - t) * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx);
    double dy = 2 * (1 - t) * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy);
    return Offset(dx, dy);
  }

  void _dibujarFlecha(Canvas canvas, Offset posicion, Offset direccion, Paint paint) {
    double angulo = atan2(direccion.dy, direccion.dx);
    double tamanioFlecha = 10.0;

    Path flecha = Path();
    flecha.moveTo(posicion.dx, posicion.dy);
    flecha.lineTo(
      posicion.dx - tamanioFlecha * cos(angulo - pi / 6),
      posicion.dy - tamanioFlecha * sin(angulo - pi / 6),
    );
    flecha.lineTo(
      posicion.dx - tamanioFlecha * cos(angulo + pi / 6),
      posicion.dy - tamanioFlecha * sin(angulo + pi / 6),
    );
    flecha.close();

    canvas.drawPath(flecha, paint);
  }

  void _dibujarPeso(Canvas canvas, Offset posicion, double peso) {
    TextSpan span = TextSpan(
      text: peso.toStringAsFixed(1),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.white,
      ),
    );

    TextPainter textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(posicion.dx - textPainter.width / 2, posicion.dy - textPainter.height / 2),
    );
  }

  void _dibujarRutaOptima(Canvas canvas) {
    if (rutaOptima == null || rutaOptima!.length < 2) return;

    Paint paintRuta = Paint()
      ..color = Colors.green.withOpacity(0.7)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Calcular cuántos segmentos dibujar según el progreso de animación
    int segmentosTotales = rutaOptima!.length;
    int segmentosDibujar = (segmentosTotales * animacionProgreso).ceil();

    for (int i = 0; i < segmentosDibujar && i < rutaOptima!.length; i++) {
      int siguiente = (i + 1) % rutaOptima!.length;
      
      if (rutaOptima![i] >= vNodo.length || rutaOptima![siguiente] >= vNodo.length) continue;

      Offset inicio = Offset(vNodo[rutaOptima![i]].x, vNodo[rutaOptima![i]].y);
      Offset fin = Offset(vNodo[rutaOptima![siguiente]].x, vNodo[rutaOptima![siguiente]].y);

      // Si es el último segmento en animación, dibujar parcialmente
      if (i == segmentosDibujar - 1 && animacionProgreso < 1.0) {
        double progresoParcial = (segmentosTotales * animacionProgreso) - i;
        Offset finParcial = Offset(
          inicio.dx + (fin.dx - inicio.dx) * progresoParcial,
          inicio.dy + (fin.dy - inicio.dy) * progresoParcial,
        );
        canvas.drawLine(inicio, finParcial, paintRuta);
      } else {
        canvas.drawLine(inicio, fin, paintRuta);
      }
    }
  }

  void _dibujarNodos(Canvas canvas) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < vNodo.length; i++) {
      var ele = vNodo[i];
      
      // Resaltar nodo seleccionado
      if (nodoSeleccionado == i) {
        Paint paintResaltado = Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawCircle(Offset(ele.x, ele.y), ele.radio + 5, paintResaltado);
      }

      paint.color = ele.color;
      canvas.drawCircle(Offset(ele.x, ele.y), ele.radio, paint);

      // Dibujar texto del nodo
      TextSpan span = TextSpan(
        text: ele.mensaje,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

      TextPainter textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(ele.x - textPainter.width / 2, ele.y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DibujoNodo oldDelegate) {
    return oldDelegate.vNodo != vNodo ||
        oldDelegate.enlaces != enlaces ||
        oldDelegate.rutaOptima != rutaOptima ||
        oldDelegate.animacionProgreso != animacionProgreso ||
        oldDelegate.nodoSeleccionado != nodoSeleccionado ||
        oldDelegate.puntoControlTemp != puntoControlTemp;
  }
}