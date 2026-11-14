// --- Salir (TEMPORAL, solo para pruebas) ---
if (keyboard_check_pressed(vk_escape)) {
    instance_destroy();
    exit;
}

if (start_delay > 0) {
    start_delay--;
    exit;
}

update_typewriter();
update_timers();
update_slides();
update_particles();
if (update_fade()) exit; // sin input mientras dura la transición

var _accept = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

switch (state) {
    case "play":
        move_cursor(); // se puede mover durante la animación de compactar

        // Durante la animación de compactar no se puede colocar ni usar los botones
        if (busy_timer > 0) {
            busy_timer--;
            if (busy_timer == 0) check_state();
            break;
        }
        play_input(_accept);
    break;

    case "win":
        if (_accept) {
            if (level + 1 < RAM_LEVELS) {
                fade_next = level + 1;
                fade_dir = 1;
            } else {
                audio_play_sound(snd_ram_end, 10, false);
                state = "end";
            }
        }
    break;

    case "end":
        if (_accept) instance_destroy();
    break;
}