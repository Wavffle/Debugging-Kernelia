draw_set_font(global.font_main);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);

gui_board();
gui_title();
gui_memory();
gui_status();
gui_queue();
gui_buttons();
gui_gepet();
if (state != "play") gui_end();
gui_dots();
if (fade_alpha > 0) gui_shade(fade_alpha);