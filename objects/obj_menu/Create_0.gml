op_space = 20;
text_scale = 1;

pos = 0;

//Pause
option [0, 0] = "Continuar";
option [0, 1] = "Opciones";
option [0, 2] = "Salir al menú principal";

//Opciones
option[1, 0] =	"Ventana";
option[1, 1] =	"Brillo";
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