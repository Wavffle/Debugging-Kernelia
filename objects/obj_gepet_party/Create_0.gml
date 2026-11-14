catchup_speed = 2.2;   // velocidad máxima para alcanzarte si se queda atrás
facing_dir = "down";

sprite_idle_down = spr_gepet_idle_front;
sprite_idle_up   = spr_gepet_idle_up;
sprite_idle_side = spr_gepet_idle_right;

sprite_walk_down = spr_gepet_walking_front;
sprite_walk_up   = spr_gepet_walking_up;
sprite_walk_side = spr_gepet_walking_right;

sprite_run_down = spr_gepet_running_front;
sprite_run_up   = spr_gepet_running_up;
sprite_run_side = spr_gepet_running_right;

follow_dist_walk = 14; // distancia al caminar (más pegado)
follow_dist_run  = 20; // distancia al correr (más atrás)
follow_dist = follow_dist_walk;

// Para suavizar animación y dirección
vx = 0;
vy = 0;
moving_anim = false;

anim_state = "idle";