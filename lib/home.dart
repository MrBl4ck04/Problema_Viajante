import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grafito/dibujos/dibujo_nodo.dart';
import 'package:grafito/modelos/modelo_nodo.dart';
import 'package:grafito/modelos/modelo_enlace.dart';
import 'package:grafito/algoritmos/tsp_genetico.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int modo = -1; 
  final ValueNotifier<List<ModeloNodo>> vNodoNotifier = ValueNotifier([]);
  final ValueNotifier<List<ModeloEnlace>> enlacesNotifier = ValueNotifier([]);
  int? nodoSeleccionado; // Para arrastrar o seleccionar
  int? nodoOrigen; // Para crear enlaces
  List<int>? rutaOptima;
  double animacionProgreso = 0.0;
  AnimationController? animationController;
  bool resolviendoTSP = false;

  @override
  void dispose() {
    vNodoNotifier.dispose();
    enlacesNotifier.dispose();
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanDown: (details) => _handleTouch(details.localPosition),
        onPanUpdate: (details) {
          if (modo == 3 && nodoSeleccionado != null) {
            final vNodo = List<ModeloNodo>.from(vNodoNotifier.value);
            vNodo[nodoSeleccionado!] = ModeloNodo(
              x: details.localPosition.dx,
              y: details.localPosition.dy,
              radio: vNodo[nodoSeleccionado!].radio,
              color: vNodo[nodoSeleccionado!].color,
              mensaje: vNodo[nodoSeleccionado!].mensaje,
            );
            vNodoNotifier.value = vNodo;
          } else if (modo != 3) {
            _handleTouch(details.localPosition);
          }
        },
        onPanEnd: (details) {
          nodoSeleccionado = null;
        },
        child: ValueListenableBuilder<List<ModeloNodo>>(
          valueListenable: vNodoNotifier,
          builder: (context, vNodo, child) {
            return ValueListenableBuilder<List<ModeloEnlace>>(
              valueListenable: enlacesNotifier,
              builder: (context, enlaces, child) {
                return CustomPaint(
                  painter: DibujoNodo(
                    vNodo: vNodo,
                    enlaces: enlaces,
                    rutaOptima: rutaOptima,
                    animacionProgreso: animacionProgreso,
                    nodoSeleccionado: nodoSeleccionado,
                  ),
                  child: Container(),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Boton TSP
              ElevatedButton.icon(
                onPressed: resolviendoTSP ? null : _resolverTSP,
                icon: resolviendoTSP
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.route),
                label: const Text('TSP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (modo == 1) ? Colors.green : Colors.red.shade900,
                    radius: 25,
                    child: IconButton(
                      onPressed: () => setState(() {
                        modo = 1;
                        nodoOrigen = null;
                      }),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: (modo == 2) ? Colors.green : Colors.red.shade900,
                    radius: 25,
                    child: IconButton(
                      onPressed: () => setState(() {
                        modo = 2;
                        nodoOrigen = null;
                      }),
                      icon: const Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: (modo == 3) ? Colors.green : Colors.red.shade900,
                    radius: 25,
                    child: IconButton(
                      onPressed: () => setState(() {
                        modo = 3;
                        nodoOrigen = null;
                      }),
                      icon: const Icon(Icons.open_with, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: (modo == 4) ? Colors.green : Colors.red.shade900,
                    radius: 25,
                    child: IconButton(
                      onPressed: () => setState(() {
                        modo = 4;
                        nodoOrigen = null;
                      }),
                      icon: const Icon(Icons.link, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTouch(Offset posicion) {
    final vNodo = List<ModeloNodo>.from(vNodoNotifier.value); 

    if (modo == 1) {
      vNodo.add(
        ModeloNodo(
          x: posicion.dx,
          y: posicion.dy,
          radio: 40,
          color: Colors.teal.shade900,
          mensaje: 'Nodo ${vNodo.length + 1}',
        ),
      );
      vNodoNotifier.value = vNodo;
    } else if (modo == 2) {
      int index = buscarNodo(posicion.dx, posicion.dy, vNodo);
      if (index != -1) {
        vNodo.removeAt(index);
        // Eliminar enlaces relacionados
        final enlaces = List<ModeloEnlace>.from(enlacesNotifier.value);
        enlaces.removeWhere((e) => e.origen == index || e.destino == index);
        // Reindexar enlaces
        for (int i = 0; i < enlaces.length; i++) {
          if (enlaces[i].origen > index) {
            enlaces[i] = ModeloEnlace(
              origen: enlaces[i].origen - 1,
              destino: enlaces[i].destino,
              peso: enlaces[i].peso,
              puntoControl: enlaces[i].puntoControl,
            );
          }
          if (enlaces[i].destino > index) {
            enlaces[i] = ModeloEnlace(
              origen: enlaces[i].origen,
              destino: enlaces[i].destino - 1,
              peso: enlaces[i].peso,
              puntoControl: enlaces[i].puntoControl,
            );
          }
        }
        enlacesNotifier.value = enlaces;
      }
      vNodoNotifier.value = vNodo;
    } else if (modo == 3) {
      nodoSeleccionado = buscarNodo(posicion.dx, posicion.dy, vNodo);
    } else if (modo == 4) {
      int index = buscarNodo(posicion.dx, posicion.dy, vNodo);
      if (index != -1) {
        if (nodoOrigen == null) {
          // Primer nodo seleccionado
          setState(() {
            nodoOrigen = index;
            nodoSeleccionado = index;
          });
        } else if (nodoOrigen != index) {
          // Segundo nodo seleccionado, crear enlace
          _mostrarDialogoPeso(nodoOrigen!, index);
          setState(() {
            nodoOrigen = null;
            nodoSeleccionado = null;
          });
        }
      }
    }
  }

  void _mostrarDialogoPeso(int origen, int destino) {
    final TextEditingController pesoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Enlace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Origen: Nodo ${origen + 1}'),
            Text('Destino: Nodo ${destino + 1}'),
            const SizedBox(height: 10),
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso/Distancia',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              double peso = double.tryParse(pesoController.text) ?? 1.0;
              _crearEnlace(origen, destino, peso);
              Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _crearEnlace(int origen, int destino, double peso) {
    final enlaces = List<ModeloEnlace>.from(enlacesNotifier.value);
    
    // Calcular punto de control para la curva (punto medio elevado)
    final vNodo = vNodoNotifier.value;
    Offset puntoOrigen = Offset(vNodo[origen].x, vNodo[origen].y);
    Offset puntoDestino = Offset(vNodo[destino].x, vNodo[destino].y);
    
    Offset puntoMedio = Offset(
      (puntoOrigen.dx + puntoDestino.dx) / 2,
      (puntoOrigen.dy + puntoDestino.dy) / 2,
    );
    
    // Perpendicular para crear curvatura
    double dx = puntoDestino.dx - puntoOrigen.dx;
    double dy = puntoDestino.dy - puntoOrigen.dy;
    double distancia = sqrt(dx * dx + dy * dy);
    double desplazamiento = distancia * 0.2; // 20% de curvatura
    
    Offset puntoControl = Offset(
      puntoMedio.dx - dy / distancia * desplazamiento,
      puntoMedio.dy + dx / distancia * desplazamiento,
    );
    
    enlaces.add(ModeloEnlace(
      origen: origen,
      destino: destino,
      peso: peso,
      puntoControl: puntoControl,
    ));
    
    enlacesNotifier.value = enlaces;
  }

  void _resolverTSP() async {
    if (vNodoNotifier.value.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se necesitan al menos 2 nodos')),
      );
      return;
    }

    setState(() {
      resolviendoTSP = true;
      rutaOptima = null;
      animacionProgreso = 0.0;
    });

    // Ejecutar algoritmo genetico
    final tsp = TSPGenetico(
      nodos: vNodoNotifier.value,
      enlaces: enlacesNotifier.value,
      tamanioPoblacion: 100,
      generaciones: 500,
      tasaMutacion: 0.02,
      tasaCruce: 0.8,
    );

    final resultado = await Future.delayed(
      const Duration(milliseconds: 100),
      () => tsp.resolver(),
    );

    setState(() {
      resolviendoTSP = false;
      rutaOptima = resultado.mejorRuta;
    });

    // Mostrar resultado
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Distancia total: ${resultado.distanciaTotal.toStringAsFixed(2)}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Iniciar animacion
    _iniciarAnimacion();
  }

  void _iniciarAnimacion() {
    animationController?.dispose();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    animationController!.addListener(() {
      setState(() {
        animacionProgreso = animationController!.value;
      });
    });

    animationController!.forward();
  }

  int buscarNodo(double x, double y, List<ModeloNodo> vNodo) {
    for (int i = 0; i < vNodo.length; i++) {
      double dx = x - vNodo[i].x;
      double dy = y - vNodo[i].y;
      double distancia = sqrt(dx * dx + dy * dy);
      if (distancia <= vNodo[i].radio) return i;
    }
    return -1;
  }
}