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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
            child: GestureDetector(
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
        ),
        // Indicador de modo activo
        if (modo > 0)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getModoGradient(),
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _getModoGradient()[0].withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getModoIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getModoTexto(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Boton TSP con efecto moderno
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf12711), Color(0xFFf5af19)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf12711).withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: resolviendoTSP ? null : _resolverTSP,
                  icon: resolviendoTSP
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.route, size: 24),
                  label: const Text(
                    'TSP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildModeButton(
                    icon: Icons.add_circle_outline,
                    modeNumber: 1,
                    tooltip: 'Agregar Nodos',
                  ),
                  const SizedBox(width: 12),
                  _buildModeButton(
                    icon: Icons.delete_outline,
                    modeNumber: 2,
                    tooltip: 'Eliminar Nodos',
                  ),
                  const SizedBox(width: 12),
                  _buildModeButton(
                    icon: Icons.open_with,
                    modeNumber: 3,
                    tooltip: 'Mover Nodos',
                  ),
                  const SizedBox(width: 12),
                  _buildModeButton(
                    icon: Icons.link,
                    modeNumber: 4,
                    tooltip: 'Crear Enlaces',
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
      // Colores vibrantes y variados para los nodos
      final colores = [
        const Color(0xFF6A11CB), // Púrpura
        const Color(0xFFFC466B), // Rosa
        const Color(0xFF3F5EFB), // Azul
        const Color(0xFF11998E), // Verde azulado
        const Color(0xFFFF6B6B), // Rojo coral
        const Color(0xFFFFD93D), // Amarillo dorado
        const Color(0xFF6BCB77), // Verde
        const Color(0xFFFF8C42), // Naranja
      ];
      
      vNodo.add(
        ModeloNodo(
          x: posicion.dx,
          y: posicion.dy,
          radio: 40,
          color: colores[vNodo.length % colores.length],
          mensaje: '${vNodo.length + 1}',
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
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF3498DB),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.link,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Crear Enlace',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Origen:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Nodo ${origen + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Destino:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Nodo ${destino + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Peso/Distancia',
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.straighten,
                    color: Colors.white70,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF56ab2f).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          double peso = double.tryParse(pesoController.text) ?? 1.0;
                          _crearEnlace(origen, destino, peso);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Crear',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

    // Mostrar resultado con diseño moderno
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F260), Color(0xFF0575E6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ruta Óptima Encontrada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Distancia: ${resultado.distanciaTotal.toStringAsFixed(2)} unidades',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF1a1a2e),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          elevation: 8,
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

  Widget _buildModeButton({
    required IconData icon,
    required int modeNumber,
    required String tooltip,
  }) {
    final isActive = modo == modeNumber;
    
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade700,
                  ],
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF56ab2f).withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() {
              modo = modeNumber;
              nodoOrigen = null;
            }),
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getModoGradient() {
    switch (modo) {
      case 1:
        return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
      case 2:
        return [const Color(0xFFEB3349), const Color(0xFFF45C43)];
      case 3:
        return [const Color(0xFF4776E6), const Color(0xFF8E54E9)];
      case 4:
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      default:
        return [Colors.grey, Colors.grey];
    }
  }

  IconData _getModoIcon() {
    switch (modo) {
      case 1:
        return Icons.add_circle_outline;
      case 2:
        return Icons.delete_outline;
      case 3:
        return Icons.open_with;
      case 4:
        return Icons.link;
      default:
        return Icons.help_outline;
    }
  }

  String _getModoTexto() {
    switch (modo) {
      case 1:
        return 'AGREGAR NODOS';
      case 2:
        return 'ELIMINAR NODOS';
      case 3:
        return 'MOVER NODOS';
      case 4:
        return nodoOrigen == null ? 'SELECCIONAR ORIGEN' : 'SELECCIONAR DESTINO';
      default:
        return '';
    }
  }
}