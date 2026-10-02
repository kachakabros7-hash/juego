HEART OF THE WORLD V139 — WORLD & GAMEPLAY OVERHAUL

Objetivo:
Conectar los sistemas existentes para que exploración, zonas, progreso, guardado y ambientación compartan un estado común.

Cambios:
- WorldDirector global detecta automáticamente la habitación y región actual.
- Cada habitación visitada se registra en GameState.
- Cada región aplica su balance global al entrar.
- Se añade atmósfera de pantalla ligera y diferenciada por región.
- Checkpoints y derrotas de jefe solicitan guardado automático diferido.
- El guardado pasa a versión 6 y conserva compatibilidad con partidas anteriores mediante valores por defecto.
- Se añade registro persistente de salas secretas para futuras recompensas.
- Se conserva el sistema de Misha, enemigos, minibosses, mapa y habilidades existentes.

Limitación:
Esta versión fue validada estáticamente y mediante integridad del ZIP. No se ejecutó Godot 4.7 en este entorno.
