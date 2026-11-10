//textbox parameters
textbox_height = 86;
border = 12;
line_sep = 14;
txtb_spr[0] = spr_dialogue_box_protagonista;
txtb_img = 0;
//for when the textbox is animated
txtb_img_spd = 0;

//the text
page = 0;
page_number = 0;
text[0] = "";
text_length[0] = string_length(text[0]);

char[0,0] = ""
char_x[0,0] = 0;
char_y[0,0] = 0;

// --- Layout (pantalla de 480x270) ---
screen_margin = 16;     // margen a los bordes de la pantalla (y al borde inferior)
box_gap = 16;           // espacio entre el cuadro del retrato y la caja de texto
portrait_box_w = 72;   // ancho del cuadro del retrato
portrait_box_h = 72;   // alto del cuadro del retrato
portrait_scale = 1;    // tamaño del dibujo del personaje dentro del cuadro (usa enteros)

no_portrait_w = 340; // ancho de la caja cuando no hay retrato (480 = pantalla completa)

draw_char = 0;
text_spd = 1;
//options
option[0] = "";
option_link_id[0] = -1;
option_pos = 0;
option_number = 0;

setup = false;

//sound
snd_delay = 4;
snd_count = snd_delay;

//effects
scr_set_defaults_for_text();
last_free_space = 0;
text_pause_timer = 0;
text_pause_time = 16;

//arrows and name tag
options_right = true;  // true: opciones a la derecha y tarjeta a la izquierda; false: al revés
arrow_fps = 14;       // flecha de las opciones (spr_textbox_arrow)
arrow_down_fps = 6;   // flecha de "continuar" (spr_textbox_arrow_down);
arrow_gap = 4;         // separación entre la flecha y la opción
arrow_margin = 10;      // margen de la flecha de "continuar" respecto al borde de la caja
tag_pad_x = 6;         // espacio a los lados del nombre
tag_pad_y = 2;         // espacio arriba y abajo del nombre
tag_overlap = 0; // 1 o 2 hace que la tarjeta "tape" el borde del retrato y se vea fusionada

first_frame = true; // ignora el input del frame en que se crea

fast_spd = 6;          // letras por frame durante el fast forward
skip_page_delay = 6;   // frames de espera entre páginas durante el fast forward
skip_timer = skip_page_delay;