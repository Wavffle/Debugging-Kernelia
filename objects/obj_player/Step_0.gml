if (global.paused) {
    image_speed = 0;
    exit;
}
image_speed = 1;

// --- Leer input ---
var input_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var input_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var input_up = keyboard_check(vk_up) || keyboard_check(ord("W"));
var input_down = keyboard_check(vk_down) || keyboard_check(ord("S"));
var input_shift = keyboard_check(vk_shift);

// --- ¿Hay un diálogo abierto? Si es así, se anula el movimiento ---
var talking = instance_exists(obj_textbox);
if (talking) {
    input_right = false;
    input_left = false;
    input_up = false;
    input_down = false;
    input_shift = false;
}

// --- Determinar velocidad según Shift ---
if (input_shift) {
    move_speed = walk_speed;
} else {
    move_speed = run_speed;
}

// --- Calcular dirección de movimiento (-1, 0, 1 en cada eje) ---
var move_x = input_right - input_left;
var move_y = input_down - input_up;

// --- Normalizar movimiento diagonal ---
if (move_x != 0 && move_y != 0) {
    move_x *= 0.7071;
    move_y *= 0.7071;
}

// --- Aplicar movimiento con colisiones ---
var _dx = move_x * move_speed;
var _dy = move_y * move_speed;

if (!place_meeting(x + _dx, y, obj_npc_parent)) {
    x += _dx;
}
if (!place_meeting(x, y + _dy, obj_npc_parent)) {
    y += _dy;
}

// --- Determinar dirección visual (4 direcciones, prioridad vertical) ---
if (move_y < 0) {
    facing_dir = "up";
} else if (move_y > 0) {
    facing_dir = "down";
} else if (move_x < 0) {
    facing_dir = "left";
} else if (move_x > 0) {
    facing_dir = "right";
}
// Sin input, facing_dir conserva su último valor

// --- Guardar si el jugador se está moviendo ---
is_moving = (move_x != 0 || move_y != 0);

// --- Guardar el rastro solo si se alejó al menos 1 px del último punto ---
var _n_trail = array_length(trail_x);
if (_n_trail == 0 || point_distance(x, y, trail_x[_n_trail - 1], trail_y[_n_trail - 1]) >= 1) {
    array_push(trail_x, x);
    array_push(trail_y, y);
    if (array_length(trail_x) > trail_max) {
        array_delete(trail_x, 0, 1);
        array_delete(trail_y, 0, 1);
    }
}

// --- Estado de animación: idle / walk (con Shift) / run (por defecto) ---
var state = "idle";
if (is_moving) {
    state = input_shift ? "walk" : "run";
}

// --- Elegir sprite según dirección y estado ---
var new_sprite = sprite_index;

switch (facing_dir) {
    case "right":
        image_xscale = 1;
        if (state == "walk")     new_sprite = spr_player_walking_right;
        else if (state == "run") new_sprite = spr_player_running_right;
        else                     new_sprite = spr_player_idle_right;
        break;

    case "left":
        image_xscale = -1; // espejo de right
        if (state == "walk")     new_sprite = spr_player_walking_right;
        else if (state == "run") new_sprite = spr_player_running_right;
        else                     new_sprite = spr_player_idle_right;
        break;

    case "up":
        image_xscale = 1;
        if (state == "walk")     new_sprite = spr_player_walking_up;
        else if (state == "run") new_sprite = spr_player_running_up;
        else                     new_sprite = spr_player_idle_up;
        break;

    case "down":
        image_xscale = 1;
        if (state == "walk")     new_sprite = spr_player_walking_front;
        else if (state == "run") new_sprite = spr_player_running_front;
        else                     new_sprite = spr_player_idle_front;
        break;
}

if (new_sprite != sprite_index) {
    sprite_index = new_sprite;
    image_index = 0;
}

// --- Elegir máscara de colisión según hacia dónde miramos ---
var new_mask = mask_front;
if (facing_dir == "left" || facing_dir == "right") {
    new_mask = mask_side;
}

if (new_mask != mask_index) {
    var old_mask = mask_index;
    mask_index = new_mask;
    if (place_meeting(x, y, obj_npc_parent)) {
        mask_index = old_mask;
    }
}

// --- Orden de dibujo ---
depth = -y;

// --- Interacción con NPCs (Z o Enter) ---
var input_interact = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

if (input_interact && !talking) {
    // Hacia dónde apunta el jugador
    var _fx = 0;
    var _fy = 0;
    switch (facing_dir) {
        case "up": _fy = -1; break;
        case "down": _fy = 1; break;
        case "left": _fx = -1; break;
        case "right": _fx = 1; break;
    }

    // ¿Hay un NPC justo delante, a distancia de alcance?
    var npc = instance_place(x + _fx * interact_reach, y + _fy * interact_reach, obj_npc_parent);

    if (npc != noone) {
    // El NPC mira en sentido contrario a hacia donde mira el jugador
    var _opposite = "down";
    switch (facing_dir) {
        case "up":    _opposite = "down";  break;
        case "down":  _opposite = "up";    break;
        case "left":  _opposite = "right"; break;
        case "right": _opposite = "left";  break;
    }

    npc.interact(_opposite);
	}
}