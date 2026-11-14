// --- Datos generales de cualquier NPC ---
facing_dir = "down";

// Cada NPC hijo define sus propios sprites (ver obj_gepet)
sprite_idle_down = -1;
sprite_idle_up   = -1;
sprite_idle_side = -1; // mirando a la derecha; la izquierda se logra volteando

// --- Mirar hacia una dirección concreta: "up", "down", "left" o "right" ---
face_direction = function(_dir) {
    facing_dir = _dir;

    // Si falta algún sprite, se usa el de frente
    var _spr = sprite_idle_down;
    var _flip = 1;

    switch (facing_dir) {
        case "up":
            if (sprite_idle_up != -1) _spr = sprite_idle_up;
            break;
        case "right":
            if (sprite_idle_side != -1) _spr = sprite_idle_side;
            break;
        case "left":
            if (sprite_idle_side != -1) { _spr = sprite_idle_side; _flip = -1; }
            break;
    }

    sprite_index = _spr;
    image_xscale = _flip;
}

// --- Diálogo ---
text_id = "";

// --- Interacción: el NPC mira al jugador y abre su diálogo ---
interact = function(_dir_to_player) {
    in_dialogue = true;
    return_pending = false; // si estaba volviendo, se cancela
    if (can_wander) wander_stop();
    face_direction(_dir_to_player);
    if (text_id != "") create_textbox(text_id);
}

// --- Sprites al caminar (cada hijo los define; si falta alguno se usa el idle) ---
sprite_walk_down = -1;
sprite_walk_up   = -1;
sprite_walk_side = -1;

// --- Deambular ---
can_wander = false;     // actívalo en los NPCs que quieras que caminen
wander_range = 24;      // mitad del lado del cuadrado (24 = cuadrado de 48x48 px)
wander_speed = 0.5;
wander_wait_min = 60;   // frames de espera entre caminatas (60 = 1 s)
wander_wait_max = 180;

in_dialogue = false;

home_x = x;
home_y = y;
wander_state = "wait";
wander_dir = "down";
wander_target_x = x;
wander_target_y = y;
wander_timer = irandom_range(wander_wait_min, wander_wait_max);

// Mostrar la animación de caminar hacia una dirección
walk_direction = function(_dir) {
    facing_dir = _dir;

    var _spr = sprite_walk_down;
    var _flip = 1;
    switch (_dir) {
        case "up":    _spr = sprite_walk_up; break;
        case "right": _spr = sprite_walk_side; break;
        case "left":  _spr = sprite_walk_side; _flip = -1; break;
    }

    // Si no hay sprite de caminar, se usa el idle
    if (_spr == -1) {
        face_direction(_dir);
        return;
    }

    if (sprite_index != _spr) {
        sprite_index = _spr;
        image_index = 0;
    }
    image_xscale = _flip;
}

// Dejar de caminar y volver a esperar
wander_stop = function() {
    wander_state = "wait";
    wander_timer = irandom_range(wander_wait_min, wander_wait_max);
    face_direction(facing_dir);
}

start_facing = "down"; // dirección inicial; se puede cambiar en el Creation Code de la room

// --- Volver a la posición inicial después de hablar ---
return_to_start = true;  // por defecto, todos vuelven a su sitio tras hablar
return_delay = 140;      // frames de espera tras el diálogo (140 ≈ 2,3 s))
return_timer = 0;
return_pending = false;

// --- Se ejecuta cuando termina su diálogo (cada NPC puede sobrescribirlo) ---
on_dialogue_end = function() {}