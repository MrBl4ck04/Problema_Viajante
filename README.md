# Grafito - Aplicación de Grafos con TSP

Una aplicación moderna de visualización y manipulación de grafos con resolución del **Problema del Viajante (TSP)** mediante **Algoritmos Genéticos**, desarrollada en Flutter con un diseño visual premium.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Capturas de Pantalla](#-capturas-de-pantalla)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Algoritmo Genético](#-algoritmo-genético)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Roadmap](#-roadmap)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

---

## ✨ Características

### 🎯 Funcionalidades Principales

- **✅ Modo 1: Agregar Nodos** - Crea nodos con un click en cualquier parte del canvas
- **✅ Modo 2: Eliminar Nodos** - Elimina nodos y sus enlaces asociados automáticamente
- **✅ Modo 3: Mover Nodos** - Arrastra nodos libremente, los enlaces se ajustan dinámicamente
- **✅ Modo 4: Crear Enlaces** - Conecta nodos con enlaces ponderados y curvas de Bezier
- **✅ Resolver TSP** - Encuentra la ruta óptima usando algoritmos genéticos

### 🎨 Diseño Visual Premium

- **Nodos 3D** con gradientes radiales, sombras y efectos glow
- **8 Colores Vibrantes** que rotan automáticamente
- **Curvas de Bezier Cuadráticas** para enlaces suaves y elegantes
- **Puntos de Control Visibles** para ajustar la curvatura de enlaces
- **Animación de Ruta Óptima** con gradiente dinámico (3 segundos)
- **Efectos de Pulso** en nodos seleccionados
- **Glassmorphism** en diálogos y elementos UI
- **Gradientes Modernos** en toda la interfaz
- **Indicador de Modo Activo** con feedback visual claro

### 🧬 Algoritmo Genético

- **Población**: 100 individuos
- **Generaciones**: 500 iteraciones
- **Selección**: Torneo binario
- **Cruce**: Order Crossover (OX)
- **Mutación**: Intercambio de genes (2%)
- **Elitismo**: Preservación del mejor individuo
- **Fitness**: Minimización de distancia total

---

## 📸 Capturas de Pantalla

### Interfaz Principal
```
┌─────────────────────────────────────────┐
│  [🔗 CREAR ENLACES]  ← Indicador Modo   │
│                                         │
│    ●₁────────●₂                         │
│    │ ╲      ╱ │                         │
│    │   ◆   │  │  ← Punto Control       │
│    │ ╱  [15.5]│  ← Peso                │
│    ●₃────────●₄                         │
│                                         │
│  Fondo Gradiente Oscuro Elegante       │
└─────────────────────────────────────────┘
  [🔥 TSP]  [+] [-] [⇄] [🔗]  ← Controles
```

### Ruta Óptima TSP
```
┌─────────────────────────────────────────┐
│    ●₁════════●₂  ← Ruta Verde Animada  │
│    ║ ╲      ╱ ║                         │
│    ║   ╲  ╱   ║                         │
│    ║   ╱  ╲   ║                         │
│    ●₃════════●₄                         │
│    ╚══════════╝                         │
│                                         │
│  ✓ Ruta Óptima Encontrada              │
│    Distancia: 45.8 unidades             │
└─────────────────────────────────────────┘
```

---

## 🚀 Instalación

### Requisitos Previos

- Flutter SDK 3.9.2 o superior
- Dart 3.0 o superior
- IDE: VS Code, Android Studio o IntelliJ IDEA

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/grafito.git
   cd grafito
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   # Windows
   flutter run -d windows
   
   # macOS
   flutter run -d macos
   
   # Linux
   flutter run -d linux
   
   # Web
   flutter run -d chrome
   ```

---

## 📖 Uso

### Guía Rápida

#### 1. Crear un Grafo

**Paso 1: Agregar Nodos**
- Presiona el botón **[+]** (Modo 1)
- Haz click en el canvas para crear nodos
- Los nodos se numeran automáticamente (1, 2, 3...)
- Cada nodo tiene un color vibrante único

**Paso 2: Crear Enlaces**
- Presiona el botón **[🔗]** (Modo 4)
- Click en el **nodo origen** (se resalta con pulso dorado)
- Click en el **nodo destino**
- Ingresa el **peso/distancia** en el diálogo
- El enlace se dibuja con una curva de Bezier suave

**Paso 3: Ajustar Posiciones**
- Presiona el botón **[⇄]** (Modo 3)
- Arrastra los nodos a nuevas posiciones
- Los enlaces se ajustan automáticamente

#### 2. Resolver el Problema del Viajante

**Paso 1: Preparar el Grafo**
- Asegúrate de tener al menos 2 nodos
- Crea enlaces entre los nodos con pesos

**Paso 2: Ejecutar TSP**
- Presiona el botón **[🔥 TSP]**
- Espera mientras el algoritmo genético calcula (< 1 segundo)
- Observa la animación de 3 segundos mostrando la ruta óptima

**Paso 3: Interpretar Resultados**
- La **ruta verde** muestra el camino óptimo
- El **SnackBar** muestra la distancia total minimizada
- La ruta incluye el retorno al nodo inicial

#### 3. Editar el Grafo

**Eliminar Nodos**
- Presiona el botón **[-]** (Modo 2)
- Click en el nodo a eliminar
- Los enlaces conectados se eliminan automáticamente
- Los índices se reajustan

**Modificar Enlaces**
- Elimina el nodo origen o destino
- Crea un nuevo enlace con el peso deseado

---

## 🧬 Algoritmo Genético

### Funcionamiento

El algoritmo genético simula el proceso de **evolución natural** para encontrar la ruta óptima:

```
1. INICIALIZACIÓN
   └─ Genera 100 rutas aleatorias (población inicial)

2. EVALUACIÓN
   └─ Calcula la distancia total de cada ruta (fitness)

3. SELECCIÓN (500 generaciones)
   ├─ Torneo: Compara 2 rutas, selecciona la mejor
   └─ Repite para crear pool de padres

4. CRUCE (80% probabilidad)
   ├─ Order Crossover (OX)
   ├─ Preserva orden relativo de genes
   └─ Evita duplicados

5. MUTACIÓN (2% probabilidad)
   └─ Intercambia 2 ciudades aleatoriamente

6. ELITISMO
   └─ La mejor ruta siempre sobrevive

7. RESULTADO
   └─ Ruta con menor distancia total
```

### Parámetros Configurables

```dart
TSPGenetico(
  nodos: vNodoNotifier.value,
  enlaces: enlacesNotifier.value,
  tamanioPoblacion: 100,    // Número de soluciones simultáneas
  generaciones: 500,         // Iteraciones de mejora
  tasaMutacion: 0.02,       // 2% de cambios aleatorios
  tasaCruce: 0.8,           // 80% de combinación de padres
);
```

### Complejidad

- **Tiempo**: O(g × p × n²)
  - g = generaciones (500)
  - p = población (100)
  - n = número de nodos
- **Espacio**: O(p × n)
- **Rendimiento**: < 1 segundo para grafos de 10 nodos

---

## 🏗️ Arquitectura

### Estructura del Proyecto

```
grafito/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── home.dart                    # Pantalla principal y lógica
│   ├── modelos/
│   │   ├── modelo_nodo.dart        # Modelo de nodo
│   │   ├── modelo_enlace.dart      # Modelo de enlace
│   │   └── dibujo.dart             # CustomPainter base
│   ├── dibujos/
│   │   └── dibujo_nodo.dart        # Renderizado de grafos
│   └── algoritmos/
│       └── tsp_genetico.dart       # Algoritmo genético
├── pubspec.yaml                     # Dependencias
└── README.md                        # Este archivo
```

### Modelos de Datos

#### ModeloNodo
```dart
class ModeloNodo {
  final double x, y;        // Posición en canvas
  final double radio;       // Tamaño del nodo
  final Color color;        // Color del nodo
  final String mensaje;     // Etiqueta (número)
}
```

#### ModeloEnlace
```dart
class ModeloEnlace {
  final int origen;         // Índice del nodo origen
  final int destino;        // Índice del nodo destino
  final double peso;        // Peso/distancia
  final Offset? puntoControl; // Para curva de Bezier
}
```

### Componentes Principales

#### DibujoNodo (CustomPainter)
Renderiza todos los elementos visuales:
- Enlaces con curvas de Bezier
- Puntos de control
- Nodos con efectos 3D
- Ruta óptima animada
- Etiquetas de peso

#### TSPGenetico
Implementa el algoritmo genético:
- Generación de población inicial
- Evaluación de fitness
- Selección por torneo
- Cruce ordenado (OX)
- Mutación por intercambio
- Elitismo

---

## 🛠️ Tecnologías

### Framework y Lenguaje
- **Flutter 3.9.2** - Framework de UI multiplataforma
- **Dart 3.0+** - Lenguaje de programación

### Librerías Nativas de Flutter
- **CustomPainter** - Dibujo personalizado en canvas
- **AnimationController** - Animaciones fluidas
- **ValueNotifier** - Gestión de estado reactiva
- **GestureDetector** - Detección de toques y gestos

### Técnicas de Diseño
- **Gradientes** (Linear, Radial, Sweep)
- **Blur Effects** (MaskFilter)
- **Shadows** (BoxShadow)
- **Glassmorphism** (Translucidez + Blur)
- **Bezier Curves** (Curvas cuadráticas)

### Algoritmos
- **Algoritmos Genéticos** (Metaheurística)
- **Order Crossover** (Operador de cruce)
- **Tournament Selection** (Selección)

-----