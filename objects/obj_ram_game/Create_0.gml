global.paused = true;
start_delay = 2; // ignora la pulsación de Z que abrió el minijuego

// --- Medidas (pantalla de 480x270) ---
board_x = 32;
board_y = 24;
cell_w = 37;
cell_h = 57;
cell_x0 = board_x + 23;   // (416 - 370) / 2
cell_y0 = board_y + 11;   // si queda 1 px alto o bajo, ajusta este número
queue_x = 32;
queue_y = 122;

block_colors = [
    make_colour_rgb(56, 189, 248),  make_colour_rgb(244, 114, 182),
    make_colour_rgb(250, 204, 21),  make_colour_rgb(167, 139, 250),
    make_colour_rgb(251, 146, 60),  make_colour_rgb(74, 222, 128),
    make_colour_rgb(45, 212, 191),  make_colour_rgb(248, 113, 113)
];
sel_col = make_colour_rgb(185, 248, 235);
ink_col = make_colour_rgb(27, 27, 58);

// --- Estado general ---
btn_c_down = false;
btn_r_down = false;
btn_shake = 0;
board_shake = 0;
hold_dir = 0;      // dirección que se está manteniendo apretada (-1, 0, 1)
hold_t = 0;        // frames que lleva apretada
hold_delay = 14;   // espera antes de empezar a repetir (unos 0.25 s)
hold_rate = 4;     // cada cuántos frames se mueve una celda al mantener
tick_flash = 0;         // destello de los procesos temporales al pasar el turno
pin_t = 0;          // animación de los contactos dorados al compactar
pin_t_total = 40;   // duración en frames
pin_y = 74;         // fila de spr_ram_board donde empiezan los contactos dorados
pin_h = 10;         // alto de esa franja
dot_t = 0;          // rebote del punto de nivel al ganar
busy_timer = 0;
pulse = false;
dead_end = false;
dead_msg = "Ningún bloque alcanza y no se puede compactar más: esta asignación no tiene salida. Probemos otra distribución.";
msg = "";
state = "play";

qcell_w = 24;           // ancho de una celda en la cola
qcell_h = 34;           // alto de los bloques de la cola
emo = "normal";         // emoción actual de Gepe-T
emo_base = "normal";    // emoción a la que vuelve
emo_timer = 0;

// --- Máquina de escribir de Gepe-T (misma lógica que obj_textbox) ---
msg_full = "";          // texto con los saltos de línea ya puestos
msg_len = 0;
msg_char = 0;           // letras visibles
msg_acc = 0;            // acumulador de velocidad
msg_spd = 1.2;          // letras por frame (obj_textbox usa 1)
msg_pause_timer = 0;
msg_pause_time = 10;    // obj_textbox usa 16
msg_snd_delay = 4;
msg_snd_count = 4;
msg_line_w = 350;       // mismo ancho que antes

fade_alpha = 0;
fade_dir = 0;       // 1: oscureciendo, -1: aclarando, 0: nada
fade_next = 0;
fade_speed = 0.09;  // más alto = más rápido (0.09 son unos 11 frames)

// --- Utilidades ---
arrays_equal = function(_a, _b) {
    for (var i = 0; i < array_length(_a); i++) {
        if (_a[i] != _b[i]) return false;
    }
    return true;
}

free_count = function() {
    var _n = 0;
    for (var i = 0; i < RAM_CELLS; i++) {
        if (mem[i] == -1) _n++;
    }
    return _n;
}

// ¿Cabe un proceso de tamaño _z en algún hueco de la memoria?
any_fit = function(_z) {
    for (var s = 0; s + _z <= RAM_CELLS; s++) {
        if (fits(mem, s, _z)) return true;
    }
    return false;
}

// --- ¿Caben _z celdas libres seguidas desde _s? ---
fits = function(_m, _s, _z) {
    if (_s < 0 || _s + _z > RAM_CELLS) return false;
    for (var i = _s; i < _s + _z; i++) {
        if (_m[i] != -1) return false;
    }
    return true;
}

// --- Compactar: los procesos se pegan a la izquierda dentro de cada zona ---
// Los anclados no se mueven ni se cruzan: dividen la memoria en zonas
compact_array = function(_m) {
    var _r = array_create(RAM_CELLS, -1);
    var i = 0;
    while (i < RAM_CELLS) {
        if (_m[i] != -1 && procs[_m[i]].fixed) {
            _r[i] = _m[i];
            i++;
            continue;
        }
        // Zona: desde i hasta el siguiente bloque anclado
        var j = i;
        while (j < RAM_CELLS && !(_m[j] != -1 && procs[_m[j]].fixed)) j++;

        var _p = i;
        var _last = -1;
        for (var k = i; k < j; k++) {
            var _id = _m[k];
            if (_id != -1 && _id != _last) {
                for (var t = 0; t < procs[_id].size; t++) {
                    _r[_p] = _id;
                    _p++;
                }
            }
            _last = _id;
        }
        i = j;
    }
    return _r;
}

// --- Estados (para simular jugadas sin tocar el juego real) ---
cur_state = function() {
    return { m: mem, q: queue, c: comp_left };
}

// Devuelve el estado que resulta de colocar el primer proceso de la cola desde _start
place_state = function(_st, _start) {
    var _id = _st.q[0];
    var _m = array_create(RAM_CELLS, -1);
    for (var i = 0; i < RAM_CELLS; i++) _m[i] = _st.m[i];
    for (var i = _start; i < _start + procs[_id].size; i++) _m[i] = _id;

    var _q = [];
    for (var i = 1; i < array_length(_st.q); i++) array_push(_q, _st.q[i]);

    // Procesos que terminan y liberan su espacio
    var _placed = total_queue - array_length(_q);
    for (var e = 0; e < array_length(data.leave); e++) {
        if (data.leave[e].after == _placed) {
            for (var g = 0; g < array_length(data.leave[e].ids); g++) {
                var _gone = data.leave[e].ids[g];
                for (var m = 0; m < RAM_CELLS; m++) {
                    if (_m[m] == _gone) _m[m] = -1;
                }
            }
        }
    }
    return { m: _m, q: _q, c: _st.c };
}

// --- Actualiza la posición visual de cada proceso según la memoria ---
sync_slots = function() {
    for (var i = 0; i < array_length(procs); i++) {
        var _new = -1;
        for (var j = 0; j < RAM_CELLS; j++) {
            if (mem[j] == i) { _new = j; break; }
        }
        if (procs[i].slot == -1 && _new != -1) procs[i].dx = _new; // aparece de golpe
        procs[i].slot = _new;                                      // si ya estaba, se desliza
    }
}

// --- Parte el texto en líneas del ancho dado (usa "\n") ---
wrap_text = function(_txt, _w) {
    draw_set_font(global.font_main);
    var _out = "";
    var _line = "";
    var _word = "";
    var _n = string_length(_txt);
    for (var i = 1; i <= _n + 1; i++) {
        var _c = (i <= _n) ? string_char_at(_txt, i) : " ";
        if (_c == " ") {
            var _try = (_line == "") ? _word : _line + " " + _word;
            if (string_width(_try) > _w && _line != "") {
                _out += _line + "\n";
                _line = _word;
            } else {
                _line = _try;
            }
            _word = "";
        } else {
            _word += _c;
        }
    }
    return _out + _line;
}

gepet_voice = function() {
    var _base = 1;
    if (emo == "serio") _base = 0.9;        // más grave cuando está serio
    else if (emo == "feliz") _base = 1.08;  // más agudo cuando está feliz
    var _s = audio_play_sound(snd_voice_gepet, 8, false);
    audio_sound_pitch(_s, _base + random_range(-0.08, 0.08));
    audio_sound_gain(_s, 0.7, 0);
}

// --- Mensaje de Gepe-T con su emoción: "normal", "feliz", "error" o "serio" ---
set_msg = function(_txt, _emo) {
    if (dead_end && _txt != dead_msg) return; // sin salida: ningún otro mensaje lo pisa
    if (_txt == msg) return;                  // mismo mensaje: no se reinicia la escritura
    msg = _txt;
    msg_full = wrap_text(_txt, msg_line_w);
    msg_len = string_length(msg_full);
    msg_char = 0;
    msg_acc = 0;
    msg_pause_timer = 0;
    msg_snd_count = msg_snd_delay;
    emo = _emo;
    emo_base = _emo;
    emo_timer = 0;
}

// --- Emoción pasajera: dura _frames y luego vuelve a la del mensaje ---
flash_emo = function(_emo, _frames) {
    if (dead_end) return;
    emo = _emo;
    emo_timer = _frames;
}

// --- Cargar un nivel ---
load_level = function(_n) {
    level = _n;
    data = scr_ram_level(_n);
    mem = array_create(RAM_CELLS, -1);
    procs = [];
    queue = [];

    // Procesos que ya están en la memoria (su id es su posición en procs)
    for (var i = 0; i < array_length(data.pre); i++) {
        var _s = data.pre[i][0];
        var _z = data.pre[i][1];
        array_push(procs, { size: _z, k: array_length(procs), slot: -1, dx: 0, fixed: (data.pre[i][2] == 1), leave_after: -1, pop: 0, qx: 0 });
        for (var j = _s; j < _s + _z; j++) mem[j] = i;
    }
    // Procesos en espera (cola estricta: solo se usa el primero)
    for (var i = 0; i < array_length(data.queue); i++) {
        var _id = array_length(procs);
        array_push(procs, { size: data.queue[i], k: _id, slot: -1, dx: 0, fixed: false, leave_after: -1, pop: 0, qx: 0 });
        array_push(queue, _id);
    }

    // Procesos temporales: terminan tras N colocaciones
    for (var e = 0; e < array_length(data.leave); e++) {
        for (var g = 0; g < array_length(data.leave[e].ids); g++) {
            procs[data.leave[e].ids[g]].leave_after = data.leave[e].after;
        }
    }

    total_queue = array_length(queue);
	// Posición inicial de cada proceso en la cola (para que no aparezcan deslizando)
	var _tx = queue_x + 22;
	for (var i = 0; i < array_length(queue); i++) {
	    procs[queue[i]].qx = _tx;
	    _tx += procs[queue[i]].size * qcell_w + 6;
	}
    comp_left = data.comp;
    cur = 0;
    busy_timer = 0;
    pulse = false;
    btn_c_down = false;
    btn_r_down = false;
    state = "play";
    parts = [];
    board_shake = 0;
    tick_flash = 0;
	pin_t = 0;
	dot_t = 0;
    dead_end = false;
    sync_slots();
    set_msg(data.hint, (_n == RAM_LEVELS - 1) ? "serio" : "normal"); // el desafío final empieza serio
}

// --- Colocar el primer proceso de la cola al inicio del hueco elegido ---
place_selected = function() {
    if (array_length(queue) == 0) return;
    var _z = procs[queue[0]].size;

    if (!fits(mem, cur, _z)) {
	    board_shake = 12;
	    audio_play_sound(snd_ram_error, 1, false);
	    flash_emo("error", 30); // reacciona con la cara, sin hablar

	    var _any = any_fit(_z);
	    var _free = free_count();
	    // Solo explica la fragmentación la primera vez de cada nivel
	    if (!_any && _free >= _z) tell_once("frag", "Hay " + string(_free) + " celdas libres, pero no son contiguas. Un proceso necesita un bloque continuo.", "error", true);
	    return;
	}

    var _pid = queue[0];
    var _before = []; // procesos que están en la memoria antes de colocar
    for (var i = 0; i < array_length(procs); i++) {
        if (procs[i].slot != -1) array_push(_before, i);
    }

    var _next = place_state(cur_state(), cur);
    mem = _next.m;
    queue = _next.q;
    sync_slots();
	procs[_pid].pop = 10;

    // Chispas donde se colocó el proceso
    spawn_parts(cell_x0 + cur * cell_w, cell_y0, _z * cell_w, cell_h, 10, block_colors[_pid mod 8]);

    // Polvo donde un proceso terminó y se fue
    for (var i = 0; i < array_length(_before); i++) {
        var _gp = procs[_before[i]];
        if (_gp.slot == -1) spawn_parts(cell_x0 + _gp.dx * cell_w, cell_y0, _gp.size * cell_w, cell_h, 12, block_colors[_gp.k mod 8]);
    }
    audio_play_sound(snd_ram_place, 1, false);
    flash_emo("feliz", 45); // acierto

    var _placed = total_queue - array_length(queue);

    // ¿Terminan procesos en este turno?
    var _released = false;
    for (var e = 0; e < array_length(data.leave); e++) {
        if (data.leave[e].after == _placed) {
            _released = true;
            tell_once("release", "Algunos procesos terminaron y liberaron su memoria. Fíjate en los huecos que quedaron.", "normal");
        }
    }

    // ¿Quedan temporales en memoria con turnos pendientes? (el reloj que se ve en el bloque)
    var _min_steps = 999;
    for (var i = 0; i < array_length(procs); i++) {
        if (procs[i].slot != -1 && procs[i].leave_after > _placed) {
            _min_steps = min(_min_steps, procs[i].leave_after - _placed);
        }
    }

    if (_released) play_sfx(snd_ram_release, 1, 0.04);
    if (_min_steps < 999) {
        // El tic sube de tono cuanto menos turnos quedan
        play_sfx(snd_ram_tick, clamp(1.3 - _min_steps * 0.1, 0.8, 1.3), 0.02);
    }
    if (_released || _min_steps < 999) tick_flash = 16; // destello del turno

    check_state();
}

// --- ¿Ganó, quedó sin salida o necesita compactar? ---
check_state = function() {
    if (array_length(queue) == 0) {
        state = "win";
        dot_t = 30;
        audio_play_sound(snd_ram_win, 10, false);
        return;
    }

    dead_end = false;
    var _z = procs[queue[0]].size;
    if (any_fit(_z)) return; // hay dónde colocarlo: se sigue jugando

    // No cabe en ningún lado: ¿queda una compactación que cambie algo?
    var _can_compact = (comp_left > 0 && !arrays_equal(compact_array(mem), mem));
    if (!_can_compact) {
        audio_play_sound(snd_ram_deadend, 5, false);
        dead_end = true;
        set_msg(dead_msg, "serio");
        return;
    }

    // Aún se puede compactar: se avisa y parpadea el botón
    audio_play_sound(snd_ram_alert, 5, false);
    tell_once("alert", "Ningún hueco alcanza para el proceso de tamaño " + string(_z) + ": hay " + string(free_count()) + " celdas libres, pero fragmentadas. La compactación las uniría en un solo bloque.", "normal", true);
    pulse = true;
}

// --- Compactar no está permitido ---
deny_compact = function() {
    btn_shake = 12;
    audio_play_sound(snd_ram_denied, 1, false);
}

compact_memory = function() {
    if (state != "play" || busy_timer > 0) return;
    if (comp_left <= 0) { deny_compact(); return; }

    var _new = compact_array(mem);
    if (arrays_equal(_new, mem)) {
        btn_shake = 12;
        audio_play_sound(snd_ram_denied, 1, false);
        set_msg("No hay nada que reubicar: los procesos ya están contiguos.", "error");
        return;
    }

    var _has_fixed = false;
    for (var i = 0; i < array_length(procs); i++) {
        if (procs[i].fixed && procs[i].slot != -1) _has_fixed = true;
    }

    mem = _new;
    comp_left--;
    sync_slots();
    pulse = false;
    busy_timer = 25; // duración de la animación; no se juega mientras tanto
	pin_t = pin_t_total;
    audio_play_sound(snd_ram_compact, 1, false);

    if (_has_fixed) tell_once("compact_fixed", "Compactación hecha. La memoria reservada del sistema no se reubica.", "normal");
	else tell_once("compact", "Compactación hecha: los procesos se reubicaron y el espacio libre quedó en un solo bloque contiguo.", "normal");
    flash_emo("feliz", 60);
}

// --- Dibuja un proceso (_a = opacidad) ---
draw_block = function(_x, _y, _p, _a = 1) {
    var _w = _p.size * cell_w;
    var _steps = _p.leave_after - (total_queue - array_length(queue)); // pasos que le faltan para terminar
    var _temp = (_p.leave_after > 0 && _steps > 0);
	
	var _g = (_p.pop > 6) ? 3 : ((_p.pop > 3) ? 2 : ((_p.pop > 0) ? 1 : 0)); // píxeles extra por lado

    draw_set_alpha(_a);
    draw_sprite_stretched_ext(_temp ? spr_ram_block_temp : spr_ram_block_base, 0, _x - _g, _y - _g, _w + _g * 2, cell_h + _g * 2, block_colors[_p.k mod 8], _a);

    // Paso del tiempo: destello al pasar el turno y latido en el último turno
    if (_temp) {
        var _glow = (tick_flash / 16) * 0.6;
        if (_steps == 1) _glow = max(_glow, 0.15 + 0.15 * sin(current_time / 150));
        if (_glow > 0) {
            gpu_set_blendmode(bm_add);
            draw_sprite_stretched_ext(spr_ram_block_temp, 0, _x, _y, _w, cell_h, c_white, _glow * _a);
            gpu_set_blendmode(bm_normal);
        }
    }

    draw_set_halign(fa_center);
    draw_set_colour(ink_col);

    if (_temp) {
        // Ícono arriba y, abajo, reloj con los pasos que faltan
        var _bounce = (tick_flash > 11) ? -1 : 0; // el reloj salta al pasar el turno
        draw_sprite(spr_ram_process_icons, _p.k mod 8, floor(_x + _w / 2 - 8), _y + 8);
        var _tw = string_width(string(_steps));
        var _cx = floor(_x + _w / 2 - (12 + 2 + _tw) / 2);
        draw_sprite(spr_ram_icon_clock, 0, _cx, _y + 30 + _bounce);
        draw_set_halign(fa_left);
        draw_set_colour(c_white);
        draw_text(_cx + 14, _y + 31 + _bounce, string(_steps));
    } else {
        draw_sprite(spr_ram_process_icons, _p.k mod 8, floor(_x + _w / 2 - 8), _y + 13);
        draw_text(floor(_x + _w / 2), _y + 33, string(_p.size));
    }

    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_alpha(1);
}

draw_queue_block = function(_x, _y, _p, _a) {
    var _w = _p.size * qcell_w;
    draw_set_alpha(_a);
    draw_sprite_stretched_ext(spr_ram_block_base, 0, _x, _y, _w, qcell_h, block_colors[_p.k mod 8], _a);
    draw_sprite(spr_ram_process_icons, _p.k mod 8, floor(_x + _w / 2 - 8), _y + 4);
    draw_set_font(fnt_main_small);
    draw_set_halign(fa_center);
    draw_set_colour(ink_col);
    draw_text(floor(_x + _w / 2), _y + 19, string(_p.size));
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_font(global.font_main);
    draw_set_alpha(1);
}

// --- Efecto con pitch: _pitch = base (1 = normal), _var = variación aleatoria ---
play_sfx = function(_snd, _pitch = 1, _var = 0.03) {
    var _s = audio_play_sound(_snd, 5, false);
    audio_sound_pitch(_s, _pitch + random_range(-_var, _var));
}

// --- Partículas ---
parts = [];
spawn_parts = function(_x, _y, _w, _h, _n, _col) {
    for (var i = 0; i < _n; i++) {
        array_push(parts, {
            x: _x + random(_w), y: _y + random(_h),
            vx: random_range(-0.8, 0.8), vy: random_range(-1.2, -0.2),
            life: 0, max_life: irandom_range(18, 30), col: _col
        });
    }
}

// --- Avisos que se dicen una sola vez ---
told = {};
tell_once = function(_key, _txt, _emo, _each_level = false) {
    var _k = _each_level ? _key + string(level) : _key; // true: una vez por nivel; false: una vez en todo el juego
    if (variable_struct_exists(told, _k)) return;
    variable_struct_set(told, _k, true);
    set_msg(_txt, _emo);
}

// --- Actualización por frame (las usa el evento Step) ---
update_typewriter = function() {
    if (msg_pause_timer > 0) {
        msg_pause_timer--;
        return;
    }
    if (msg_char >= msg_len) return;

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
        if (_c == "\n") continue;

        if (msg_snd_count < msg_snd_delay) msg_snd_count++;
        else {
            msg_snd_count = 0;
            gepet_voice();
        }
    }
}

update_timers = function() {
    if (btn_shake > 0) btn_shake--;
    if (tick_flash > 0) tick_flash--;
    if (board_shake > 0) board_shake--;
    if (pin_t > 0) pin_t--;
    if (dot_t > 0) dot_t--;

    if (emo_timer > 0) {
        emo_timer--;
        if (emo_timer == 0) emo = emo_base;
    }
}

// Los procesos se deslizan a su sitio y la cola a su lugar
update_slides = function() {
    for (var i = 0; i < array_length(procs); i++) {
        var _p = procs[i];
        if (_p.pop > 0) _p.pop--;
        if (_p.slot == -1) continue;

        _p.dx = lerp(_p.dx, _p.slot, 0.15);
        if (abs(_p.dx - _p.slot) < 0.02) _p.dx = _p.slot;

        // Estela mientras se compacta
        if (busy_timer > 0 && abs(_p.dx - _p.slot) > 0.1) {
            spawn_parts(cell_x0 + (_p.dx + _p.size) * cell_w, cell_y0 + 8, 4, cell_h - 16, 1, block_colors[_p.k mod 8]);
        }
    }

    var _qtx = queue_x + 22;
    for (var i = 0; i < array_length(queue); i++) {
        var _qp = procs[queue[i]];
        _qp.qx = lerp(_qp.qx, _qtx, 0.25);
        if (abs(_qp.qx - _qtx) < 0.3) _qp.qx = _qtx;
        _qtx += _qp.size * qcell_w + 6;
    }
}

// Mueve las partículas y borra las que terminaron
update_particles = function() {
    for (var i = array_length(parts) - 1; i >= 0; i--) {
        var _q = parts[i];
        _q.x += _q.vx;
        _q.y += _q.vy;
        _q.vy += 0.04; // caen un poco
        _q.life++;
        if (_q.life >= _q.max_life) array_delete(parts, i, 1);
    }
}

// Transición entre niveles. Devuelve true mientras dura (sin input)
update_fade = function() {
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
    return fade_dir != 0;
}

// Cursor: da la vuelta y se repite al mantener apretado
move_cursor = function() {
    var _hi = RAM_CELLS - ((array_length(queue) > 0) ? procs[queue[0]].size : 1); // el proceso entero dentro del tablero
    var _count = _hi + 1;
    cur = clamp(cur, 0, _hi); // por si el siguiente proceso tiene otro tamaño

    var _dir = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
    var _move = 0;
    if (_dir == 0) {
        hold_t = 0;
    }
    else if (_dir != hold_dir) {
        hold_t = 0;                    // pulsación nueva: se mueve una celda
        _move = _dir;
    }
    else {
        hold_t++;                      // se mantiene apretado
        if (hold_t >= hold_delay && (hold_t - hold_delay) mod hold_rate == 0) _move = _dir;
    }
    hold_dir = _dir;

    if (_move != 0) {
        cur = (cur + _move + _count) mod _count;
        // Suena en la pulsación y en una de cada dos repeticiones, para no saturar
        if (hold_t == 0 || ((hold_t - hold_delay) div hold_rate) mod 2 == 0) play_sfx(snd_ram_move, 0.9 + cur * 0.03, 0.01);
    }
}

// Colocar (Z) y botones Compactar (C) y Reiniciar (R): se hunden al apretar y actúan al soltar
play_input = function(_accept) {
    if (_accept) place_selected();

    if (keyboard_check_pressed(ord("C"))) {
        if (comp_left <= 0) deny_compact();
        else { btn_c_down = true; audio_play_sound(snd_ram_button, 5, false); }
    }
    if (btn_c_down && keyboard_check_released(ord("C"))) {
        btn_c_down = false;
        compact_memory();
    }

    if (keyboard_check_pressed(ord("R"))) { btn_r_down = true; play_sfx(snd_ram_button, 1.1, 0.02); }
    if (btn_r_down && keyboard_check_released(ord("R"))) {
        btn_r_down = false;
        load_level(level);
    }
}

// --- Dibujo (las usa el evento Draw GUI) ---
shake_offset = function(_t) {
    if (_t <= 0) return 0;
    return ((_t div 2) mod 2 == 0) ? -2 : 2;
}

// Pantalla oscurecida con alpha _alpha
gui_shade = function(_alpha) {
    draw_set_alpha(_alpha);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, 480, 270, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

// Fondo, placa y brillo recorriendo los contactos dorados al compactar
gui_board = function() {
    draw_sprite(spr_ram_bg, 0, 0, 0);
    draw_sprite(spr_ram_board, 0, board_x, board_y);

    if (pin_t > 0) {
        var _bw = sprite_get_width(spr_ram_board);
        var _ww = 48; // ancho de la franja de luz
        var _pos = lerp(-_ww, _bw, 1 - pin_t / pin_t_total);
        gpu_set_blendmode(bm_add);
        for (var _s = 0; _s < _ww; _s += 4) {
            var _lx = _pos + _s;
            if (_lx < 0 || _lx + 4 > _bw) continue;
            var _al = sin(pi * (_s + 2) / _ww) * 0.8; // más fuerte al centro de la franja
            draw_sprite_part_ext(spr_ram_board, 0, _lx, pin_y, 4, pin_h, board_x + _lx, board_y + pin_y, 1, 1, c_white, _al);
        }
        gpu_set_blendmode(bm_normal);
    }
}

// Título y nombre del nivel
gui_title = function() {
    var _lvl = "Nivel " + string(level + 1) + " :";
    var _name = " " + data.name;
    var _tw = string_width(_lvl) + 1 + string_width(_name) + 16; // +1 por la negrita
    draw_sprite_stretched(spr_ram_level, 0, 32, 4, _tw, 18);

    draw_set_colour(make_colour_rgb(126, 248, 203));
    draw_text(40, 5, _lvl);
    draw_text(41, 5, _lvl); // segunda pasada: negrita falsa
    draw_set_colour(c_white);
    draw_text(41 + string_width(_lvl), 5, _name);
}

// Celdas, procesos, reservas del sistema, cursor y partículas
gui_memory = function() {
    for (var c = 0; c < RAM_CELLS; c++) {
        draw_sprite(spr_ram_cell_free, 0, cell_x0 + c * cell_w, cell_y0);
    }

    for (var i = 0; i < array_length(procs); i++) {
        var _p = procs[i];
        if (_p.slot == -1) continue;
        var _px = cell_x0 + _p.dx * cell_w;
        if (!_p.fixed) {
            draw_block(_px, cell_y0, _p, 1);
        }
        else if (_p.size == 2) {
            draw_sprite(spr_ram_cell_system_x2, 0, _px, cell_y0);
        }
        else {
            for (var t = 0; t < _p.size; t++) draw_sprite(spr_ram_cell_system, 0, _px + t * cell_w, cell_y0);
        }
    }

    // Cursor: verde si el proceso cabe desde aquí, rojo si no
    if (state == "play" && array_length(queue) > 0) {
        var _z = procs[queue[0]].size;
        var _frame = (busy_timer > 0 || !fits(mem, cur, _z)) ? 1 : 0;
        var _csh = shake_offset(board_shake);
        for (var j = max(cur, 0); j < cur + _z && j < RAM_CELLS; j++) {
            var _ca = (mem[j] != -1) ? 0.35 : 1; // sobre un proceso: se ve lo de abajo
            draw_sprite_ext(spr_ram_cell_cursor, _frame, cell_x0 + j * cell_w + _csh, cell_y0, 1, 1, 0, c_white, _ca);
        }
    }

    for (var i = 0; i < array_length(parts); i++) {
        var _q = parts[i];
        var _pf = floor(_q.life / _q.max_life * sprite_get_number(spr_ram_particle));
        draw_sprite_ext(spr_ram_particle, _pf, floor(_q.x), floor(_q.y), 1, 1, 0, _q.col, 1);
    }
}

// Barra de estado (total 10 = 8 usables + 2 del sistema)
gui_status = function() {
    var _free = free_count();
    var _txt = ["Memoria total: " + string(RAM_CELLS), "Usada: " + string(RAM_CELLS - _free), "Libre: " + string(_free), "Compactaciones: " + string(comp_left)];
    draw_sprite_stretched(spr_ram_status_panel, 0, 32, 115, 416, 16);
    draw_set_font(fnt_main_small);
    draw_set_valign(fa_middle);

    var _col_w = 416 / 4;
    var _iw = sprite_get_width(spr_ram_status_icons);
    var _gap = 5; // espacio entre icono y texto
    for (var i = 0; i < 4; i++) {
        var _gw = _iw + _gap + string_width(_txt[i]);
        var _gx = floor(32 + _col_w * i + _col_w / 2 - _gw / 2);
        draw_sprite(spr_ram_status_icons, i, _gx, 118);
        draw_text(_gx + _iw + _gap, 123, _txt[i]);
    }

    // Separadores verticales ligeros entre columnas
    draw_set_alpha(0.3);
    for (var i = 1; i < 4; i++) {
        var _sx = floor(32 + _col_w * i);
        draw_rectangle(_sx, 119, _sx, 127, false);
    }
    draw_set_alpha(1);

    draw_set_font(global.font_main);
    draw_set_valign(fa_top);
}

// Cola de entrada: se ve toda, pero solo el primero se puede usar
gui_queue = function() {
    var _qy = 140;
    draw_sprite_stretched(spr_ram_queue_panel, 0, queue_x, 134, 416, 46);
    for (var i = 0; i < array_length(queue); i++) {
        var _p = procs[queue[i]];
        var _qx = floor(_p.qx);
        draw_queue_block(_qx, _qy, _p, (i == 0) ? 1 : 0.55);
        if (i == 0) {
            var _w = _p.size * qcell_w;
            var _sf = floor(current_time / 1000 * 6) mod sprite_get_number(spr_ram_queue_select);
            draw_sprite_stretched(spr_ram_queue_select, _sf, _qx - 3, _qy - 3, _w + 6, qcell_h + 6);
            // Flecha que apunta al primero (4 frames)
            var _af = floor(current_time / 1000 * 8) mod sprite_get_number(spr_ram_queue_next);
            draw_sprite(spr_ram_queue_next, _af, _qx + floor(_w / 2) - 4, _qy - 10);
        }
    }
}

// Botones Compactar y Reiniciar, y la ayuda de teclas
gui_buttons = function() {
    var _cf = 0;
    if (comp_left <= 0) _cf = 2;
    else if (btn_c_down || (pulse && (current_time div 300) mod 2 == 0)) _cf = 1;

    var _sx = shake_offset(btn_shake);
    var _cy = btn_c_down ? 2 : 0;
    var _ry = btn_r_down ? 2 : 0;

    // Sombras (desaparecen cuando el botón está hundido)
    if (!btn_c_down) draw_sprite_stretched_ext(spr_ram_button, 0, 32 + _sx, 186, 100, 20, c_black, 0.5);
    if (!btn_r_down) draw_sprite_stretched_ext(spr_ram_button, 0, 140, 186, 90, 20, c_black, 0.5);

    draw_sprite_stretched(spr_ram_button, _cf, 32 + _sx, 184 + _cy, 100, 20);
    draw_sprite_stretched(spr_ram_button, btn_r_down ? 1 : 0, 140, 184 + _ry, 90, 20);

    // Iconos y textos (se hunden junto con los botones)
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_sprite_ext(spr_ram_icon_compact, 0, 45 + _sx, 187 + _cy, 1, 1, 0, c_white, (comp_left <= 0) ? 0.5 : 1); // se apaga sin compactaciones
    draw_sprite(spr_ram_icon_restart, 0, 154, 187 + _ry);
    draw_text(91 + _sx, 193 + _cy, "Compactar");
    draw_text(195, 193 + _ry, "Reiniciar");
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);

    draw_set_font(fnt_main_small);
    var _x2 = 240 + max(string_width("A/D mover"), string_width("C compactar")) + 12; // segunda columna, con 12 px de separación
    draw_text(240, 183, "A/D Mover");
    draw_text(240, 193, "C Compactar");
    draw_text(_x2, 183, "Z Colocar");
    draw_text(_x2, 193, "R Reiniciar");
    draw_set_font(global.font_main);
}

// Gepe-T: cara con emoción a la izquierda y mensaje a la derecha
gui_gepet = function() {
    draw_sprite_stretched(spr_dialogue_box_gepet, 0, 32, 210, 416, 52);
    var _spr = spr_ram_gepet_normal; // "feliz" usa por ahora el mismo sprite que "normal"
    if (emo == "error") _spr = spr_ram_gepet_error;
    else if (emo == "serio") _spr = spr_ram_gepet_serio;
    var _talking = (msg_char < msg_len) && (msg_pause_timer <= 0);
    var _f = _talking ? (floor(current_time / 1000 * 6) mod sprite_get_number(_spr)) : 0; // boca abierta/cerrada a 6 fps
    draw_sprite(_spr, _f, 36, 211);
    draw_text_ext(90, 216, string_copy(msg_full, 1, msg_char), 12, 1000);
}

// Pantallas de victoria y final
gui_end = function() {
    gui_shade(0.75);
    draw_sprite_stretched(spr_ram_queue_panel, 0, 60, 60, 360, 150);
    draw_set_halign(fa_center);

    var _title, _body, _foot;
    if (state == "win") {
        _title = "¡Nivel completado!";
        _body = data.win + "\nAprendiste: " + data.learn;
        _foot = "Z: continuar";
    } else {
        _title = "Memorian vuelve a funcionar";
        _body = "¡Gracias por ordenar la memoria!";
        _foot = "Z: salir";
    }
    draw_text(240, 70, _title);
    draw_text_ext(240, 92, _body, 12, 330);
    draw_text(240, 190, _foot);
    draw_set_halign(fa_left);
}

// Puntos de nivel (van encima de la pantalla oscura de victoria)
gui_dots = function() {
    for (var i = 0; i < RAM_LEVELS; i++) {
        var _df = (i < level) ? 2 : ((i == level) ? 1 : 0); // completado, actual, pendiente
        var _dy = 0;
        if (i == level && state != "play") {
            _df = 2; // el nivel recién ganado ya se ve completado
            _dy = -floor(abs(sin((30 - dot_t) * 0.35)) * 6 * (dot_t / 30)); // rebote que se apaga
        }
        draw_sprite(spr_ram_level_dot, _df, 331 + i * 15, 8 + _dy);
    }
}

load_level(0);