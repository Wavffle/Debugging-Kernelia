function scr_set_defaults_for_text(){
	line_break_pos[0, page_number] = 999;
	line_break_num[page_number] = 0;
	line_break_offset[page_number] = 0;
	
	//variables for every letter/character
	for (var c = 0 ; c < 500 ; c++){
		
		col_1[c, page_number] = c_white;
		col_2[c, page_number] = c_white;
		col_3[c, page_number] = c_white;
		col_4[c, page_number] = c_white;
		
		float_text[c, page_number] = 0;
		float_dir[c, page_number] = c*20;
		
		shake_text[c, page_number] = 0;
		shake_dir[c, page_number] = irandom(360);
		shake_timer[c, page_number] = irandom(4);
	}
	
	txtb_spr[page_number] = spr_dialogue_box_protagonista;
	speaker_sprite[page_number] = noone;
	speaker_side[page_number] = noone;
	speaker_name[page_number] = "";
	
	snd[page_number] = snd_voice_protagonista;
}

//-----------------------text VFX-----------------------//
/// @param 1st_char
/// @param last_char
/// @param col1
/// @param col2
/// @param col3
/// @param col4
function scr_text_color(_start, _end, _col1, _col2, _col3, _col4){
	
	for (var c = _start ; c <= _end ; c++) {
	
		col_1[c, page_number-1] = _col1;
		col_2[c, page_number-1] = _col2;
		col_3[c, page_number-1] = _col3;
		col_4[c, page_number-1] = _col4;
		
	}
}

/// @param 1st_char
/// @param last_char
function scr_text_float(_start, _end){

	for (var c = _start ; c <= _end ; c++) {
	
		float_text[c, page_number-1] = true;
	}
}

/// @param 1st char
/// @param last char
function scr_text_shake(_start, _end){

	for (var c = _start ; c <= _end ; c++){
	
		shake_text[c, page_number-1] = true;
	}
}

/// @param character_id
function scr_character_name(_id){
	switch(_id){
		case "protagonista": return "Protagonista"; // más adelante: el nombre elegido + "-IA"
		case "gepet": return "Gepe-T";
		case "cloude": return "Cloude";
		case "rey": return "Rey de Tutorealis";

	}
	return "";
}

/// @param text
/// @param [character]
/// @param [side]
function scr_text(_text){
	
	scr_set_defaults_for_text();
	
	text[page_number] = _text;
	
	// get character info
	if (argument_count > 1) {
		
		// el nombre depende solo del personaje
		var _char_id = argument[1];
		var _dash = string_pos("-", _char_id);
		if (_dash > 0) { _char_id = string_copy(_char_id, 1, _dash - 1); }
		speaker_name[page_number] = scr_character_name(_char_id);
		
		speaker_side[page_number] = 1; // por defecto, el personaje va a la izquierda
		
		switch(argument[1]){
			
			//protagonista
			case "protagonista":
				speaker_sprite[page_number] = spr_portrait_protagonista_normal;
				txtb_spr[page_number] = spr_dialogue_box_protagonista;
				snd[page_number] = snd_voice_protagonista;
				break;
				
			case "protagonista-curioso":
				speaker_sprite[page_number] = spr_portrait_protagonista_curioso;
				txtb_spr[page_number] = spr_dialogue_box_protagonista;
				snd[page_number] = snd_voice_protagonista;
				break;
			case "protagonista-cansado":
				speaker_sprite[page_number] = spr_portrait_protagonista_cansado;
				txtb_spr[page_number] = spr_dialogue_box_protagonista;
				snd[page_number] = snd_voice_protagonista;
				break;
				
			//gepet
			case "gepet":
				speaker_sprite[page_number] = spr_portrait_gepet;
				txtb_spr[page_number] = spr_dialogue_box_gepet;
				snd[page_number] = snd_voice_gepet;
				break;
				
			//cloude
			case "cloude":
			    speaker_sprite[page_number] = spr_portrait_cloude;
			    txtb_spr[page_number] = spr_dialogue_box_cloude;
			    snd[page_number] = snd_voice_cloude;
			    break;
				
			//rey de tutorealis
			case "rey":
			    speaker_sprite[page_number] = spr_portrait_rey;
			    txtb_spr[page_number] = spr_dialogue_box_protagonista;
			    snd[page_number] = snd_voice_rey;
			    break;
			case "rey-sorprendido":
			    speaker_sprite[page_number] = spr_portrait_rey_sorprendido;
			    txtb_spr[page_number] = spr_dialogue_box_protagonista;
			    snd[page_number] = snd_voice_rey;
			    break;
				
			//npc de tutorealis
			case "npc-1":
			    txtb_spr[page_number] = spr_dialogue_box_protagonista;
			    snd[page_number] = snd_voice_npc_tutorealis;
			    break;
			case "npc-2":
			    txtb_spr[page_number] = spr_dialogue_box_protagonista;
			    snd[page_number] = snd_voice_npc_tutorealis;
			    break;
			case "npc-3":
			    txtb_spr[page_number] = spr_dialogue_box_protagonista;
			    snd[page_number] = snd_voice_npc_tutorealis;
			    break;
		}
	}
	
	// Si el personaje no tiene retrato, la caja va centrada
	if (speaker_sprite[page_number] == noone) {
	    speaker_side[page_number] = noone;
	}
	
	//side the character is on
	if (argument_count > 2) {
		speaker_side[page_number] = argument[2];
	}
	
	page_number++;
}

/// @param option
/// @param link_id
function scr_option(_option, _link_id) {
	option[option_number] = _option;
	option_link_id[option_number] = _link_id;
	
	option_number++;
}

/// @param text_id
function create_textbox(_text_id){
	
	with (instance_create_depth(0, 0, -9999, obj_textbox)){
		scr_game_text(_text_id);
	}
}