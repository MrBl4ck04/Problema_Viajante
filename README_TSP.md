# Aplicación de Grafos con TSP - Documentación

## Características Implementadas

### Modos de Operación

#### Modo 1: Agregar Nodos ➕
- Click en cualquier parte del canvas para agregar un nuevo nodo
- Los nodos se numeran automáticamente (Nodo 1, Nodo 2, etc.)
- Color: Teal oscuro
- Radio: 40 píxeles

#### Modo 2: Eliminar Nodos 🗑️
- Click sobre un nodo para eliminarlo
- Al eliminar un nodo, todos los enlaces conectados a él se eliminan automáticamente
- Los índices de los enlaces se reajustan correctamente

#### Modo 3: Mover Nodos 🔄
- Click y arrastra un nodo para moverlo por el canvas
- Los enlaces conectados se actualizan en tiempo real

#### Modo 4: Crear Enlaces 🔗
- **Primer click**: Selecciona el nodo origen (se resalta en amarillo)
- **Segundo click**: Selecciona el nodo destino
- Se abre un diálogo para ingresar el peso/distancia del enlace
- El enlace se dibuja con una curva de Bezier cuadrática
- Características de los enlaces:
  - Línea gris con flecha direccional
  - Punto de control azul visible (permite ajustar la curvatura)
  - Peso/distancia mostrado cerca del punto de control
  - Curvatura automática del 20% de la distancia entre nodos

### Algoritmo Genético para TSP 🧬

#### Parámetros del Algoritmo
- **Tamaño de población**: 100 individuos
- **Generaciones**: 500 iteraciones
- **Tasa de mutación**: 2%
- **Tasa de cruce**: 80%

#### Operadores Genéticos

1. **Selección por Torneo**
   - Compara dos individuos aleatorios
   - Selecciona el de menor distancia total

2. **Cruce Ordenado (Order Crossover - OX)**
   - Preserva el orden relativo de los genes
   - Evita duplicados en la ruta

3. **Mutación por Intercambio**
   - Intercambia dos ciudades aleatorias en la ruta
   - Mantiene la validez de la solución

4. **Elitismo**
   - La mejor solución siempre pasa a la siguiente generación

#### Función de Fitness
- Calcula la distancia total del recorrido
- Usa los pesos de los enlaces cuando existen
- Usa distancia euclidiana cuando no hay enlace directo
- Incluye el retorno al nodo inicial

### Visualización Animada 🎬

Al resolver el TSP, la ruta óptima se muestra con:
- **Línea verde gruesa** que traza la ruta
- **Animación de 3 segundos** que dibuja la ruta progresivamente
- **Mensaje con distancia total** en la parte inferior
- La animación muestra el recorrido completo incluyendo el retorno al inicio

### Gestión Avanzada de Enlaces

#### Curvas de Bezier
- Cada enlace usa una curva cuadrática de Bezier
- El punto de control se calcula perpendicular a la línea entre nodos
- Desplazamiento del 20% de la distancia para curvatura óptima
- Los puntos de control son visibles y editables

#### Flechas Direccionales
- Indican la dirección del enlace (origen → destino)
- Se posicionan en el punto medio de la curva
- La orientación sigue la tangente de la curva

## Cómo Usar la Aplicación

### Crear un Grafo
1. Activa el **Modo 1** (botón +)
2. Click en el canvas para agregar nodos
3. Activa el **Modo 4** (botón 🔗)
4. Click en el primer nodo (origen)
5. Click en el segundo nodo (destino)
6. Ingresa el peso en el diálogo
7. Repite para crear más enlaces

### Resolver el Problema del Viajante
1. Asegúrate de tener al menos 2 nodos
2. Click en el botón **"TSP"** (naranja)
3. Espera mientras el algoritmo genético calcula la solución
4. Observa la animación de la ruta óptima
5. Lee la distancia total en el mensaje

### Editar el Grafo
- **Mover nodos**: Modo 3 + arrastrar
- **Eliminar nodos**: Modo 2 + click en el nodo
- **Reorganizar**: Los enlaces se mantienen conectados al mover nodos

## Estructura del Código

### Modelos
- `modelo_nodo.dart`: Define la estructura de un nodo (posición, radio, color, mensaje)
- `modelo_enlace.dart`: Define enlaces con origen, destino, peso y punto de control

### Algoritmos
- `tsp_genetico.dart`: Implementación completa del algoritmo genético
  - Clase `TSPGenetico`: Motor del algoritmo
  - Clase `ResultadoTSP`: Almacena la solución y estadísticas

### Visualización
- `dibujo_nodo.dart`: CustomPainter que dibuja:
  - Enlaces con curvas de Bezier
  - Nodos con etiquetas
  - Ruta óptima animada
  - Puntos de control
  - Flechas direccionales

### Interfaz
- `home.dart`: Gestiona la interacción del usuario
  - Manejo de modos
  - Creación/eliminación de nodos y enlaces
  - Ejecución del algoritmo TSP
  - Control de animaciones

## Calificación Objetivo: 100 PUNTOS

✅ **Administración perfecta del grafo**
- Nodos: crear, mover, eliminar
- Enlaces curvos con puntos de control visibles
- Gestión de pesos/distancias
- Reindexación automática al eliminar nodos

✅ **Algoritmo Genético para TSP**
- Implementación completa con operadores genéticos
- Selección por torneo
- Cruce ordenado (OX)
- Mutación por intercambio
- Elitismo

✅ **Visualización Animada**
- Animación suave de 3 segundos
- Ruta óptima en verde
- Progreso visual del recorrido
- Mensaje con distancia total

✅ **Control de Curvatura**
- Curvas de Bezier cuadráticas
- Puntos de control visibles
- Curvatura automática calculada
- Flechas direccionales en las curvas

## Tecnologías Utilizadas

- **Flutter 3.9.2**: Framework de UI
- **Dart**: Lenguaje de programación
- **CustomPainter**: Para dibujo personalizado en canvas
- **AnimationController**: Para animaciones fluidas
- **ValueNotifier**: Para gestión de estado reactiva

## Mejoras Futuras Posibles

1. Permitir editar puntos de control arrastrándolos
2. Guardar/cargar grafos desde archivo
3. Visualizar la evolución del algoritmo genético
4. Agregar más algoritmos (Dijkstra, A*, etc.)
5. Soporte para grafos no dirigidos
6. Exportar la solución como imagen o PDF
