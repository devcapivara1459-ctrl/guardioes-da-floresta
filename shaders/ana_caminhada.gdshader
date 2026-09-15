shader_type canvas_item;
render_mode unshaded;

uniform vec4 quadro = vec4(0.0, 0.0, 1.0, 1.0);
uniform float fase = 0.0;
uniform float intensidade = 0.0;
uniform float lado = 1.0;
uniform bool perfil = true;
varying vec4 tint;

void vertex() { tint = COLOR; }

void fragment() {
	vec2 p = (UV - quadro.xy) / quadro.zw;
	float passo = sin(fase) * intensidade;
	float perna = clamp((p.y - 0.66) / 0.34, 0.0, 1.0);
	// Displace the knee between fixed hip and ankle: legs bend rather than rotate rigidly.
	float joelho = sin(perna * 3.14159265);
	float metade = smoothstep(0.44, 0.56, p.x);
	float membro = mix(-1.0, 1.0, metade);
	float flexao = perfil ? lado * abs(passo) : membro * passo;
	p.x -= joelho * 0.075 * flexao;
	// The swinging foot clears the ground; the supporting foot stays planted.
	float suspensa = max(0.0, membro * passo);
	p.y += smoothstep(0.78, 0.96, p.y) * suspensa * 0.040;
	// Local elbow bend and delayed hair motion, keeping the face stable.
	float braco = smoothstep(0.40, 0.48, p.y) * (1.0 - smoothstep(0.61, 0.68, p.y));
	float borda = smoothstep(0.10, 0.27, abs(p.x - 0.5));
	p.x += braco * borda * passo * 0.030;
	float cabelo = smoothstep(0.18, 0.28, p.y) * (1.0 - smoothstep(0.48, 0.58, p.y));
	p.x += cabelo * borda * sin(fase - 0.6) * intensidade * 0.009;
	float dentro = step(0.0,p.x)*step(p.x,1.0)*step(0.0,p.y)*step(p.y,1.0);
	COLOR = texture(TEXTURE, quadro.xy + clamp(p,vec2(0.0),vec2(1.0)) * quadro.zw) * tint;
	COLOR.a *= dentro;
}
