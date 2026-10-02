Misha Hollow Realm — V62 Prueba y corrección de recorrido

Base: V61 Pulido de nivel.

Objetivo:
- Hacer más robusto el recorrido Z01 -> Z02 -> Z03 -> Z04 y el regreso.
- Evitar que una caída accidental deje al jugador fuera de una zona.

Cambios:
- Nuevo RouteSafety en Z01, Z02, Z03 y Z04.
- Si el jugador cae por debajo del límite de cámara, vuelve a PlayerSpawn con velocidad reiniciada.
- Se cancelan estados de movimiento que podrían dejar al personaje bloqueado después de una caída.
- Se mantienen doble salto, Dash, Parry, cámara, transiciones y animaciones.
- No se agregan enemigos, NPC, armas ni coleccionables.

Validación estructural:
- Escenas Z01-Z04 mantienen sus destinos y Spawn markers.
- RouteSafety referencia solo nodos/propiedades existentes del proyecto.
- Godot no está instalado en el entorno de trabajo, por lo que no se pudo ejecutar la escena aquí.
