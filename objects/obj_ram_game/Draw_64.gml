draw_set_font(global.font_main);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);

// --- Fondo y placa ---
draw_sprite(spr_ram_bg, 0, 0, 0);
draw_sprite(spr_ram_board, 0, board_x, board_y);

// --- Brillo recorriendo los contactos dorados al compactar ---
if (pin_t > 0) {
    var _gprog = 1 - pin_t / pin_t_total;
    var _gbw = sprite_get_width(spr_ram_board);
    var _gww = 48; // ancho de la franja de luz
    var _gpos = lerp(-_gww, _gbw, _gprog);
    gpu_set_blendmode(bm_add);
    for (var _gs = 0; _gs < _gww; _gs += 4) {
        var _glx = _gpos + _gs;
        if (_glx < 0 || _glx + 4 > _gbw) continue;
        var _gal = sin(pi * (_gs + 2) / _gww) * 0.8; // más fuerte al centro de la franja
        draw_sprite_part_ext(spr_ram_board, 0, _glx, pin_y, 4, pin_h, board_x + _glx, board_y + pin_y, 1, 1, c_white, _gal);
    }
    gpu_set_blendmode(bm_normal);
}

// --- Título y pasos de nivel ---
var _lvl = "Nivel " + string(level + 1) + " :";
var _name = " " + data.name;
var _tw = string_width(_lvl) + 1 + string_width(_name) + 16; // +1 por la negrita
draw_sprite_stretched(spr_ram_level, 0, 32, 4, _tw, 18);

draw_set_colour(make_colour_rgb(126, 248, 203));
draw_text(40, 5, _lvl);
draw_text(41, 5, _lvl); // segunda pasada: negrita falsa
draw_set_colour(c_white);
draw_text(41 + string_width(_lvl), 5, _name);

// --- Celdas: las 10 son libres; el sistema se dibuja como proceso fijo ---
for (var c = 0; c < RAM_CELLS; c++) {
    draw_sprite(spr_ram_cell_free, 0, cell_x0 + c * cell_w, cell_y0);
}

// --- Procesos y reservas del sistema ---
for (var i = 0; i < array_length(procs); i++) {
    var _p = procs[i];
    if (_p.slot == -1) continue;
    var _px = cell_x0 + _p.dx * cell_w;
    if (_p.fixed) {
        if (_p.size == 2) draw_sprite(spr_ram_cell_system_x2, 0, _px, cell_y0);
        else {
            for (var t = 0; t < _p.size; t++) draw_sprite(spr_ram_cell_system, 0, _px + t * cell_w, cell_y0);
        }
    } else {
        draw_block(_px, cell_y0, _p, 1);
    }
}

// --- Cursor: verde si el proceso cabe desde aquí, rojo si no ---
if (state == "play" && array_length(queue) > 0) {
    var _z = procs[queue[0]].size;
    var _frame = (busy_timer > 0 || !fits(mem, cur, _z)) ? 1 : 0;
    var _csh = 0;
    if (board_shake > 0) _csh = ((board_shake div 2) mod 2 == 0) ? -2 : 2;
    for (var j = max(cur, 0); j < cur + _z && j < RAM_CELLS; j++) {
        var _ca2 = (mem[j] != -1) ? 0.35 : 1; // sobre un proceso: se ve lo de abajo
        draw_sprite_ext(spr_ram_cell_cursor, _frame, cell_x0 + j * cell_w + _csh, cell_y0, 1, 1, 0, c_white, _ca2);
    }
}

// --- Partículas ---
for (var i = 0; i < array_length(parts); i++) {
    var _q = parts[i];
    var _pf = floor(_q.life / _q.max_life * sprite_get_number(spr_ram_particle));
    draw_sprite_ext(spr_ram_particle, _pf, floor(_q.x), floor(_q.y), 1, 1, 0, _q.col, 1);
}

// --- Barra de estado (total 10 = 8 usables + 2 del sistema) ---
var _free = free_count();
var _st_txt = ["Memoria total: " + string(RAM_CELLS), "Usada: " + string(RAM_CELLS - _free), "Libre: " + string(_free), "Compactaciones: " + string(comp_left)];
draw_sprite_stretched(spr_ram_status_panel, 0, 32, 115, 416, 16);
draw_set_font(fnt_main_small);
draw_set_valign(fa_middle);

var _col_w = 416 / 4;
var _iw = sprite_get_width(spr_ram_status_icons);
var _gap = 5; // espacio entre icono y texto
for (var i = 0; i < 4; i++) {
    var _gw = _iw + _gap + string_width(_st_txt[i]);
    var _gx = floor(32 + _col_w * i + _col_w / 2 - _gw / 2);
    draw_sprite(spr_ram_status_icons, i, _gx, 118);
    draw_text(_gx + _iw + _gap, 123, _st_txt[i]);
}

// Separadores verticales ligeros entre columnas
draw_set_alpha(0.3);
for (var i = 1; i < 4; i++) {
    var _sep_x = floor(32 + _col_w * i);
    draw_rectangle(_sep_x, 119, _sep_x, 127, false);
}
draw_set_alpha(1);

draw_set_font(global.font_main);
draw_set_valign(fa_top);

// --- Cola de entrada: se ve toda, pero solo el primero se puede usar ---
var _qy = 140;
draw_sprite_stretched(spr_ram_queue_panel, 0, queue_x, 134, 416, 46);
var _qx = queue_x + 22; // deja lugar a la flecha
for (var i = 0; i < array_length(queue); i++) {
    var _p = procs[queue[i]];
	_qx = floor(_p.qx);
    draw_queue_block(_qx, _qy, _p, (i == 0) ? 1 : 0.55);
    if (i == 0) {
        var _w = _p.size * qcell_w;
        var _sf = floor(current_time / 1000 * 6) mod sprite_get_number(spr_ram_queue_select);
		draw_sprite_stretched(spr_ram_queue_select, _sf, _qx - 3, _qy - 3, _w + 6, qcell_h + 6);
        // Flecha que apunta al primero (4 frames)
        var _af = floor(current_time / 1000 * 8) mod sprite_get_number(spr_ram_queue_next);
        draw_sprite(spr_ram_queue_next, _af, _qx + floor(_w / 2) - 4, _qy - 10);
    }
    _qx += _p.size * qcell_w + 6;
}

// --- Botones ---
var _cf = 0;
if (comp_left <= 0) _cf = 2;
else if (btn_c_down) _cf = 1;
else if (pulse && (current_time div 300) mod 2 == 0) _cf = 1;


var _sx = 0;
if (btn_shake > 0) _sx = ((btn_shake div 2) mod 2 == 0) ? -2 : 2;

var _cy = btn_c_down ? 2 : 0;
var _ry = btn_r_down ? 2 : 0;

// Sombras (desaparecen cuando el botón está hundido)
if (!btn_c_down) draw_sprite_stretched_ext(spr_ram_button, 0, 32 + _sx, 186, 100, 20, c_black, 0.5);
if (!btn_r_down) draw_sprite_stretched_ext(spr_ram_button, 0, 140, 186, 90, 20, c_black, 0.5);

draw_sprite_stretched(spr_ram_button, _cf, 32 + _sx, 184 + _cy, 100, 20);
draw_sprite_stretched(spr_ram_button, btn_r_down ? 1 : 0, 140, 184 + _ry, 90, 20);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
// Iconos dentro de los botones (se hunden junto con ellos)
var _ca = (comp_left <= 0) ? 0.5 : 1; // se apaga cuando no quedan compactaciones
draw_sprite_ext(spr_ram_icon_compact, 0, 45 + _sx, 187 + _cy, 1, 1, 0, c_white, _ca);
draw_sprite(spr_ram_icon_restart, 0, 154, 187 + _ry);

draw_text(91 + _sx, 193 + _cy, "Compactar");
draw_text(195, 193 + _ry, "Reiniciar");
draw_set_valign(fa_top);
draw_set_halign(fa_left);

draw_set_font(fnt_main_small);
var _c1 = max(string_width("A/D mover"), string_width("C compactar"));
var _x2 = 240 + _c1 + 12; // segunda columna, con 12 px de separación
draw_text(240, 183, "A/D Mover");
draw_text(240, 193, "C Compactar");
draw_text(_x2, 183, "Z Colocar");
draw_text(_x2, 193, "R Reiniciar");
draw_set_font(global.font_main);

// --- Gepe-T: cara con emoción a la izquierda y mensaje a la derecha ---
draw_sprite_stretched(spr_dialogue_box_gepet, 0, 32, 210, 416, 52);
var _gspr = spr_ram_gepet_normal;
if (emo == "error") _gspr = spr_ram_gepet_error;
else if (emo == "serio") _gspr = spr_ram_gepet_serio;
// "feliz" usa por ahora el mismo sprite que "normal"
var _talking = (msg_char < msg_len) && (msg_pause_timer <= 0);
var _gf = _talking ? (floor(current_time / 1000 * 6) mod sprite_get_number(_gspr)) : 0; // boca abierta/cerrada a 6 fps
draw_sprite(_gspr, _gf, 36, 211);
draw_text_ext(90, 216, string_copy(msg_full, 1, msg_char), 12, 1000);

// --- Pantallas de victoria y final ---
if (state != "play") {
    draw_set_alpha(0.75);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, 480, 270, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_sprite_stretched(spr_ram_queue_panel, 0, 60, 60, 360, 150);
    draw_set_halign(fa_center);

    var _title = "";
    var _body = "";
    var _foot = "Z: continuar";

    if (state == "win") {
        _title = "¡Nivel completado!";
        _body = data.win + "\nAprendiste: " + data.learn;
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

// --- Puntos de nivel (encima de la pantalla oscura de victoria) ---
for (var i = 0; i < RAM_LEVELS; i++) {
    var _df = (i < level) ? 2 : ((i == level) ? 1 : 0); // completado, actual, pendiente
    var _dy = 0;
    if (i == level && state != "play") {
        _df = 2; // el nivel recién ganado ya se ve completado
        _dy = -floor(abs(sin((30 - dot_t) * 0.35)) * 6 * (dot_t / 30)); // rebote que se apaga
    }
    draw_sprite(spr_ram_level_dot, _df, 331 + i * 15, 8 + _dy);
}

// --- Fundido ---
if (fade_alpha > 0) {
    draw_set_alpha(fade_alpha);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, 480, 270, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}