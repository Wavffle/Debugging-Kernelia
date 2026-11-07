// --- Mover todas las nubes a la vez, en pasos de 1 px ---
cloud_timer++;
if (cloud_timer >= cloud_interval) {
    cloud_timer = 0;

    for (var i = 0; i < array_length(clouds); i++) {
        var _c = clouds[i];
        _c.x += 1;

        // Al salir por la derecha: tamaño, opacidad y altura nuevos, y vuelve a su sitio del ciclo
        if (_c.x > GUI_W + cloud_margin) {
            cloud_randomize(_c);
            _c.x -= cloud_loop_w;
            _c.y = cloud_pick_y(i);
        }
    }
}

var up_key = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var down_key = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
var back_key = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("X"));

op_length = array_length(option[menu_level]);

// --- Parpadeo en curso: al terminar, se ejecuta la acción ---
if (blink_timer > 0) {
    blink_timer--;

    if (blink_timer <= 0) {
        switch (menu_level) {
            // Menú principal
            case 0:
                switch (pos) {
                    case 0: room_goto(rm_start); break;      // Nueva Partida
                    case 2: menu_level = 1; pos = 0; break;  // Opciones
                    case 3: game_end(); break;               // Salir
                }
            break;

            // Opciones
            case 1:
                switch (pos) {
                    case 0: break; // Tamaño de la ventana
                    case 1: break; // Brillo
                    case 2: break; // Controles
                    case 3: menu_level = 0; pos = 2; break; // Volver
                }
            break;
        }
        op_length = array_length(option[menu_level]);
    }
    exit;
}

// --- Esc o X: salir de Opciones ---
if (back_key && menu_level == 1) {
    audio_play_sound(snd_menu_back, 1, false);
    menu_level = 0;
    pos = 2;
    op_length = array_length(option[menu_level]);
    exit;
}

// --- Moverse ---
var _old_pos = pos;
pos += down_key - up_key;
if (pos >= op_length) { pos = 0; }
if (pos < 0) { pos = op_length - 1; }
if (pos != _old_pos) {
    audio_play_sound(snd_menu_move, 1, false);
}

// --- Seleccionar ---
if (accept_key) {
    // "Continuar" todavía no hace nada
    if (menu_level == 0 && pos == 1) exit;

    var _is_back = (menu_level == 1 && pos == 3);
    var _is_new_game = (menu_level == 0 && pos == 0);

    var _snd = snd_menu_select;
    if (_is_back) _snd = snd_menu_back;
    if (_is_new_game) _snd = snd_new_game;

    audio_play_sound(_snd, 1, false);
    blink_timer = _is_new_game ? 60 : blink_duration;
}