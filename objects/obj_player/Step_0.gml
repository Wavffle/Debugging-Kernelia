// --- Leer input ---
var input_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var input_left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
var input_up    = keyboard_check(vk_up)    || keyboard_check(ord("W"));
var input_down  = keyboard_check(vk_down)  || keyboard_check(ord("S"));
var input_shift = keyboard_check(vk_shift);

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

// --- Aplicar movimiento ---
x += move_x * move_speed;
y += move_y * move_speed;

// --- Determinar dirección visual (8 direcciones) con tiempo de gracia ---
var new_facing = "";

if (move_y < 0 && move_x > 0) {
    new_facing = "up_right";
} else if (move_y < 0 && move_x < 0) {
    new_facing = "up_left";
} else if (move_y > 0 && move_x > 0) {
    new_facing = "down_right";
} else if (move_y > 0 && move_x < 0) {
    new_facing = "down_left";
} else if (move_y < 0) {
    new_facing = "up";
} else if (move_y > 0) {
    new_facing = "down";
} else if (move_x < 0) {
    new_facing = "left";
} else if (move_x > 0) {
    new_facing = "right";
}

if (new_facing == "") {
    // Sin input: se conserva facing_dir y se reinicia el contador
    diagonal_grace_timer = 0;
}
else if (string_pos("_", new_facing) > 0) {
    // Es una diagonal: se actualiza y se recarga el tiempo de gracia
    facing_dir = new_facing;
    last_diagonal = new_facing;
    diagonal_grace_timer = diagonal_grace_max;
}
else if (diagonal_grace_timer > 0 && string_pos(new_facing, last_diagonal) > 0) {
    // Quedó una sola tecla, pero es parte de la diagonal anterior
    // (ej: venía "up_right" y queda "up" o "right") -> mantener la diagonal
    facing_dir = last_diagonal;
    diagonal_grace_timer--;
}
else {
    // Dirección simple normal
    facing_dir = new_facing;
    diagonal_grace_timer = 0;
}

// --- Guardar si el jugador se está moviendo ---
is_moving = (move_x != 0 || move_y != 0);

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

    case "down_right":
        image_xscale = 1;
        if (state == "walk")     new_sprite = spr_player_walking_down_right;
        else if (state == "run") new_sprite = spr_player_running_down_right;
        else                     new_sprite = spr_player_idle_down_right;
        break;

    case "down_left":
        image_xscale = -1; // espejo de down_right
        if (state == "walk")     new_sprite = spr_player_walking_down_right;
        else if (state == "run") new_sprite = spr_player_running_down_right;
        else                     new_sprite = spr_player_idle_down_right;
        break;

    case "up_right":
        image_xscale = 1;
        if (state == "walk")     new_sprite = spr_player_walking_right_up; // ver aviso: renombrar a walking_up_right
        else if (state == "run") new_sprite = spr_player_running_up_right;
        else                     new_sprite = spr_player_idle_up_right;
        break;

    case "up_left":
        image_xscale = -1; // espejo de up_right
        if (state == "walk")     new_sprite = spr_player_walking_right_up; // ver aviso
        else if (state == "run") new_sprite = spr_player_running_up_right;
        else                     new_sprite = spr_player_idle_up_right;
        break;
}

// --- Solo cambiar el sprite si es distinto al actual ---
if (new_sprite != sprite_index) {
    sprite_index = new_sprite;
    image_index = 0;
}

// --- Interacción con NPCs (Z o Enter) ---
var input_interact = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);

if (input_interact) {
    var npc = instance_nearest(x, y, obj_npc_parent);

    if (npc != noone && point_distance(x, y, npc.x, npc.y) <= interact_range) {
        npc.face_towards(x, y);
    }
}