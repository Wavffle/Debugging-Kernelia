// --- Datos generales de cualquier NPC ---
npc_name = "NPC";
facing_dir = "down";

// Cada NPC hijo define sus propios sprites (ver obj_gepet)
sprite_idle_down = -1;
sprite_idle_up   = -1;
sprite_idle_side = -1; // mirando a la derecha; la izquierda se logra volteando

// --- Mirar hacia un punto (por ejemplo, hacia el jugador) ---
face_towards = function(_target_x, _target_y) {
    var dx = _target_x - x;
    var dy = _target_y - y;

    // Elegimos el eje con mayor distancia: horizontal o vertical
    if (abs(dx) > abs(dy)) {
        facing_dir = (dx > 0) ? "right" : "left";
    } else {
        facing_dir = (dy > 0) ? "down" : "up";
    }

    // Aplicar el sprite correspondiente
    switch (facing_dir) {
        case "down":
            sprite_index = sprite_idle_down;
            image_xscale = 1;
            break;
        case "up":
            sprite_index = sprite_idle_up;
            image_xscale = 1;
            break;
        case "right":
            sprite_index = sprite_idle_side;
            image_xscale = 1;
            break;
        case "left":
            sprite_index = sprite_idle_side;
            image_xscale = -1; // espejo
            break;
    }
}