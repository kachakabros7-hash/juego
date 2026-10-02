MISHA: ADVENTURE - MAPA CONECTADO

Esta versión conecta automáticamente las 9 habitaciones mediante las salidas.

RUTA PRINCIPAL:
Entrada -> Sendero -> Profundidad -> Santuario -> Templo -> Guardián
                    |
                    v
                 Cavernas -> Lago -> Templo
                    |
                    v
              Cueva secreta

CONEXIONES:
- Entrada ExitRight -> Sendero SpawnLeft
- Entrada ExitTop -> Profundidad SpawnBottom
- Sendero ExitLeft -> Entrada SpawnRight
- Sendero ExitRight -> Profundidad SpawnLeft
- Sendero ExitTop -> Santuario SpawnLeft
- Profundidad ExitLeft -> Sendero SpawnRight
- Profundidad ExitRight -> Santuario SpawnLeft
- Profundidad ExitBottom -> Cavernas SpawnTop
- Santuario ExitLeft -> Profundidad SpawnRight
- Santuario ExitRight -> Templo SpawnLeft
- Cavernas ExitTop -> Profundidad SpawnBottom
- Cavernas ExitRight -> Lago SpawnLeft
- Cavernas ExitBottom -> Cueva secreta SpawnTop
- Cueva secreta ExitTop -> Cavernas SpawnBottom
- Lago ExitLeft -> Cavernas SpawnRight
- Lago ExitRight -> Templo SpawnLeft
- Templo ExitLeft -> Lago SpawnRight
- Templo ExitRight -> Guardián SpawnLeft
- Guardián ExitLeft -> Templo SpawnRight

SPAWNS:
Cada habitación tiene SpawnLeft, SpawnRight, SpawnTop y SpawnBottom.
El script player.gd usa GameState.punto_spawn para colocar al jugador en el marcador correcto.

CONTROLES:
A / D o flechas: mover
Espacio: saltar
Shift: dash
J: atacar
M: mapa (si el mapa está incluido en la escena que se está ejecutando)

IMPORTANTE:
El proyecto se entrega sin la carpeta .godot ni archivos .import generados para que Godot los regenere al abrirlo.
