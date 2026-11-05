up_key = keyboard_check_pressed(vk_up);
down_key = keyboard_check_pressed(vk_down);
accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

op_length = array_length(option[menu_level]);

// Ignorar el frame en que se abrió
if (just_opened) {
    just_opened = false;
    exit;
}

// --- Parpadeo en curso: se ignora el input y, al terminar, se ejecuta la acción ---
if (blink_timer > 0) {
    blink_timer--;

    if (blink_timer <= 0) {
        var _sml = menu_level;
        var _new_pos = 0;

        switch (menu_level) {
            // Pausa
            case 0:
                switch (pos) {
                    case 0: instance_destroy(); break;  // Continuar
                    case 1: menu_level = 1; break;      // Opciones
                    case 2: menu_level = 2; break;      // Menú principal
                    case 3: game_end(); break;          // Salir
                }
            break;

            // Opciones
            case 1:
                switch (pos) {
                    case 0: break; // Tamaño de la ventana
                    case 1: break; // Brillo
                    case 2: break; // Controles
                    case 3: menu_level = 0; break; // Volver
                }
            break;

            // Confirmación
            case 2:
                switch (pos) {
                    case 0: room_goto(rm_title_screen); break;   // Sí
                    case 1: menu_level = 0; _new_pos = 2; break; // No
                }
            break;
        }

        if (_sml != menu_level) { pos = _new_pos; }
        op_length = array_length(option[menu_level]);
    }
    exit;
}

// Esc o X: volver un nivel, o cerrar el menú si ya estamos en el principal
var back_key = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("X"));

if (back_key) {
    audio_play_sound(snd_menu_back, 1, false);
    if (menu_level == 0) {
        instance_destroy();
        exit;
    } else {
        pos = (menu_level == 2) ? 2 : 0;
        menu_level = 0;
        op_length = array_length(option[menu_level]);
        exit;
    }
}

// Moverse en el menú
var _old_pos = pos;
pos += down_key - up_key;
if (pos >= op_length) { pos = 0; }
if (pos < 0) { pos = op_length - 1; }
if (pos != _old_pos) {
    audio_play_sound(snd_menu_move, 1, false);
}

// Seleccionar: suena de inmediato y empieza el parpadeo
if (accept_key) {
    // Opciones que "retroceden" suenan distinto
    var _is_back = (menu_level == 0 && pos == 0)
                || (menu_level == 1 && pos == 3)
                || (menu_level == 2 && pos == 1);

    audio_play_sound(_is_back ? snd_menu_back : snd_menu_select, 1, false);
    blink_timer = blink_duration;
}