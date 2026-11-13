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
tick_flash = 0;         // destello de los procesos temporales al pasar el turno
pin_t = 0;          // animación de los contactos dorados al compactar
pin_t_total = 40;   // duración en frames
pin_y = 74;         // fila de spr_ram_board donde empiezan los contactos dorados
pin_h = 10;         // alto de esa franja
dot_t = 0;          // rebote del punto de nivel al ganar
busy_timer = 0;
pulse = false;
dead_end = false;
dead_msg = "Este camino ya no tiene salida. Mejor reintentamos.";
msg = "";
state = "play";

qcell_w = 24;           // ancho de una celda en la cola
qcell_h = 34;           // alto de los bloques de la cola
emo = "normal";         // emoción actual de Gepe-T
emo_base = "normal";    // emoción a la que vuelve
emo_timer = 0;
talk_timer = 0;         // mientras es > 0, Gepe-T mueve la boca

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

state_key = function(_st) {
    var _k = "";
    for (var i = 0; i < RAM_CELLS; i++) _k += string(_st.m[i]) + ",";
    return _k + "|" + string(array_length(_st.q)) + "|" + string(_st.c);
}

// --- ¿Se puede ganar desde este estado? (prueba todas las jugadas posibles) ---
solvable = function(_st, _memo) {
    if (array_length(_st.q) == 0) return true;

    var _key = state_key(_st);
    if (variable_struct_exists(_memo, _key)) return variable_struct_get(_memo, _key);
    variable_struct_set(_memo, _key, false);

    var _z = procs[_st.q[0]].size;
    for (var s = 0; s + _z <= RAM_CELLS; s++) {
        if (fits(_st.m, s, _z) && solvable(place_state(_st, s), _memo)) {
            variable_struct_set(_memo, _key, true);
            return true;
        }
    }

    if (_st.c > 0) {
        var _cm = compact_array(_st.m);
        if (!arrays_equal(_cm, _st.m) && solvable({ m: _cm, q: _st.q, c: _st.c - 1 }, _memo)) {
            variable_struct_set(_memo, _key, true);
            return true;
        }
    }
    return false;
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

	    var _any = false;
	    for (var s = 0; s + _z <= RAM_CELLS; s++) {
	        if (fits(mem, s, _z)) _any = true;
	    }
	    var _free = free_count();
	    // Solo explica la fragmentación la primera vez de cada nivel
	    if (!_any && _free >= _z) tell_once("frag", "Hay " + string(_free) + " espacios libres, pero no están juntos. Un proceso necesita todo su espacio seguido.", "error", true);
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
            tell_once("release", "¡Algunos procesos terminaron y liberaron su espacio! Mira cómo quedó la memoria.", "normal");
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
    var _fits = false;
    for (var s = 0; s + _z <= RAM_CELLS; s++) {
        if (fits(mem, s, _z)) _fits = true;
    }
    if (_fits) return; // hay dónde colocarlo: se sigue jugando

    // No cabe en ningún lado: ¿queda una compactación que cambie algo?
    var _can_compact = (comp_left > 0 && !arrays_equal(compact_array(mem), mem));
    if (!_can_compact) {
        if (!dead_end) audio_play_sound(snd_ram_deadend, 5, false);
        dead_end = true;
        set_msg(dead_msg, "serio");
        return;
    }

    // Aún se puede compactar: se avisa y parpadea el botón
    audio_play_sound(snd_ram_alert, 5, false);
    tell_once("alert", "Ningún hueco alcanza para el proceso de tamaño " + string(_z) + ": hay " + string(free_count()) + " celdas libres, pero repartidas. Prueba a compactar (C).", "normal", true);
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
        set_msg("No hay nada que compactar: los procesos ya están juntos.", "error");
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

    if (_has_fixed) tell_once("compact_fixed", "Compactación lista. Las celdas del sistema no se movieron: solo se juntó lo que hay entre ellas.", "normal");
	else tell_once("compact", "¡Mira cómo se juntan! Ahora el espacio libre está todo seguido.", "normal");
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

load_level(0);