# Guía Rápida - Aplicación de Grafos con TSP

## 🚀 Inicio Rápido

### Paso 1: Crear Nodos
1. Presiona el botón **verde con +** (Modo 1)
2. Haz click en cualquier parte de la pantalla
3. Aparecerá un nodo numerado (Nodo 1, Nodo 2, etc.)
4. Crea al menos 3-5 nodos para una buena demostración

### Paso 2: Crear Enlaces
1. Presiona el botón **verde con 🔗** (Modo 4)
2. Haz click en el **primer nodo** (origen) - se resaltará en amarillo
3. Haz click en el **segundo nodo** (destino)
4. Aparecerá un diálogo:
   - Muestra origen y destino
   - Ingresa el peso/distancia (ejemplo: 10.5)
   - Presiona "Crear"
5. Verás el enlace con:
   - Una línea curva gris
   - Una flecha indicando dirección
   - El peso mostrado en la curva
   - Un punto azul (punto de control de la curva)

### Paso 3: Resolver el Problema del Viajante
1. Presiona el botón **naranja "TSP"** en la esquina inferior izquierda
2. El algoritmo genético calculará la ruta óptima (toma unos segundos)
3. Verás:
   - Una animación de 3 segundos dibujando la ruta en verde
   - Un mensaje mostrando la distancia total
   - La ruta completa que visita todos los nodos y regresa al inicio

## 🎮 Controles

### Botones Inferiores (de izquierda a derecha)

| Botón | Modo | Función |
|-------|------|---------|
| 🟠 TSP | - | Resolver problema del viajante |
| 🟢 + | Modo 1 | Agregar nodos |
| 🟢 🗑️ | Modo 2 | Eliminar nodos |
| 🟢 ⇄ | Modo 3 | Mover nodos |
| 🟢 🔗 | Modo 4 | Crear enlaces |

**Nota**: El botón verde indica el modo activo

## 📝 Ejemplos de Uso

### Ejemplo 1: Grafo Simple
```
1. Crea 4 nodos en forma de cuadrado
2. Conecta cada nodo con sus vecinos:
   - Nodo 1 → Nodo 2 (peso: 10)
   - Nodo 2 → Nodo 3 (peso: 15)
   - Nodo 3 → Nodo 4 (peso: 10)
   - Nodo 4 → Nodo 1 (peso: 15)
3. Agrega diagonales:
   - Nodo 1 → Nodo 3 (peso: 20)
   - Nodo 2 → Nodo 4 (peso: 20)
4. Presiona TSP
5. Observa la ruta óptima
```

### Ejemplo 2: Grafo Complejo
```
1. Crea 6-8 nodos distribuidos por la pantalla
2. Conecta varios nodos con diferentes pesos
3. Usa pesos variados (5, 10, 15, 20, 25)
4. Presiona TSP
5. El algoritmo encontrará la ruta más corta
```

## 🔧 Funciones Avanzadas

### Mover Nodos (Modo 3)
- Los enlaces se mantienen conectados
- Las curvas se ajustan automáticamente
- Útil para reorganizar el grafo visualmente

### Eliminar Nodos (Modo 2)
- Elimina el nodo y todos sus enlaces
- Los índices se reajustan automáticamente
- No afecta otros nodos

### Curvas de Bezier
- Cada enlace tiene una curva suave
- El punto azul es el punto de control
- La curvatura es del 20% de la distancia
- Evita que los enlaces se superpongan

## 💡 Consejos

1. **Distribución de Nodos**: Separa bien los nodos para ver mejor las conexiones
2. **Pesos Realistas**: Usa pesos proporcionales a la distancia visual
3. **Grafos Pequeños**: Empieza con 4-5 nodos para entender el algoritmo
4. **Grafos Grandes**: Prueba con 8-10 nodos para ver el poder del algoritmo genético
5. **Múltiples Soluciones**: Ejecuta TSP varias veces - puede encontrar rutas diferentes

## 🎯 Problema del Viajante (TSP)

### ¿Qué hace el algoritmo?
- Encuentra la ruta más corta que visita todos los nodos
- Regresa al nodo inicial
- Usa algoritmos genéticos (inspirados en la evolución)

### Parámetros del Algoritmo
- **Población**: 100 soluciones simultáneas
- **Generaciones**: 500 iteraciones de mejora
- **Mutación**: 2% de cambios aleatorios
- **Cruce**: 80% de combinación de soluciones

### Interpretación de Resultados
- **Distancia Total**: Suma de todos los pesos en la ruta
- **Ruta Verde**: Secuencia óptima de visita
- **Animación**: Muestra el orden de visita

## ⚠️ Notas Importantes

1. **Mínimo de Nodos**: Se necesitan al menos 2 nodos para resolver TSP
2. **Enlaces Opcionales**: Si no hay enlace directo, usa distancia euclidiana
3. **Direccionalidad**: Los enlaces son dirigidos (tienen dirección)
4. **Tiempo de Cálculo**: Más nodos = más tiempo (pero menos de 1 segundo normalmente)

## 🐛 Solución de Problemas

### "Se necesitan al menos 2 nodos"
- Crea más nodos antes de presionar TSP

### No veo los enlaces
- Asegúrate de estar en Modo 4
- Verifica que hayas hecho click en dos nodos diferentes
- Los enlaces aparecen después de ingresar el peso

### La animación no se ve
- Espera a que termine el cálculo
- La animación dura 3 segundos
- La ruta verde aparece gradualmente

### Los nodos se superponen
- Usa Modo 3 para moverlos
- Arrastra los nodos a nuevas posiciones
- Los enlaces se ajustan automáticamente

## 📚 Más Información

Ver `README_TSP.md` para:
- Detalles técnicos del algoritmo
- Estructura del código
- Explicación matemática
- Posibles mejoras
