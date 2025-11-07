import 'dart:math';
import 'package:grafito/modelos/modelo_nodo.dart';
import 'package:grafito/modelos/modelo_enlace.dart';

class TSPGenetico {
  final List<ModeloNodo> nodos;
  final List<ModeloEnlace> enlaces;
  final int tamanioPoblacion;
  final int generaciones;
  final double tasaMutacion;
  final double tasaCruce;
  final int nodoInicial;
  final Random random = Random();

  TSPGenetico({
    required this.nodos,
    required this.enlaces,
    this.tamanioPoblacion = 100,
    this.generaciones = 500,
    this.tasaMutacion = 0.02,
    this.tasaCruce = 0.8,
    this.nodoInicial = 0,
  });

  // Calcula la distancia entre dos nodos usando los enlaces
  double calcularDistancia(int nodo1, int nodo2) {
    // Buscar enlace directo
    for (var enlace in enlaces) {
      if ((enlace.origen == nodo1 && enlace.destino == nodo2) ||
          (enlace.origen == nodo2 && enlace.destino == nodo1)) {
        return enlace.peso;
      }
    }
    
    // Si no hay enlace, calcular distancia euclidiana
    double dx = nodos[nodo1].x - nodos[nodo2].x;
    double dy = nodos[nodo1].y - nodos[nodo2].y;
    return sqrt(dx * dx + dy * dy);
  }

  // Calcula el fitness (distancia total) de una ruta
  double calcularFitness(List<int> ruta) {
    double distanciaTotal = 0;
    for (int i = 0; i < ruta.length - 1; i++) {
      distanciaTotal += calcularDistancia(ruta[i], ruta[i + 1]);
    }
    // Agregar distancia de regreso al inicio
    distanciaTotal += calcularDistancia(ruta.last, ruta.first);
    return distanciaTotal;
  }

  // Genera una población inicial aleatoria comenzando desde el nodo inicial
  List<List<int>> generarPoblacionInicial() {
    List<List<int>> poblacion = [];
    List<int> rutaBase = List.generate(nodos.length, (index) => index);
    rutaBase.remove(nodoInicial);

    for (int i = 0; i < tamanioPoblacion; i++) {
      List<int> ruta = List.from(rutaBase);
      ruta.shuffle(random);
      // Insertar el nodo inicial al principio
      ruta.insert(0, nodoInicial);
      poblacion.add(ruta);
    }

    return poblacion;
  }

  // Selección por torneo
  List<int> seleccionTorneo(List<List<int>> poblacion, List<double> fitness) {
    int idx1 = random.nextInt(poblacion.length);
    int idx2 = random.nextInt(poblacion.length);
    
    return fitness[idx1] < fitness[idx2] ? poblacion[idx1] : poblacion[idx2];
  }

  // Cruce ordenado (Order Crossover - OX) manteniendo el nodo inicial
  List<int> cruceOrdenado(List<int> padre1, List<int> padre2) {
    int size = padre1.length;
    if (size <= 2) return List.from(padre1);
    
    // Trabajar solo con los nodos después del inicial
    int inicio = 1 + random.nextInt(size - 1);
    int fin = inicio + random.nextInt(size - inicio);

    List<int?> hijo = List.filled(size, null);
    
    // El primer nodo siempre es el nodo inicial
    hijo[0] = nodoInicial;
    
    // Copiar segmento del padre1
    for (int i = inicio; i <= fin; i++) {
      hijo[i] = padre1[i];
    }

    // Llenar el resto con genes del padre2 en orden
    int posHijo = (fin + 1) % size;
    if (posHijo == 0) posHijo = 1;
    int posPadre2 = 1;

    while (hijo.contains(null)) {
      if (!hijo.contains(padre2[posPadre2])) {
        hijo[posHijo] = padre2[posPadre2];
        posHijo = (posHijo + 1) % size;
        if (posHijo == 0) posHijo = 1;
      }
      posPadre2 = (posPadre2 + 1) % size;
      if (posPadre2 == 0) posPadre2 = 1;
    }

    return hijo.cast<int>();
  }

  // Mutación por intercambio (evitando mutar el nodo inicial)
  List<int> mutacion(List<int> ruta) {
    List<int> rutaMutada = List.from(ruta);
    
    if (random.nextDouble() < tasaMutacion && rutaMutada.length > 2) {
      // Evitar intercambiar el primer nodo (nodo inicial)
      int idx1 = 1 + random.nextInt(rutaMutada.length - 1);
      int idx2 = 1 + random.nextInt(rutaMutada.length - 1);
      
      int temp = rutaMutada[idx1];
      rutaMutada[idx1] = rutaMutada[idx2];
      rutaMutada[idx2] = temp;
    }

    return rutaMutada;
  }

  // Algoritmo genético principal
  ResultadoTSP resolver() {
    if (nodos.length < 2) {
      return ResultadoTSP(
        mejorRuta: [],
        distanciaTotal: 0,
        historialFitness: [],
      );
    }

    List<List<int>> poblacion = generarPoblacionInicial();
    List<double> historialMejorFitness = [];
    List<int> mejorRutaGlobal = [];
    double mejorFitnessGlobal = double.infinity;

    for (int gen = 0; gen < generaciones; gen++) {
      // Calcular fitness de toda la población
      List<double> fitness = poblacion.map((ruta) => calcularFitness(ruta)).toList();

      // Encontrar mejor ruta de esta generación
      double mejorFitnessGen = fitness.reduce(min);
      int idxMejor = fitness.indexOf(mejorFitnessGen);

      if (mejorFitnessGen < mejorFitnessGlobal) {
        mejorFitnessGlobal = mejorFitnessGen;
        mejorRutaGlobal = List.from(poblacion[idxMejor]);
      }

      historialMejorFitness.add(mejorFitnessGlobal);

      // Crear nueva generación
      List<List<int>> nuevaPoblacion = [];

      // Elitismo: mantener la mejor ruta
      nuevaPoblacion.add(List.from(mejorRutaGlobal));

      while (nuevaPoblacion.length < tamanioPoblacion) {
        List<int> padre1 = seleccionTorneo(poblacion, fitness);
        List<int> padre2 = seleccionTorneo(poblacion, fitness);

        List<int> hijo;
        if (random.nextDouble() < tasaCruce) {
          hijo = cruceOrdenado(padre1, padre2);
        } else {
          hijo = List.from(padre1);
        }

        hijo = mutacion(hijo);
        nuevaPoblacion.add(hijo);
      }

      poblacion = nuevaPoblacion;
    }

    return ResultadoTSP(
      mejorRuta: mejorRutaGlobal,
      distanciaTotal: mejorFitnessGlobal,
      historialFitness: historialMejorFitness,
    );
  }
}

class ResultadoTSP {
  final List<int> mejorRuta;
  final double distanciaTotal;
  final List<double> historialFitness;

  ResultadoTSP({
    required this.mejorRuta,
    required this.distanciaTotal,
    required this.historialFitness,
  });
}
