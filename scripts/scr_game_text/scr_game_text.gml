// @param text_id

function scr_game_text(_text_id){
	switch(_text_id){
		
		//--------------------------Conversación con el Rey--------------------------
		case "conversacion_con_rey":
		    scr_text("Hola papá", "protagonista");
		    scr_text("ahhh, protagonista", "rey", -1);
		    scr_text("Hace tiempo no venias por estos lados, ¿que te trae por aquí?", "rey", -1);
			scr_text("Te queria decir que ya derroté al villano y salvé Kernelia", "protagonista");
				scr_text_color(20, 59, c_fuchsia, c_fuchsia, c_fuchsia, c_fuchsia);
			scr_text("Como?????!!!", "rey-sorprendido", -1);
				scr_text_shake(0,12);
			scr_text("Es broma! Jeje", "protagonista");
				scr_text_float(0, 14);
			break;
		
		//--------------------------Conversación con Gepe-T--------------------------
		case "conversacion_con_gepet":
			scr_text("Hola, como estás Gepe-T?", "protagonista")
			scr_text("Bien! estoy preparado para una aventura!", "gepet", -1)
			scr_text("A donde crees que deberiamos ir primero?", "protagonista-curioso")
			scr_text("He escuchado que hay problemas en el reino de Memorian... Quizas deberiamos ir a investigar", "gepet", -1)
				scr_text_shake(37, 53)
			scr_text("Está bien, a Memorian vamos! Sigueme!", "protagonista")
			scr_text("Estaré detrás de tí!", "gepet", -1)
			break;
		
		//--------------------------Conversación con Cloude--------------------------
		case "conversacion_con_cloude":
			scr_text("Hola, soy Cloude", "cloude", -1)
			scr_text("Memorian, huh?", "cloude", -1)
			scr_text("Hace tiempo no venia por aquí. No parece nada que no pueda resolver con un poco de prueba y error", "cloude", -1)
			scr_text("Que me dices? Me acompañas en mi aventura?", "cloude", -1);
		        scr_option("Claro!","cloude_si");
		        scr_option("No busco una aventura ahora mismo","cloude_no");
		    break;
		    case "cloude_si":
		        scr_text("Entonces no perdamos más el tiempo y vamos a la aventura!", "cloude", -1);
				scr_text("...", "protagonista-cansado")
		        break;
		    case "cloude_no":
		        scr_text("Eso pensaba, no tienes la cara de un aventurero de verdad.", "cloude", -1);
				scr_text_float(0,13)
		        break;
		//--------------------------Conversación con un NPC random--------------------------
		case "conversacion_con_npc1":
			scr_text("Hola, soy un npc sin nombre ni ilustracion", "npc-1")
			scr_text("Es un gusto conocerte", "protagonista")
			break;
		case "conversacion_con_npc2":
			scr_text("Hola, soy otro npc sin nombre ni ilustracion", "npc-2")
			scr_text("Es un gusto conocerte", "protagonista")
			break;
		case "conversacion_con_npc3":
			scr_text("Aunque no lo creas, soy un npc sin nombre ni ilustracion", "npc-3")
			scr_text("Es un gusto conocerte", "protagonista")
			break;
		case "conversacion_npc_b":
			scr_text("Hey, me pillaste hablando con mi amigo...", "npc-1")
			scr_text("Si... el es mudo", "npc-1")
			scr_text("?", "protagonista-curioso")
	}
}