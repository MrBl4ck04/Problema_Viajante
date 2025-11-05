import 'package:flutter/material.dart';

class ModeloEnlace {
  final int origen;
  final int destino;
  final double peso;
  final Offset? puntoControl; // Para curvas de Bezier
  
  ModeloEnlace({
    required this.origen,
    required this.destino,
    required this.peso,
    this.puntoControl,
  });

  ModeloEnlace copyWith({
    int? origen,
    int? destino,
    double? peso,
    Offset? puntoControl,
  }) {
    return ModeloEnlace(
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      peso: peso ?? this.peso,
      puntoControl: puntoControl ?? this.puntoControl,
    );
  }
}
