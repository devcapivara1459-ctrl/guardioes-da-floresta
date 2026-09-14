shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float sat = max(c.r,max(c.g,c.b))-min(c.r,min(c.g,c.b));
	if (sat < 0.13 && min(c.r,min(c.g,c.b)) > 0.48) { c.a = 0.0; }
	COLOR = c * tint;
}
