HEART OF THE WORLD — V142 STABILITY & GAMEPLAY FIX

Base: V141 IA INTELIGENTE

Cambios principales:
- Reparada la indentación literal de eco_perdido.gd.
- Reconstruido SpriteFrames de Misha con idle/run/jump/fall/attack_1/attack_2/dash/death/hurt y animaciones seguras auxiliares.
- Corregido el salto aéreo gratuito al caer de una cornisa: un salto aéreo solo consume un salto de suelo previo.
- Camera2D cacheada con @onready.
- Corregida la compra doble de daño.
- Fragmentos de vida ahora tienen bonus persistente en GameState y guardado.
- Evitado el doble incremento de vida en recompensa_especial.
- Reparados los tres destinos SpawnTop inexistentes en recompensas.
- Corregido ID duplicado cofreraicesv82.
- Muerte comprueba el resultado de change_scene_to_file y usa fallback.
- Guardado temporal + backup .bak y validación de versiones futuras.
- Carga parte del estado actual y fusiona diccionarios sin borrar claves nuevas.
- Añadidos hooks de SFX para salto/daño; si faltan WAV, AudioManager no falla.

Validación: estática e integridad ZIP. No se ejecutó Godot; por tanto no se declara compilación/runtime verificados.
