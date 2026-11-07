// @param text_id

function scr_game_text(_text_id){
	switch(_text_id){
		
		case "npc 1":
			scr_text("Hola, soy el npc 1")
			scr_text("Texto de prueba")
			scr_text("Estás bien?")
				scr_option("Si, estoy bastante bien","npc 1 - si")
				scr_option("Nah","npc 1 - no")
			break;
			case "npc 1 - si":
				scr_text("Genial!");
				break
			case "npc 1 - no":
				scr_text(":(");
				break
			
		case "npc 2":
			scr_text("Hola, soy el npc 2")
			scr_text("Texto de prueba")
			break;
			
		case "npc 3":
			scr_text("Hola, soy el npc 3")
			scr_text("Texto de prueba")
			break;
	}
}