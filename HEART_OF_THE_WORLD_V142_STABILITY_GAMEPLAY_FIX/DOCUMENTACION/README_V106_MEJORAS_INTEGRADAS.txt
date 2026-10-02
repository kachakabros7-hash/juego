HEART OF THE WORLD — V106 MEJORAS INTEGRADAS

Base: V105 CORREGIDO CONTROLES.

INTEGRADO:
- Player con State Machine.
- GameState con señales/API de progreso.
- SaveManager robusto (guardado v4).
- AudioManager y TutorialManager como autoloads.
- Feedback de combate: hitstop, vibración de cámara y partículas.
- Controlador de sprites de Misha (si hay sprites compatibles).
- Enemigos y boss_guardian mejorados.
- Checkpoints y transiciones más seguras.
- Mapa/minimapa optimizados.
- Pausa con prioridad ESC: diálogo -> mapa -> pausa.
- Mejoras de tienda.
- Scripts de pulido de salas conservados.

REGLA:
Esta versión se construyó encima de V105. No se eliminan las 12 zonas ni la base del proyecto.

AUToloads añadidos:
AudioManager -> res://scripts/core/audio_manager.gd
TutorialManager -> res://scripts/core/tutorial_manager.gd

IMPORTANTE:
No incluye sprites externos nuevos. El controlador de Misha busca assets si el usuario los coloca en assets/sprites/misha/.
