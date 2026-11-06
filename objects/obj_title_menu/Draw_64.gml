// --- Cielo ---
gpu_set_texfilter(true);
draw_sprite_stretched(spr_title_sky, 0, 0, 0, GUI_W, GUI_H);
gpu_set_texfilter(false);

// --- Nubes (encima del cielo, detrás del paisaje) ---
gpu_set_texfilter(clouds_filter);
for (var i = 0; i < array_length(clouds); i++) {
    var _cl = clouds[i];
    draw_sprite_ext(_cl.spr, 0, floor(_cl.x), _cl.y, _cl.scale, _cl.scale, 0, c_white, _cl.alpha);
}
gpu_set_texfilter(false);

// --- Paisaje (cielo transparente, tapa las nubes en las montañas) ---
gpu_set_texfilter(true);
draw_sprite_stretched(spr_title_land, 0, 0, 0, GUI_W, GUI_H);
gpu_set_texfilter(false);

// --- Logo en alta resolución ---
var _cx = GUI_W / 2;
gpu_set_texfilter(true);
draw_sprite_ext(spr_title_logo, 0, _cx, logo_y, logo_scale, logo_scale, 0, c_white, 1);
gpu_set_texfilter(false);

// --- Opciones ---
draw_set_font(fnt_title);
draw_set_valign(fa_top);
draw_set_halign(fa_center);

var _sel_col = make_colour_rgb(185, 248, 235); // #B9F8EB

for (var i = 0; i < op_length; i++) {
    var _txt = option[menu_level, i];
    var _y = floor(menu_y + op_space * i);
    var _c = c_white;
    var _a = unselected_alpha;
    var _grad = false;

    // ¿Es "Nueva Partida" del menú principal y está seleccionada?
    var _is_main = (pos == i && menu_level == 0 && i == 0);

    if (pos == i) {
        _c = _sel_col;
        _a = 1;
        _grad = _is_main;

        // Parpadeo: alterna entre el color normal y blanco
        if (blink_timer > 0 && floor(blink_timer / blink_speed) mod 2 == 1) {
            _c = c_white;
            _grad = false;
        }
    }

    var _w = spaced_width(_txt);
    var _left = floor(_cx - _w / 2);
    draw_text_outline(_left, _y, _txt, _c, _a, _grad);

    // Indicadores a ambos lados de la opción seleccionada
    if (pos == i) {
        draw_text_outline(_left - indicator_gap - spaced_width(">"), _y, ">", _c, 1, _grad);
        draw_text_outline(_left + _w + indicator_gap, _y, "<", _c, 1, _grad);
    }
}

draw_set_halign(fa_left);