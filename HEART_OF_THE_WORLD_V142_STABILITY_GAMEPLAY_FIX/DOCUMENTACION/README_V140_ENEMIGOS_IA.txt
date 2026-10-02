HEART OF THE WORLD — V140 — IA DE ENEMIGOS

Base: V139 WORLD GAMEPLAY OVERHAUL

OBJETIVO
Mejorar la inteligencia de los enemigos sin convertirlos en enemigos injustos. La IA ahora intenta percibir al jugador, conservar memoria de su última posición, predecir ligeramente su movimiento, evitar agruparse, respetar los bordes y adaptar su comportamiento al tipo de enemigo.

MEJORAS GENERALES
- Percepción mediante distancia y comprobación de obstáculos.
- Memoria temporal de la última posición conocida del jugador.
- Investigación de la última posición cuando el jugador sale de vista.
- Patrulla local alrededor de la posición inicial.
- Aceleración y desaceleración en lugar de cambios instantáneos de velocidad.
- Predicción corta del movimiento del jugador durante la persecución.
- Separación entre enemigos para reducir amontonamientos.
- Prevención básica de caminar directamente hacia un vacío.
- Ataques condicionados por distancia horizontal y vertical.
- Reacción al daño que conserva el contexto del combate.

TIPOS ESPECÍFICOS
- Enemy Basic: comportamiento completo de percepción, persecución, memoria y patrulla.
- Armored: hereda la IA y conserva su guardia defensiva.
- Ambush: permanece oculto, detecta al jugador, ataca primero y se reposiciona.
- Elite: conserva su carga, pero ahora evalúa distancia, altura, visibilidad y suelo antes de lanzarse.
- Ranged: mantiene una distancia preferida, hace strafe lateral y cambia de dirección para no ser totalmente predecible.
- Flyer: persigue con predicción y usa una trayectoria orbital suave antes de acercarse al ataque.
- Weaver: conserva distancia, cambia de lado y usa su ataque de eco cuando tiene una oportunidad.

ERROR CORREGIDO
Se eliminó la declaración duplicada de registrar_sala_secreta() y sala_secreta_descubierta() en GameState.gd que provocaba el Parser Error mostrado por Godot.

VALIDACIÓN
- Se revisaron los scripts modificados y sus rutas.
- Se comprobó que no quedan funciones duplicadas en scripts del proyecto fuera de addons.
- El ZIP se verifica con testzip().
- No se ejecutó Godot en este entorno; por tanto, esta versión no se declara compilada ni probada en runtime.

NOTA
La IA está diseñada para el mapa actual basado en plataformas. No se añadió navegación automática compleja ni teletransporte. Los enemigos terrestres no saltan todavía entre plataformas: prefieren detenerse ante un vacío, lo que evita comportamientos absurdos. Una futura versión puede añadir navegación por saltos, coordinación de grupos y estados especiales por región.
