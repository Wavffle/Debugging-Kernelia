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
busy_timer = 0;
pulse = false;
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

// --- Utilidades ---
arrays_equal = function(_a, _b) {
    for (var i = 0; i < array_length(_a); i++) {
        if (_a[i] != _b[i]) return false;
    }
    return true;
}

free_count = function() {
    var _n = 0;
    for (var i = 0; i < 8; i++) {
        if (mem[i] == -1) _n++;
    }
    return _n;
}

// --- ¿Caben _z celdas libres seguidas desde _s? ---
fits = function(_m, _s, _z) {
    if (_s < 0 || _s + _z > 8) return false;
    for (var i = _s; i < _s + _z; i++) {
        if (_m[i] != -1) return false;
    }
    return true;
}

// --- Compactar: los procesos se pegan a la izquierda dentro de cada zona ---
// Los anclados no se mueven ni se cruzan: dividen la memoria en zonas
compact_array = function(_m) {
    var _r = array_create(8, -1);
    var i = 0;
    while (i < 8) {
        if (_m[i] != -1 && procs[_m[i]].fixed) {
            _r[i] = _m[i];
            i++;
            continue;
        }
        // Zona: desde i hasta el siguiente bloque anclado
        var j = i;
        while (j < 8 && !(_m[j] != -1 && procs[_m[j]].fixed)) j++;

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
    var _m = array_create(8, -1);
    for (var i = 0; i < 8; i++) _m[i] = _st.m[i];
    for (var i = _start; i < _start + procs[_id].size; i++) _m[i] = _id;

    var _q = [];
    for (var i = 1; i < array_length(_st.q); i++) array_push(_q, _st.q[i]);

    // Procesos que terminan y liberan su espacio
    var _placed = total_queue - array_length(_q);
    for (var e = 0; e < array_length(data.leave); e++) {
        if (data.leave[e].after == _placed) {
            for (var g = 0; g < array_length(data.leave[e].ids); g++) {
                var _gone = data.leave[e].ids[g];
                for (var m = 0; m < 8; m++) {
                    if (_m[m] == _gone) _m[m] = -1;
                }
            }
        }
    }
    return { m: _m, q: _q, c: _st.c };
}

state_key = function(_st) {
    var _k = "";
    for (var i = 0; i < 8; i++) _k += string(_st.m[i]) + ",";
    return _k + "|" + string(array_length(_st.q)) + "|" + string(_st.c);
}

// --- ¿Se puede ganar desde este estado? (prueba todas las jugadas posibles) ---
solvable = function(_st, _memo) {
    if (array_length(_st.q) == 0) return true;

    var _key = state_key(_st);
    if (variable_struct_exists(_memo, _key)) return variable_struct_get(_memo, _key);
    variable_struct_set(_memo, _key, false);

    var _z = procs[_st.q[0]].size;
	for (var s = 0; s + _z <= 8; s++) {
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
        for (var j = 0; j < 8; j++) {
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

// --- Mensaje de Gepe-T con su emoción: "normal", "feliz", "error" o "serio" ---
set_msg = function(_txt, _emo) {
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
    emo = _emo;
    emo_timer = _frames;
}

// --- Cargar un nivel ---
load_level = function(_n) {
    level = _n;
    data = scr_ram_level(_n);
    mem = array_create(8, -1);
    procs = [];
    queue = [];

    // Procesos que ya están en la memoria (su id es su posición en procs)
    for (var i = 0; i < array_length(data.pre); i++) {
        var _s = data.pre[i][0];
        var _z = data.pre[i][1];
        array_push(procs, { size: _z, k: array_length(procs), slot: -1, dx: 0, fixed: (data.pre[i][2] == 1), leave_after: -1 });
        for (var j = _s; j < _s + _z; j++) mem[j] = i;
    }
    // Procesos en espera (cola estricta: solo se usa el primero)
    for (var i = 0; i < array_length(data.queue); i++) {
        var _id = array_length(procs);
        array_push(procs, { size: data.queue[i], k: _id, slot: -1, dx: 0, fixed: false, leave_after: -1 });
        array_push(queue, _id);
    }

    // Procesos temporales: terminan tras N colocaciones
    for (var e = 0; e < array_length(data.leave); e++) {
        for (var g = 0; g < array_length(data.leave[e].ids); g++) {
            procs[data.leave[e].ids[g]].leave_after = data.leave[e].after;
        }
    }

    total_queue = array_length(queue);
    comp_left = data.comp;
    cur = 0;
    busy_timer = 0;
    pulse = false;
    btn_c_down = false;
    btn_r_down = false;
    state = "play";
    sync_slots();
    set_msg(data.hint, (_n == RAM_LEVELS - 1) ? "serio" : "normal"); // el desafío final empieza serio
}

// --- Colocar el primer proceso de la cola al inicio del hueco elegido ---
place_selected = function() {
    if (array_length(queue) == 0) return;
    var _z = procs[queue[0]].size;

    if (!fits(mem, cur, _z)) {
        audio_play_sound(snd_menu_back, 1, false);
        var _any = false;
        for (var s = 0; s + _z <= 8; s++) {
            if (fits(mem, s, _z)) _any = true;
        }
        var _free = free_count();
        if (_any) set_msg("Ahí no cabe, pero hay espacio seguido en otro lugar.", "error");
        else if (_free >= _z) set_msg("Hay " + string(_free) + " espacios libres, pero no están juntos. Un proceso necesita todo su espacio seguido.", "error");
        else set_msg("No queda espacio suficiente para este proceso.", "error");
        return;
    }

    var _next = place_state(cur_state(), cur);
    mem = _next.m;
    queue = _next.q;
    sync_slots();
    audio_play_sound(snd_menu_select, 1, false);
    flash_emo("feliz", 45); // acierto

    var _placed = total_queue - array_length(queue);
    for (var e = 0; e < array_length(data.leave); e++) {
        if (data.leave[e].after == _placed) {
            set_msg("¡Algunos procesos terminaron y liberaron su espacio! Mira cómo quedó la memoria.", "normal");
        }
    }

    check_state();
}

// --- ¿Ganó, quedó sin salida o necesita compactar? ---
check_state = function() {
    if (array_length(queue) == 0) {
        state = "win";
        return;
    }

    if (!solvable(cur_state(), {})) {
        set_msg("Este camino ya no tiene salida. Reinicia el nivel con R: no hay penalización.", "serio");
        return;
    }

    var _z = procs[queue[0]].size;
    var _fits = false;
    for (var s = 0; s + _z <= 8; s++) {
        if (fits(mem, s, _z)) _fits = true;
    }
    if (!_fits) {
        set_msg("Ningún hueco alcanza para el proceso de tamaño " + string(_z) + ": hay " + string(free_count()) + " celdas libres, pero repartidas. Prueba a compactar (C).", "normal");
        pulse = true;
    }
}

// --- Compactar no está permitido ---
deny_compact = function() {
    btn_shake = 12;
    audio_play_sound(snd_menu_back, 1, false);
    if (data.comp == 0) set_msg("En este nivel todavía no se puede compactar.", "serio");
    else set_msg("Ya usaste la compactación de este nivel.", "serio");
}

compact_memory = function() {
    if (state != "play" || busy_timer > 0) return;
    if (comp_left <= 0) { deny_compact(); return; }

    var _new = compact_array(mem);
    if (arrays_equal(_new, mem)) {
        btn_shake = 12;
        audio_play_sound(snd_menu_back, 1, false);
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
    busy_timer = 50; // duración de la animación; no se juega mientras tanto
    audio_play_sound(snd_menu_select, 1, false);

    if (_has_fixed) set_msg("Compactación lista. Las celdas del sistema no se movieron: solo se juntó lo que hay entre ellas.", "normal");
    else set_msg("¡Mira cómo se juntan! Ahora el espacio libre está todo seguido.", "normal");
    flash_emo("feliz", 60);
}

// --- Dibuja un proceso (_a = opacidad) ---
draw_block = function(_x, _y, _p, _a = 1) {
    var _w = _p.size * cell_w;
    var _steps = _p.leave_after - (total_queue - array_length(queue)); // pasos que le faltan para terminar
    var _temp = (_p.leave_after > 0 && _steps > 0);

    draw_set_alpha(_a);
    draw_sprite_stretched_ext(_temp ? spr_ram_block_temp : spr_ram_block_base, 0, _x, _y, _w, cell_h, block_colors[_p.k mod 8], _a);
    draw_set_halign(fa_center);
    draw_set_colour(ink_col);

	if (_temp) {
	    // Ícono arriba y, abajo, reloj con los pasos que faltan
	    draw_sprite(spr_ram_process_icons, _p.k mod 8, floor(_x + _w / 2 - 8), _y + 8);
	    var _tw = string_width(string(_steps));
	    var _cx = floor(_x + _w / 2 - (12 + 2 + _tw) / 2);
	    draw_sprite(spr_ram_icon_clock, 0, _cx, _y + 30);
	    draw_set_halign(fa_left);
	    draw_set_colour(c_white);   // <- nuevo: número en blanco
	    draw_text(_cx + 14, _y + 31, string(_steps));
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
    draw_sprite(spr_ram_process_icons, _p.k mod 8, floor(_x + _w / 2 - 8), _y + 3);
    draw_set_font(fnt_main_small);
    draw_set_halign(fa_center);
    draw_set_colour(ink_col);
    draw_text(floor(_x + _w / 2), _y + 20, string(_p.size));
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_font(global.font_main);
    draw_set_alpha(1);
}

load_level(0);