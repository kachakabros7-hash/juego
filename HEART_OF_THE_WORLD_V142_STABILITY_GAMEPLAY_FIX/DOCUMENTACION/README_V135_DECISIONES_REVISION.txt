HEART OF THE WORLD — V135: DECISIONES Y REVISIÓN

CAMBIOS
- Se añadió una elección jugable tras aceptar la primera misión de Luma: escuchar a las criaturas antes de juzgarlas o priorizar la protección del bosque.
- La decisión se guarda en GameState durante la sesión y modifica una línea de los diálogos posteriores de Luma.
- Se conserva el controlador del jugador y los sistemas existentes.

REVISIÓN ESTÁTICA
- ZIP de origen íntegro antes de modificar.
- Se comprobará la integridad del ZIP final y la presencia de los archivos clave.
- No se pudo ejecutar el proyecto dentro del motor Godot en este entorno; por tanto, no se afirma que la ejecución en runtime esté validada.

NOTA
La elección narrativa se mantiene en memoria durante la sesión. Todavía no se añade a la serialización de SaveManager, por lo que no se garantiza que sobreviva al cierre del juego.
