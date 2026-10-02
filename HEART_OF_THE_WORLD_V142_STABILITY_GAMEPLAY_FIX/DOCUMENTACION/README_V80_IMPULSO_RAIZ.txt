MISHA: CORAZÓN DEL MUNDO — V80
RECOMPENSA DEL GUARDIÁN: IMPULSO DE RAÍZ

Basado directamente en V79, sin eliminar sistemas existentes.

NOVEDAD PRINCIPAL
- Al derrotar al Guardián de las Raíces aparece una recompensa física.
- Habilidad: IMPULSO DE RAÍZ.
- Tecla: V.
- Solo se activa desde el suelo.
- Lanza a Misha verticalmente con gran fuerza.
- Tiene enfriamiento de 1.6 s.
- Daño defensivo corto de 18 a enemigos muy cercanos.
- Concede una breve invulnerabilidad durante el despegue.
- Se guarda mediante GameState/SaveManager.
- Si ya fue obtenida, no vuelve a aparecer.

INTEGRACIÓN
- GameState incluye root_burst.
- HUD muestra IMPULSO DE RAÍZ [V].
- habilidad_pickup.gd reconoce root_burst.
- El Guardián crea el pickup al morir.
- Se conserva la recompensa anterior de 200 monedas y corazon_raiz.
