draw_set_font(global.font_main);
draw_set_valign(fa_top);
draw_set_halign(fa_center);

var _view_x = camera_get_view_x(VIEW);
var _view_y = camera_get_view_y(VIEW);
var _view_w = camera_get_view_width(VIEW);
var _view_h = camera_get_view_height(VIEW);

var _sel_col = make_colour_rgb(185, 248, 235); // #B9F8EB
var _center_x = _view_x + _view_w / 2;

// --- Oscurecer el fondo ---
draw_set_alpha(0.6);
draw_set_color(c_black);
draw_rectangle(_view_x, _view_y, _view_x + _view_w, _view_y + _view_h, false);
draw_set_alpha(1);
draw_set_color(c_white);

// --- Alto del bloque (pregunta + opciones) para centrarlo ---
var _header_h = 0;
if (menu_level == 2) {
    _header_h = string_height(confirm_msg) * text_scale + 16;
}
var _opts_h = string_height(option[0, 0]) * text_scale + (op_length - 1) * op_space;
var _start_y = _view_y + _view_h / 2 - (_header_h + _opts_h) / 2;

// --- Pregunta de confirmación (solo en el nivel 2) ---
if (menu_level == 2) {
    draw_text_transformed(_center_x, _start_y, confirm_msg, text_scale, text_scale, 0);
    _start_y += _header_h;
}

// --- Opciones ---
for (var i = 0; i < op_length; i++) {
    var _txt = option[menu_level, i];
    var _y = _start_y + op_space * i;
    var _c = c_white;
    if (pos == i) { _c = _sel_col; }

    draw_set_halign(fa_center);
    draw_text_transformed_colour(_center_x, _y, _txt, text_scale, text_scale, 0, _c, _c, _c, _c, 1);

    if (pos == i) {
        var _half_w = string_width(_txt) * text_scale / 2;
        draw_set_halign(fa_right);
        draw_text_transformed_colour(_center_x - _half_w - 4, _y, ">", text_scale, text_scale, 0, _c, _c, _c, _c, 1);
    }
}

// --- Ayuda fija abajo (siempre visible) ---
var _hs = 1; // escala pequeña y fija
var _parts = ["Z", " para confirmar,", " X", " para volver"];
var _cols = [make_colour_rgb(90, 220, 110), c_white, make_colour_rgb(240, 80, 80), c_white];

var _total_w = 0;
for (var j = 0; j < array_length(_parts); j++) {
    _total_w += string_width(_parts[j]) * _hs;
}

var _hx = _center_x - _total_w / 2;
var _hy = _view_y + _view_h - string_height("Z") * _hs - 8;

draw_set_halign(fa_left);
for (var j = 0; j < array_length(_parts); j++) {
    draw_text_transformed_colour(_hx, _hy, _parts[j], _hs, _hs, 0, _cols[j], _cols[j], _cols[j], _cols[j], 1);
    _hx += string_width(_parts[j]) * _hs;
}

draw_set_halign(fa_left);