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
				//--------------------------Cloude: RAM vs almacenamiento--------------------------
		case "cloude_ram_vs_disco":
			scr_text("Oh, eres tú. Justo a tiempo para presenciar mi genialidad.", "cloude", -1)
				scr_text_float(47, 56)
			scr_text("¿Genialidad?", "protagonista-curioso")
			scr_text("Voy a Memorian, así que estudié cómo funciona su memoria.", "cloude", -1)
			scr_text("El almacenamiento es un archivador: guarda todo, pero es lento.", "cloude", -1)
				scr_text_color(24, 33, c_orange, c_orange, c_orange, c_orange)
			scr_text("La RAM es un escritorio: poco espacio, pero lo que usas ahora queda a mano.", "cloude", -1)
				scr_text_color(13, 22, c_aqua, c_aqua, c_aqua, c_aqua)
			scr_text("¿Y si se apaga el computador?", "protagonista-curioso")
			scr_text("Buena pregunta. Veamos si adivinas qué pasa con lo que había en la RAM.", "cloude", -1)
				scr_option("Se borra todo", "cloude_apagar_borra");
				scr_option("Queda guardado", "cloude_apagar_guarda");
				scr_option("No lo sé", "cloude_apagar_nose");
			break;

			case "cloude_apagar_borra":
				scr_text("¡Correcto! Sin energía, la RAM se vacía por completo.", "cloude", -1)
					scr_text_float(0, 9)
				scr_text("Por eso hay que guardar: pasar lo importante del escritorio al archivador.", "cloude", -1)
				scr_game_text("cloude_ram_llena");
				break;

			case "cloude_apagar_guarda":
				scr_text("Jaja, no. Eso lo hace el almacenamiento, no la RAM.", "cloude", -1)
				scr_text("La RAM es temporal: sin energía se vacía. Por eso se guarda lo importante.", "cloude", -1)
				scr_game_text("cloude_ram_llena");
				break;

			case "cloude_apagar_nose":
				scr_text("Tranquilo, para eso me tienes a mí.", "cloude", -1)
				scr_text("Se borra todo: la RAM es temporal y sin energía se vacía.", "cloude", -1)
				scr_text("Por eso se guarda lo importante: del escritorio al archivador.", "cloude", -1)
				scr_game_text("cloude_ram_llena");
				break;

			case "cloude_ram_llena":
				scr_text("Segunda pregunta. Imagina que la RAM está completamente llena.", "cloude", -1)
				scr_text("Llega un proceso nuevo, un programa que quiere ejecutarse. ¿Qué pasa?", "cloude", -1)
					scr_option("Espera a que haya espacio", "cloude_llena_espera");
					scr_option("Se instala igual", "cloude_llena_igual");
				break;

			case "cloude_llena_espera":
				scr_text("Exacto. Sin espacio libre, el proceso espera su turno.", "cloude", -1)
				scr_game_text("cloude_cierre");
				break;

			case "cloude_llena_igual":
				scr_text("Ja. La RAM no hace magia: si no hay espacio, no cabe.", "cloude", -1)
				scr_text("El proceso espera hasta que otro termine y libere su lugar.", "cloude", -1)
				scr_game_text("cloude_cierre");
				break;

			case "cloude_cierre":
				scr_text("¿Y si hay espacio libre, pero repartido en pedacitos sueltos?", "protagonista-curioso")
				scr_text("...", "cloude", -1)
				scr_text("Eso lo verás en Memorian. Obviamente, yo ya lo sé.", "cloude", -1)
					scr_text_shake(26, 35)
				break;
		//--------------------------Conversación con NPC random--------------------------
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
			break;
			
		//--------------------------Habitante de Memorian: la RAM como hotel--------------------------
		case "memoriano_ram_hotel":
			scr_text("¡Bienvenido a Memorian! Aquí la RAM funciona como un gran hotel.", "memoriano")
			scr_text("¿Un hotel?", "protagonista-curioso")
			scr_text("Cada habitación tiene un número: su dirección de memoria.", "memoriano")
			scr_text("Y los huéspedes son los datos que el procesador necesita ahora.", "memoriano")
			scr_text("El ascensor llega a cualquier habitación sin pasar por las otras.", "memoriano")
			scr_text("Eso es el acceso aleatorio: llegar a cualquier dato tarda lo mismo.", "memoriano")
				scr_text_color(10, 25, c_aqua, c_aqua, c_aqua, c_aqua)
			scr_text("RAM significa Random Access Memory, memoria de acceso aleatorio.", "memoriano")
			scr_text("¿Y si no hubiera ascensor?", "protagonista-curioso")
			scr_text("Sería como una cinta: para oír la canción 9, pasas las 8 primeras.", "memoriano")
			scr_text("Eso es acceso secuencial, y es mucho más lento.", "memoriano")
			scr_text("¿Y cómo recuerda tantos datos a la vez?", "protagonista-curioso")
			scr_text("Cada dato vive en un cubito con una gotera, y se va vaciando.", "memoriano")
				scr_text_shake(36, 41)
			scr_text("Si nadie lo rellena a tiempo, el dato desaparece.", "memoriano")
			scr_text("Por eso se refresca muchas veces por segundo: es la DRAM.", "memoriano")
			scr_text("Ahora, una pregunta de recepción. Hora punta en la cocina del hotel.", "memoriano")
			scr_text("El chef usa sus manos, una mesa y una bodega, según lo que necesite.", "memoriano")
			scr_text("Las manos son la caché, la mesa es la RAM y la bodega es el disco.", "memoriano")
				scr_text_color(38, 40, c_aqua, c_aqua, c_aqua, c_aqua)
			scr_text("Cuanto más cerca de las manos, más rápido, pero cabe menos.", "memoriano")
			scr_text("La mesa se llenó y el chef necesita más espacio. ¿Qué hace?", "memoriano")
				scr_option("Usa la bodega de apoyo", "memoriano_mesa_bodega");
				scr_option("Cocina más rápido", "memoriano_mesa_rapido");
				scr_option("Deja de cocinar", "memoriano_mesa_parar");
			break;

			case "memoriano_mesa_bodega":
				scr_text("¡Muy bien! Eso es justo lo que hace un computador.", "memoriano")
				scr_game_text("memoriano_cierre");
				break;

			case "memoriano_mesa_rapido":
				scr_text("Ojalá. Pero las manos no crecen: si no cabe, hay que ir a la bodega.", "memoriano")
				scr_game_text("memoriano_cierre");
				break;

			case "memoriano_mesa_parar":
				scr_text("Podría, pero sería un desastre en hora punta. Mejor usa la bodega.", "memoriano")
				scr_game_text("memoriano_cierre");
				break;

			case "memoriano_cierre":
				scr_text("Eso se llama memoria virtual: el disco hace de mesa extra.", "memoriano")
				scr_text("Funciona, pero la bodega es muchísimo más lenta que la mesa.", "memoriano")
				scr_text("Por eso, más RAM no te hace más veloz: evita viajes a la bodega.", "memoriano")
					scr_text_color(39, 62, c_orange, c_orange, c_orange, c_orange)
				scr_text("Entonces, la RAM es donde ocurre todo lo que se está usando.", "protagonista")
				scr_text("¡Exacto! Ya podrías atender la recepción de Memorian.", "memoriano")
					scr_text_float(0, 7)
				break;
	}
}