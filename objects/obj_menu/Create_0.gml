op_space = 20;
text_scale = 1;

pos = 0;

//Pause
option [0, 0] = "Continuar";
option [0, 1] = "Opciones";
option [0, 2] = "Salir al menú principal";

//Opciones
option[1, 0] =	"Ventana";
option[1, 1] =	"Sonido";
option[1, 2] =	"Controles";
option[1, 3] =	"Volver";

// Confirmación
option[2, 0] = "Sí, quiero volver";
option[2, 1] = "No, seguir jugando";
confirm_msg = "¿Estás seguro de que deseas volver\nal menú principal?";

menu_level = 0;
op_length = array_length(option[menu_level]);

just_opened = true;

depth = -100000;

audio_play_sound(snd_menu_open, 1, false);

blink_timer = 0;
blink_duration = 12; // duración total en frames (12 = 0.2 s a 60 fps)
blink_speed = 3;     // frames entre cada cambio de color

key_pad = 3;  // margen horizontal dentro de cada tecla
key_trim = 3; // píxeles vacíos que la fuente deja arriba de las letras (ajustable)

keycap_width = function(_label) {
    return string_width(_label) + key_pad * 2;
}

keycap_height = function() {
    return string_height("Z") - key_trim + 2;
}

// Dibuja una tecla en pixel art: relieve, cara, borde sin esquinas y letra
draw_keycap = function(_x, _y, _label, _col) {
    var _w = keycap_width(_label);
    var _h = keycap_height();
    var _face  = make_colour_rgb(28, 32, 44);
    var _shade = merge_colour(_col, c_black, 0.5);

    // Relieve (2 px visibles bajo la tecla, con la última fila más corta)
    draw_set_colour(_shade);
    draw_rectangle(_x, _y + _h - 1, _x + _w - 1, _y + _h, false);
    draw_rectangle(_x + 1, _y + _h + 1, _x + _w - 2, _y + _h + 1, false);

    // Cara
    draw_set_colour(_face);
    draw_rectangle(_x + 1, _y + 1, _x + _w - 2, _y + _h - 2, false);

    // Borde de 1 px sin las esquinas
    draw_set_colour(_col);
    draw_rectangle(_x + 1, _y, _x + _w - 2, _y, false);                   // arriba
    draw_rectangle(_x + 1, _y + _h - 1, _x + _w - 2, _y + _h - 1, false); // abajo
    draw_rectangle(_x, _y + 1, _x, _y + _h - 2, false);                   // izquierda
    draw_rectangle(_x + _w - 1, _y + 1, _x + _w - 1, _y + _h - 2, false); // derecha

    // Letra
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(_x + key_pad, _y + 1 - key_trim, _label);

    draw_set_colour(c_white);
}