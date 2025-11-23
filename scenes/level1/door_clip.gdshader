shader_type canvas_item;

uniform float clip_amount = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV + vec2(clip_amount, 0.0));
}