MISHA: CORAZÓN DEL MUNDO — V84

CORRECCIÓN Y DISEÑO DE TRAVESÍAS

1. Se restauraron los nodos StaticBody2D de las plataformas que habían quedado solo como CollisionShape2D en varias salas principales.
2. Las plataformas ahora tienen posición y colisión reales en el editor; el sistema visual de plataformas sigue activo.
3. zone_level_design.gd evita duplicar plataformas dinámicas cuando la sala ya tiene geometría explícita.
4. La entrada temprana a Raíces Profundas ahora está arriba de una ruta de parkour: el jugador debe encadenar saltos por plataformas para alcanzar el arco.
5. Se conservó la ruta alternativa de Impulso de Raíz y la ruta de Salto Celestial como atajos opcionales.
6. El texto de navegación identifica Z02 como RAÍCES PROFUNDAS.
7. No se eliminan sistemas previos.

Nota: esta versión fue validada de forma estática; no se dispone de un ejecutable de Godot 4.7.1 en este entorno para hacer una prueba de ejecución.
