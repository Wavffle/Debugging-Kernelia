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
    if (pos == i) {
        _c = _sel_col;
        // Parpadeo: alterna entre el color de selección y blanco
        if (blink_timer > 0 && floor(blink_timer / blink_speed) mod 2 == 1) {
            _c = c_white;
        }
    }

    draw_set_halign(fa_center);
    draw_text_transformed_colour(_center_x, _y, _txt, text_scale, text_scale, 0, _c, _c, _c, _c, 1);

    if (pos == i) {
        var _half_w = string_width(_txt) * text_scale / 2;
        draw_set_halign(fa_right);
        draw_text_transformed_colour(_center_x - _half_w - 4, _y, ">", text_scale, text_scale, 0, _c, _c, _c, _c, 1);
    }
}

// --- Ayuda fija abajo, con teclas en pixel art ---
var _gap = 4;          // espacio entre elementos
var _group_gap = 12;   // espacio extra entre "confirmar" y la siguiente tecla

var _green = make_colour_rgb(90, 220, 110);
var _red   = make_colour_rgb(240, 80, 80);

var _items = [
    { kind: "key", txt: "Z",         col: _green },
    { kind: "key", txt: "Enter",     col: _green },
    { kind: "txt", txt: "confirmar", col: c_white },
    { kind: "gap", txt: "",          col: c_white },
    { kind: "key", txt: "X",         col: _red },
    { kind: "key", txt: "Esc",       col: _red },
    { kind: "txt", txt: "volver",    col: c_white }
];
var _n = array_length(_items);

// Ancho total para centrar el conjunto
var _total_w = 0;
for (var j = 0; j < _n; j++) {
    var _it = _items[j];
    if (_it.kind == "key")      _total_w += keycap_width(_it.txt);
    else if (_it.kind == "txt") _total_w += string_width(_it.txt);
    else                        _total_w += _group_gap;
    if (j < _n - 1) _total_w += _gap;
}

var _key_h = keycap_height() + 2; // altura de la tecla + relieve
var _hx = _center_x - _total_w / 2;
var _hy = _view_y + _view_h - _key_h - 10;

draw_set_halign(fa_left);
draw_set_valign(fa_top);

for (var j = 0; j < _n; j++) {
    var _it = _items[j];
    if (_it.kind == "key") {
        draw_keycap(_hx, _hy, _it.txt, _it.col);
        _hx += keycap_width(_it.txt);
    } else if (_it.kind == "txt") {
        draw_set_colour(_it.col);
        draw_text(_hx, _hy + 1 - key_trim, _it.txt);
        _hx += string_width(_it.txt);
    } else {
        _hx += _group_gap;
    }
    _hx += _gap;
}

draw_set_colour(c_white);

draw_set_halign(fa_left);