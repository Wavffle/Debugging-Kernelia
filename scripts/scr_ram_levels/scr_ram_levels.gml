#macro RAM_LEVELS 8
#macro RAM_CELLS 10

/// @param level_index
function scr_ram_level(_n) {
    switch (_n) {
        case 0: return {
            name: "Llegan los procesos",
            pre: [[3, 1, 1]],
            queue: [1, 2, 2, 3],
            leave: [],
            comp: 0,
            hint: "Mueve el cursor con A/D y coloca el primer proceso con Z. La celda gris es del sistema: no se puede usar.",
            win: "¡Todo cargado! La RAM se llenó. La memoria es limitada: los procesos nuevos deben esperar a que haya espacio libre.",
            learn: "Memoria libre y ocupada"
        };
        case 1: return {
            name: "Cada proceso, su tamaño",
            pre: [[8, 2, 1], [3, 1, 0], [5, 1, 0]],
            queue: [3, 2, 1],
            leave: [],
            comp: 0,
            hint: "El proceso ocupa las celdas que cubre el cursor. Verde: cabe. Rojo: no cabe. Aquí no sobra nada.",
            win: "Un proceso necesita memoria contigua: no basta con que existan espacios libres, tienen que estar juntos.",
            learn: "Memoria contigua"
        };
        case 2: return {
            name: "Procesos que terminan",
            pre: [[3, 1, 0], [5, 1, 0], [6, 1, 0], [8, 1, 0], [9, 1, 0]],
            queue: [1, 2, 2],
            leave: [{ after: 2, ids: [0, 1] }],
            comp: 0,
            hint: "Algunos procesos terminarán pronto y liberarán su espacio. Piensa qué huecos van a quedar.",
            win: "Cuando los procesos terminan, dejan huecos sueltos. La memoria libre queda dividida en pedazos: eso es fragmentación.",
            learn: "Fragmentación"
        };
        case 3: return {
            name: "Hay espacio, pero no cabe",
            pre: [[2, 1, 0], [7, 1, 0], [6, 1, 0], [5, 1, 0]],
            queue: [1, 3, 2],
            leave: [],
            comp: 1,
            hint: "Coloca el primer proceso y mira si el siguiente, de tamaño 3, cabe en algún lado.",
            win: "Compactar mueve los procesos para juntar toda la memoria libre en un solo bloque. Así el proceso grande por fin cabe.",
            learn: "Compactación"
        };
        case 4: return {
            name: "Memoria reservada",
            pre: [[5, 1, 1], [7, 1, 0], [2, 1, 0], [3, 1, 0]],
            queue: [1, 2, 3],
            leave: [],
            comp: 1,
            hint: "El sistema reservó una celda en medio. Compacta (C) y observa que esa celda no se mueve.",
            win: "La memoria reservada del sistema no se mueve al compactar. Divide la memoria en zonas, y el espacio libre solo se junta dentro de cada zona.",
            learn: "Memoria reservada"
        };
        case 5: return {
            name: "Zonas y decisiones",
            pre: [[3, 1, 1], [7, 1, 1], [1, 1, 0], [5, 1, 0], [9, 1, 0]],
            queue: [1, 2, 2],
            leave: [],
            comp: 1,
            hint: "Hay tres zonas y una sola compactación. Piensa en qué zona conviene colocar el proceso de tamaño 1.",
            win: "Planificar es decidir dónde va cada proceso antes de compactar, porque las zonas reservadas limitan lo que se puede reorganizar.",
            learn: "Planificación"
        };
        case 6: return {
            name: "Otra vez fragmentado",
            pre: [[7, 2, 1], [3, 1, 0], [5, 1, 0], [0, 1, 0], [1, 1, 0]],
            queue: [1, 2, 2, 1],
            leave: [{ after: 2, ids: [1, 3] }],
            comp: 2,
            hint: "Tienes dos compactaciones y las dos hacen falta. Cuando un proceso termina, el espacio vuelve a quedar roto.",
            win: "Cada vez que terminan procesos, la memoria puede fragmentarse de nuevo. Compactar se hace cuando hace falta, no una sola vez.",
            learn: "Fragmentación repetida"
        };
        case 7: return {
            name: "Desafío final",
            pre: [[2, 1, 1], [6, 1, 1], [4, 1, 0], [3, 1, 0], [5, 1, 0], [1, 1, 0], [8, 1, 0]],
            queue: [1, 2, 2],
            leave: [{ after: 2, ids: [3, 4] }],
            comp: 2,
            hint: "Dos celdas reservadas y dos compactaciones. Decide cuándo compactar y cuándo esperar.",
            win: "¡Lo lograste! Asignar, fragmentar, compactar y planificar: así administra la memoria un sistema operativo.",
            learn: "Asignación, fragmentación, compactación y planificación"
        };
    }
}