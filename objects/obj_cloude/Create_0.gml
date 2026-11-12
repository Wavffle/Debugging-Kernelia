event_inherited();

can_wander = false;

npc_name = "Cloude";

// --- Sprites en reposo (los usa face_towards al interactuar) ---
sprite_idle_down = spr_cloude_idle_front;
sprite_idle_up   = spr_cloude_idle_up;
sprite_idle_side = spr_cloude_idle_right;

// --- Sprites al caminar (todavía no se usan, quedan listos para después) ---
sprite_walk_down = spr_cloude_walking_front;
sprite_walk_up   = spr_cloude_walking_up;
sprite_walk_side = spr_cloude_walking_right;

// La máscara de colisión no cambia al cambiar de animación
mask_index = spr_cloude_idle_front;

text_id = "cloude_ram_vs_disco";