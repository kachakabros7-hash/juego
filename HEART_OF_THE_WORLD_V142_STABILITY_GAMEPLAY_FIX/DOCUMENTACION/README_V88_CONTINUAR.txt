V88 — CONTINUAR Y PARTIDA GUARDADA

Se conserva todo el contenido de V87.

CAMBIOS:
- CONTINUAR ahora es un boton fijo del menu principal.
- Si existe una partida guardada, CONTINUAR queda disponible y recibe el foco inicial.
- Si no existe partida, CONTINUAR aparece desactivado y JUGAR recibe el foco.
- CONTINUAR llama a SaveManager.cargar_partida() y recupera escena, posicion, vida, monedas, habilidades, mapa, recompensas, puertas, salas, jefes y checkpoint guardados.
- JUGAR inicia una partida nueva y borra el guardado anterior, como antes.
- No se eliminan sistemas previos.
