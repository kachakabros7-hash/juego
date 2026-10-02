MAPA BOSQUE - MISHA: ADVENTURE

Este ZIP incluye una versión de prototipo del mapa grande sin fondo, sin tileset y sin arte de escenario.
Se construyó con nodos de Godot:
- Suelo y paredes con StaticBody2D + CollisionShape2D.
- 6 plataformas por habitación.
- Spawn del jugador.
- Salidas laterales que conectan 4 habitaciones.
- Zonas secretas con mensaje al descubrirlas.
- El botón JUGAR del menú abre Bosque Encantado.

Habitaciones:
1. bosque_entrada.tscn -> bosque_sendero.tscn
2. bosque_sendero.tscn -> bosque_profundidad.tscn
3. bosque_profundidad.tscn -> bosque_santuario.tscn
4. bosque_santuario.tscn -> final del prototipo

Controles del proyecto:
A/D o flechas = mover
Espacio = saltar
Shift = dash
J = atacar

Abrir el archivo project.godot con Godot 4.7.
