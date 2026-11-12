// --- Salir (TEMPORAL, solo para pruebas) ---
if (keyboard_check_pressed(vk_escape)) {
    instance_destroy();
    exit;
}

if (start_delay > 0) {
    start_delay--;
    exit;
}

// --- Máquina de escribir de Gepe-T ---
if (msg_pause_timer > 0) {
    msg_pause_timer--;
}
else if (msg_char < msg_len) {
    msg_acc += msg_spd;
    while (msg_acc >= 1 && msg_char < msg_len) {
        msg_acc--;
        msg_char++;
        var _c = string_char_at(msg_full, msg_char);

        if (_c == "." || _c == "?" || _c == "!" || _c == ",") {
            msg_pause_timer = msg_pause_time;
            // Los puntos de unos puntos suspensivos no suenan
            var _ell = (_c == "." && (string_char_at(msg_full, msg_char - 1) == "." || string_char_at(msg_full, msg_char + 1) == "."));
            if (!_ell && !audio_is_playing(snd_voice_gepet)) audio_play_sound(snd_voice_gepet, 8, false);
            break; // la pausa corta el avance de este frame
        }
        else if (_c != "\n") {
            if (msg_snd_count < msg_snd_delay) msg_snd_count++;
            else {
                msg_snd_count = 0;
                audio_play_sound(snd_voice_gepet, 8, false);
            }
        }
    }
}

if (btn_shake > 0) btn_shake--;

if (emo_timer > 0) {
    emo_timer--;
    if (emo_timer == 0) emo = emo_base;
}

// --- Animación: los procesos se deslizan a su sitio ---
for (var i = 0; i < array_length(procs); i++) {
    var _p = procs[i];
    if (_p.slot == -1) continue;
    _p.dx = lerp(_p.dx, _p.slot, 0.15);
    if (abs(_p.dx - _p.slot) < 0.02) _p.dx = _p.slot;
}

var _accept = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

switch (state) {
	case "play":
        // Durante la animación de compactar no se puede jugar
        if (busy_timer > 0) {
            busy_timer--;
            if (busy_timer == 0) check_state();
            break;
        }

        // Mover el cursor
        var _l = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"));
        var _r = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
        var _old_cur = cur;
        cur = clamp(cur + _r - _l, 0, 7);
        if (cur != _old_cur) audio_play_sound(snd_menu_move, 1, false);

        // Colocar el primer proceso de la cola
        if (_accept) place_selected();

        // --- Compactar (C): se hunde al apretar y actúa al soltar ---
        if (keyboard_check_pressed(ord("C"))) {
            if (comp_left <= 0) deny_compact();
            else btn_c_down = true;
        }
        if (btn_c_down && keyboard_check_released(ord("C"))) {
            btn_c_down = false;
            compact_memory();
        }

        // --- Reiniciar (R): se hunde al apretar y actúa al soltar ---
        if (keyboard_check_pressed(ord("R"))) btn_r_down = true;
        if (btn_r_down && keyboard_check_released(ord("R"))) {
            btn_r_down = false;
            load_level(level);
        }
    break;

    case "win":
        if (_accept) {
            if (level + 1 < RAM_LEVELS) load_level(level + 1);
            else state = "end";
        }
    break;

    case "end":
        if (_accept) instance_destroy();
    break;
}