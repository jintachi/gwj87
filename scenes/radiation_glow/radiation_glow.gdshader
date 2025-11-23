shader_type canvas_item;

uniform float subdivisions = 32.0;
uniform sampler2D noise : repeat_enable;

void fragment() {
	
	vec2 pixel_uv = vec2(round(UV.x * subdivisions) / subdivisions, round(UV.y * subdivisions) / subdivisions);
	COLOR = texture(TEXTURE, pixel_uv);	// Called for every pixel the material is visible on.
	COLOR.a *= texture(noise, vec2(TIME, 0.5)).r;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
