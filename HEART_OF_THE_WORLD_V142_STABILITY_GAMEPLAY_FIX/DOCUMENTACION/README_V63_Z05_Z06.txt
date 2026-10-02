Misha Hollow Realm — V63
========================

Esta versión continúa el prototipo jugable desde ZONA 04 y añade dos salas completas:

ZONA 05 — LAGO OSCURO
- Sala horizontal de 4400 x 2500.
- Entrada desde Z04 por la ruta inferior.
- Salida de regreso a Z04.
- Salida hacia Z06.
- Ruta principal elevada y ruta inferior alternativa.
- Plataformas escalonadas pensadas para salto y movilidad.
- El agua es visual y no hace daño; si el jugador cae fuera del área jugable, RouteSafety lo devuelve al spawn.
- Sin enemigos, NPC, armas, monedas ni coleccionables.

ZONA 06 — RUINAS ANTIGUAS
- Sala horizontal/laberíntica de 4600 x 2600.
- Entrada desde Z05.
- Corredor principal.
- Rutas alternativas superior e inferior.
- Salida hacia Z07 / ciudad perdida.
- Regreso a Z05.
- La salida a Z07 conserva el requisito Impulso Espectral (Dash), ya existente en el proyecto.
- Sin enemigos, NPC, armas, monedas ni coleccionables.

MEJORAS GENERALES V63
- CameraBounds con suavizado consistente a 8.0.
- RouteSafety reescrito de forma segura usando CharacterBody2D y get() para evitar comprobaciones dinámicas frágiles.
- Se conserva el sistema existente de transiciones, spawns, habilidades, cámara, navegación y visuales de plataformas.
- Z05 y Z06 usan los estilos visuales existentes de lago y templo.

RUTA DE PRUEBA RECOMENDADA
Z01 Refugio → Z02 Valle → Z04 Santuario → Z05 Lago → Z06 Ruinas → Z07 Ciudad.
También se conservan las rutas secundarias existentes por Z03.

NOTA
No se pudo ejecutar el proyecto con el editor/ejecutable de Godot en este entorno, por lo que la validación realizada aquí es estructural y de integridad del ZIP. Abrir el proyecto en Godot y ejecutar la ruta indicada para la prueba final.
