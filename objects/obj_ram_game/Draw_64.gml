draw_set_font(global.font_main);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);

// --- Fondo y placa ---
draw_sprite(spr_ram_bg, 0, 0, 0);
draw_sprite(spr_ram_board, 0, board_x, board_y);

// --- Título y pasos de nivel ---
draw_text(32, 4, "Nivel " + string(level + 1) + ": " + data.name);
for (var i = 0; i < RAM_LEVELS; i++) {
    var _df = (i < level) ? 2 : ((i == level) ? 1 : 0); // completado, actual, pendiente
    draw_sprite(spr_ram_level_dot, _df, 331 + i * 15, 8);
}

// --- Celdas: 10 columnas, con el sistema en los extremos ---
for (var c = 0; c < 10; c++) {
    var _spr = (c == 0 || c == 9) ? spr_ram_cell_system : spr_ram_cell_free;
    draw_sprite(_spr, 0, cell_x0 + c * cell_w, cell_y0);
}

// --- Procesos y reservas del sistema ---
for (var i = 0; i < array_length(procs); i++) {
    var _p = procs[i];
    if (_p.slot == -1) continue;
    var _px = cell_x0 + (_p.dx + 1) * cell_w;
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
    var _frame = fits(mem, cur, _z) ? 0 : 1;
    for (var j = cur; j < cur + _z && j < 8; j++) {
        draw_sprite(spr_ram_cell_cursor, _frame, cell_x0 + (j + 1) * cell_w, cell_y0);
    }
}

// --- Barra de estado (total 10 = 8 usables + 2 del sistema) ---
var _free = free_count();
var _st_x = [40, 150, 250, 340];
var _st_txt = ["Memoria total: 10", "Usada: " + string(10 - _free), "Libre: " + string(_free), "Compactaciones: " + string(comp_left)];
draw_sprite_stretched(spr_ram_status_panel, 0, 32, 115, 416, 16);
draw_set_font(fnt_main_small);
draw_set_valign(fa_middle);
for (var i = 0; i < 4; i++) {
    draw_sprite(spr_ram_status_icons, i, _st_x[i], 118);
    draw_text(_st_x[i] + 14, 123, _st_txt[i]);
}
draw_set_font(global.font_main);
draw_set_valign(fa_top);

// --- Cola de entrada: se ve toda, pero solo el primero se puede usar ---
var _qy = 140;
draw_sprite_stretched(spr_ram_queue_panel, 0, queue_x, 134, 416, 46);
var _qx = queue_x + 22; // deja lugar a la flecha
for (var i = 0; i < array_length(queue); i++) {
    var _p = procs[queue[i]];
    draw_queue_block(_qx, _qy, _p, (i == 0) ? 1 : 0.55);
    if (i == 0) {
        var _w = _p.size * qcell_w;
        draw_set_colour(sel_col);
        draw_rectangle(_qx - 1, _qy - 1, _qx + _w, _qy + qcell_h, true);
        draw_rectangle(_qx - 2, _qy - 2, _qx + _w + 1, _qy + qcell_h + 1, true);
        draw_set_colour(c_white);
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
draw_text(82 + _sx, 194 + _cy, "Compactar");
draw_text(185, 194 + _ry, "Reiniciar");
draw_set_valign(fa_top);
draw_set_halign(fa_left);

draw_set_font(fnt_main_small);
draw_text_ext(240, 184, "A/D mover   Z colocar\nC compactar   R reiniciar", 10, 210);
draw_set_font(global.font_main);

// --- Gepe-T: cara con emoción a la izquierda y mensaje a la derecha ---
draw_sprite_stretched(spr_dialogue_box_gepet, 0, 32, 210, 416, 56);
var _gspr = spr_ram_gepet_normal;
if (emo == "error") _gspr = spr_ram_gepet_error;
else if (emo == "serio") _gspr = spr_ram_gepet_serio;
// "feliz" usa por ahora el mismo sprite que "normal"
var _talking = (msg_char < msg_len) && (msg_pause_timer <= 0);
var _gf = _talking ? (floor(current_time / 1000 * 6) mod sprite_get_number(_gspr)) : 0; // boca abierta/cerrada a 6 fps
draw_sprite(_gspr, _gf, 36, 214);
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
        _body = "Ramelia: ¡Gracias por ordenar la memoria!\nGepe-T: Espera... estos fallos no parecen naturales. Alguien los provocó. ¿Será el BUG?";
        _foot = "Z: salir";
    }

    draw_text(240, 70, _title);
    draw_text_ext(240, 92, _body, 12, 330);
    draw_text(240, 190, _foot);
    draw_set_halign(fa_left);
}