MISHA: CORAZÓN DEL MUNDO — V79
GUARDIÁN DE LAS RAÍCES

CONTINÚA V78 SIN ELIMINAR LOS SISTEMAS EXISTENTES.

- Primer jefe del Bosque del Amanecer integrado.
- Nombre: Guardián de las Raíces.
- 1200 HP, 3 fases.
- Ataques: golpe, embestida, onda y lluvia de raíces.
- Telegraphs visibles para anticipar cada ataque.
- Barra de jefe y textos de fase.
- Sprite original del Guardián del Bosque integrado mediante hoja 8x7 (56 frames).
- Animaciones dinámicas: reposo, movimiento, ataque, fase y muerte.
- Arena con seis plataformas adicionales y puertas de combate.
- La arena se bloquea al iniciar y se libera al derrotar al jefe.
- Derrota persistente: GameState + SaveManager.
- Recompensa: 200 monedas + registro especial "corazon_raiz".
- El jefe no reaparece ni vuelve a cerrar la arena tras ser derrotado.
- Se corrigió la escena de la arena para declarar las seis plataformas antes de sus CollisionShape2D.

VALIDACIÓN:
- Referencias res:// verificadas estáticamente.
- Jerarquía de nodos de jefe revisada.
- No se pudo ejecutar Godot 4.7.1 en este entorno, por lo que no se afirma prueba de runtime.
