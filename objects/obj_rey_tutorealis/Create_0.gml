event_inherited();

can_wander = false;

npc_name = "Rey de Tutorealis";

// --- Sprites en reposo (los usa face_towards al interactuar) ---
sprite_idle_down = spr_rey_idle_front;
sprite_idle_up   = spr_rey_idle_up;
sprite_idle_side = spr_rey_idle_right;

// --- Sprites al caminar (todavía no se usan, quedan listos para después) ---
sprite_walk_down = spr_rey_walking_front;
sprite_walk_up   = spr_rey_walking_up;
sprite_walk_side = spr_rey_walking_right;

// La máscara de colisión
mask_index = spr_rey_idle_front;

text_id = "conversacion_con_rey";