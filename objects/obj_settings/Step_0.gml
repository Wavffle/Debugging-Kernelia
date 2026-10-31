if (keyboard_check_pressed(vk_escape) && !global.paused && room == rm_start) {
    instance_create_layer(0, 0, "Instances", obj_menu);
}