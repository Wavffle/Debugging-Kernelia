run_speed = 3;      // velocidad normal (correr, por defecto)
walk_speed = 1.5;   // velocidad reducida (caminar, con Shift)
move_speed = run_speed; // variable que se usa realmente en el movimiento

facing_dir = "down";
is_moving = false;

diagonal_grace_max = 6;   // frames de gracia (6 frames = 0.1 s a 60 fps)
diagonal_grace_timer = 0; // contador interno
last_diagonal = "";       // última diagonal detectada, ej: "up_right"

interact_range = 40; // distancia máxima (en píxeles) para poder interactuar