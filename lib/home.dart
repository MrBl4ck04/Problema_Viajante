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

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int modo = -1; 
  final ValueNotifier<List<ModeloNodo>> vNodoNotifier = ValueNotifier([]);
  final ValueNotifier<List<ModeloEnlace>> enlacesNotifier = ValueNotifier([]);
  int? nodoSeleccionado; // Para arrastrar o seleccionar
  int? nodoOrigen; // Para crear enlaces
  int? enlaceSeleccionado; // Para editar peso de enlace
  List<int>? rutaOptima;
  double animacionProgreso = 0.0;
  AnimationController? animationController;
  bool resolviendoTSP = false;
  int nodoInicialTSP = 0; // Nodo desde donde comenzará el TSP

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
              nombre: vNodo[nodoSeleccionado!].nombre,
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
              Row(
                children: [
                  // Botón TSP
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFf093fb).withOpacity(0.5),
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
                          : const Icon(Icons.route, size: 20),
                      label: const Text(
                        'TSP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón Limpiar
                  Tooltip(
                    message: 'Limpiar solución',
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEB3349), Color(0xFFF45C43)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        onPressed: rutaOptima != null ? _limpiarSolucion : null,
                        icon: const Icon(Icons.clear, color: Colors.white, size: 20),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón Conectar Todos
                  Tooltip(
                    message: 'Conectar todos los nodos',
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        onPressed: _conectarTodosLosNodos,
                        icon: const Icon(Icons.hub, color: Colors.white, size: 20),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón Limpiar Enlaces
                  Tooltip(
                    message: 'Limpiar todos los enlaces',
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        onPressed: enlacesNotifier.value.isNotEmpty ? _limpiarEnlaces : null,
                        icon: const Icon(Icons.link_off, color: Colors.white, size: 20),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildModeButton(
                      icon: Icons.add_circle_outline,
                      modeNumber: 1,
                      tooltip: 'Agregar Nodos',
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      icon: Icons.delete_outline,
                      modeNumber: 2,
                      tooltip: 'Eliminar Nodos',
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      icon: Icons.open_with,
                      modeNumber: 3,
                      tooltip: 'Mover Nodos',
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      icon: Icons.link,
                      modeNumber: 4,
                      tooltip: 'Crear Enlaces',
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      icon: Icons.edit_road,
                      modeNumber: 5,
                      tooltip: 'Editar Peso de Enlace',
                    ),
                  ],
                ),
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
      // Mostrar diálogo para nombrar el nodo
      _mostrarDialogoNombreNodo(posicion, vNodo.length);
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
    } else if (modo == 5) {
      // Editar peso de enlace
      int? enlaceIndex = _buscarEnlace(posicion);
      if (enlaceIndex != null) {
        _mostrarDialogoEditarPeso(enlaceIndex);
      }
    }
  }

  void _mostrarDialogoNombreNodo(Offset posicion, int indiceNodo) {
    final TextEditingController nombreController = TextEditingController();
    
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
                Color(0xFF134E5E),
                Color(0xFF71B280),
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
                Icons.location_on,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nombrar Nodo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nombreController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Nombre del nodo',
                  hintText: 'Ej: Ciudad A, Punto 1, etc.',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.edit,
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
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _crearNodoConNombre(posicion, indiceNodo, '');
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.shuffle, size: 20),
                        label: const Text(
                          'Aleatorio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          String nombre = nombreController.text.trim();
                          _crearNodoConNombre(posicion, indiceNodo, nombre);
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

  void _crearNodoConNombre(Offset posicion, int indiceNodo, String nombre) {
    final vNodo = List<ModeloNodo>.from(vNodoNotifier.value);
    
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
        color: colores[indiceNodo % colores.length],
        mensaje: '${indiceNodo + 1}',
        nombre: nombre.isEmpty ? 'Nodo ${indiceNodo + 1}' : nombre,
      ),
    );
    vNodoNotifier.value = vNodo;
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
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Generar peso aleatorio entre 1 y 100
                          double pesoAleatorio = Random().nextInt(100) + 1.0;
                          _crearEnlace(origen, destino, pesoAleatorio);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.shuffle, size: 20),
                        label: const Text(
                          'Aleatorio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
        const SnackBar(
          content: Text('Se necesitan al menos 2 nodos'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (enlacesNotifier.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No hay enlaces. Usa "Conectar Todos" o crea enlaces manualmente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Mostrar diálogo para seleccionar nodo inicial
    await _mostrarDialogoSeleccionNodoInicial();
  }

  Future<void> _mostrarDialogoSeleccionNodoInicial() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8E2DE2),
                  Color(0xFF4A00E0),
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
                  Icons.flag,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seleccionar Nodo Inicial',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige desde dónde comenzará el recorrido',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        vNodoNotifier.value.length,
                        (index) {
                          final nodo = vNodoNotifier.value[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                setStateDialog(() {
                                  nodoInicialTSP = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: nodoInicialTSP == index
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: nodoInicialTSP == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: nodo.color,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: nodo.color.withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          nodo.mensaje,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        nodo.nombre,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (nodoInicialTSP == index)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
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
                    Navigator.pop(context);
                    _ejecutarTSP();
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
                    'Resolver TSP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _resetearEstadoTSP() {
    // Detener y limpiar animación
    if (animationController != null) {
      animationController!.stop();
      animationController!.dispose();
      animationController = null;
    }
    
    // Resetear todas las variables de estado relacionadas con TSP
    setState(() {
      rutaOptima = null;
      animacionProgreso = 0.0;
      resolviendoTSP = false;
    });
  }

  void _limpiarSolucion() {
    _resetearEstadoTSP();
    
    // Resetear nodo inicial
    setState(() {
      nodoInicialTSP = 0;
    });
    
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Solución limpiada',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _conectarTodosLosNodos() {
    if (vNodoNotifier.value.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesitan al menos 2 nodos para conectar'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final vNodo = vNodoNotifier.value;
    final enlacesExistentes = List<ModeloEnlace>.from(enlacesNotifier.value);
    int enlacesAgregados = 0;

    // Conectar cada nodo con todos los demás (grafo completo)
    for (int i = 0; i < vNodo.length; i++) {
      for (int j = i + 1; j < vNodo.length; j++) {
        // Verificar si ya existe un enlace de i a j
        bool existeIJ = enlacesExistentes.any((enlace) =>
          enlace.origen == i && enlace.destino == j
        );
        
        // Verificar si ya existe un enlace de j a i
        bool existeJI = enlacesExistentes.any((enlace) =>
          enlace.origen == j && enlace.destino == i
        );

        // Calcular distancia euclidiana
        double dx = vNodo[i].x - vNodo[j].x;
        double dy = vNodo[i].y - vNodo[j].y;
        double distancia = sqrt(dx * dx + dy * dy);
        
        // Redondear a 2 decimales
        double peso = double.parse(distancia.toStringAsFixed(2));

        // Agregar enlace i -> j si no existe
        if (!existeIJ) {
          enlacesExistentes.add(
            ModeloEnlace(
              origen: i,
              destino: j,
              peso: peso,
            ),
          );
          enlacesAgregados++;
        }
        
        // Agregar enlace j -> i si no existe
        if (!existeJI) {
          enlacesExistentes.add(
            ModeloEnlace(
              origen: j,
              destino: i,
              peso: peso,
            ),
          );
          enlacesAgregados++;
        }
      }
    }

    // Forzar actualización creando una nueva lista
    enlacesNotifier.value = List<ModeloEnlace>.from(enlacesExistentes);

    if (enlacesAgregados > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Se agregaron $enlacesAgregados enlaces automáticamente',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF1a1a2e),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los nodos ya están conectados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _ejecutarTSP() async {
    // Limpiar estado anterior completamente
    _resetearEstadoTSP();
    
    // Marcar que estamos resolviendo
    setState(() {
      resolviendoTSP = true;
    });
    
    // Esperar un frame para que el UI se actualice
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      // Ejecutar algoritmo genetico
      final tsp = TSPGenetico(
        nodos: vNodoNotifier.value,
        enlaces: enlacesNotifier.value,
        tamanioPoblacion: 100,
        generaciones: 500,
        tasaMutacion: 0.02,
        tasaCruce: 0.8,
        nodoInicial: nodoInicialTSP,
      );

      final resultado = await Future.delayed(
        const Duration(milliseconds: 100),
        () => tsp.resolver(),
      );

      if (mounted) {
        setState(() {
          resolviendoTSP = false;
          rutaOptima = resultado.mejorRuta;
        });

        // Iniciar animacion
        _iniciarAnimacion();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          resolviendoTSP = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al resolver TSP: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _iniciarAnimacion() {
    // Limpiar controller anterior si existe
    if (animationController != null) {
      animationController!.stop();
      animationController!.dispose();
      animationController = null;
    }
    
    // Crear nuevo controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    animationController!.addListener(() {
      if (mounted) {
        setState(() {
          animacionProgreso = animationController!.value;
        });
      }
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

  void _limpiarEnlaces() {
    // Limpiar enlaces creando una nueva lista vacía
    enlacesNotifier.value = List<ModeloEnlace>.from([]);
    
    // También limpiar la solución si existe
    if (rutaOptima != null) {
      _resetearEstadoTSP();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Todos los enlaces eliminados',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int? _buscarEnlace(Offset posicion) {
    final enlaces = enlacesNotifier.value;
    final vNodo = vNodoNotifier.value;
    
    for (int i = 0; i < enlaces.length; i++) {
      final enlace = enlaces[i];
      if (enlace.origen >= vNodo.length || enlace.destino >= vNodo.length) continue;
      
      Offset inicio = Offset(vNodo[enlace.origen].x, vNodo[enlace.origen].y);
      Offset fin = Offset(vNodo[enlace.destino].x, vNodo[enlace.destino].y);
      
      // Calcular distancia del punto a la línea
      double distancia;
      if (enlace.puntoControl != null) {
        // Para curvas, verificar distancia al punto de control
        double distControl = (posicion - enlace.puntoControl!).distance;
        if (distControl <= 20) return i;
        
        // También verificar distancia a la curva (simplificado)
        distancia = _distanciaPuntoALinea(posicion, inicio, fin);
      } else {
        distancia = _distanciaPuntoALinea(posicion, inicio, fin);
      }
      
      if (distancia <= 15) return i;
    }
    return null;
  }

  double _distanciaPuntoALinea(Offset punto, Offset lineaInicio, Offset lineaFin) {
    double dx = lineaFin.dx - lineaInicio.dx;
    double dy = lineaFin.dy - lineaInicio.dy;
    double longitud = sqrt(dx * dx + dy * dy);
    
    if (longitud == 0) return (punto - lineaInicio).distance;
    
    double t = ((punto.dx - lineaInicio.dx) * dx + (punto.dy - lineaInicio.dy) * dy) / (longitud * longitud);
    t = t.clamp(0.0, 1.0);
    
    Offset proyeccion = Offset(
      lineaInicio.dx + t * dx,
      lineaInicio.dy + t * dy,
    );
    
    return (punto - proyeccion).distance;
  }

  void _mostrarDialogoEditarPeso(int indiceEnlace) {
    final enlace = enlacesNotifier.value[indiceEnlace];
    final TextEditingController pesoController = TextEditingController(text: enlace.peso.toString());
    
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
                Color(0xFFFF6B6B),
                Color(0xFFFF8E53),
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
                Icons.edit_road,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Editar Peso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nodo ${enlace.origen + 1} → Nodo ${enlace.destino + 1}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
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
                  labelText: 'Nuevo peso',
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
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          double nuevoPeso = double.tryParse(pesoController.text) ?? enlace.peso;
                          
                          // Crear completamente nueva lista de enlaces
                          final enlacesActualizados = <ModeloEnlace>[];
                          for (int i = 0; i < enlacesNotifier.value.length; i++) {
                            if (i == indiceEnlace) {
                              enlacesActualizados.add(ModeloEnlace(
                                origen: enlace.origen,
                                destino: enlace.destino,
                                peso: nuevoPeso,
                                puntoControl: enlace.puntoControl,
                              ));
                            } else {
                              enlacesActualizados.add(enlacesNotifier.value[i]);
                            }
                          }
                          
                          // Asignar la nueva lista
                          enlacesNotifier.value = enlacesActualizados;
                          
                          // Limpiar solución completamente para que se recalcule
                          if (rutaOptima != null) {
                            _resetearEstadoTSP();
                          }
                          
                          Navigator.pop(context);
                          
                          // Mostrar confirmación
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Peso actualizado a ${nuevoPeso.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1a1a2e),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            ),
                          );
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
                          'Guardar',
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
      case 5:
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
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
      case 5:
        return Icons.edit_road;
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
      case 5:
        return 'EDITAR PESO DE ENLACE';
      default:
        return '';
    }
  }
}