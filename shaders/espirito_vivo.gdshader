shader_type canvas_item;
render_mode unshaded;

uniform float tempo = 0.0;
varying vec4 tint;
void vertex() { tint = COLOR; }

void fragment() {
	// Eight poses per second preserve the stepped rhythm of pixel animation.
	float t = floor(tempo * 8.0) / 8.0;
	vec2 uv = UV;
	float torso = smoothstep(0.22, 0.40, uv.y) * (1.0 - smoothstep(0.65, 0.85, uv.y));
	float tail = smoothstep(0.55, 0.98, uv.y);
	float fringe = smoothstep(0.10, 0.35, abs(uv.x - 0.5));
	// Face stays steady; breathing, outer leaves and light tail move independently.
	uv.x = 0.5 + (uv.x - 0.5) / (1.0 + sin(t * 1.8) * 0.035 * torso);
	uv.x += sin(t * 2.2 + uv.y * 8.0) * 0.027 * tail;
	uv.x += sin(t * 1.5 + uv.y * 17.0) * 0.010 * fringe * smoothstep(0.2, 0.4, uv.y);
	uv.y += sin(t * 1.8) * 0.004 * torso;
	vec4 tex = texture(TEXTURE, uv);
	float inside = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
	float light = smoothstep(0.60, 0.95, tex.g) * (1.0 - smoothstep(0.65, 0.90, tex.b));
	tex.rgb *= 1.0 + light * (0.06 * sin(t * 1.7) - 0.06);
	COLOR = tint * vec4(tex.rgb, tex.a * inside);
}
