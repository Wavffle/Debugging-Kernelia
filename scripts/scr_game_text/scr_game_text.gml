// @param text_id

function scr_game_text(_text_id){
	switch(_text_id){
		
		//--------------------------Conversación con opciones--------------------------
		case "protagonista":
		    scr_text("Hola, soy el protagonista de la historia", "protagonista");
				scr_text_float(13, 40)
		    scr_text("Así que hay problemas en Memorian... Será mejor investigar", "protagonista");
				scr_text_color(25, 32, c_purple, c_purple, c_purple, c_purple);	
		    scr_text("Seguro podremos encontrar una solución. Qué me dices, me ayudas?", "protagonista");
		        scr_option("Si, vamos a investigar","protagonista - si");
		        scr_option("Nah, estoy bien","protagonista - no");
		    break;
		    case "protagonista - si":
		        scr_text("Genial! empecemos hablando con los habitantes", "protagonista");
		        break;
		    case "protagonista - no":
		        scr_text("Entiendo, investigaré solo", "protagonista");
		        break;
		
		//--------------------------Conversación con emociones--------------------------
		case "npc 2":
			scr_text("Hola, como estás Gepe-T?", "protagonista")
			scr_text("Bien! estoy preparado para una aventura!", "gepet", -1)
			scr_text("A donde crees que deberiamos ir primero?", "protagonista-curioso")
			scr_text("He escuchado que hay problemas en el reino de Memorian... Quizas deberiamos ir a investigar", "gepet", -1)
				scr_text_shake(37, 54)
			break;
			
		case "npc 3":
			scr_text("Hola, soy el npc 3")
			scr_text("Texto de prueba")
			break;
	}
}