import 'package:flutter/material.dart';


class ModeloNodo {
  final double x,y,radio;
  final Color color;
  final String mensaje;
  final String nombre;

  ModeloNodo({
    required this.x, 
    required this.y, 
    required this.radio, 
    required this.color, 
    required this.mensaje,
    this.nombre = '',
  });
}