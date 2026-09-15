shader_type canvas_item;
render_mode unshaded;
// The supplied sheet contains a baked gray checkerboard. Hide neutral background
// pixels at render time, keeping the source file unchanged and the colored roots.
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float saturation = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
	if (saturation < 0.10 && c.r > 0.36) { c.a = 0.0; }
	COLOR = c;
}
