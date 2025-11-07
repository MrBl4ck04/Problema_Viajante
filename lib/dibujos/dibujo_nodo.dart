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
    // Sombra del enlace
    Paint paintSombra = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    Paint paintLinea = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ).createShader(const Rect.fromLTWH(0, 0, 500, 500))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint paintFlecha = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ).createShader(const Rect.fromLTWH(0, 0, 200, 200))
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
        // Dibujar sombra primero
        canvas.drawPath(path, paintSombra);
        // Luego la línea con gradiente
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
        // Dibujar línea recta con sombra
        canvas.drawLine(inicio, fin, paintSombra);
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
    // Glow effect
    Paint paintGlow = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(punto, 10, paintGlow);
    
    // Gradiente radial
    Paint paintControl = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
      ).createShader(Rect.fromCircle(center: punto, radius: 8))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(punto, 8, paintControl);
    
    // Borde brillante
    Paint paintBorde = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(punto, 8, paintBorde);
    
    // Punto central brillante
    Paint paintCentro = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(punto, 2, paintCentro);
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
    // Fondo con glassmorphism
    Paint paintFondo = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    final textSpan = TextSpan(
      text: peso.toStringAsFixed(1),
      style: const TextStyle(
        color: Color(0xFF667eea),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );

    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    
    // Dibujar fondo redondeado
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: posicion,
        width: textPainter.width + 12,
        height: textPainter.height + 8,
      ),
      const Radius.circular(12),
    );
    
    canvas.drawRRect(rect, paintFondo);
    
    // Borde del fondo
    Paint paintBorde = Paint()
      ..color = const Color(0xFF667eea).withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rect, paintBorde);
    
    textPainter.paint(
      canvas,
      Offset(posicion.dx - textPainter.width / 2, posicion.dy - textPainter.height / 2),
    );
  }

  void _dibujarRutaOptima(Canvas canvas) {
    if (rutaOptima == null || rutaOptima!.length < 2) return;

    // Sombra de la ruta
    Paint paintSombra = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Ruta con gradiente animado
    Paint paintRuta = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00F260),
          const Color(0xFF0575E6),
          const Color(0xFF00F260),
        ],
        stops: [
          0.0,
          animacionProgreso,
          1.0,
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 1000, 1000))
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Glow effect
    Paint paintGlow = Paint()
      ..color = const Color(0xFF00F260).withOpacity(0.5)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

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
        canvas.drawLine(inicio, finParcial, paintSombra);
        canvas.drawLine(inicio, finParcial, paintGlow);
        canvas.drawLine(inicio, finParcial, paintRuta);
      } else {
        canvas.drawLine(inicio, fin, paintSombra);
        canvas.drawLine(inicio, fin, paintGlow);
        canvas.drawLine(inicio, fin, paintRuta);
        
        // Dibujar flecha direccional en el punto medio
        Offset puntoMedio = Offset(
          (inicio.dx + fin.dx) / 2,
          (inicio.dy + fin.dy) / 2,
        );
        Offset direccion = Offset(fin.dx - inicio.dx, fin.dy - inicio.dy);
        
        Paint paintFlecha = Paint()
          ..color = const Color(0xFF00F260)
          ..style = PaintingStyle.fill;
        
        _dibujarFlecha(canvas, puntoMedio, direccion, paintFlecha);
      }
    }
  }

  void _dibujarNodos(Canvas canvas) {
    for (int i = 0; i < vNodo.length; i++) {
      var ele = vNodo[i];
      Offset centro = Offset(ele.x, ele.y);
      
      // Resaltar nodo seleccionado con pulso
      if (nodoSeleccionado == i) {
        double pulseFactor = 1.0 + (sin(animacionProgreso * pi * 4) * 0.15);
        
        // Glow pulsante
        Paint paintGlowPulse = Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(centro, ele.radio * pulseFactor * 1.3, paintGlowPulse);
        
        // Anillo exterior
        Paint paintAnillo = Paint()
          ..shader = const SweepGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFF6B6B),
              Color(0xFFFFD700),
            ],
          ).createShader(Rect.fromCircle(center: centro, radius: ele.radio + 10))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawCircle(centro, ele.radio + 8, paintAnillo);
      }

      // Sombra del nodo
      Paint paintSombra = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(ele.x + 3, ele.y + 3), ele.radio, paintSombra);
      
      // Glow del nodo
      Paint paintGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            ele.color.withOpacity(0.8),
            ele.color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: centro, radius: ele.radio * 1.5))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centro, ele.radio * 1.3, paintGlow);
      
      // Gradiente radial del nodo
      Paint paintNodo = Paint()
        ..shader = RadialGradient(
          colors: [
            ele.color.withOpacity(1.0),
            ele.color.withOpacity(0.7),
            ele.color.withOpacity(0.9),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: centro, radius: ele.radio))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centro, ele.radio, paintNodo);
      
      // Brillo superior (highlight)
      Paint paintBrillo = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: centro, radius: ele.radio))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(ele.x - ele.radio * 0.2, ele.y - ele.radio * 0.2),
        ele.radio * 0.5,
        paintBrillo,
      );
      
      // Borde del nodo
      Paint paintBorde = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(centro, ele.radio, paintBorde);

      // Dibujar número del nodo
      TextSpan spanNumero = TextSpan(
        text: ele.mensaje,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black87,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
            Shadow(
              color: Colors.black54,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );

      TextPainter textPainterNumero = TextPainter(
        text: spanNumero,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainterNumero.layout();
      textPainterNumero.paint(
        canvas,
        Offset(ele.x - textPainterNumero.width / 2, ele.y - textPainterNumero.height / 2),
      );

      // Dibujar nombre del nodo debajo si existe y no está vacío
      if (ele.nombre.isNotEmpty) {
        TextSpan spanNombre = TextSpan(
          text: ele.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black87,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        );

        TextPainter textPainterNombre = TextPainter(
          text: spanNombre,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          maxLines: 2,
          ellipsis: '...',
        );

        textPainterNombre.layout(maxWidth: ele.radio * 3);
        
        // Dibujar fondo semi-transparente para el nombre
        final nombreRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(ele.x, ele.y + ele.radio + 18),
            width: textPainterNombre.width + 8,
            height: textPainterNombre.height + 4,
          ),
          const Radius.circular(8),
        );
        
        Paint paintFondoNombre = Paint()
          ..color = Colors.black.withOpacity(0.6)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(nombreRect, paintFondoNombre);
        
        textPainterNombre.paint(
          canvas,
          Offset(
            ele.x - textPainterNombre.width / 2,
            ele.y + ele.radio + 10,
          ),
        );
      }
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