MISHA: CORAZÓN DEL MUNDO — REVISIÓN 44

Mejoras conservadoras aplicadas sin eliminar sistemas:
- Menú: VideoStreamPlayer queda como fondo real; TextureRect estático queda oculto para que no tape el vídeo. Background se conserva como oscurecimiento translúcido.
- Vídeo OGV existente conservado.
- 3 hitboxes unificadas en enemy_basic, enemy_cave, enemy_forest, enemy_flyer, enemy_ranged y enemy_temple:
  1) cuerpo: CapsuleShape2D radio 42, altura 96, posición (0,15)
  2) Hurtbox: CircleShape2D radio 38, posición (0,15)
  3) AttackArea: RectangleShape2D 116x72, posición (64,8)
- Se mantiene la estructura y los scripts existentes.
- No se reemplazaron escenas completas.

Nota: esta revisión fue validada estáticamente; este entorno no tiene el ejecutable de Godot 4.7.1 para hacer prueba de ejecución.
