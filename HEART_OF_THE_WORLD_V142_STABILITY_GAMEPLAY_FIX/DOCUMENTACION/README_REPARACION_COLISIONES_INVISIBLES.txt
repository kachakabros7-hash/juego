REPARACIÓN — COLISIONES INVISIBLES SOBRANTES

Se eliminaron únicamente los bloques de plataformas estáticas antiguas Platform01, Platform02, etc. de las salas que ya tienen el sistema V70 de plataformas dinámicas (zone_level_design.gd).

Se conservaron:
- Ground y paredes.
- Salidas/portales y sus colisiones.
- Zonas secretas.
- Puertas/bloqueos de habilidades.
- Plataformas V70 generadas por zone_level_design.gd.
- Player, enemigos, habilidades y demás sistemas.

Motivo: las plataformas antiguas duplicaban la geometría de juego y podían dejar superficies de colisión sin una plataforma visible correspondiente.
