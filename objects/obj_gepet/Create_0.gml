event_inherited(); // IMPORTANTE: ejecuta primero el Create del padre

can_wander = false;

sprite_idle_down = spr_gepet_idle_front;
sprite_idle_up   = spr_gepet_idle_up;
sprite_idle_side = spr_gepet_idle_right;

sprite_walk_down = spr_gepet_walking_front;
sprite_walk_up   = spr_gepet_walking_up;
sprite_walk_side = spr_gepet_walking_right;

mask_index = spr_gepet_idle_front;

text_id = "conversacion_con_gepet";

// Al terminar el diálogo, Gepe-T se une a la party
on_dialogue_end = function() {
    var _g = instance_create_depth(x, y, depth, obj_gepet_party);
    _g.facing_dir = facing_dir;
    global.gepet_in_party = true;
    instance_destroy();
}