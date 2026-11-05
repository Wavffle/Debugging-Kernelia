// --- Datos generales de cualquier NPC ---
npc_name = "NPC";
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

// --- Mirar hacia un punto (respaldo, por si no se conoce la dirección) ---
face_towards = function(_target_x, _target_y) {
    var dx = _target_x - x;
    var dy = _target_y - y;

    if (abs(dx) > abs(dy)) {
        face_direction((dx > 0) ? "right" : "left");
    } else {
        face_direction((dy > 0) ? "down" : "up");
    }
}