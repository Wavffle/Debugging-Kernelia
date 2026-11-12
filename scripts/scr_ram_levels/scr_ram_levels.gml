#macro RAM_LEVELS 8

/// @param level_index
function scr_ram_level(_n) {
    switch (_n) {
        case 0: return {
            name: "Llegan los procesos",
            pre: [[1, 1, 1]],               // [espacio inicial, tamaño, reservado por el sistema (1) o no (0)]
            queue: [1, 1, 2, 3],
            leave: [],                      // {after: nº de colocados, ids: [...]}
            comp: 0,                        // compactaciones permitidas
            hint: "Mueve el cursor con A/D y coloca el primer proceso con Z. Las celdas grises son del sistema: no se pueden usar.",
            win: "¡Todo cargado! La RAM se llenó. La memoria es limitada: los procesos nuevos deben esperar a que haya espacio libre.",
            learn: "Memoria libre y ocupada"
        };
        case 1: return {
            name: "Cada proceso, su tamaño",
            pre: [[0, 2, 1], [3, 1, 0]],
            queue: [1, 1, 3],
            leave: [],
            comp: 0,
            hint: "El proceso ocupa las celdas que cubre el cursor. Verde: cabe. Rojo: no cabe. Aquí no sobra nada.",
            win: "Un proceso necesita memoria contigua: no basta con que existan espacios libres, tienen que estar juntos.",
            learn: "Memoria contigua"
        };
        case 2: return {
            name: "Procesos que terminan",
            pre: [[5, 1, 1], [0, 1, 0], [6, 1, 0], [4, 1, 0]],
            queue: [1, 1, 2, 2],
            leave: [{ after: 2, ids: [2, 3] }],
            comp: 0,
            hint: "Algunos procesos terminarán pronto y liberarán su espacio. Piensa qué huecos van a quedar.",
            win: "Cuando los procesos terminan, dejan huecos sueltos. La memoria libre queda dividida en pedazos: eso es fragmentación.",
            learn: "Fragmentación"
        };
        case 3: return {
            name: "Hay espacio, pero no cabe",
            pre: [[1, 1, 0], [3, 1, 0], [5, 1, 0]],
            queue: [1, 3, 1],
            leave: [],
            comp: 1,
            hint: "Coloca el primer proceso y mira si el siguiente, de tamaño 3, cabe en algún lado.",
            win: "Compactar mueve los procesos para juntar toda la memoria libre en un solo bloque. Así el proceso grande por fin cabe.",
            learn: "Compactación"
        };
        case 4: return {
            name: "Memoria reservada",
            pre: [[3, 1, 1], [2, 1, 0], [6, 1, 0]],
            queue: [1, 3, 1],
            leave: [],
            comp: 1,
            hint: "El sistema reservó una celda en medio. Compacta (C) y observa que esa celda no se mueve.",
            win: "La memoria reservada del sistema no se mueve al compactar. Divide la memoria en zonas, y el espacio libre solo se junta dentro de cada zona.",
            learn: "Memoria reservada"
        };
        case 5: return {
            name: "Zonas y decisiones",
            pre: [[6, 1, 1], [3, 1, 1], [5, 1, 0], [1, 1, 0]],
            queue: [1, 2, 1],
            leave: [],
            comp: 1,
            hint: "Hay tres zonas y una sola compactación. Piensa en qué zona cabrá el proceso de tamaño 2.",
            win: "Planificar es decidir dónde va cada proceso antes de compactar, porque las zonas reservadas limitan lo que se puede reorganizar.",
            learn: "Planificación"
        };
        case 6: return {
            name: "Otra vez fragmentado",
            pre: [[1, 2, 1], [4, 1, 0], [6, 1, 0]],
            queue: [1, 2, 2],
            leave: [{ after: 2, ids: [1] }],
            comp: 2,
            hint: "Tienes dos compactaciones. Cuando un proceso termina, el espacio vuelve a quedar roto.",
            win: "Cada vez que terminan procesos, la memoria puede fragmentarse de nuevo. Compactar se hace cuando hace falta, no una sola vez.",
            learn: "Fragmentación repetida"
        };
        case 7: return {
            name: "Desafío final",
            pre: [[0, 1, 1], [6, 1, 1], [5, 1, 0], [2, 1, 0], [4, 1, 0]],
            queue: [1, 2, 2],
            leave: [{ after: 2, ids: [2, 3] }],
            comp: 2,
            hint: "Dos zonas reservadas y dos compactaciones. Decide cuándo compactar y cuándo esperar.",
            win: "¡Lo lograste! Asignar, fragmentar, compactar y planificar: así administra la memoria un sistema operativo.",
            learn: "Asignación, fragmentación, compactación y planificación"
        };
    }
}