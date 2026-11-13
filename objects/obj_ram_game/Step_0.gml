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
            if (!_ell && !audio_is_playing(snd_voice_gepet)) gepet_voice();
            break; // la pausa corta el avance de este frame
        }
        else if (_c != "\n") {
            if (msg_snd_count < msg_snd_delay) msg_snd_count++;
            else {
			    msg_snd_count = 0;
			    gepet_voice();
			}
        }
    }
}

if (btn_shake > 0) btn_shake--;
if (tick_flash > 0) tick_flash--;
if (board_shake > 0) board_shake--;

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

// --- Animaciones de la interfaz ---
if (pin_t > 0) pin_t--;
if (dot_t > 0) dot_t--;

for (var i = 0; i < array_length(procs); i++) {
    if (procs[i].pop > 0) procs[i].pop--;
}

// La cola: cada proceso se desliza a su lugar
var _qtx = queue_x + 22;
for (var i = 0; i < array_length(queue); i++) {
    var _qp = procs[queue[i]];
    _qp.qx = lerp(_qp.qx, _qtx, 0.25);
    if (abs(_qp.qx - _qtx) < 0.3) _qp.qx = _qtx;
    _qtx += _qp.size * qcell_w + 6;
}

// Estela mientras se compacta
if (busy_timer > 0) {
    for (var i = 0; i < array_length(procs); i++) {
        var _tp = procs[i];
        if (_tp.slot != -1 && abs(_tp.dx - _tp.slot) > 0.1) {
            spawn_parts(cell_x0 + (_tp.dx + _tp.size) * cell_w, cell_y0 + 8, 4, cell_h - 16, 1, block_colors[_tp.k mod 8]);
        }
    }
}

// --- Partículas: mover y borrar las que terminaron ---
for (var i = array_length(parts) - 1; i >= 0; i--) {
    var _q = parts[i];
    _q.x += _q.vx;
    _q.y += _q.vy;
    _q.vy += 0.04; // caen un poco
    _q.life++;
    if (_q.life >= _q.max_life) array_delete(parts, i, 1);
}

// --- Transición entre niveles ---
if (fade_dir == 1) {
    fade_alpha = min(1, fade_alpha + fade_speed);
    if (fade_alpha >= 1) {
        load_level(fade_next);
        audio_play_sound(snd_ram_levelstart, 5, false);
        fade_dir = -1;
    }
}
else if (fade_dir == -1) {
    fade_alpha = max(0, fade_alpha - fade_speed);
    if (fade_alpha <= 0) fade_dir = 0;
}
if (fade_dir != 0) exit; // sin input mientras dura la transición

var _accept = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

switch (state) {
	case "play":
	    // Mover el cursor (se puede mover durante la animación de compactar)
	    var _l = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"));
	    var _r = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
	    var _old_cur = cur;
	    var _cz = (array_length(queue) > 0) ? procs[queue[0]].size : 1;
	    cur = clamp(cur + _r - _l, 1 - _cz, RAM_CELLS - 1);
	    if (cur != _old_cur) play_sfx(snd_ram_move, 0.9 + cur * 0.03, 0.01);

	    // Durante la animación de compactar no se puede colocar ni usar los botones
	    if (busy_timer > 0) {
	        busy_timer--;
	        if (busy_timer == 0) check_state();
	        break;
	    }

	    // Colocar el primer proceso de la cola
	    if (_accept) place_selected();

        // --- Compactar (C): se hunde al apretar y actúa al soltar ---
        if (keyboard_check_pressed(ord("C"))) {
		    if (comp_left <= 0) deny_compact();
		    else { btn_c_down = true; audio_play_sound(snd_ram_button, 5, false); }
		}
        if (btn_c_down && keyboard_check_released(ord("C"))) {
            btn_c_down = false;
            compact_memory();
        }

        // --- Reiniciar (R): se hunde al apretar y actúa al soltar ---
        if (keyboard_check_pressed(ord("R"))) { btn_r_down = true; play_sfx(snd_ram_button, 1.1, 0.02); }
        if (btn_r_down && keyboard_check_released(ord("R"))) {
            btn_r_down = false;
            load_level(level);
        }
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