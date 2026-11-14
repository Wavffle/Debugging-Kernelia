event_inherited();

can_wander = false;

// --- Sprites en reposo (los usa face_direction al interactuar) ---
sprite_idle_down = spr_habitante_memorian2_idle_front;
sprite_idle_up   = spr_habitante_memorian2_idle_up;
sprite_idle_side = spr_habitante_memorian2_idle_right;

// --- Sprites al caminar (se usan al deambular) ---
sprite_walk_down = spr_habitante_memorian2_walking_front;
sprite_walk_up   = spr_habitante_memorian2_walking_up;
sprite_walk_side = spr_habitante_memorian2_walking_right;

// La máscara de colisión
mask_index = spr_habitante_memorian2_idle_front;