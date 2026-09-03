// --- Leer input ---
var input_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var input_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var input_up = keyboard_check(vk_up) || keyboard_check(ord("W"));
var input_down = keyboard_check(vk_down) || keyboard_check(ord("S"));

// --- Calcular dirección de movimiento (-1, 0, 1 en cada eje) ---
var move_x = input_right - input_left;
var move_y = input_down - input_up;

// --- Normalizar movimiento diagonal ---
// Si te mueves en diagonal, sin esto irías más rápido (por Pitágoras).
if (move_x != 0 && move_y != 0) {
    move_x *= 0.7071; // aprox 1/sqrt(2)
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
// Si move_x y move_y son 0, facing_dir mantiene su último valor (no se mueve, pero sigue "mirando" hacia donde miraba)

// --- Guardar si el jugador se está moviendo (útil para animación) ---
is_moving = (move_x != 0 || move_y != 0);