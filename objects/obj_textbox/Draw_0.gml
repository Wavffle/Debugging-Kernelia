accept_key = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
skip_hold = keyboard_check(ord("X")) || keyboard_check(vk_escape);

// La pulsación que abrió este textbox no cuenta
if (first_frame) {
    accept_key = false;
    skip_hold = false;
    first_frame = false;
}

textbox_x = VIEW_X;
textbox_y = VIEW_Y + VIEW_H - textbox_height - screen_margin;

//------------------------setup------------------------//
if (setup = false) {
	setup = true;
	draw_set_font(global.font_main);
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	
	//loop through the pages
	for (var p = 0 ; p < page_number ; p++) {
		
		//find how many characters are on each page and store that number in the "text_length" array
		text_length[p] = string_length(text[p]);
		
				//layout: ancho de la caja de texto y posiciones según el lado del personaje
		if (speaker_side[p] == noone) {
			//sin personaje: caja centrada, más angosta
			txtb_w[p] = no_portrait_w;
			text_x_offset[p] = floor((VIEW_W - no_portrait_w) / 2);
			portrait_x_offset[p] = 0;
		}
		else {
			txtb_w[p] = VIEW_W - screen_margin*2 - box_gap - portrait_box_w;
			if (speaker_side[p] == -1) {
				//personaje a la derecha
				text_x_offset[p] = screen_margin;
				portrait_x_offset[p] = VIEW_W - screen_margin - portrait_box_w;
			}
			else {
				//personaje a la izquierda
				portrait_x_offset[p] = screen_margin;
				text_x_offset[p] = screen_margin + portrait_box_w + box_gap;
			}
		}
		line_w[p] = txtb_w[p] - border*2;
			
		//setting individual characters and finding where the lines of text should break
		for (var c=0; c < text_length[p]; c++){
			var _char_pos = c+1;
			
			//store individual characters in the "char" way
			char [c,p] = string_char_at(text[p], _char_pos);
			
			//get current width of the line
			var _txt_up_to_char = string_copy(text[p],1, _char_pos);
			var _current_txt_w = string_width(_txt_up_to_char) - string_width(char[c,p]);
			
			//get the last free space
			if (char[c,p] == " ") {last_free_space= _char_pos+1;}
			
			//get the line breaks
			if _current_txt_w - line_break_offset[p] > line_w[p]{
				line_break_pos[line_break_num[p], p] = last_free_space;
				line_break_num[p]++;
				var _txt_up_to_last_space = string_copy(text[p],1, last_free_space);
				var _last_free_space_string = string_char_at(text[p], last_free_space);
				line_break_offset[p] = string_width(_txt_up_to_last_space) - string_width(_last_free_space_string);
			}
		}
		for (var c=0; c < text_length[p]; c++){
			var _char_pos = c+1;
			var _txt_x = text_x_offset[p] + border;
			var _txt_y = border;
			//get current width of the line
			var _txt_up_to_char = string_copy(text[p],1, _char_pos);
			var _current_txt_w = string_width(_txt_up_to_char) - string_width(char[c,p]);
			var _txt_line = 0;
			
			//compensate for string breaks
			for (var lb = 0; lb < line_break_num[p]; lb++){
				//if the current looping character is after a line break
				if (_char_pos >= line_break_pos[lb,p]){
					var _str_copy = string_copy(text[p], line_break_pos[lb,p], _char_pos-line_break_pos[lb,p]);
					_current_txt_w = string_width(_str_copy);
					
					//record the "line" this character should be on
					_txt_line = lb+1
				}
			}
			
			//add to the x and y coordinates on the new info
			char_x[c,p] = _txt_x + _current_txt_w;
			char_y[c,p] = _txt_y + _txt_line*line_sep;
		}
	}
}

//------------------------typing the text------------------------//
if (skip_hold) text_pause_timer = 0; // sin pausas en puntuación

if (text_pause_timer <= 0) {
	if (draw_char < text_length[page]) {
		
		draw_char += skip_hold ? fast_spd : text_spd;
		draw_char = clamp(draw_char, 0, text_length[page]);
		var _check_char = string_char_at(text[page], draw_char);
		
		if (_check_char == "." || _check_char == "?" || _check_char == "!" || _check_char == ",") {
			text_pause_timer = text_pause_time;
			
			// Los puntos de unos puntos suspensivos no suenan
			var _is_ellipsis = (_check_char == "." && (string_char_at(text[page], draw_char - 1) == "." || string_char_at(text[page], draw_char + 1) == "."));
			
			if (!_is_ellipsis && !audio_is_playing(snd[page])) {
				audio_play_sound(snd[page], 8, false);
			}
		}
		else{
			//typing sound
			if snd_count < snd_delay{
				snd_count++;
			}
			else{
				snd_count = 0;
				audio_play_sound(snd[page], 8, false);
			}
		}
	}
}
else {
	text_pause_timer--;
}

//------------------------fast forward------------------------//
if (skip_hold && draw_char == text_length[page] && page < page_number - 1) {
	skip_timer--;
	if (skip_timer <= 0) {
		page++;
		draw_char = 0;
		skip_timer = skip_page_delay;
	}
}
else if (!skip_hold) {
	skip_timer = skip_page_delay;
}

//------------------------flip through pages------------------------//

if (accept_key) {
	//if the typing is done
	if (draw_char == text_length[page]) {
		//next page
		if (page < page_number - 1) {
			page++;
			draw_char = 0;
		}
		//destroy textbox
		else{
			//link text for options
			if (option_number>0){
				audio_play_sound(snd_menu_select, 1, false);
				create_textbox(option_link_id[option_pos]);
			}
			instance_destroy();	
		}
	}
	//if not done typing
	else{
		draw_char = text_length[page];	
	}
}

//------------------------draw the textbox------------------------//

var _txtb_x = textbox_x + text_x_offset[page];
var _txtb_y = textbox_y;
txtb_img += txtb_img_spd;
txtb_spr_w = sprite_get_width(txtb_spr[page]);
txtb_spr_h = sprite_get_height(txtb_spr[page]);

//draw the speaker
if (speaker_sprite[page] != noone) {
	
	sprite_index = speaker_sprite[page];
	if (draw_char == text_length[page]) { image_index = 0 }
	
	var _px = textbox_x + portrait_x_offset[page];
	var _py = textbox_y + textbox_height - portrait_box_h; // alineado con el borde inferior de la caja de texto
	
	//cuadro del retrato
	draw_sprite_ext(txtb_spr[page], txtb_img, _px, _py, portrait_box_w/txtb_spr_w, portrait_box_h/txtb_spr_h, 0, c_white, 1);
	
	//personaje centrado dentro del cuadro
	var _w = sprite_width * portrait_scale;
	var _h = sprite_height * portrait_scale;
	var _sx = floor(_px + (portrait_box_w - _w) / 2);
	var _sy = floor(_py + (portrait_box_h - _h) / 2);
	if (speaker_side[page] == -1) { _sx += _w; } // al voltearlo, el origen queda en el otro extremo
	draw_sprite_ext(sprite_index, image_index, _sx, _sy, speaker_side[page] * portrait_scale, portrait_scale, 0, c_white, 1);
}

//back of the textbox
draw_sprite_ext(txtb_spr[page], txtb_img, _txtb_x, _txtb_y, txtb_w[page]/txtb_spr_w, textbox_height/txtb_spr_h, 0, c_white, 1)

//name tag (usa la caja del personaje, centrada sobre el retrato)
if (speaker_sprite[page] != noone && speaker_name[page] != "") {
	draw_set_font(fnt_main_small);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	
	var _tag_w = string_width(speaker_name[page]) + tag_pad_x*2;
	var _tag_h = string_height(speaker_name[page]) + tag_pad_y*2;
	var _port_x = textbox_x + portrait_x_offset[page];
	var _port_y = textbox_y + textbox_height - portrait_box_h;
	var _tag_x = floor(_port_x + (portrait_box_w - _tag_w) / 2);
	var _tag_y = _port_y - _tag_h + tag_overlap;
	
	draw_sprite_ext(txtb_spr[page], txtb_img, _tag_x, _tag_y, _tag_w/txtb_spr_w, _tag_h/txtb_spr_h, 0, c_white, 1);
	draw_text(_tag_x + tag_pad_x, _tag_y + tag_pad_y, speaker_name[page]);
	
	// Devolver la fuente normal: lo que se dibuja después (opciones y texto) usa global.font_main
	draw_set_font(global.font_main);
}

//continue arrow (solo cuando faltan páginas por decir)
if (draw_char == text_length[page] && page < page_number - 1) {
	var _d_spr = spr_textbox_arrow_down;
	var _d_frame = floor(current_time / 1000 * arrow_down_fps) mod sprite_get_number(_d_spr);
	var _arrow_right = (speaker_side[page] != -1); // con el retrato a la derecha, la flecha va a la izquierda
	var _d_x = _arrow_right ? (_txtb_x + txtb_w[page] - arrow_margin - sprite_get_width(_d_spr)) : (_txtb_x + arrow_margin);
	var _d_y = _txtb_y + textbox_height - arrow_margin - sprite_get_height(_d_spr);
	draw_sprite(_d_spr, _d_frame, floor(_d_x + sprite_get_xoffset(_d_spr)), floor(_d_y + sprite_get_yoffset(_d_spr)));
}


//------------------------options------------------------//
if (draw_char == text_length[page] && page == page_number - 1) {
	
	//option selection
	var _old_option_pos = option_pos;
	var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
	var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
	option_pos += _down - _up;
	option_pos = clamp(option_pos, 0, option_number-1);
	if (option_pos != _old_option_pos) {
		audio_stop_sound(snd_voice_protagonista);
		audio_play_sound(snd_voice_protagonista, 8, false); // siempre suena el protagonista
	}
	
	var _pad_x = 4;    // espacio a los costados del texto
	var _pad_y = 3;    // espacio arriba y abajo del texto
	var _op_gap = 1;   // separación entre una caja de opción y la siguiente
	var _text_dy = 0;  // sube (negativo) o baja (positivo) el texto dentro de la caja
	
	var _op_h = string_height("A") + _pad_y*2;
	var _op_space = _op_h + _op_gap;
	
	for (var op = 0; op < option_number; op++){
		var _o_y = _txtb_y - _op_space*option_number + _op_space*op - 2;
		var _o_w = string_width(option[op]) + _pad_x*2;
		
		//alineadas a la derecha o a la izquierda
		var _o_x = options_right ? (_txtb_x + txtb_w[page] - _o_w) : (_txtb_x + sprite_get_width(spr_textbox_arrow) + arrow_gap);
		
		//the option box
		draw_sprite_ext(txtb_spr[page], txtb_img, _o_x, _o_y, _o_w / txtb_spr_w, _op_h/txtb_spr_h, 0, c_white, 1)
		
		//the arrow (animada), a la izquierda de la opción seleccionada
		if (option_pos == op){
			var _a_spr = spr_textbox_arrow;
			var _a_frame = floor(current_time / 1000 * arrow_fps) mod sprite_get_number(_a_spr);
			var _a_x = _o_x - sprite_get_width(_a_spr) - arrow_gap + sprite_get_xoffset(_a_spr);
			var _a_y = _o_y + (_op_h - sprite_get_height(_a_spr)) / 2 + sprite_get_yoffset(_a_spr);
			draw_sprite(_a_spr, _a_frame, floor(_a_x), floor(_a_y));
		}
		
		//the option text
		draw_text(_o_x + _pad_x, _o_y + _pad_y + _text_dy, option[op]);
	}
}

//draw the text
for(var c = 0 ; c < draw_char ; c++){
	
	//----special stuff----//
	//floating text
	var _float_y = 0;
	if (float_text[c, page] == true){
	
		float_dir[c, page] += -6;
		_float_y = dsin(float_dir[c, page]) * 1;
	}
	
	//shake text
	var _shake_x = 0;
	var _shake_y = 0;
	if(shake_text[c, page] == true){
		
		shake_timer[c, page]--;
		if (shake_timer[c, page] <= 0){
		
			shake_timer[c, page] = irandom_range(4,8);
			shake_dir[c, page] = irandom (360);
		}
		if (shake_timer[c, page] <= 2){
		
			_shake_x = lengthdir_x(1, shake_dir[c, page]);
			_shake_y = lengthdir_y(1, shake_dir[c, page]);
		}
	}
	
	//the text
	draw_text_colour(textbox_x + char_x[c,page] + _shake_x, textbox_y + char_y[c,page] + _float_y + _shake_y, char[c,page], col_1[c,page], col_2[c,page], col_3[c,page], col_4[c,page], 1);
}