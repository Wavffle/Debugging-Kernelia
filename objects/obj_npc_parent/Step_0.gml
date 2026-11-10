if (global.paused) {
    image_speed = 0;
    exit;
}
image_speed = 1;

depth = -y;

// --- Diálogo: el NPC que habla se queda quieto ---
if (in_dialogue) {
    if (!instance_exists(obj_textbox)) {
        in_dialogue = false;
        if (can_wander) wander_stop();
        if (return_to_start) {
            return_pending = true;
            return_timer = return_delay;
        }
        on_dialogue_end();
    }
    exit;
}

// --- Volver a la posición inicial ---
if (return_pending) {
    if (return_timer > 0) {
        return_timer--;
        exit;
    }

    var _rx = clamp(home_x - x, -wander_speed, wander_speed);
    var _ry = 0;
    if (_rx == 0) _ry = clamp(home_y - y, -wander_speed, wander_speed); // primero en X, luego en Y

    if (_rx == 0 && _ry == 0) {
        // Ya llegó: mira hacia su dirección inicial
        return_pending = false;
        face_direction(start_facing);
        if (can_wander) wander_stop();
        exit;
    }

    // Si algo le bloquea el paso, espera un momento
    if (place_meeting(x + _rx, y + _ry, obj_player) || place_meeting(x + _rx, y + _ry, obj_npc_parent)) {
        exit;
    }

    x += _rx;
    y += _ry;
    if (_rx != 0) walk_direction((_rx > 0) ? "right" : "left");
    else          walk_direction((_ry > 0) ? "down" : "up");
    exit;
}

// --- Deambular ---
if (!can_wander) exit;

var _sx = 0;
var _sy = 0;

switch (wander_state) {
    case "wait":
        wander_timer--;
        if (wander_timer <= 0) {
            // Elegir dirección y distancia, sin salir del cuadrado
            var _dirs = ["up", "down", "left", "right"];
            wander_dir = _dirs[irandom(3)];
            var _dist = irandom_range(8, 24);

            wander_target_x = x;
            wander_target_y = y;
            switch (wander_dir) {
                case "up":    wander_target_y = max(y - _dist, home_y - wander_range); break;
                case "down":  wander_target_y = min(y + _dist, home_y + wander_range); break;
                case "left":  wander_target_x = max(x - _dist, home_x - wander_range); break;
                case "right": wander_target_x = min(x + _dist, home_x + wander_range); break;
            }
            wander_state = "walk";
        }
    break;

    case "walk":
        // Paso hacia el destino (clamp evita pasarse al llegar)
        _sx = clamp(wander_target_x - x, -wander_speed, wander_speed);
        _sy = clamp(wander_target_y - y, -wander_speed, wander_speed);

        // ¿Ya llegó, o está en el borde y no hay a dónde ir?
        if (_sx == 0 && _sy == 0) {
            wander_stop();
            break;
        }

        // ¿Choca con el jugador u otro NPC?
        if (place_meeting(x + _sx, y + _sy, obj_player) || place_meeting(x + _sx, y + _sy, obj_npc_parent)) {
            wander_stop();
            break;
        }

        x += _sx;
        y += _sy;
        walk_direction(wander_dir);
    break;
}