if (global.paused) {
    image_speed = 0;
    exit;
}
image_speed = 1;

depth = -y;

if (!instance_exists(obj_player)) exit;

var _old_x = x;
var _old_y = y;

// --- La distancia cambia suavemente según corras o camines ---
var _want_dist = follow_dist_run;
if (obj_player.move_speed <= obj_player.walk_speed) _want_dist = follow_dist_walk;
follow_dist = lerp(follow_dist, _want_dist, 0.05);

// --- Buscar en el rastro el punto que está follow_dist píxeles detrás del jugador ---
var _n = array_length(obj_player.trail_x);
var _acc = 0;
var _px = obj_player.x;
var _py = obj_player.y;
var _tx = x;
var _ty = y;
var _found = false;

for (var i = _n - 1; i >= 0; i--) {
    var _rx = obj_player.trail_x[i];
    var _ry = obj_player.trail_y[i];
    _acc += point_distance(_px, _py, _rx, _ry);
    _px = _rx;
    _py = _ry;

    if (_acc >= follow_dist) {
        _tx = _rx;
        _ty = _ry;
        _found = true;
        break;
    }
}

// --- Ir hacia ese punto ---
if (_found) {
    var _dist = point_distance(x, y, _tx, _ty);
    if (_dist > 0) {
        var _step = min(_dist * 0.35, catchup_speed); // frena suavemente al acercarse
        var _dir = point_direction(x, y, _tx, _ty);
        x += lengthdir_x(_step, _dir);
        y += lengthdir_y(_step, _dir);
    }
}

// --- Cuánto se movió ---
var _dx = x - _old_x;
var _dy = y - _old_y;

// Velocidad suavizada: evita los saltos idle/walk frame a frame
vx = lerp(vx, _dx, 0.25);
vy = lerp(vy, _dy, 0.25);
var _spd = point_distance(0, 0, vx, vy);

// Margen para empezar y para parar (histéresis)
if (_spd > 0.35)      moving_anim = true;
else if (_spd < 0.1)  moving_anim = false;

// --- Dirección: solo cambia de eje si el nuevo eje domina claramente ---
if (moving_anim) {
    var _horizontal = (facing_dir == "left" || facing_dir == "right");

    if (_horizontal) {
        if (abs(vy) > abs(vx) * 1.5) {
            facing_dir = (vy > 0) ? "down" : "up";
        } else if (vx != 0) {
            facing_dir = (vx > 0) ? "right" : "left";
        }
    } else {
        if (abs(vx) > abs(vy) * 1.5) {
            facing_dir = (vx > 0) ? "right" : "left";
        } else if (vy != 0) {
            facing_dir = (vy > 0) ? "down" : "up";
        }
    }
}

// --- Idle / caminar / correr ---
var _state = "idle";
if (moving_anim) {
    // Camina o corre según lo que hace el jugador, no según su propia velocidad
    if (obj_player.move_speed <= obj_player.walk_speed) _state = "walk";
    else                                                _state = "run";
}

var _spr = sprite_idle_down;

switch (facing_dir) {
    case "up":
        if (_state == "run")       _spr = sprite_run_up;
        else if (_state == "walk") _spr = sprite_walk_up;
        else                       _spr = sprite_idle_up;
        break;

    case "down":
        if (_state == "run")       _spr = sprite_run_down;
        else if (_state == "walk") _spr = sprite_walk_down;
        else                       _spr = sprite_idle_down;
        break;

    default: // izquierda y derecha usan el mismo sprite (izquierda con espejo)
        if (_state == "run")       _spr = sprite_run_side;
        else if (_state == "walk") _spr = sprite_walk_side;
        else                       _spr = sprite_idle_side;
        break;
}

if (_spr != sprite_index) {
    var _prev_idx = image_index;
    sprite_index = _spr;
    // Entre caminar y correr se conserva el frame; desde/hacia idle se reinicia
    if (_state == "idle" || anim_state == "idle") image_index = 0;
    else image_index = _prev_idx mod sprite_get_number(_spr);
}
anim_state = _state;

if (facing_dir == "left") image_xscale = -1;
else                      image_xscale = 1;