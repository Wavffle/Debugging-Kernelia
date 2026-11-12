can_wander = false;

on_dialogue_end = function() {
    if (!instance_exists(obj_ram_game)) instance_create_depth(0, 0, -10000, obj_ram_game);
}