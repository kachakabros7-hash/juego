HEART OF THE WORLD - V98
MEJORAS + REPARACION DEL MENU

Base: V97 Parse Reparado

Cambios principales:
- Reescritura conservadora de scripts/ui/main_menu.gd para evitar construcciones que puedan provocar Parse Error en Godot 4.7.1.
- Navegacion robusta con W/S, flechas, Enter, Enter numerico, Espacio y Escape.
- Navegacion ciclica que salta botones deshabilitados.
- Compatibilidad con teclado fisico y layout de teclado.
- Panel de controles con cierre por Escape y foco de teclado.
- Opciones funcionales: volumen general y pantalla completa.
- Mantiene sonidos del menu, animaciones, particulas y estilo rojo/negro.
- Mantiene Continuar/Jugar/Controles/Opciones/Salir y las conexiones existentes de la escena.
- Se evito conectar dos veces las senales que ya estaban conectadas en main_menu.tscn.
- Se conserva el contenido y sistemas anteriores; no se elimina ninguna zona, enemigo, jefe, habilidad o sistema de guardado.

Revision estatica:
- 92 escenas TSCN revisadas.
- 52 scripts GDScript presentes.
- 0 rutas res:// de ext_resource inexistentes.
- 0 nombres de nodos hermanos duplicados.
- 0 referencias load/preload a archivos inexistentes.
- Integridad del ZIP verificada.

Limitacion:
No hay ejecutable de Godot 4.7.1 disponible en este entorno, por lo que la prueba final de ejecucion debe hacerse en Godot 4.7.1 localmente.
