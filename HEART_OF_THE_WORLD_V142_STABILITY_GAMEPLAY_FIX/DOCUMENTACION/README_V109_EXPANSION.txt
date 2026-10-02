HEART OF THE WORLD — V109 EXPANSION

Base: V108 ESTABLE LIMPIA.

NOVEDADES:
- Sistema de misiones preparado: Ecos del Bosque (3 enemigos).
- MissionManager como autoload.
- Conteo global de enemigos derrotados.
- Inventario de pociones: 2 iniciales, máximo 9.
- Uso de poción con P; cura 30 si Misha no tiene la vida completa.
- HUD de misión, progreso y pociones.
- Mensajes breves de misión/poción.
- Números de daño sobre enemigos.
- enemy_basic.gd estabilizado para variantes heredadas.
- Conserva MetSys, mapa, escenas y sistemas existentes.

IMPORTANTE:
La misión queda NO INICIADA hasta que se conecte con Luma.
No se eliminan las 12 zonas ni los sistemas existentes.

PRUEBA SUGERIDA:
1. Abrir el proyecto en Godot 4.7.
2. Ejecutar.
3. Comprobar que no haya Parse Error.
4. Entrar al Bosque.
5. Verificar HUD de pociones.
6. Pulsar P con vida incompleta.
7. Para probar la misión, desde un script/NPC futuro llamar MissionManager.iniciar_mision().
