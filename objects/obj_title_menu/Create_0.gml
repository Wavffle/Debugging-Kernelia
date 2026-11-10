menu_level = 0;
pos = 0;

// Menú principal
option[0, 0] = "Nueva Partida";
option[0, 1] = "Continuar";
option[0, 2] = "Opciones";
option[0, 3] = "Salir";

// Opciones (mismo contenido que en el menú de pausa)
option[1, 0] = "Tamaño de la Ventana";
option[1, 1] = "Sonido";
option[1, 2] = "Controles";
option[1, 3] = "Volver";

op_length = array_length(option[menu_level]);

// Posiciones (en coordenadas del GUI, 480x270)
op_space = 22;

// Parpadeo al seleccionar
blink_timer = 0;
blink_duration = 12;
blink_speed = 3;

letter_space = 1; // píxeles extra entre letras (prueba 1 o 2)
indicator_gap = 6; // separación entre el texto y los indicadores > <

logo_target_w = 235; // ancho del logo en pantalla (GUI), antes 280 * 0.84
logo_scale = logo_target_w / sprite_get_width(spr_title_logo);
logo_fps = 7;
logo_y = 25;
// El menú queda debajo del logo, con 20 px de separación
menu_y = floor(logo_y + sprite_get_height(spr_title_logo) * logo_scale + 14);

// Ancho de un texto con la separación extra
spaced_width = function(_txt) {
    var _w = 0;
    var _n = string_length(_txt);
    for (var i = 1; i <= _n; i++) {
        _w += string_width(string_char_at(_txt, i)) + letter_space;
    }
    return _w - letter_space;
}

unselected_alpha = 0.6; // opacidad de las opciones no seleccionadas (1 = normal)

shadow_col = make_colour_rgb(43, 64, 94);   // #2b405e
shadow_grad_col = make_colour_rgb(14, 22, 38); // sombra más oscura, solo para el degradado

// --- Degradado vertical de "Nueva Partida" ---
grad_white = c_white;
grad_cyan  = make_colour_rgb(55, 231, 222); // #37e7de

// Qué parte de la altura de la celda ocupa realmente la letra (0 = arriba, 1 = abajo).
// Rango más corto = degradado más marcado. Prueba valores entre 0.15 y 0.35 para el
// primero, y entre 0.65 y 0.85 para el segundo.
grad_ink_top = 0.2;
grad_ink_bottom = 0.8;

// Color en un punto del degradado: 0 = blanco, 1 = celeste (admite valores fuera de 0..1)
grad_color_at = function(_g) {
    var _r = clamp(lerp(255, 55, _g), 0, 255);
    var _gr = clamp(lerp(255, 231, _g), 0, 255);
    var _b = clamp(lerp(255, 222, _g), 0, 255);
    return make_colour_rgb(_r, _gr, _b);
}

// Colores de las esquinas, calculados para que el blanco quede arriba de la letra y
// el celeste abajo, y no en los bordes de la celda
var _span = grad_ink_bottom - grad_ink_top;
grad_top    = grad_color_at(-grad_ink_top / _span);
grad_bottom = grad_color_at((1 - grad_ink_top) / _span);

// _t va de 0 (inicio de la palabra) a 1 (final): blanco -> celeste -> azul
gradient_color = function(_t) {
    _t = clamp(_t, 0, 1);
    if (_t < 0.5) return merge_colour(grad_white, grad_cyan, _t * 2);
    return merge_colour(grad_cyan, grad_blue, (_t - 0.5) * 2);
}

// --- Animación del degradado de "Nueva Partida" ---
grad_scroll_speed = 6; // velocidad: px del GUI por segundo (hacia abajo)
grad_period = 16;       // alto de un ciclo blanco -> celeste -> blanco (px del GUI)
grad_steps = 4;         // niveles de color: 4 = escalonado pixel art, 0 = degradado suave

u_grad_offset = shader_get_uniform(shd_title_gradient, "u_offset");
u_grad_period = shader_get_uniform(shd_title_gradient, "u_period");
u_grad_steps  = shader_get_uniform(shd_title_gradient, "u_steps");
u_grad_col_a  = shader_get_uniform(shd_title_gradient, "u_col_a");
u_grad_col_b  = shader_get_uniform(shd_title_gradient, "u_col_b");

// Dibuja un texto desde su borde izquierdo, con sombra de 1 px y letras separadas
draw_text_outline = function(_left, _y, _txt, _col, _alpha, _gradient) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(_alpha);

    var _n = string_length(_txt);

    // Pasada 1: sombras
    draw_set_colour(shadow_col);
    var _px = _left;
    for (var i = 1; i <= _n; i++) {
        var _ch = string_char_at(_txt, i);
        draw_text(_px + 1, _y + 1, _ch);
        _px += string_width(_ch) + letter_space;
    }

    // Pasada 2: letras (con el shader si lleva degradado)
    if (_gradient) {
        shader_set(shd_title_gradient);
        shader_set_uniform_f(u_grad_offset, (current_time / 1000) * grad_scroll_speed);
        shader_set_uniform_f(u_grad_period, grad_period);
        shader_set_uniform_f(u_grad_steps, grad_steps);
        shader_set_uniform_f(u_grad_col_a, color_get_red(grad_white) / 255, color_get_green(grad_white) / 255, color_get_blue(grad_white) / 255);
        shader_set_uniform_f(u_grad_col_b, color_get_red(grad_cyan) / 255, color_get_green(grad_cyan) / 255, color_get_blue(grad_cyan) / 255);
    } else {
        draw_set_colour(_col);
    }

    _px = _left;
    for (var i = 1; i <= _n; i++) {
        var _ch = string_char_at(_txt, i);
        draw_text(_px, _y, _ch);
        _px += string_width(_ch) + letter_space;
    }

    if (_gradient) shader_reset();

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

// --- Nubes ---
clouds_filter = false; // false = bordes duros (pixel art); true = suavizado

cloud_scale_min = 0.12;
cloud_scale_max = 0.26;
cloud_scale_small_min = 0.08;
cloud_scale_small_max = 0.16;
cloud_alpha_min = 0.45;
cloud_alpha_max = 1;

sky_top = 4;
sky_bottom = 150;

// --- SEPARACIÓN: cambia este número ---
cloud_spacing = 55;  // distancia horizontal entre nubes (px del GUI). Menor = más nubes
cloud_min_dy = 28;   // diferencia mínima de altura entre nubes vecinas

// Velocidad única: cada cuántos frames avanzan 1 px todas las nubes
cloud_interval = 12;
cloud_timer = 0;

// Devuelve el rango de tamaño que le corresponde a cada sprite
cloud_scale_range = function(_spr) {
    if (_spr == spr_title_cloud_5 || _spr == spr_title_cloud_6 || _spr == spr_title_cloud_7) {
        return [cloud_scale_small_min, cloud_scale_small_max];
    }
    return [cloud_scale_min, cloud_scale_max];
}

// Sortea un tamaño y una opacidad nuevos para una nube
cloud_randomize = function(_c) {
    var _range = cloud_scale_range(_c.spr);
    _c.scale = random_range(_range[0], _range[1]);
    _c.alpha = random_range(cloud_alpha_min, cloud_alpha_max);
}

// Elige una altura al azar para la nube _i, lejos de la altura de sus vecinas
cloud_pick_y = function(_i) {
    var _c = clouds[_i];
    var _near = cloud_spacing * 2.2; // a qué distancia horizontal cuenta una nube como "vecina"
    var _best_y = sky_top;
    var _best_score = -1;

    for (var t = 0; t < 15; t++) {
        var _y = random_range(sky_top, sky_bottom);
        var _score = 9999;

        for (var j = 0; j < array_length(clouds); j++) {
            if (j == _i) continue;
            var _dx = abs(clouds[j].x - _c.x);
            _dx = min(_dx, cloud_loop_w - _dx); // el ciclo da la vuelta
            if (_dx < _near) {
                _score = min(_score, abs(clouds[j].y - _y));
            }
        }

        if (_score >= cloud_min_dy) return floor(_y); // altura válida
        if (_score > _best_score) { _best_score = _score; _best_y = _y; }
    }
    return floor(_best_y); // si ninguna cumple, la mejor de los intentos
}

randomize();

var _sprites = [
    spr_title_cloud_1, spr_title_cloud_2, spr_title_cloud_3, spr_title_cloud_4,
    spr_title_cloud_5, spr_title_cloud_6, spr_title_cloud_7
];
var _sn = array_length(_sprites);

// Mezclar el orden de los sprites
for (var i = _sn - 1; i > 0; i--) {
    var _j = irandom(i);
    var _t = _sprites[i]; _sprites[i] = _sprites[_j]; _sprites[_j] = _t;
}

// Margen: ancho de la nube más grande posible, para entrar y salir fuera de pantalla
cloud_margin = 0;
for (var i = 0; i < _sn; i++) {
    cloud_margin = max(cloud_margin, sprite_get_width(_sprites[i]) * cloud_scale_max);
}
cloud_margin = ceil(cloud_margin);

// Cantidad de nubes y largo del ciclo (se calculan solos a partir de la separación)
cloud_count = ceil((GUI_W + cloud_margin * 2) / cloud_spacing);
cloud_loop_w = cloud_count * cloud_spacing;

clouds = [];
for (var i = 0; i < cloud_count; i++) {
    var _x = -cloud_margin + i * cloud_spacing + random_range(-cloud_spacing * 0.15, cloud_spacing * 0.15);

    var _cloud = {
        spr: _sprites[i mod _sn], // con más nubes que sprites, los sprites se repiten
        x: _x,
        y: 0,
        scale: 1,
        alpha: 1
    };
    cloud_randomize(_cloud);
    array_push(clouds, _cloud);

    clouds[i].y = cloud_pick_y(i); // altura según las nubes ya colocadas
}