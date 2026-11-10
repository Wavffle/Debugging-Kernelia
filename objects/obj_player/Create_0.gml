run_speed = 2.2; // velocidad normal (correr, por defecto)
walk_speed = 1; // velocidad reducida (caminar, con Shift)
move_speed = run_speed;

facing_dir = "down";
is_moving = false;

interact_reach = 10;

mask_front = spr_player_idle_front;
mask_side  = spr_player_idle_right;
mask_index = mask_front;

// --- Rastro de posiciones (lo siguen los compañeros de la party) ---
trail_x = [];
trail_y = [];
trail_max = 60;