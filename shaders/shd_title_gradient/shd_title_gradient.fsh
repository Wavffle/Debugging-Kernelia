varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying float v_y;

uniform float u_offset;  // cuánto se ha desplazado el degradado
uniform float u_period;  // alto de un ciclo completo
uniform float u_steps;   // niveles de color (0 = suave)
uniform vec3 u_col_a;    // color 1 (blanco)
uniform vec3 u_col_b;    // color 2 (celeste)

void main()
{
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);

    float p = (v_y - u_offset) / u_period;
    float w = abs(fract(p) * 2.0 - 1.0);   // onda triangular entre 0 y 1
    w = w * w * (3.0 - 2.0 * w);            // la suaviza

    if (u_steps > 1.5) {
        w = min(floor(w * u_steps), u_steps - 1.0) / (u_steps - 1.0);
    }

    gl_FragColor = vec4(mix(u_col_a, u_col_b, w), tex.a * v_vColour.a);
}