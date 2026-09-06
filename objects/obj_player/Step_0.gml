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

// --- Determinar dirección "visual" (solo 4 direcciones, prioridad vertical) ---
if (move_y < 0) {
    facing_dir = "up";
} else if (move_y > 0) {
    facing_dir = "down";
} else if (move_x < 0) {
    facing_dir = "left";
} else if (move_x > 0) {
    facing_dir = "right";
}

// --- Guardar si el jugador se está moviendo ---
is_moving = (move_x != 0 || move_y != 0);

// --- Elegir sprite según dirección y estado ---
var new_sprite = sprite_index;

switch (facing_dir) {
    case "right":
        new_sprite = spr_player_idle_right;
        image_xscale = 1;
		if(is_moving && input_shift){
			new_sprite = spr_player_walking_right;
		}else {
            new_sprite = spr_player_idle_right;
        }
        break;
    
    case "left":
        new_sprite = spr_player_idle_right;
        image_xscale = -1;
		if(is_moving && input_shift){
			new_sprite = spr_player_walking_right
		}else {
            new_sprite = spr_player_idle_right;
        }
        break;
    
    case "up":
        new_sprite = spr_player_idle_up;
        image_xscale = 1;
		if(is_moving && input_shift){
			new_sprite = spr_player_walking_up;
		}else {
            new_sprite = spr_player_idle_up;
        }
        break;
    
    case "down":
        image_xscale = 1;
        if (is_moving && input_shift) {
            new_sprite = spr_player_walking_front;
        }else {
            new_sprite = spr_player_idle_front;
        }
        break;
}

if (new_sprite != sprite_index) {
    sprite_index = new_sprite;
    image_index = 0;
}