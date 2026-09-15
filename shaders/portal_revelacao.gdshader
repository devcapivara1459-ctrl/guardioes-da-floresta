shader_type canvas_item;
uniform float revelar : hint_range(0.0, 1.0) = 0.0;
float ruido(vec2 p) {
 return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void fragment() {
 vec4 arte = texture(TEXTURE, UV);
 vec2 pixel = floor(UV * vec2(74.0, 75.0));
 float limite = (1.0 - UV.y) * 0.68 + ruido(pixel) * 0.24;
 float fase = revelar * 1.18 - 0.12;
 float visivel = smoothstep(limite - 0.10, limite + 0.10, fase);
 float borda = (1.0 - smoothstep(0.0, 0.12, abs(fase - limite))) * sin(revelar * 3.14159265);
 arte.rgb = mix(arte.rgb, vec3(0.82, 0.96, 0.48), borda * 0.55);
 COLOR = vec4(arte.rgb, arte.a * visivel);
}
