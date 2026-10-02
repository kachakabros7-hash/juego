HEART OF THE WORLD - V97
REPARACIÓN DEL PARSE ERROR DEL MENÚ

Base: V96_Revision_Completa

Cambios de esta versión:
- Reparado scripts/ui/main_menu.gd para evitar construcciones que podían provocar el Parse Error en Godot 4.7.1.
- Se usan range() explícito en los bucles.
- Se eliminó la variable tipada con null en la navegación del menú.
- Se reemplazó el acceso abreviado a Dictionary por acceso explícito con ["clave"].
- Se eliminó el await innecesario al reconstruir las filas del panel de controles.
- Se conserva la navegación W/S, flechas, Enter, Enter numérico, Espacio y Escape.
- Se conserva el arreglo ok_button_text del AcceptDialog.
- No se eliminaron sistemas, escenas, enemigos, jefes, habilidades, guardado, mapa, audio ni contenido existente.

Nota:
No se dispone de un ejecutable de Godot dentro de este entorno, por lo que no se afirma una prueba de ejecución real. El proyecto queda preparado para abrirse en Godot 4.7.1.
